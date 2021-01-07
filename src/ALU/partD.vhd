Library ieee;
Use ieee.std_logic_1164.all;

ENTITY partD IS 
GENERIC (n: INTEGER := 16);
PORT(
	A: IN std_logic_vector(n-1 DOWNTO 0);
	Cin: IN std_logic;
	S: IN std_logic_vector(1 DOWNTO 0);
	F: OUT std_logic_vector(n-1 DOWNTO 0);
	Cout: OUT std_logic
);
END ENTITY;

ARCHITECTURE default OF partD IS
BEGIN
 F <= 		A(14 DOWNTO 0) & '0' WHEN S="00"
	ELSE	A(14 DOWNTO 0) & A(n-1) WHEN S="01"
	ELSE	A(14 DOWNTO 0) & Cin WHEN S="10"
	ELSE	(OTHERS => '0') WHEN S="11"; 

Cout<=	A(n-1) WHEN S="00"
	ELSE	A(n-1) WHEN S="01"
	ELSE 	A(n-1) WHEN S="10"
	ELSE	'0' WHEN S="11";
END ARCHITECTURE;