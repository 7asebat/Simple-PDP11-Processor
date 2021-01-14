MOV #5, R0  ; R0 = 5

;inc
INC R0  ; R0 = 6

;dec
DEC R0  ; R0 = 5

;clr
CLR R0  ; R0 = 0

;inv
MOV #5, R0  ; R0 = 5
INV R0  ; R0 = b'1111 1111 1111 1010 == FFFA

;lsr
MOV #5, R0  ; R0 = 5
LSR R0  ; R0 = 2

;lsl
LSL R0  ; R0 = 4

; todo: asr, rol, ror