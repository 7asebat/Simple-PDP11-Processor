inc R0      ; 0
cmp #1, r0  ; 1
blo BREAK   ; 3

; INTERRUPT SIGNAL RAISED HERE
HLT         ; 4

BREAK:
IRET        ; 5