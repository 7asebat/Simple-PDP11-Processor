mov #5, R0 ; 0
mov #6, R1 ; 2

cmp R0, R1 ; 4, CARRY = 0
adc R0, R0 ; 5, R0 = 10

cmp R0, R1 ; 6, CARRY = 1
sbc R0, R1 ; 7, R1 = 3
HLT        ; 8