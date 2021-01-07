Library ieee;
Use ieee.std_logic_1164.all;

ENTITY partA IS 
	GENERIC(n: INTEGER := 16);
	PORT(
		A, B: IN std_logic_vector(n-1 DOWNTO 0);
		Cin: IN std_logic;
		S: IN std_logic_vector(1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0);
		Cout: OUT std_logic
	);
END ENTITY;

ARCHITECTURE default OF partA IS

COMPONENT nBitFA IS 
GENERIC (n: INTEGER := 16);
PORT(
	A, B: IN std_logic_vector(n-1 DOWNTO 0);
	Cin: IN std_logic;
	S: OUT std_logic_vector(n-1 DOWNTO 0);
	Cout: OUT std_logic
);
END COMPONENT;

SIGNAL op1: std_logic_vector(n-1 DOWNTO 0);
SIGNAL op2: std_logic_vector(n-1 DOWNTO 0);
SIGNAL op3: std_logic_vector(n-1 DOWNTO 0);
SIGNAL SCin: std_logic_vector(2 DOWNTO 0);
BEGIN

fa0: nBitFA GENERIC MAP(16) PORT MAP(op1, op2, Cin, F, Cout);

SCin <= S & Cin;

WITH SCin SELECT
	op1 <= (OTHERS=>'0') WHEN "111",
			A WHEN OTHERS;

WITH S SELECT
	op2 <=	(OTHERS => '0') WHEN "00",
			B(15 DOWNTO 0) WHEN "01",
			(not B(15 DOWNTO 0)) WHEN "10",
			(OTHERS=>'1') WHEN OTHERS;

END ARCHITECTURE;