0: Mov #100,R6
2: Mov #10,R2
4: Mov R6,4(R2)
6: Add R2,4(R2)
Loopa:
8: INc R4
9: Inc R4
10: NOP
11:CMP R4,R4
12: BNE loopa
13: HLT

DEFINE M 10
; 
; Mov #100, R6:
; R6 = 100
; Mov #10, R2:
; R2 = 10
; Mov R6, 4(R2):
; R6 = 20
; Add R2, 4(R2):
; R2 = 23
; INC R4:
; R4 = 1
; INC R4:
; R4 = 2
; NOP:
; CMP R4, R4:
; E flag = 1
; BNE loopa:
; will not branch