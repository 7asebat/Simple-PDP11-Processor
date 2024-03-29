; SOURCE ADDRESSING MODES
MOV N, R0       ; address 0 r0 = 18
MOV #10, R1     ; address 2 r1 = 10
MOV (R0)+, R3   ; address 4 r3 = 21, r0 = 19
MOV -(R0), R4   ; address 5 r0 = 18, r4 = 21
MOV 2(R0), R5   ; address 6 r5 = 22
MOV @R0, R2     ; address 8 r2 = 21
MOV @(R0)+, R3  ; address 9 r3 = 9, r0 = 19
MOV @-(R0), R4  ; address 10 r0 = 18, r4 = 9
MOV @2(R0), R5  ; address 11 r5 = 10
HLT             ; address 13

Define N 18     ; address 14
Define M 5      ; address 15
Define X 1      ; address 16
Define A 21     ; address 17
Define B 21     ; address 18
Define C 23     ; address 19
Define Q 22     ; address 20
Define P 9      ; address 21
Define R 10     ; address 22