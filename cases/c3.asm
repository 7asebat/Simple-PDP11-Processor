0: Mov #100,R6
2: Mov #12,R2
4: Mov R6,@R2
5: Add R2,@R2
Loopa:
6: INc R4
7: Inc R4
8: NOP
9: CMP R4,R4
10: BNE loopa
11: HLT

12: DEFINE M 10


Mov #100, R6:
R6 = 100
Mov #11, R2:
R2 = 11
Mov R6, @R2:
R6 = 10
Add R2, @R2:
R2 = 21
INC R4:
R4 = 1
INC R4:
R4 = 1
NOP:
CMP R4, R4:
E flag = 1
BNE loopa:
will not branch