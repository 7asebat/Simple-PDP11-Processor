inc R0      ; 0
cmp #1, r0  ; 1
blo BREAK   ; 3

INTERRUPT   ; 4, INTERRUPT_ADDRESS is set to 0, the program will loop twice and exit
HLT         ; 5

BREAK:
IRET        ; 6