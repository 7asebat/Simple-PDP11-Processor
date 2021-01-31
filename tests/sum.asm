mov #0x05, R0
; Load array's effective address
mov #array, R1
mov #0, R2

SUM_LOOP:
add (R1)+, R2
dec R0
bne SUM_LOOP

HLT

; Spaces and bases are optional
define array 0b1, 0o2, 0x3, 4,5