0: Mov #100,R6
2: Mov #14,R2
4: Mov @-(R2), R6
5: Add @-(R2), R2
Loopa:
6: Inc R4
7: Inc R4
8: NOP
9: CMP R4,R4
10: BNE loopa
11: HLT

DEFINE M 14
DEFINE N 15
DEFINE X 20
DEFINE Y 25

; Mov #100, R6:
; R6 = 100
; Mov #14, R2:
; R2 = 14
; Mov R6, @-(R2):
; R6 = 25, R2=13
; Add R2, @-(R2):
; R2 = 32
; INC R4:
; R4 = 1
; INC R4:
; R4 = 1
; NOP:
; CMP R4, R4:
; E flag = 1
; BNE loopa:
; will not branch