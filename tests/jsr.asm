mov #255, R1 ; 0
mov #255, R2 ; 2
JSR LABEL    ; 4
mov #255, R3 ; 6
JSR LABEL2   ; 8
HLT          ; 10
LABEL:
mov #255, R4 ; 11
RTS          ; 13
LABEL2:
mov #255, R0 ; 14
RTS          ; 16