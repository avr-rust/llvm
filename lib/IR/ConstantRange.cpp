//===-- ConstantRange.cpp - ConstantRange implementation ------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Represent a range of possible values that may occur when the program is run
// for an integral value.  This keeps track of a lower and upper bound for the
// constant, which MAY wrap around the end of the numeric range.  To do this, it
// keeps track of a [lower, upper) bound, which specifies an interval just like
// STL iterators.  When used with boolean values, the following are important
// ranges (other integral ranges use min/max values for special range values):
//
//  [F, F) = {}     = Empty set
//  [T, F) = {T}
//  [F, T) = {F}
//  [T, T) = {F, T} = Full set
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/Instruction.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Operator.h"
#include "llvm/IR/ConstantRange.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

ConstantRange::ConstantRange(uint32_t BitWidth, bool Full)
    : Lower(Full ? APInt::getMaxValue(BitWidth) : APInt::getMinValue(BitWidth)),
      Upper(Lower) {}

ConstantRange::ConstantRange(APInt V)
    : Lower(std::move(V)), Upper(Lower + 1) {}

ConstantRange::ConstantRange(APInt L, APInt U)
    : Lower(std::move(L)), Upper(std::move(U)) {
  assert(Lower.getBitWidth() == Upper.getBitWidth() &&
         "ConstantRange with unequal bit widths");
  assert((Lower != Upper || (Lower.isMaxValue() || Lower.isMinValue())) &&
         "Lower == Upper, but they aren't min or max value!");
}

ConstantRange ConstantRange::makeAllowedICmpRegion(CmpInst::Predicate Pred,
                                                   const ConstantRange &CR) {
  if (CR.isEmptySet())
    return CR;

  uint32_t W = CR.getBitWidth();
  switch (Pred) {
  default:
    llvm_unreachable("Invalid ICmp predicate to makeAllowedICmpRegion()");
  case CmpInst::ICMP_EQ:
    return CR;
  case CmpInst::ICMP_NE:
    if (CR.isSingleElement())
      return ConstantRange(CR.getUpper(), CR.getLower());
    return ConstantRange(W);
  case CmpInst::ICMP_ULT: {
    APInt UMax(CR.getUnsignedMax());
    if (UMax.isMinValue())
      return ConstantRange(W, /* empty */ false);
    return ConstantRange(APInt::getMinValue(W), UMax);
  }
  case CmpInst::ICMP_SLT: {
    APInt SMax(CR.getSignedMax());
    if (SMax.isMinSignedValue())
      return ConstantRange(W, /* empty */ false);
    return ConstantRange(APInt::getSignedMinValue(W), SMax);
  }
  case CmpInst::ICMP_ULE: {
    APInt UMax(CR.getUnsignedMax());
    if (UMax.isMaxValue())
      return ConstantRange(W);
    return ConstantRange(APInt::getMinValue(W), UMax + 1);
  }
  case CmpInst::ICMP_SLE: {
    APInt SMax(CR.getSignedMax());
    if (SMax.isMaxSignedValue())
      return ConstantRange(W);
    return ConstantRange(APInt::getSignedMinValue(W), SMax + 1);
  }
  case CmpInst::ICMP_UGT: {
    APInt UMin(CR.getUnsignedMin());
    if (UMin.isMaxValue())
      return ConstantRange(W, /* empty */ false);
    return ConstantRange(UMin + 1, APInt::getNullValue(W));
  }
  case CmpInst::ICMP_SGT: {
    APInt SMin(CR.getSignedMin());
    if (SMin.isMaxSignedValue())
      return ConstantRange(W, /* empty */ false);
    return ConstantRange(SMin + 1, APInt::getSignedMinValue(W));
  }
  case CmpInst::ICMP_UGE: {
    APInt UMin(CR.getUnsignedMin());
    if (UMin.isMinValue())
      return ConstantRange(W);
    return ConstantRange(UMin, APInt::getNullValue(W));
  }
  case CmpInst::ICMP_SGE: {
    APInt SMin(CR.getSignedMin());
    if (SMin.isMinSignedValue())
      return ConstantRange(W);
    return ConstantRange(SMin, APInt::getSignedMinValue(W));
  }
  }
}

ConstantRange ConstantRange::makeSatisfyingICmpRegion(CmpInst::Predicate Pred,
                                                      const ConstantRange &CR) {
  // Follows from De-Morgan's laws:
  //
  // ~(~A union ~B) == A intersect B.
  //
  return makeAllowedICmpRegion(CmpInst::getInversePredicate(Pred), CR)
      .inverse();
}

ConstantRange ConstantRange::makeExactICmpRegion(CmpInst::Predicate Pred,
                                                 const APInt &C) {
  // Computes the exact range that is equal to both the constant ranges returned
  // by makeAllowedICmpRegion and makeSatisfyingICmpRegion. This is always true
  // when RHS is a singleton such as an APInt and so the assert is valid.
  // However for non-singleton RHS, for example ult [2,5) makeAllowedICmpRegion
  // returns [0,4) but makeSatisfyICmpRegion returns [0,2).
  //
  assert(makeAllowedICmpRegion(Pred, C) == makeSatisfyingICmpRegion(Pred, C));
  return makeAllowedICmpRegion(Pred, C);
}

bool ConstantRange::getEquivalentICmp(CmpInst::Predicate &Pred,
                                      APInt &RHS) const {
  bool Success = false;

  if (isFullSet() || isEmptySet()) {
    Pred = isEmptySet() ? CmpInst::ICMP_ULT : CmpInst::ICMP_UGE;
    RHS = APInt(getBitWidth(), 0);
    Success = true;
  } else if (auto *OnlyElt = getSingleElement()) {
    Pred = CmpInst::ICMP_EQ;
    RHS = *OnlyElt;
    Success = true;
  } else if (auto *OnlyMissingElt = getSingleMissingElement()) {
    Pred = CmpInst::ICMP_NE;
    RHS = *OnlyMissingElt;
    Success = true;
  } else if (getLower().isMinSignedValue() || getLower().isMinValue()) {
    Pred =
        getLower().isMinSignedValue() ? CmpInst::ICMP_SLT : CmpInst::ICMP_ULT;
    RHS = getUpper();
    Success = true;
  } else if (getUpper().isMinSignedValue() || getUpper().isMinValue()) {
    Pred =
        getUpper().isMinSignedValue() ? CmpInst::ICMP_SGE : CmpInst::ICMP_UGE;
    RHS = getLower();
    Success = true;
  }

  assert((!Success || ConstantRange::makeExactICmpRegion(Pred, RHS) == *this) &&
         "Bad result!");

  return Success;
}

ConstantRange
ConstantRange::makeGuaranteedNoWrapRegion(Instruction::BinaryOps BinOp,
                                          const ConstantRange &Other,
                                          unsigned NoWrapKind) {
  typedef OverflowingBinaryOperator OBO;

  // Computes the intersection of CR0 and CR1.  It is different from
  // intersectWith in that the ConstantRange returned will only contain elements
  // in both CR0 and CR1 (i.e. SubsetIntersect(X, Y) is a *subset*, proper or
  // not, of both X and Y).
  auto SubsetIntersect =
      [](const ConstantRange &CR0, const ConstantRange &CR1) {
    return CR0.inverse().unionWith(CR1.inverse()).inverse();
  };

  assert(BinOp >= Instruction::BinaryOpsBegin &&
         BinOp < Instruction::BinaryOpsEnd && "Binary operators only!");

  assert((NoWrapKind == OBO::NoSignedWrap ||
          NoWrapKind == OBO::NoUnsignedWrap ||
          NoWrapKind == (OBO::NoUnsignedWrap | OBO::NoSignedWrap)) &&
         "NoWrapKind invalid!");

  unsigned BitWidth = Other.getBitWidth();
  if (BinOp != Instruction::Add)
    // Conservative answer: empty set
    return ConstantRange(BitWidth, false);

  if (auto *C = Other.getSingleElement())
    if (C->isNullValue())
      // Full set: nothing signed / unsigned wraps when added to 0.
      return ConstantRange(BitWidth);

  ConstantRange Result(BitWidth);

  if (NoWrapKind & OBO::NoUnsignedWrap)
    Result =
        SubsetIntersect(Result, ConstantRange(APInt::getNullValue(BitWidth),
                                              -Other.getUnsignedMax()));

  if (NoWrapKind & OBO::NoSignedWrap) {
    const APInt &SignedMin = Other.getSignedMin();
    const APInt &SignedMax = Other.getSignedMax();

    if (SignedMax.isStrictlyPositive())
      Result = SubsetIntersect(
          Result,
          ConstantRange(APInt::getSignedMinValue(BitWidth),
                        APInt::getSignedMinValue(BitWidth) - SignedMax));

    if (SignedMin.isNegative())
      Result = SubsetIntersect(
          Result, ConstantRange(APInt::getSignedMinValue(BitWidth) - SignedMin,
                                APInt::getSignedMinValue(BitWidth)));
  }

  return Result;
}

bool ConstantRange::isFullSet() const {
  return Lower == Upper && Lower.isMaxValue();
}

bool ConstantRange::isEmptySet() const {
  return Lower == Upper && Lower.isMinValue();
}

bool ConstantRange::isWrappedSet() const {
  return Lower.ugt(Upper);
}

bool ConstantRange::isSignWrappedSet() const {
  return contains(APInt::getSignedMaxValue(getBitWidth())) &&
         contains(APInt::getSignedMinValue(getBitWidth()));
}

APInt ConstantRange::getSetSize() const {
  if (isFullSet()) {
    APInt Size(getBitWidth()+1, 0);
    Size.setBit(getBitWidth());
    return Size;
  }

  // This is also correct for wrapped sets.
  return (Upper - Lower).zext(getBitWidth()+1);
}

bool
ConstantRange::isSizeStrictlySmallerThanOf(const ConstantRange &Other) const {
  assert(getBitWidth() == Other.getBitWidth());
  if (isFullSet())
    return false;
  if (Other.isFullSet())
    return true;
  return (Upper - Lower).ult(Other.Upper - Other.Lower);
}

APInt ConstantRange::getUnsignedMax() const {
  if (isFullSet() || isWrappedSet())
    return APInt::getMaxValue(getBitWidth());
  return getUpper() - 1;
}

APInt ConstantRange::getUnsignedMin() const {
  if (isFullSet() || (isWrappedSet() && getUpper() != 0))
    return APInt::getMinValue(getBitWidth());
  return getLower();
}

APInt ConstantRange::getSignedMax() const {
  APInt SignedMax(APInt::getSignedMaxValue(getBitWidth()));
  if (!isWrappedSet()) {
    APInt UpperMinusOne = getUpper() - 1;
    if (getLower().sle(UpperMinusOne))
      return UpperMinusOne;
    return APInt::getSignedMaxValue(getBitWidth());
  }
  if (getLower().isNegative() == getUpper().isNegative())
    return APInt::getSignedMaxValue(getBitWidth());
  return getUpper() - 1;
}

APInt ConstantRange::getSignedMin() const {
  if (!isWrappedSet()) {
    if (getLower().sle(getUpper() - 1))
      return getLower();
    return APInt::getSignedMinValue(getBitWidth());
  }
  if ((getUpper() - 1).slt(getLower())) {
    if (!getUpper().isMinSignedValue())
      return APInt::getSignedMinValue(getBitWidth());
  }
  return getLower();
}

bool ConstantRange::contains(const APInt &V) const {
  if (Lower == Upper)
    return isFullSet();

  if (!isWrappedSet())
    return Lower.ule(V) && V.ult(Upper);
  return Lower.ule(V) || V.ult(Upper);
}

bool ConstantRange::contains(const ConstantRange &Other) const {
  if (isFullSet() || Other.isEmptySet()) return true;
  if (isEmptySet() || Other.isFullSet()) return false;

  if (!isWrappedSet()) {
    if (Other.isWrappedSet())
      return false;

    return Lower.ule(Other.getLower()) && Other.getUpper().ule(Upper);
  }

  if (!Other.isWrappedSet())
    return Other.getUpper().ule(Upper) ||
           Lower.ule(Other.getLower());

  return Other.getUpper().ule(Upper) && Lower.ule(Other.getLower());
}

ConstantRange ConstantRange::subtract(const APInt &Val) const {
  assert(Val.getBitWidth() == getBitWidth() && "Wrong bit width");
  // If the set is empty or full, don't modify the endpoints.
  if (Lower == Upper) 
    return *this;
  return ConstantRange(Lower - Val, Upper - Val);
}

ConstantRange ConstantRange::difference(const ConstantRange &CR) const {
  return intersectWith(CR.inverse());
}

ConstantRange ConstantRange::intersectWith(const ConstantRange &CR) const {
  assert(getBitWidth() == CR.getBitWidth() && 
         "ConstantRange types don't agree!");

  // Handle common cases.
  if (   isEmptySet() || CR.isFullSet()) return *this;
  if (CR.isEmptySet() ||    isFullSet()) return CR;

  if (!isWrappedSet() && CR.isWrappedSet())
    return CR.intersectWith(*this);

  if (!isWrappedSet() && !CR.isWrappedSet()) {
    if (Lower.ult(CR.Lower)) {
      if (Upper.ule(CR.Lower))
        return ConstantRange(getBitWidth(), false);

      if (Upper.ult(CR.Upper))
        return ConstantRange(CR.Lower, Upper);

      return CR;
    }
    if (Upper.ult(CR.Upper))
      return *this;

    if (Lower.ult(CR.Upper))
      return ConstantRange(Lower, CR.Upper);

    return ConstantRange(getBitWidth(), false);
  }

  if (isWrappedSet() && !CR.isWrappedSet()) {
    if (CR.Lower.ult(Upper)) {
      if (CR.Upper.ult(Upper))
        return CR;

      if (CR.Upper.ule(Lower))
        return ConstantRange(CR.Lower, Upper);

      if (isSizeStrictlySmallerThanOf(CR))
        return *this;
      return CR;
    }
    if (CR.Lower.ult(Lower)) {
      if (CR.Upper.ule(Lower))
        return ConstantRange(getBitWidth(), false);

      return ConstantRange(Lower, CR.Upper);
    }
    return CR;
  }

  if (CR.Upper.ult(Upper)) {
    if (CR.Lower.ult(Upper)) {
      if (isSizeStrictlySmallerThanOf(CR))
        return *this;
      return CR;
    }

    if (CR.Lower.ult(Lower))
      return ConstantRange(Lower, CR.Upper);

    return CR;
  }
  if (CR.Upper.ule(Lower)) {
    if (CR.Lower.ult(Lower))
      return *this;

    return ConstantRange(CR.Lower, Upper);
  }
  if (isSizeStrictlySmallerThanOf(CR))
    return *this;
  return CR;
}

ConstantRange ConstantRange::unionWith(const ConstantRange &CR) const {
  assert(getBitWidth() == CR.getBitWidth() && 
         "ConstantRange types don't agree!");

  if (   isFullSet() || CR.isEmptySet()) return *this;
  if (CR.isFullSet() ||    isEmptySet()) return CR;

  if (!isWrappedSet() && CR.isWrappedSet()) return CR.unionWith(*this);

  if (!isWrappedSet() && !CR.isWrappedSet()) {
    if (CR.Upper.ult(Lower) || Upper.ult(CR.Lower)) {
      // If the two ranges are disjoint, find the smaller gap and bridge it.
      APInt d1 = CR.Lower - Upper, d2 = Lower - CR.Upper;
      if (d1.ult(d2))
        return ConstantRange(Lower, CR.Upper);
      return ConstantRange(CR.Lower, Upper);
    }

    APInt L = Lower, U = Upper;
    if (CR.Lower.ult(L))
      L = CR.Lower;
    if ((CR.Upper - 1).ugt(U - 1))
      U = CR.Upper;

    if (L == 0 && U == 0)
      return ConstantRange(getBitWidth());

    return ConstantRange(L, U);
  }

  if (!CR.isWrappedSet()) {
    // ------U   L-----  and  ------U   L----- : this
    //   L--U                            L--U  : CR
    if (CR.Upper.ule(Upper) || CR.Lower.uge(Lower))
      return *this;

    // ------U   L----- : this
    //    L---------U   : CR
    if (CR.Lower.ule(Upper) && Lower.ule(CR.Upper))
      return ConstantRange(getBitWidth());

    // ----U       L---- : this
    //       L---U       : CR
    //    <d1>  <d2>
    if (Upper.ule(CR.Lower) && CR.Upper.ule(Lower)) {
      APInt d1 = CR.Lower - Upper, d2 = Lower - CR.Upper;
      if (d1.ult(d2))
        return ConstantRange(Lower, CR.Upper);
      return ConstantRange(CR.Lower, Upper);
    }

    // ----U     L----- : this
    //        L----U    : CR
    if (Upper.ult(CR.Lower) && Lower.ult(CR.Upper))
      return ConstantRange(CR.Lower, Upper);

    // ------U    L---- : this
    //    L-----U       : CR
    assert(CR.Lower.ult(Upper) && CR.Upper.ult(Lower) &&
           "ConstantRange::unionWith missed a case with one range wrapped");
    return ConstantRange(Lower, CR.Upper);
  }

  // ------U    L----  and  ------U    L---- : this
  // -U  L-----------  and  ------------U  L : CR
  if (CR.Lower.ule(Upper) || Lower.ule(CR.Upper))
    return ConstantRange(getBitWidth());

  APInt L = Lower, U = Upper;
  if (CR.Upper.ugt(U))
    U = CR.Upper;
  if (CR.Lower.ult(L))
    L = CR.Lower;

  return ConstantRange(L, U);
}

ConstantRange ConstantRange::castOp(Instruction::CastOps CastOp,
                                    uint32_t ResultBitWidth) const {
  switch (CastOp) {
  default:
    llvm_unreachable("unsupported cast type");
  case Instruction::Trunc:
    return truncate(ResultBitWidth);
  case Instruction::SExt:
    return signExtend(ResultBitWidth);
  case Instruction::ZExt:
    return zeroExtend(ResultBitWidth);
  case Instruction::BitCast:
    return *this;
  case Instruction::FPToUI:
  case Instruction::FPToSI:
    if (getBitWidth() == ResultBitWidth)
      return *this;
    else
      return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  case Instruction::UIToFP: {
    // TODO: use input range if available
    auto BW = getBitWidth();
    APInt Min = APInt::getMinValue(BW).zextOrSelf(ResultBitWidth);
    APInt Max = APInt::getMaxValue(BW).zextOrSelf(ResultBitWidth);
    return ConstantRange(Min, Max);
  }
  case Instruction::SIToFP: {
    // TODO: use input range if available
    auto BW = getBitWidth();
    APInt SMin = APInt::getSignedMinValue(BW).sextOrSelf(ResultBitWidth);
    APInt SMax = APInt::getSignedMaxValue(BW).sextOrSelf(ResultBitWidth);
    return ConstantRange(SMin, SMax);
  }
  case Instruction::FPTrunc:
  case Instruction::FPExt:
  case Instruction::IntToPtr:
  case Instruction::PtrToInt:
  case Instruction::AddrSpaceCast:
    // Conservatively return full set.
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  };
}

ConstantRange ConstantRange::zeroExtend(uint32_t DstTySize) const {
  if (isEmptySet()) return ConstantRange(DstTySize, /*isFullSet=*/false);

  unsigned SrcTySize = getBitWidth();
  assert(SrcTySize < DstTySize && "Not a value extension");
  if (isFullSet() || isWrappedSet()) {
    // Change into [0, 1 << src bit width)
    APInt LowerExt(DstTySize, 0);
    if (!Upper) // special case: [X, 0) -- not really wrapping around
      LowerExt = Lower.zext(DstTySize);
    return ConstantRange(LowerExt, APInt::getOneBitSet(DstTySize, SrcTySize));
  }

  return ConstantRange(Lower.zext(DstTySize), Upper.zext(DstTySize));
}

ConstantRange ConstantRange::signExtend(uint32_t DstTySize) const {
  if (isEmptySet()) return ConstantRange(DstTySize, /*isFullSet=*/false);

  unsigned SrcTySize = getBitWidth();
  assert(SrcTySize < DstTySize && "Not a value extension");

  // special case: [X, INT_MIN) -- not really wrapping around
  if (Upper.isMinSignedValue())
    return ConstantRange(Lower.sext(DstTySize), Upper.zext(DstTySize));

  if (isFullSet() || isSignWrappedSet()) {
    return ConstantRange(APInt::getHighBitsSet(DstTySize,DstTySize-SrcTySize+1),
                         APInt::getLowBitsSet(DstTySize, SrcTySize-1) + 1);
  }

  return ConstantRange(Lower.sext(DstTySize), Upper.sext(DstTySize));
}

ConstantRange ConstantRange::truncate(uint32_t DstTySize) const {
  assert(getBitWidth() > DstTySize && "Not a value truncation");
  if (isEmptySet())
    return ConstantRange(DstTySize, /*isFullSet=*/false);
  if (isFullSet())
    return ConstantRange(DstTySize, /*isFullSet=*/true);

  APInt MaxValue = APInt::getMaxValue(DstTySize).zext(getBitWidth());
  APInt MaxBitValue(getBitWidth(), 0);
  MaxBitValue.setBit(DstTySize);

  APInt LowerDiv(Lower), UpperDiv(Upper);
  ConstantRange Union(DstTySize, /*isFullSet=*/false);

  // Analyze wrapped sets in their two parts: [0, Upper) \/ [Lower, MaxValue]
  // We use the non-wrapped set code to analyze the [Lower, MaxValue) part, and
  // then we do the union with [MaxValue, Upper)
  if (isWrappedSet()) {
    // If Upper is greater than Max Value, it covers the whole truncated range.
    if (Upper.uge(MaxValue))
      return ConstantRange(DstTySize, /*isFullSet=*/true);

    Union = ConstantRange(APInt::getMaxValue(DstTySize),Upper.trunc(DstTySize));
    UpperDiv = APInt::getMaxValue(getBitWidth());

    // Union covers the MaxValue case, so return if the remaining range is just
    // MaxValue.
    if (LowerDiv == UpperDiv)
      return Union;
  }

  // Chop off the most significant bits that are past the destination bitwidth.
  if (LowerDiv.uge(MaxValue)) {
    APInt Div(getBitWidth(), 0);
    APInt::udivrem(LowerDiv, MaxBitValue, Div, LowerDiv);
    UpperDiv = UpperDiv - MaxBitValue * Div;
  }

  if (UpperDiv.ule(MaxValue))
    return ConstantRange(LowerDiv.trunc(DstTySize),
                         UpperDiv.trunc(DstTySize)).unionWith(Union);

  // The truncated value wraps around. Check if we can do better than fullset.
  APInt UpperModulo = UpperDiv - MaxBitValue;
  if (UpperModulo.ult(LowerDiv))
    return ConstantRange(LowerDiv.trunc(DstTySize),
                         UpperModulo.trunc(DstTySize)).unionWith(Union);

  return ConstantRange(DstTySize, /*isFullSet=*/true);
}

ConstantRange ConstantRange::zextOrTrunc(uint32_t DstTySize) const {
  unsigned SrcTySize = getBitWidth();
  if (SrcTySize > DstTySize)
    return truncate(DstTySize);
  if (SrcTySize < DstTySize)
    return zeroExtend(DstTySize);
  return *this;
}

ConstantRange ConstantRange::sextOrTrunc(uint32_t DstTySize) const {
  unsigned SrcTySize = getBitWidth();
  if (SrcTySize > DstTySize)
    return truncate(DstTySize);
  if (SrcTySize < DstTySize)
    return signExtend(DstTySize);
  return *this;
}

ConstantRange ConstantRange::binaryOp(Instruction::BinaryOps BinOp,
                                      const ConstantRange &Other) const {
  assert(BinOp >= Instruction::BinaryOpsBegin &&
         BinOp < Instruction::BinaryOpsEnd && "Binary operators only!");

  switch (BinOp) {
  case Instruction::Add:
    return add(Other);
  case Instruction::Sub:
    return sub(Other);
  case Instruction::Mul:
    return multiply(Other);
  case Instruction::UDiv:
    return udiv(Other);
  case Instruction::Shl:
    return shl(Other);
  case Instruction::LShr:
    return lshr(Other);
  case Instruction::And:
    return binaryAnd(Other);
  case Instruction::Or:
    return binaryOr(Other);
  // Note: floating point operations applied to abstract ranges are just
  // ideal integer operations with a lossy representation
  case Instruction::FAdd:
    return add(Other);
  case Instruction::FSub:
    return sub(Other);
  case Instruction::FMul:
    return multiply(Other);
  default:
    // Conservatively return full set.
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  }
}

ConstantRange
ConstantRange::add(const ConstantRange &Other) const {
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);
  if (isFullSet() || Other.isFullSet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);

  APInt NewLower = getLower() + Other.getLower();
  APInt NewUpper = getUpper() + Other.getUpper() - 1;
  if (NewLower == NewUpper)
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);

  ConstantRange X = ConstantRange(NewLower, NewUpper);
  if (X.isSizeStrictlySmallerThanOf(*this) ||
      X.isSizeStrictlySmallerThanOf(Other))
    // We've wrapped, therefore, full set.
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  return X;
}

ConstantRange ConstantRange::addWithNoSignedWrap(const APInt &Other) const {
  // Calculate the subset of this range such that "X + Other" is
  // guaranteed not to wrap (overflow) for all X in this subset.
  // makeGuaranteedNoWrapRegion will produce an exact NSW range since we are
  // passing a single element range.
  auto NSWRange = ConstantRange::makeGuaranteedNoWrapRegion(BinaryOperator::Add,
                                      ConstantRange(Other),
                                      OverflowingBinaryOperator::NoSignedWrap);
  auto NSWConstrainedRange = intersectWith(NSWRange);

  return NSWConstrainedRange.add(ConstantRange(Other));
}

ConstantRange
ConstantRange::sub(const ConstantRange &Other) const {
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);
  if (isFullSet() || Other.isFullSet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);

  APInt NewLower = getLower() - Other.getUpper() + 1;
  APInt NewUpper = getUpper() - Other.getLower();
  if (NewLower == NewUpper)
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);

  ConstantRange X = ConstantRange(NewLower, NewUpper);
  if (X.isSizeStrictlySmallerThanOf(*this) ||
      X.isSizeStrictlySmallerThanOf(Other))
    // We've wrapped, therefore, full set.
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  return X;
}

ConstantRange
ConstantRange::multiply(const ConstantRange &Other) const {
  // TODO: If either operand is a single element and the multiply is known to
  // be non-wrapping, round the result min and max value to the appropriate
  // multiple of that element. If wrapping is possible, at least adjust the
  // range according to the greatest power-of-two factor of the single element.

  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);

  // Multiplication is signedness-independent. However different ranges can be
  // obtained depending on how the input ranges are treated. These different
  // ranges are all conservatively correct, but one might be better than the
  // other. We calculate two ranges; one treating the inputs as unsigned
  // and the other signed, then return the smallest of these ranges.

  // Unsigned range first.
  APInt this_min = getUnsignedMin().zext(getBitWidth() * 2);
  APInt this_max = getUnsignedMax().zext(getBitWidth() * 2);
  APInt Other_min = Other.getUnsignedMin().zext(getBitWidth() * 2);
  APInt Other_max = Other.getUnsignedMax().zext(getBitWidth() * 2);

  ConstantRange Result_zext = ConstantRange(this_min * Other_min,
                                            this_max * Other_max + 1);
  ConstantRange UR = Result_zext.truncate(getBitWidth());

  // If the unsigned range doesn't wrap, and isn't negative then it's a range
  // from one positive number to another which is as good as we can generate.
  // In this case, skip the extra work of generating signed ranges which aren't
  // going to be better than this range.
  if (!UR.isWrappedSet() && UR.getLower().isNonNegative())
    return UR;

  // Now the signed range. Because we could be dealing with negative numbers
  // here, the lower bound is the smallest of the cartesian product of the
  // lower and upper ranges; for example:
  //   [-1,4) * [-2,3) = min(-1*-2, -1*2, 3*-2, 3*2) = -6.
  // Similarly for the upper bound, swapping min for max.

  this_min = getSignedMin().sext(getBitWidth() * 2);
  this_max = getSignedMax().sext(getBitWidth() * 2);
  Other_min = Other.getSignedMin().sext(getBitWidth() * 2);
  Other_max = Other.getSignedMax().sext(getBitWidth() * 2);
  
  auto L = {this_min * Other_min, this_min * Other_max,
            this_max * Other_min, this_max * Other_max};
  auto Compare = [](const APInt &A, const APInt &B) { return A.slt(B); };
  ConstantRange Result_sext(std::min(L, Compare), std::max(L, Compare) + 1);
  ConstantRange SR = Result_sext.truncate(getBitWidth());

  return UR.isSizeStrictlySmallerThanOf(SR) ? UR : SR;
}

ConstantRange
ConstantRange::smax(const ConstantRange &Other) const {
  // X smax Y is: range(smax(X_smin, Y_smin),
  //                    smax(X_smax, Y_smax))
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);
  APInt NewL = APIntOps::smax(getSignedMin(), Other.getSignedMin());
  APInt NewU = APIntOps::smax(getSignedMax(), Other.getSignedMax()) + 1;
  if (NewU == NewL)
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  return ConstantRange(NewL, NewU);
}

ConstantRange
ConstantRange::umax(const ConstantRange &Other) const {
  // X umax Y is: range(umax(X_umin, Y_umin),
  //                    umax(X_umax, Y_umax))
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);
  APInt NewL = APIntOps::umax(getUnsignedMin(), Other.getUnsignedMin());
  APInt NewU = APIntOps::umax(getUnsignedMax(), Other.getUnsignedMax()) + 1;
  if (NewU == NewL)
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  return ConstantRange(NewL, NewU);
}

ConstantRange
ConstantRange::smin(const ConstantRange &Other) const {
  // X smin Y is: range(smin(X_smin, Y_smin),
  //                    smin(X_smax, Y_smax))
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);
  APInt NewL = APIntOps::smin(getSignedMin(), Other.getSignedMin());
  APInt NewU = APIntOps::smin(getSignedMax(), Other.getSignedMax()) + 1;
  if (NewU == NewL)
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  return ConstantRange(NewL, NewU);
}

ConstantRange
ConstantRange::umin(const ConstantRange &Other) const {
  // X umin Y is: range(umin(X_umin, Y_umin),
  //                    umin(X_umax, Y_umax))
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);
  APInt NewL = APIntOps::umin(getUnsignedMin(), Other.getUnsignedMin());
  APInt NewU = APIntOps::umin(getUnsignedMax(), Other.getUnsignedMax()) + 1;
  if (NewU == NewL)
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  return ConstantRange(NewL, NewU);
}

ConstantRange
ConstantRange::udiv(const ConstantRange &RHS) const {
  if (isEmptySet() || RHS.isEmptySet() || RHS.getUnsignedMax() == 0)
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);
  if (RHS.isFullSet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);

  APInt Lower = getUnsignedMin().udiv(RHS.getUnsignedMax());

  APInt RHS_umin = RHS.getUnsignedMin();
  if (RHS_umin == 0) {
    // We want the lowest value in RHS excluding zero. Usually that would be 1
    // except for a range in the form of [X, 1) in which case it would be X.
    if (RHS.getUpper() == 1)
      RHS_umin = RHS.getLower();
    else
      RHS_umin = APInt(getBitWidth(), 1);
  }

  APInt Upper = getUnsignedMax().udiv(RHS_umin) + 1;

  // If the LHS is Full and the RHS is a wrapped interval containing 1 then
  // this could occur.
  if (Lower == Upper)
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);

  return ConstantRange(Lower, Upper);
}

ConstantRange
ConstantRange::binaryAnd(const ConstantRange &Other) const {
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);

  // TODO: replace this with something less conservative

  APInt umin = APIntOps::umin(Other.getUnsignedMax(), getUnsignedMax());
  if (umin.isAllOnesValue())
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  return ConstantRange(APInt::getNullValue(getBitWidth()), umin + 1);
}

ConstantRange
ConstantRange::binaryOr(const ConstantRange &Other) const {
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);

  // TODO: replace this with something less conservative

  APInt umax = APIntOps::umax(getUnsignedMin(), Other.getUnsignedMin());
  if (umax.isNullValue())
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  return ConstantRange(umax, APInt::getNullValue(getBitWidth()));
}

ConstantRange
ConstantRange::shl(const ConstantRange &Other) const {
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);

  APInt min = getUnsignedMin().shl(Other.getUnsignedMin());
  APInt max = getUnsignedMax().shl(Other.getUnsignedMax());

  // there's no overflow!
  APInt Zeros(getBitWidth(), getUnsignedMax().countLeadingZeros());
  if (Zeros.ugt(Other.getUnsignedMax()))
    return ConstantRange(min, max + 1);

  // FIXME: implement the other tricky cases
  return ConstantRange(getBitWidth(), /*isFullSet=*/true);
}

ConstantRange
ConstantRange::lshr(const ConstantRange &Other) const {
  if (isEmptySet() || Other.isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);
  
  APInt max = getUnsignedMax().lshr(Other.getUnsignedMin());
  APInt min = getUnsignedMin().lshr(Other.getUnsignedMax());
  if (min == max + 1)
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);

  return ConstantRange(min, max + 1);
}

ConstantRange ConstantRange::inverse() const {
  if (isFullSet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/false);
  if (isEmptySet())
    return ConstantRange(getBitWidth(), /*isFullSet=*/true);
  return ConstantRange(Upper, Lower);
}

void ConstantRange::print(raw_ostream &OS) const {
  if (isFullSet())
    OS << "full-set";
  else if (isEmptySet())
    OS << "empty-set";
  else
    OS << "[" << Lower << "," << Upper << ")";
}

#if !defined(NDEBUG) || defined(LLVM_ENABLE_DUMP)
LLVM_DUMP_METHOD void ConstantRange::dump() const {
  print(dbgs());
}
#endif

ConstantRange llvm::getConstantRangeFromMetadata(const MDNode &Ranges) {
  const unsigned NumRanges = Ranges.getNumOperands() / 2;
  assert(NumRanges >= 1 && "Must have at least one range!");
  assert(Ranges.getNumOperands() % 2 == 0 && "Must be a sequence of pairs");

  auto *FirstLow = mdconst::extract<ConstantInt>(Ranges.getOperand(0));
  auto *FirstHigh = mdconst::extract<ConstantInt>(Ranges.getOperand(1));

  ConstantRange CR(FirstLow->getValue(), FirstHigh->getValue());

  for (unsigned i = 1; i < NumRanges; ++i) {
    auto *Low = mdconst::extract<ConstantInt>(Ranges.getOperand(2 * i + 0));
    auto *High = mdconst::extract<ConstantInt>(Ranges.getOperand(2 * i + 1));

    // Note: unionWith will potentially create a range that contains values not
    // contained in any of the original N ranges.
    CR = CR.unionWith(ConstantRange(Low->getValue(), High->getValue()));
  }

  return CR;
}
