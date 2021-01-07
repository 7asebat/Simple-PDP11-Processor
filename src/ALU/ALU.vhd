Library ieee;
Use ieee.std_logic_1164.all;

ENTITY ALU IS 
	GENERIC(n: INTEGER := 16);
	PORT(
			A, B: IN std_logic_vector(n-1 DOWNTO 0);
			S: IN std_logic_vector(3 DOWNTO 0);
			Cin: IN std_logic;
			F: OUT std_logic_vector(n-1 DOWNTO 0);
			Cout: OUT std_logic
	);
END ENTITY;

ARCHITECTURE default OF ALU IS
	COMPONENT partA IS
	GENERIC (n: INTEGER := 16);
	PORT(
		A, B: IN std_logic_vector(n-1 DOWNTO 0);
		Cin: IN std_logic;
		S: IN std_logic_vector(n-1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0);
		Cout: OUT std_logic
	);
	END COMPONENT;
	
	SIGNAL Cout0: std_logic;
	SIGNAL F0: std_logic_vector(n-1 DOWNTO 0);

	COMPONENT partB IS
	GENERIC (n: INTEGER := 16);
	PORT(
		A,B: IN std_logic_vector(n-1 DOWNTO 0);
		S: IN std_logic_vector(1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0)
	);
	END COMPONENT;

	SIGNAL F1: std_logic_vector(n-1 DOWNTO 0);

	COMPONENT partC IS 
	GENERIC (n: INTEGER := 16);
	PORT(
		A: IN std_logic_vector(n-1 DOWNTO 0);
		Cin: IN std_logic;
		S: IN std_logic_vector(1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0);
		Cout: OUT std_logic
	);
	END COMPONENT;

	SIGNAL F2: std_logic_vector(n-1 DOWNTO 0);
	SIGNAL Cout2: std_logic;

	COMPONENT partD IS 
	GENERIC (n: INTEGER := 16);
	PORT(
		A: IN std_logic_vector(n-1 DOWNTO 0);
		Cin: IN std_logic;
		S: IN std_logic_vector(1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0);
		Cout: OUT std_logic
	);
	END COMPONENT;

	SIGNAL F3: std_logic_vector(n-1 DOWNTO 0);
	SIGNAL Cout3: std_logic;

BEGIN

pA: partA GENERIC MAP(n) PORT MAP(A, B, Cin, S(1 DOWNTO 0), F0, Cout0);
pB: partB GENERIC MAP(n) PORT MAP(A, B, S(1 DOWNTO 0), F1);
pC: partC GENERIC MAP(n) PORT MAP(A, Cin, S(1 DOWNTO 0), F2, Cout2);
pD: partD GENERIC MAP(n) PORT MAP(A, Cin, S(1 DOWNTO 0), F3, Cout3);

WITH S(3 DOWNTO 2) SELECT
	F <= 	F0 WHEN "00",
			F1 WHEN "01",
			F2 WHEN "10",
			F3 WHEN "11",
			(OTHERS => 'U') WHEN OTHERS;

WITH S(3 DOWNTO 2) SELECT
	Cout<=Cout0 WHEN "00",
			Cout2 WHEN "10",
			Cout3 WHEN "11",
			'U' WHEN OTHERS;

END ARCHITECTURE;