Mov #100,R6
Mov #20,R2
Mov R2, R6
And R2, R2
Loopa:
INc R4
Inc R4
NOP
CMP R4,R4
BNE loopa
HLT

; Mov #100, R6:
; R6 = 100
; Mov #20, R2:
; R2 = 20
; Mov R6, R2:
; R6 = 20
; And R2, R2:
; R2 = 20
; INC R4:
; R4 = 1
; INC R4:
; R4 = 2
; NOP:
; CMP R4, R4:
; E flag = 1
; BNE loopa:
; will not branch