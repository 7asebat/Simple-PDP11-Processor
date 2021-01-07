Library ieee;
Use ieee.std_logic_1164.all;

ENTITY partC IS 
GENERIC (n: INTEGER := 16);
PORT(
	A: IN std_logic_vector(n-1 DOWNTO 0);
	Cin: IN std_logic;
	S: IN std_logic_vector(1 DOWNTO 0);
	F: OUT std_logic_vector(n-1 DOWNTO 0);
	Cout: OUT std_logic);
END ENTITY;

ARCHITECTURE default OF partC IS
BEGIN
 F <= 	'0' & A(n-1 DOWNTO 1) 	WHEN S="00"
	ELSE 	A(0) & A(n-1 DOWNTO 1) WHEN S="01"
	ELSE	Cin & A(n-1 DOWNTO 1) 	WHEN S="10"
	ELSE	A(n-1) & A(n-1 DOWNTO 1) WHEN S="11"; 

--Cout<=	A(0) WHEN S="00"
--	ELSE	A(0) WHEN S="01"
--	ELSE 	A(0) WHEN S="10"
--	ELSE	A(0) WHEN S="11"

Cout <= A(0); -- Above is simplified to this
END ARCHITECTURE;