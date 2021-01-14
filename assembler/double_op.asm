MOV #5, R0
; mov
MOV R0, R1      ; R1 = 5
; add
ADD R0, RES_ADD
MOV RES_ADD, R1 ; R1 = 12
; adc
ADC R0, RES_ADC
MOV RES_ADC, R1 ; R1 = 13
; sub
SUB R0, RES_SUB  
MOV RES_SUB, R1 ; R1 = 3
; sbc
SBC R0, RES_SBC
MOV RES_SBC, R1 ; R1 = 2
; and
AND R0, RES_AND
MOV RES_AND, R1 ; R1 = 4
; or
OR  R0, RES_OR
MOV RES_OR, R1  ; R1 = 7
; xor
XOR R0, RES_XOR
MOV RES_XOR, R1 ; R1 = 2
; cmp
CMP R0, RES_CMP_Z ; zero flag set
CMP R0, RES_CMP_C ; carry flag set
CMP R0, RES_CMP_N ; negative flag set

Define RES_ADD 7
Define RES_ADC 7
Define RES_SUB 2
Define RES_SBC 2
Define RES_AND 4
Define RES_OR  2
Define RES_XOR 7
Define RES_CMP_Z 5
Define RES_CMP_N 7
Define RES_CMP_C 3
