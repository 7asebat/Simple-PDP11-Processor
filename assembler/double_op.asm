MOV #5, R0
; mov
MOV R0, R1      ; R1 = 5
; add
ADD R0, RESADD
MOV RESADD, R1 ; R1 = 12
; adc
ADC R0, RESADC
MOV RESADC, R1 ; R1 = 13
; sub
SUB R0, RESSUB  
MOV RESSUB, R1 ; R1 = 3
; sbc
SBC R0, RESSBC
MOV RESSBC, R1 ; R1 = 2
; and
AND R0, RESAND
MOV RESAND, R1 ; R1 = 4
; or
OR  R0, RESOR
MOV RESOR, R1  ; R1 = 7
; xor
XOR R0, RESXOR
MOV RESXOR, R1 ; R1 = 2
; cmp
CMP R0, RESCMPZ ; zero flag set
CMP R0, RESCMPN ; negative flag set
CMP R0, RESCMPC ; carry flag set

HLT

Define RESADD 7
Define RESADC 7
Define RESSUB 2
Define RESSBC 2
Define RESAND 4
Define RESOR  2
Define RESXOR 7
Define RESCMPZ 5
Define RESCMPN 7
Define RESCMPC 3