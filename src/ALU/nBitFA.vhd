Library ieee;
Use ieee.std_logic_1164.all;

ENTITY nBitFA IS 
	GENERIC (n: INTEGER := 16);
	PORT(
		A, B: IN std_logic_vector(n-1 DOWNTO 0);
		Cin: IN std_logic;
		S: OUT std_logic_vector(n-1 DOWNTO 0);
		Cout: OUT std_logic
	);

END ENTITY;

ARCHITECTURE default OF nBitFA IS
COMPONENT oneBitFA IS PORT(
		A, B, Cin: IN std_logic;
		S, Cout: OUT std_logic
	);
END COMPONENT;
SIGNAL temp: std_logic_vector(n-1 DOWNTO 0);
BEGIN
f0: oneBitFA PORT MAP(A(0), B(0), Cin, S(0), temp(0));

generateNextFAs: FOR i IN 1 TO n-1 GENERATE
	fx: oneBitFA PORT MAP (A(i), B(i), temp(i-1), S(i), temp(i));
END GENERATE;

Cout <= temp(n-1);

END ARCHITECTURE;