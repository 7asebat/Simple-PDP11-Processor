Library ieee;
Use ieee.std_logic_1164.all;

ENTITY nDFF IS 
	GENERIC(n: INTEGER := 16);
	PORT(
		clk, en, R: IN std_logic;
		D: IN std_logic_vector(n-1 DOWNTO 0);
		Q: OUT std_logic_vector(n-1 DOWNTO 0)
	); 
END ENTITY;

ARCHITECTURE main OF nDFF IS
BEGIN

PROCESS(clk, R)
BEGIN
	IF (R = '1') THEN
		Q <= (OTHERS => '0');
	ELSIF (rising_edge(clk) AND en = '1') THEN
		Q <= D;
	END IF;
END PROCESS;

END ARCHITECTURE;