MOV #1, R0  ; r0 = 1, address = 0
BR BR1      ; address = 2
MOV #2, R0  ; r0 should not be 1, address = 3
BR1:        ; address = 5
MOV #3, R0  ; r0 = 3, address = 6

CLR R1      ; r1 = 0, Z=1
BEQ BR2
MOV #4, R0  ; r0 should not be 4
BR2:
MOV #5, R0  ; r0 = 5

ADD #1, R1  ; r1 = 1, Z=0
BNE BR3
MOV #6, R0  ; r0 should not be 6
BR3:
MOV #7, R0  ; r0 = 7

MOV #5, R1  ; r1 = 5
MOV #6, R2  ; r2 = 6
CMP R1, R2  ; C = 0
BLO BR4
MOV #8, R0  ; r0 should not be 8
BR4:
MOV #9, R0  ; r0 = 9

MOV #6, R1  ; r1 = 6
MOV #6, R2  ; r2 = 6
CMP R1, R2  ; Z=0
BLS BR5
MOV #10, R0  ; r0 should not be 10
BR5:
MOV #11, R0  ; r0 = 11

MOV #5, R1  ; r1 = 5
MOV #6, R2  ; r2 = 6
CMP R1, R2  ; C = 0
BLS BR6
MOV #12, R0  ; r0 should not be 12
BR6:
MOV #13, R0  ; r0 = 13

MOV #7, R1  ; r1 = 7
MOV #6, R2  ; r2 = 6
CMP R1, R2  ; C = 1
BHI BR7
MOV #14, R0  ; r0 should not be 14
BR7:
MOV #15, R0  ; r0 = 15

MOV #7, R1  ; r1 = 7
MOV #6, R2  ; r2 = 6
CMP R1, R2  ; C = 1
BHS BR8
MOV #16, R0  ; r0 should not be 16
BR8:
MOV #17, R0  ; r0 = 17

MOV #6, R1  ; r1 = 7
MOV #6, R2  ; r2 = 6
CMP R1, R2  ; Z = 1
BHS BR9
MOV #18, R0  ; r0 should not be 18
BR9:
MOV #19, R0  ; r0 = 19

HLT ; address = 8