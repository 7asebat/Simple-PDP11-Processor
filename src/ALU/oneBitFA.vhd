Library ieee;
Use ieee.std_logic_1164.all;

ENTITY oneBitFA IS PORT(
		A, B, Cin: IN std_logic;
		S, Cout: OUT std_logic
	);
END ENTITY;

ARCHITECTURE default OF oneBitFA IS
BEGIN
S <= A xor B xor Cin;
Cout <= (A and B) or (Cin and (a xor b));
END ARCHITECTURE;
