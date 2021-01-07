LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY nDFF_TB IS
END nDFF_TB;

ARCHITECTURE main OF nDFF_TB IS
	CONSTANT testcases_count: INTEGER := 4;
	CONSTANT DFF_size: INTEGER := 16;

	TYPE typeD IS ARRAY (0 TO testcases_count-1) of std_logic_vector(DFF_size-1 downto 0);
	TYPE typeEn IS ARRAY (0 TO testcases_count-1) of std_logic;
	TYPE typeR IS ARRAY (0 TO testcases_count-1) of std_logic;
	TYPE typeQ IS ARRAY (0 TO testcases_count-1) of std_logic_vector(DFF_size-1 downto 0);

	CONSTANT casesD : typeD :=
           (x"DDDD", x"FFFF" , x"FFFF" ,x"FFFF");
	CONSTANT casesEn : typeEn :=
           ('1' ,'0' ,'1' ,'1');
	CONSTANT casesR : typeR :=
           ('0', '0', '1', '0');
	CONSTANT casesQ : typeQ :=
           (x"DDDD", x"DDDD", x"0000", x"FFFF");

	SIGNAL testD, testQ: std_logic_vector(DFF_size-1 DOWNTO 0);
	SIGNAL testClk, testEn, testR : std_logic;

	COMPONENT nDFF IS
	GENERIC(n: INTEGER := 16);
	PORT(
		clk, en, R: IN std_logic;
		D: IN std_logic_vector(n-1 DOWNTO 0);
		Q: OUT std_logic_vector(n-1 DOWNTO 0)
	); 
	END COMPONENT;

BEGIN

		dff: nDFF GENERIC MAP(DFF_SIZE)  
		PORT MAP(
			Q => testQ, 
			D => testD, 
			en => testEn, 
			R => testR, 
			clk => testClk
		);
		PROCESS
			BEGIN
				FOR i IN 0 TO testcases_count-1 LOOP
					testD <= casesD(i);
					testEn <= casesEn(i);
					testR <= casesR(i);

					testClk <= '0';
					WAIT FOR 5 ns;
					testClk <= '1';
					WAIT FOR 5 ns;
					testClk <= '0';
					WAIT FOR 5 ns;

					ASSERT(testQ = casesQ(i))
					REPORT "ASSERTION FAILED AT CASE"
					SEVERITY ERROR;
				END LOOP;
				WAIT;
		END PROCESS;

END ARCHITECTURE;