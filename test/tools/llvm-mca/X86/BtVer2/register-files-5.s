# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -iterations=1 -resource-pressure=false -instruction-info=false -dispatch-stats -register-file-stats -timeline < %s | FileCheck %s

  vdivps %ymm0, %ymm0, %ymm1
  vaddps %ymm0, %ymm0, %ymm2
  vaddps %ymm0, %ymm0, %ymm3
  vaddps %ymm0, %ymm0, %ymm4
  vaddps %ymm0, %ymm0, %ymm5
  vaddps %ymm0, %ymm0, %ymm6
  vaddps %ymm0, %ymm0, %ymm7
  vaddps %ymm0, %ymm0, %ymm8
  vaddps %ymm0, %ymm0, %ymm9
  vaddps %ymm0, %ymm0, %ymm10
  vaddps %ymm0, %ymm0, %ymm11
  vaddps %ymm0, %ymm0, %ymm12
  vaddps %ymm0, %ymm0, %ymm13
  vaddps %ymm0, %ymm0, %ymm14
  vaddps %ymm0, %ymm0, %ymm15
  vaddps %ymm2, %ymm0, %ymm0
  vaddps %ymm2, %ymm0, %ymm3
  vaddps %ymm2, %ymm0, %ymm4
  vaddps %ymm2, %ymm0, %ymm5
  vaddps %ymm2, %ymm0, %ymm6
  vaddps %ymm2, %ymm0, %ymm7
  vaddps %ymm2, %ymm0, %ymm8
  vaddps %ymm2, %ymm0, %ymm9
  vaddps %ymm2, %ymm0, %ymm10
  vaddps %ymm2, %ymm0, %ymm11
  vaddps %ymm2, %ymm0, %ymm12
  vaddps %ymm2, %ymm0, %ymm13
  vaddps %ymm2, %ymm0, %ymm14
  vaddps %ymm2, %ymm0, %ymm15
  vaddps %ymm3, %ymm0, %ymm2
  vaddps %ymm3, %ymm0, %ymm4
  vaddps %ymm3, %ymm0, %ymm5
  vaddps %ymm3, %ymm0, %ymm6

# CHECK:      Iterations:     1
# CHECK-NEXT: Instructions:   33
# CHECK-NEXT: Total Cycles:   70
# CHECK-NEXT: Dispatch Width: 2
# CHECK-NEXT: IPC:            0.47

# CHECK:      Dynamic Dispatch Stall Cycles:
# CHECK-NEXT: RAT     - Register unavailable:                      0
# CHECK-NEXT: RCU     - Retire tokens unavailable:                 8
# CHECK-NEXT: SCHEDQ  - Scheduler full:                            0
# CHECK-NEXT: LQ      - Load queue full:                           0
# CHECK-NEXT: SQ      - Store queue full:                          0
# CHECK-NEXT: GROUP   - Static restrictions on the dispatch group: 0

# CHECK:      Dispatch Logic - number of cycles where we saw N instructions dispatched:
# CHECK-NEXT: [# dispatched], [# cycles]
# CHECK-NEXT:  0,              37  (52.9%)
# CHECK-NEXT:  1,              33  (47.1%)

# CHECK:      Register File statistics:
# CHECK-NEXT: Total number of mappings created:    66
# CHECK-NEXT: Max number of mappings used:         64

# CHECK:      *  Register File #1 -- FpuPRF:
# CHECK-NEXT:    Number of physical registers:     72
# CHECK-NEXT:    Total number of mappings created: 66
# CHECK-NEXT:    Max number of mappings used:      64

# CHECK:      *  Register File #2 -- IntegerPRF:
# CHECK-NEXT:    Number of physical registers:     64
# CHECK-NEXT:    Total number of mappings created: 0
# CHECK-NEXT:    Max number of mappings used:      0

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123456789          0123456789          0123456789
# CHECK-NEXT: Index     0123456789          0123456789          0123456789          0123456789

# CHECK:      [0,0]     DeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeER    .    .    .    .    .   .   vdivps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: [0,1]     .DeeeE----------------------------------R    .    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm2
# CHECK-NEXT: [0,2]     . D=eeeE---------------------------------R   .    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm3
# CHECK-NEXT: [0,3]     .  D==eeeE-------------------------------R   .    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm4
# CHECK-NEXT: [0,4]     .   D===eeeE------------------------------R  .    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm5
# CHECK-NEXT: [0,5]     .    D====eeeE----------------------------R  .    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm6
# CHECK-NEXT: [0,6]     .    .D=====eeeE---------------------------R .    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm7
# CHECK-NEXT: [0,7]     .    . D======eeeE-------------------------R .    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm8
# CHECK-NEXT: [0,8]     .    .  D=======eeeE------------------------R.    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm9
# CHECK-NEXT: [0,9]     .    .   D========eeeE----------------------R.    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm10
# CHECK-NEXT: [0,10]    .    .    D=========eeeE---------------------R    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm11
# CHECK-NEXT: [0,11]    .    .    .D==========eeeE-------------------R    .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm12
# CHECK-NEXT: [0,12]    .    .    . D===========eeeE------------------R   .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm13
# CHECK-NEXT: [0,13]    .    .    .  D============eeeE----------------R   .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm14
# CHECK-NEXT: [0,14]    .    .    .   D=============eeeE---------------R  .    .    .    .   .   vaddps	%ymm0, %ymm0, %ymm15
# CHECK-NEXT: [0,15]    .    .    .    D==============eeeE-------------R  .    .    .    .   .   vaddps	%ymm2, %ymm0, %ymm0
# CHECK-NEXT: [0,16]    .    .    .    .D================eeeE-----------R .    .    .    .   .   vaddps	%ymm2, %ymm0, %ymm3
# CHECK-NEXT: [0,17]    .    .    .    . D=================eeeE---------R .    .    .    .   .   vaddps	%ymm2, %ymm0, %ymm4
# CHECK-NEXT: [0,18]    .    .    .    .  D==================eeeE--------R.    .    .    .   .   vaddps	%ymm2, %ymm0, %ymm5
# CHECK-NEXT: [0,19]    .    .    .    .   D===================eeeE------R.    .    .    .   .   vaddps	%ymm2, %ymm0, %ymm6
# CHECK-NEXT: [0,20]    .    .    .    .    D====================eeeE-----R    .    .    .   .   vaddps	%ymm2, %ymm0, %ymm7
# CHECK-NEXT: [0,21]    .    .    .    .    .D=====================eeeE---R    .    .    .   .   vaddps	%ymm2, %ymm0, %ymm8
# CHECK-NEXT: [0,22]    .    .    .    .    . D======================eeeE--R   .    .    .   .   vaddps	%ymm2, %ymm0, %ymm9
# CHECK-NEXT: [0,23]    .    .    .    .    .  D=======================eeeER   .    .    .   .   vaddps	%ymm2, %ymm0, %ymm10
# CHECK-NEXT: [0,24]    .    .    .    .    .   D========================eeeER .    .    .   .   vaddps	%ymm2, %ymm0, %ymm11
# CHECK-NEXT: [0,25]    .    .    .    .    .    D=========================eeeER    .    .   .   vaddps	%ymm2, %ymm0, %ymm12
# CHECK-NEXT: [0,26]    .    .    .    .    .    .D==========================eeeER  .    .   .   vaddps	%ymm2, %ymm0, %ymm13
# CHECK-NEXT: [0,27]    .    .    .    .    .    . D===========================eeeER.    .   .   vaddps	%ymm2, %ymm0, %ymm14
# CHECK-NEXT: [0,28]    .    .    .    .    .    .  D============================eeeER   .   .   vaddps	%ymm2, %ymm0, %ymm15
# CHECK-NEXT: [0,29]    .    .    .    .    .    .   D=============================eeeER .   .   vaddps	%ymm3, %ymm0, %ymm2
# CHECK-NEXT: [0,30]    .    .    .    .    .    .    D==============================eeeER   .   vaddps	%ymm3, %ymm0, %ymm4
# CHECK-NEXT: [0,31]    .    .    .    .    .    .    .D===============================eeeER .   vaddps	%ymm3, %ymm0, %ymm5
# CHECK-NEXT: [0,32]    .    .    .    .    .    .    .    .    D========================eeeER   vaddps	%ymm3, %ymm0, %ymm6

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       vdivps	%ymm0, %ymm0, %ymm1
# CHECK-NEXT: 1.     1     1.0    1.0    34.0      vaddps	%ymm0, %ymm0, %ymm2
# CHECK-NEXT: 2.     1     2.0    2.0    33.0      vaddps	%ymm0, %ymm0, %ymm3
# CHECK-NEXT: 3.     1     3.0    3.0    31.0      vaddps	%ymm0, %ymm0, %ymm4
# CHECK-NEXT: 4.     1     4.0    4.0    30.0      vaddps	%ymm0, %ymm0, %ymm5
# CHECK-NEXT: 5.     1     5.0    5.0    28.0      vaddps	%ymm0, %ymm0, %ymm6
# CHECK-NEXT: 6.     1     6.0    6.0    27.0      vaddps	%ymm0, %ymm0, %ymm7
# CHECK-NEXT: 7.     1     7.0    7.0    25.0      vaddps	%ymm0, %ymm0, %ymm8
# CHECK-NEXT: 8.     1     8.0    8.0    24.0      vaddps	%ymm0, %ymm0, %ymm9
# CHECK-NEXT: 9.     1     9.0    9.0    22.0      vaddps	%ymm0, %ymm0, %ymm10
# CHECK-NEXT: 10.    1     10.0   10.0   21.0      vaddps	%ymm0, %ymm0, %ymm11
# CHECK-NEXT: 11.    1     11.0   11.0   19.0      vaddps	%ymm0, %ymm0, %ymm12
# CHECK-NEXT: 12.    1     12.0   12.0   18.0      vaddps	%ymm0, %ymm0, %ymm13
# CHECK-NEXT: 13.    1     13.0   13.0   16.0      vaddps	%ymm0, %ymm0, %ymm14
# CHECK-NEXT: 14.    1     14.0   14.0   15.0      vaddps	%ymm0, %ymm0, %ymm15
# CHECK-NEXT: 15.    1     15.0   15.0   13.0      vaddps	%ymm2, %ymm0, %ymm0
# CHECK-NEXT: 16.    1     17.0   0.0    11.0      vaddps	%ymm2, %ymm0, %ymm3
# CHECK-NEXT: 17.    1     18.0   2.0    9.0       vaddps	%ymm2, %ymm0, %ymm4
# CHECK-NEXT: 18.    1     19.0   4.0    8.0       vaddps	%ymm2, %ymm0, %ymm5
# CHECK-NEXT: 19.    1     20.0   6.0    6.0       vaddps	%ymm2, %ymm0, %ymm6
# CHECK-NEXT: 20.    1     21.0   8.0    5.0       vaddps	%ymm2, %ymm0, %ymm7
# CHECK-NEXT: 21.    1     22.0   10.0   3.0       vaddps	%ymm2, %ymm0, %ymm8
# CHECK-NEXT: 22.    1     23.0   12.0   2.0       vaddps	%ymm2, %ymm0, %ymm9
# CHECK-NEXT: 23.    1     24.0   14.0   0.0       vaddps	%ymm2, %ymm0, %ymm10
# CHECK-NEXT: 24.    1     25.0   16.0   0.0       vaddps	%ymm2, %ymm0, %ymm11
# CHECK-NEXT: 25.    1     26.0   18.0   0.0       vaddps	%ymm2, %ymm0, %ymm12
# CHECK-NEXT: 26.    1     27.0   20.0   0.0       vaddps	%ymm2, %ymm0, %ymm13
# CHECK-NEXT: 27.    1     28.0   22.0   0.0       vaddps	%ymm2, %ymm0, %ymm14
# CHECK-NEXT: 28.    1     29.0   24.0   0.0       vaddps	%ymm2, %ymm0, %ymm15
# CHECK-NEXT: 29.    1     30.0   23.0   0.0       vaddps	%ymm3, %ymm0, %ymm2
# CHECK-NEXT: 30.    1     31.0   25.0   0.0       vaddps	%ymm3, %ymm0, %ymm4
# CHECK-NEXT: 31.    1     32.0   27.0   0.0       vaddps	%ymm3, %ymm0, %ymm5
# CHECK-NEXT: 32.    1     25.0   25.0   0.0       vaddps	%ymm3, %ymm0, %ymm6

