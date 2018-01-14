; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512f | FileCheck %s --check-prefix=ALL --check-prefix=KNL
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512f,+avx512vl,+avx512bw,+avx512dq,+fast-variable-shuffle | FileCheck %s --check-prefixes=ALL,SKX

 attributes #0 = { nounwind }

define <16 x i8> @trunc_16x32_to_16x8(<16 x i32> %i) #0 {
; ALL-LABEL: trunc_16x32_to_16x8:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovdb %zmm0, %xmm0
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %x = trunc <16 x i32> %i to <16 x i8>
  ret <16 x i8> %x
}

define <8 x i16> @trunc_8x64_to_8x16(<8 x i64> %i) #0 {
; ALL-LABEL: trunc_8x64_to_8x16:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovqw %zmm0, %xmm0
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %x = trunc <8 x i64> %i to <8 x i16>
  ret <8 x i16> %x
}

define <16 x i16> @trunc_v16i32_to_v16i16(<16 x i32> %x) #0 {
; ALL-LABEL: trunc_v16i32_to_v16i16:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovdw %zmm0, %ymm0
; ALL-NEXT:    retq
  %1 = trunc <16 x i32> %x to <16 x i16>
  ret <16 x i16> %1
}

define <8 x i8> @trunc_qb_512(<8 x i64> %i) #0 {
; ALL-LABEL: trunc_qb_512:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovqw %zmm0, %xmm0
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %x = trunc <8 x i64> %i to <8 x i8>
  ret <8 x i8> %x
}

define void @trunc_qb_512_mem(<8 x i64> %i, <8 x i8>* %res) #0 {
; ALL-LABEL: trunc_qb_512_mem:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovqb %zmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
    %x = trunc <8 x i64> %i to <8 x i8>
    store <8 x i8> %x, <8 x i8>* %res
    ret void
}

define <4 x i8> @trunc_qb_256(<4 x i64> %i) #0 {
; KNL-LABEL: trunc_qb_256:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovqd %zmm0, %ymm0
; KNL-NEXT:    ## kill: def %xmm0 killed %xmm0 killed %ymm0
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_qb_256:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovqd %ymm0, %xmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x = trunc <4 x i64> %i to <4 x i8>
  ret <4 x i8> %x
}

define void @trunc_qb_256_mem(<4 x i64> %i, <4 x i8>* %res) #0 {
; KNL-LABEL: trunc_qb_256_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovqd %zmm0, %ymm0
; KNL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; KNL-NEXT:    vmovd %xmm0, (%rdi)
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_qb_256_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovqb %ymm0, (%rdi)
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
    %x = trunc <4 x i64> %i to <4 x i8>
    store <4 x i8> %x, <4 x i8>* %res
    ret void
}

define <2 x i8> @trunc_qb_128(<2 x i64> %i) #0 {
; ALL-LABEL: trunc_qb_128:
; ALL:       ## %bb.0:
; ALL-NEXT:    retq
  %x = trunc <2 x i64> %i to <2 x i8>
  ret <2 x i8> %x
}

define void @trunc_qb_128_mem(<2 x i64> %i, <2 x i8>* %res) #0 {
; KNL-LABEL: trunc_qb_128_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,8,u,u,u,u,u,u,u,u,u,u,u,u,u,u]
; KNL-NEXT:    vpextrw $0, %xmm0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_qb_128_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovqb %xmm0, (%rdi)
; SKX-NEXT:    retq
    %x = trunc <2 x i64> %i to <2 x i8>
    store <2 x i8> %x, <2 x i8>* %res
    ret void
}

define <8 x i16> @trunc_qw_512(<8 x i64> %i) #0 {
; ALL-LABEL: trunc_qw_512:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovqw %zmm0, %xmm0
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %x = trunc <8 x i64> %i to <8 x i16>
  ret <8 x i16> %x
}

define void @trunc_qw_512_mem(<8 x i64> %i, <8 x i16>* %res) #0 {
; ALL-LABEL: trunc_qw_512_mem:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovqw %zmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
    %x = trunc <8 x i64> %i to <8 x i16>
    store <8 x i16> %x, <8 x i16>* %res
    ret void
}

define <4 x i16> @trunc_qw_256(<4 x i64> %i) #0 {
; KNL-LABEL: trunc_qw_256:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovqd %zmm0, %ymm0
; KNL-NEXT:    ## kill: def %xmm0 killed %xmm0 killed %ymm0
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_qw_256:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovqd %ymm0, %xmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x = trunc <4 x i64> %i to <4 x i16>
  ret <4 x i16> %x
}

define void @trunc_qw_256_mem(<4 x i64> %i, <4 x i16>* %res) #0 {
; KNL-LABEL: trunc_qw_256_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovqd %zmm0, %ymm0
; KNL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; KNL-NEXT:    vmovq %xmm0, (%rdi)
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_qw_256_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovqw %ymm0, (%rdi)
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
    %x = trunc <4 x i64> %i to <4 x i16>
    store <4 x i16> %x, <4 x i16>* %res
    ret void
}

define <2 x i16> @trunc_qw_128(<2 x i64> %i) #0 {
; ALL-LABEL: trunc_qw_128:
; ALL:       ## %bb.0:
; ALL-NEXT:    retq
  %x = trunc <2 x i64> %i to <2 x i16>
  ret <2 x i16> %x
}

define void @trunc_qw_128_mem(<2 x i64> %i, <2 x i16>* %res) #0 {
; KNL-LABEL: trunc_qw_128_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; KNL-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; KNL-NEXT:    vmovd %xmm0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_qw_128_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovqw %xmm0, (%rdi)
; SKX-NEXT:    retq
    %x = trunc <2 x i64> %i to <2 x i16>
    store <2 x i16> %x, <2 x i16>* %res
    ret void
}

define <8 x i32> @trunc_qd_512(<8 x i64> %i) #0 {
; ALL-LABEL: trunc_qd_512:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovqd %zmm0, %ymm0
; ALL-NEXT:    retq
  %x = trunc <8 x i64> %i to <8 x i32>
  ret <8 x i32> %x
}

define void @trunc_qd_512_mem(<8 x i64> %i, <8 x i32>* %res) #0 {
; ALL-LABEL: trunc_qd_512_mem:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovqd %zmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
    %x = trunc <8 x i64> %i to <8 x i32>
    store <8 x i32> %x, <8 x i32>* %res
    ret void
}

define <4 x i32> @trunc_qd_256(<4 x i64> %i) #0 {
; KNL-LABEL: trunc_qd_256:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovqd %zmm0, %ymm0
; KNL-NEXT:    ## kill: def %xmm0 killed %xmm0 killed %ymm0
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_qd_256:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovqd %ymm0, %xmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x = trunc <4 x i64> %i to <4 x i32>
  ret <4 x i32> %x
}

define void @trunc_qd_256_mem(<4 x i64> %i, <4 x i32>* %res) #0 {
; KNL-LABEL: trunc_qd_256_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovqd %zmm0, %ymm0
; KNL-NEXT:    vmovdqa %xmm0, (%rdi)
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_qd_256_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovqd %ymm0, (%rdi)
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
    %x = trunc <4 x i64> %i to <4 x i32>
    store <4 x i32> %x, <4 x i32>* %res
    ret void
}

define <2 x i32> @trunc_qd_128(<2 x i64> %i) #0 {
; ALL-LABEL: trunc_qd_128:
; ALL:       ## %bb.0:
; ALL-NEXT:    retq
  %x = trunc <2 x i64> %i to <2 x i32>
  ret <2 x i32> %x
}

define void @trunc_qd_128_mem(<2 x i64> %i, <2 x i32>* %res) #0 {
; KNL-LABEL: trunc_qd_128_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,2,2,3]
; KNL-NEXT:    vmovlps %xmm0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_qd_128_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovqd %xmm0, (%rdi)
; SKX-NEXT:    retq
    %x = trunc <2 x i64> %i to <2 x i32>
    store <2 x i32> %x, <2 x i32>* %res
    ret void
}

define <16 x i8> @trunc_db_512(<16 x i32> %i) #0 {
; ALL-LABEL: trunc_db_512:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovdb %zmm0, %xmm0
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %x = trunc <16 x i32> %i to <16 x i8>
  ret <16 x i8> %x
}

define void @trunc_db_512_mem(<16 x i32> %i, <16 x i8>* %res) #0 {
; ALL-LABEL: trunc_db_512_mem:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovdb %zmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
    %x = trunc <16 x i32> %i to <16 x i8>
    store <16 x i8> %x, <16 x i8>* %res
    ret void
}

define <8 x i8> @trunc_db_256(<8 x i32> %i) #0 {
; KNL-LABEL: trunc_db_256:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovdw %zmm0, %ymm0
; KNL-NEXT:    ## kill: def %xmm0 killed %xmm0 killed %ymm0
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_db_256:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovdw %ymm0, %xmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x = trunc <8 x i32> %i to <8 x i8>
  ret <8 x i8> %x
}

define void @trunc_db_256_mem(<8 x i32> %i, <8 x i8>* %res) #0 {
; KNL-LABEL: trunc_db_256_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovdw %zmm0, %ymm0
; KNL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; KNL-NEXT:    vmovq %xmm0, (%rdi)
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_db_256_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovdb %ymm0, (%rdi)
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
    %x = trunc <8 x i32> %i to <8 x i8>
    store <8 x i8> %x, <8 x i8>* %res
    ret void
}

define <4 x i8> @trunc_db_128(<4 x i32> %i) #0 {
; ALL-LABEL: trunc_db_128:
; ALL:       ## %bb.0:
; ALL-NEXT:    retq
  %x = trunc <4 x i32> %i to <4 x i8>
  ret <4 x i8> %x
}

define void @trunc_db_128_mem(<4 x i32> %i, <4 x i8>* %res) #0 {
; KNL-LABEL: trunc_db_128_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,12,u,u,u,u,u,u,u,u,u,u,u,u]
; KNL-NEXT:    vmovd %xmm0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_db_128_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovdb %xmm0, (%rdi)
; SKX-NEXT:    retq
    %x = trunc <4 x i32> %i to <4 x i8>
    store <4 x i8> %x, <4 x i8>* %res
    ret void
}

define <16 x i16> @trunc_dw_512(<16 x i32> %i) #0 {
; ALL-LABEL: trunc_dw_512:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovdw %zmm0, %ymm0
; ALL-NEXT:    retq
  %x = trunc <16 x i32> %i to <16 x i16>
  ret <16 x i16> %x
}

define void @trunc_dw_512_mem(<16 x i32> %i, <16 x i16>* %res) #0 {
; ALL-LABEL: trunc_dw_512_mem:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovdw %zmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
    %x = trunc <16 x i32> %i to <16 x i16>
    store <16 x i16> %x, <16 x i16>* %res
    ret void
}

define <8 x i16> @trunc_dw_256(<8 x i32> %i) #0 {
; KNL-LABEL: trunc_dw_256:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovdw %zmm0, %ymm0
; KNL-NEXT:    ## kill: def %xmm0 killed %xmm0 killed %ymm0
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_dw_256:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovdw %ymm0, %xmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x = trunc <8 x i32> %i to <8 x i16>
  ret <8 x i16> %x
}

define void @trunc_dw_256_mem(<8 x i32> %i, <8 x i16>* %res) #0 {
; KNL-LABEL: trunc_dw_256_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    ## kill: def %ymm0 killed %ymm0 def %zmm0
; KNL-NEXT:    vpmovdw %zmm0, %ymm0
; KNL-NEXT:    vmovdqa %xmm0, (%rdi)
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_dw_256_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovdw %ymm0, (%rdi)
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
    %x = trunc <8 x i32> %i to <8 x i16>
    store <8 x i16> %x, <8 x i16>* %res
    ret void
}

define void @trunc_dw_128_mem(<4 x i32> %i, <4 x i16>* %res) #0 {
; KNL-LABEL: trunc_dw_128_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; KNL-NEXT:    vmovq %xmm0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_dw_128_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovdw %xmm0, (%rdi)
; SKX-NEXT:    retq
    %x = trunc <4 x i32> %i to <4 x i16>
    store <4 x i16> %x, <4 x i16>* %res
    ret void
}

define <32 x i8> @trunc_wb_512(<32 x i16> %i) #0 {
; KNL-LABEL: trunc_wb_512:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpmovsxwd %ymm0, %zmm0
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    vpmovsxwd %ymm1, %zmm1
; KNL-NEXT:    vpmovdb %zmm1, %xmm1
; KNL-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_wb_512:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovwb %zmm0, %ymm0
; SKX-NEXT:    retq
  %x = trunc <32 x i16> %i to <32 x i8>
  ret <32 x i8> %x
}

define void @trunc_wb_512_mem(<32 x i16> %i, <32 x i8>* %res) #0 {
; KNL-LABEL: trunc_wb_512_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpmovsxwd %ymm0, %zmm0
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    vpmovsxwd %ymm1, %zmm1
; KNL-NEXT:    vpmovdb %zmm1, %xmm1
; KNL-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; KNL-NEXT:    vmovdqa %ymm0, (%rdi)
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_wb_512_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovwb %zmm0, (%rdi)
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
    %x = trunc <32 x i16> %i to <32 x i8>
    store <32 x i8> %x, <32 x i8>* %res
    ret void
}

define <16 x i8> @trunc_wb_256(<16 x i16> %i) #0 {
; KNL-LABEL: trunc_wb_256:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpmovsxwd %ymm0, %zmm0
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_wb_256:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovwb %ymm0, %xmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x = trunc <16 x i16> %i to <16 x i8>
  ret <16 x i8> %x
}

define void @trunc_wb_256_mem(<16 x i16> %i, <16 x i8>* %res) #0 {
; KNL-LABEL: trunc_wb_256_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpmovsxwd %ymm0, %zmm0
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    vmovdqa %xmm0, (%rdi)
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_wb_256_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovwb %ymm0, (%rdi)
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
    %x = trunc <16 x i16> %i to <16 x i8>
    store <16 x i8> %x, <16 x i8>* %res
    ret void
}

define <8 x i8> @trunc_wb_128(<8 x i16> %i) #0 {
; ALL-LABEL: trunc_wb_128:
; ALL:       ## %bb.0:
; ALL-NEXT:    retq
  %x = trunc <8 x i16> %i to <8 x i8>
  ret <8 x i8> %x
}

define void @trunc_wb_128_mem(<8 x i16> %i, <8 x i8>* %res) #0 {
; KNL-LABEL: trunc_wb_128_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u]
; KNL-NEXT:    vmovq %xmm0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: trunc_wb_128_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovwb %xmm0, (%rdi)
; SKX-NEXT:    retq
    %x = trunc <8 x i16> %i to <8 x i8>
    store <8 x i8> %x, <8 x i8>* %res
    ret void
}


define void @usat_trunc_wb_256_mem(<16 x i16> %i, <16 x i8>* %res) {
; KNL-LABEL: usat_trunc_wb_256_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpminuw {{.*}}(%rip), %ymm0, %ymm0
; KNL-NEXT:    vpmovsxwd %ymm0, %zmm0
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    vmovdqu %xmm0, (%rdi)
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: usat_trunc_wb_256_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovuswb %ymm0, (%rdi)
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x3 = icmp ult <16 x i16> %i, <i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255>
  %x5 = select <16 x i1> %x3, <16 x i16> %i, <16 x i16> <i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255>
  %x6 = trunc <16 x i16> %x5 to <16 x i8>
  store <16 x i8> %x6, <16 x i8>* %res, align 1
  ret void
}

define <16 x i8> @usat_trunc_wb_256(<16 x i16> %i) {
; KNL-LABEL: usat_trunc_wb_256:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpminuw {{.*}}(%rip), %ymm0, %ymm0
; KNL-NEXT:    vpmovsxwd %ymm0, %zmm0
; KNL-NEXT:    vpmovdb %zmm0, %xmm0
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: usat_trunc_wb_256:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovuswb %ymm0, %xmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x3 = icmp ult <16 x i16> %i, <i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255>
  %x5 = select <16 x i1> %x3, <16 x i16> %i, <16 x i16> <i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255>
  %x6 = trunc <16 x i16> %x5 to <16 x i8>
  ret <16 x i8> %x6
}

define void @usat_trunc_wb_128_mem(<8 x i16> %i, <8 x i8>* %res) {
; KNL-LABEL: usat_trunc_wb_128_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpminuw {{.*}}(%rip), %xmm0, %xmm0
; KNL-NEXT:    vpackuswb %xmm0, %xmm0, %xmm0
; KNL-NEXT:    vmovq %xmm0, (%rdi)
; KNL-NEXT:    retq
;
; SKX-LABEL: usat_trunc_wb_128_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpmovuswb %xmm0, (%rdi)
; SKX-NEXT:    retq
  %x3 = icmp ult <8 x i16> %i, <i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255>
  %x5 = select <8 x i1> %x3, <8 x i16> %i, <8 x i16> <i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255>
  %x6 = trunc <8 x i16> %x5 to <8 x i8>
  store <8 x i8> %x6, <8 x i8>* %res, align 1
  ret void
}

define void @usat_trunc_db_512_mem(<16 x i32> %i, <16 x i8>* %res) {
; ALL-LABEL: usat_trunc_db_512_mem:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovusdb %zmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %x3 = icmp ult <16 x i32> %i, <i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255>
  %x5 = select <16 x i1> %x3, <16 x i32> %i, <16 x i32> <i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255>
  %x6 = trunc <16 x i32> %x5 to <16 x i8>
  store <16 x i8> %x6, <16 x i8>* %res, align 1
  ret void
}

define void @usat_trunc_qb_512_mem(<8 x i64> %i, <8 x i8>* %res) {
; ALL-LABEL: usat_trunc_qb_512_mem:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovusqb %zmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %x3 = icmp ult <8 x i64> %i, <i64 255, i64 255, i64 255, i64 255, i64 255, i64 255, i64 255, i64 255>
  %x5 = select <8 x i1> %x3, <8 x i64> %i, <8 x i64> <i64 255, i64 255, i64 255, i64 255, i64 255, i64 255, i64 255, i64 255>
  %x6 = trunc <8 x i64> %x5 to <8 x i8>
  store <8 x i8> %x6, <8 x i8>* %res, align 1
  ret void
}

define void @usat_trunc_qd_512_mem(<8 x i64> %i, <8 x i32>* %res) {
; ALL-LABEL: usat_trunc_qd_512_mem:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovusqd %zmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %x3 = icmp ult <8 x i64> %i, <i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295>
  %x5 = select <8 x i1> %x3, <8 x i64> %i, <8 x i64> <i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295, i64 4294967295>
  %x6 = trunc <8 x i64> %x5 to <8 x i32>
  store <8 x i32> %x6, <8 x i32>* %res, align 1
  ret void
}

define void @usat_trunc_qw_512_mem(<8 x i64> %i, <8 x i16>* %res) {
; ALL-LABEL: usat_trunc_qw_512_mem:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovusqw %zmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %x3 = icmp ult <8 x i64> %i, <i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535>
  %x5 = select <8 x i1> %x3, <8 x i64> %i, <8 x i64> <i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535>
  %x6 = trunc <8 x i64> %x5 to <8 x i16>
  store <8 x i16> %x6, <8 x i16>* %res, align 1
  ret void
}

define <32 x i8> @usat_trunc_db_1024(<32 x i32> %i) {
; KNL-LABEL: usat_trunc_db_1024:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpmovusdb %zmm0, %xmm0
; KNL-NEXT:    vpmovusdb %zmm1, %xmm1
; KNL-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; KNL-NEXT:    retq
;
; SKX-LABEL: usat_trunc_db_1024:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpbroadcastd {{.*#+}} zmm2 = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; SKX-NEXT:    vpminud %zmm2, %zmm1, %zmm1
; SKX-NEXT:    vpminud %zmm2, %zmm0, %zmm0
; SKX-NEXT:    vpmovdw %zmm0, %ymm0
; SKX-NEXT:    vpmovdw %zmm1, %ymm1
; SKX-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; SKX-NEXT:    vpmovwb %zmm0, %ymm0
; SKX-NEXT:    retq
  %x3 = icmp ult <32 x i32> %i, <i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255>
  %x5 = select <32 x i1> %x3, <32 x i32> %i, <32 x i32> <i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255>
  %x6 = trunc <32 x i32> %x5 to <32 x i8>
  ret <32 x i8> %x6
}

define void @usat_trunc_db_1024_mem(<32 x i32> %i, <32 x i8>* %p) {
; KNL-LABEL: usat_trunc_db_1024_mem:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpmovusdb %zmm0, %xmm0
; KNL-NEXT:    vpmovusdb %zmm1, %xmm1
; KNL-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; KNL-NEXT:    vmovdqu %ymm0, (%rdi)
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: usat_trunc_db_1024_mem:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpbroadcastd {{.*#+}} zmm2 = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
; SKX-NEXT:    vpminud %zmm2, %zmm1, %zmm1
; SKX-NEXT:    vpminud %zmm2, %zmm0, %zmm0
; SKX-NEXT:    vpmovdw %zmm0, %ymm0
; SKX-NEXT:    vpmovdw %zmm1, %ymm1
; SKX-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; SKX-NEXT:    vpmovwb %zmm0, (%rdi)
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x3 = icmp ult <32 x i32> %i, <i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255>
  %x5 = select <32 x i1> %x3, <32 x i32> %i, <32 x i32> <i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255>
  %x6 = trunc <32 x i32> %x5 to <32 x i8>
  store <32 x i8>%x6, <32 x i8>* %p, align 1
  ret void
}

define <16 x i16> @usat_trunc_dw_512(<16 x i32> %i) {
; ALL-LABEL: usat_trunc_dw_512:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpmovusdw %zmm0, %ymm0
; ALL-NEXT:    retq
  %x3 = icmp ult <16 x i32> %i, <i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535>
  %x5 = select <16 x i1> %x3, <16 x i32> %i, <16 x i32> <i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535, i32 65535>
  %x6 = trunc <16 x i32> %x5 to <16 x i16>
  ret <16 x i16> %x6
}

define <8 x i8> @usat_trunc_wb_128(<8 x i16> %i) {
; ALL-LABEL: usat_trunc_wb_128:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpminuw {{.*}}(%rip), %xmm0, %xmm0
; ALL-NEXT:    retq
  %x3 = icmp ult <8 x i16> %i, <i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255>
  %x5 = select <8 x i1> %x3, <8 x i16> %i, <8 x i16> <i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255, i16 255>
  %x6 = trunc <8 x i16> %x5 to <8 x i8>
  ret <8 x i8>%x6
}

define <16 x i16> @usat_trunc_qw_1024(<16 x i64> %i) {
; ALL-LABEL: usat_trunc_qw_1024:
; ALL:       ## %bb.0:
; ALL-NEXT:    vpbroadcastq {{.*#+}} zmm2 = [65535,65535,65535,65535,65535,65535,65535,65535]
; ALL-NEXT:    vpminuq %zmm2, %zmm1, %zmm1
; ALL-NEXT:    vpminuq %zmm2, %zmm0, %zmm0
; ALL-NEXT:    vpmovqd %zmm0, %ymm0
; ALL-NEXT:    vpmovqd %zmm1, %ymm1
; ALL-NEXT:    vinserti64x4 $1, %ymm1, %zmm0, %zmm0
; ALL-NEXT:    vpmovdw %zmm0, %ymm0
; ALL-NEXT:    retq
  %x3 = icmp ult <16 x i64> %i, <i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535>
  %x5 = select <16 x i1> %x3, <16 x i64> %i, <16 x i64> <i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535, i64 65535>
  %x6 = trunc <16 x i64> %x5 to <16 x i16>
  ret <16 x i16> %x6
}

define <16 x i8> @usat_trunc_db_256(<8 x i32> %x) {
; KNL-LABEL: usat_trunc_db_256:
; KNL:       ## %bb.0:
; KNL-NEXT:    vpbroadcastd {{.*#+}} ymm1 = [255,255,255,255,255,255,255,255]
; KNL-NEXT:    vpminud %ymm1, %ymm0, %ymm0
; KNL-NEXT:    vpmovdw %zmm0, %ymm0
; KNL-NEXT:    vpackuswb %xmm0, %xmm0, %xmm0
; KNL-NEXT:    vzeroupper
; KNL-NEXT:    retq
;
; SKX-LABEL: usat_trunc_db_256:
; SKX:       ## %bb.0:
; SKX-NEXT:    vpminud {{.*}}(%rip){1to8}, %ymm0, %ymm0
; SKX-NEXT:    vpmovdw %ymm0, %xmm0
; SKX-NEXT:    vpackuswb %xmm0, %xmm0, %xmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %tmp1 = icmp ult <8 x i32> %x, <i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255>
  %tmp2 = select <8 x i1> %tmp1, <8 x i32> %x, <8 x i32> <i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255, i32 255>
  %tmp3 = trunc <8 x i32> %tmp2 to <8 x i8>
  %tmp4 = shufflevector <8 x i8> %tmp3, <8 x i8> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %tmp4
}

