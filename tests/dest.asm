; Destination Addressing Modes

; Direct
mov A, R0; 0
; A[0] = Address of B[0] = 38
mov X, (R0)+; 2 
; A[1] = Address of B[0] = 38
mov X, (R0)+; 4
; A[1] = Address of B[1] = 39
mov Y, -(R0); 6
; A[2] = Address of B[2] = 40
mov Z, 1(R0); 8

; Indirect
mov A, R0; 11
; B[0] = Address of B[0] = 38
mov X, @(R0)+; 13
; B[1] = Address of B[0] = 38
mov X, @(R0)+; 15
; B[1] = Address of B[1] = 39
mov Y, @-(R0); 17
; B[2] = Address of B[2] = 40
mov Z, @1(R0); 19

mov A, R0; 22, R0 = 34
mov (R0)+, R1; 24, R1 = 38
mov (R0)+, R1; 25, R1 = 39
mov (R0)+, R1; 26, R1 = 40

mov B, R0; 27, R0 = 38
mov (R0)+, R1; 29, R1 = 38
mov (R0)+, R1; 30, R1 = 39
mov (R0)+, R1; 31, R1 = 40
HLT

; Starting address, values...
define A  34,0,0,0 ;33
; Starting address, values...
define B  38,0,0,0 ;37

define X 38 ; 41, Address of B[0]
define Y 39 ; 42, Address of B[1]
define Z 40 ; 43, Address of B[2]
