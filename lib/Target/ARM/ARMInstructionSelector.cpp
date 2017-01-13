//===- ARMInstructionSelector.cpp ----------------------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the targeting of the InstructionSelector class for ARM.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#include "ARMInstructionSelector.h"
#include "ARMRegisterBankInfo.h"
#include "ARMSubtarget.h"
#include "ARMTargetMachine.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "arm-isel"

using namespace llvm;

#ifndef LLVM_BUILD_GLOBAL_ISEL
#error "You shouldn't build this"
#endif

ARMInstructionSelector::ARMInstructionSelector(const ARMSubtarget &STI,
                                               const ARMRegisterBankInfo &RBI)
    : InstructionSelector(), TII(*STI.getInstrInfo()),
      TRI(*STI.getRegisterInfo()), RBI(RBI) {}

static bool selectCopy(MachineInstr &I, const TargetInstrInfo &TII,
                       MachineRegisterInfo &MRI, const TargetRegisterInfo &TRI,
                       const RegisterBankInfo &RBI) {
  unsigned DstReg = I.getOperand(0).getReg();
  if (TargetRegisterInfo::isPhysicalRegister(DstReg))
    return true;

  const RegisterBank *RegBank = RBI.getRegBank(DstReg, MRI, TRI);
  (void)RegBank;
  assert(RegBank && "Can't get reg bank for virtual register");

  const unsigned DstSize = MRI.getType(DstReg).getSizeInBits();
  (void)DstSize;
  unsigned SrcReg = I.getOperand(1).getReg();
  const unsigned SrcSize = RBI.getSizeInBits(SrcReg, MRI, TRI);
  (void)SrcSize;
  assert((DstSize == SrcSize ||
          // Copies are a means to setup initial types, the number of
          // bits may not exactly match.
          (TargetRegisterInfo::isPhysicalRegister(SrcReg) &&
           DstSize <= SrcSize)) &&
         "Copy with different width?!");

  assert(RegBank->getID() == ARM::GPRRegBankID && "Unsupported reg bank");
  const TargetRegisterClass *RC = &ARM::GPRRegClass;

  // No need to constrain SrcReg. It will get constrained when
  // we hit another of its uses or its defs.
  // Copies do not have constraints.
  if (!RBI.constrainGenericRegister(DstReg, *RC, MRI)) {
    DEBUG(dbgs() << "Failed to constrain " << TII.getName(I.getOpcode())
                 << " operand\n");
    return false;
  }
  return true;
}

bool ARMInstructionSelector::select(MachineInstr &I) const {
  assert(I.getParent() && "Instruction should be in a basic block!");
  assert(I.getParent()->getParent() && "Instruction should be in a function!");

  auto &MBB = *I.getParent();
  auto &MF = *MBB.getParent();
  auto &MRI = MF.getRegInfo();

  if (!isPreISelGenericOpcode(I.getOpcode())) {
    if (I.isCopy())
      return selectCopy(I, TII, MRI, TRI, RBI);

    return true;
  }

  MachineInstrBuilder MIB{MF, I};

  using namespace TargetOpcode;
  switch (I.getOpcode()) {
  case G_ADD:
    I.setDesc(TII.get(ARM::ADDrr));
    MIB.add(predOps(ARMCC::AL)).add(condCodeOp());
    break;
  case G_FRAME_INDEX:
    // Add 0 to the given frame index and hope it will eventually be folded into
    // the user(s).
    I.setDesc(TII.get(ARM::ADDri));
    MIB.addImm(0).add(predOps(ARMCC::AL)).add(condCodeOp());
    break;
  case G_LOAD:
    I.setDesc(TII.get(ARM::LDRi12));
    MIB.addImm(0).add(predOps(ARMCC::AL));
    break;
  default:
    return false;
  }

  return constrainSelectedInstRegOperands(I, TII, TRI, RBI);
}
