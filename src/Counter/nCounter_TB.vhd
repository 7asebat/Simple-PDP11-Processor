LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY nCounter_TB IS
END nCounter_TB;

ARCHITECTURE main OF nCounter_TB IS
CONSTANT testcases_count: INTEGER := 7;
CONSTANT n: INTEGER := 8;

SIGNAL testClk, testEn, testMode, testR, testLoad: std_logic;
SIGNAL testDataIn, testDataOut: std_logic_vector(n-1 DOWNTO 0);

	TYPE type1 IS ARRAY (0 TO testcases_count-1) of std_logic;
	TYPE type2 IS ARRAY (0 TO testcases_count-1) of std_logic_vector(n-1 DOWNTO 0);

	CONSTANT casesEn : type1 :=
            ('1', '1', '1', '1', '0', '1', '1');
  CONSTANT casesMode : type1 :=
            ('1', '1', '1', '1', '1', '0', '0');
  CONSTANT casesR : type1 :=
            ('1', '0', '0' , '0', '0' , '0', '0');
  CONSTANT casesLoad : type1 :=
            ('0', '1' , '0', '0', '0', '0', '0');
  CONSTANT casesDataIn : type2 :=
          	(x"14", x"14" , x"00", x"00", x"00", x"00", x"00");
  CONSTANT casesDataOut : type2 :=
          	(x"00", x"14" , x"13" , x"12", x"12", x"13", x"14");

  COMPONENT nCounter IS
	GENERIC(n: INTEGER := 8);
	PORT(
		clk, en, mode, R, load: IN std_logic; -- mode: 0 increment, 1 decrement
		dataIn: IN std_logic_vector(n-1 DOWNTO 0);
		dataOut: OUT std_logic_vector(n-1 DOWNTO 0)
	); 
  END COMPONENT;

BEGIN
    counter: nCounter
		GENERIC MAP(n) 
		PORT MAP(
      en => testEn,
			clk => testClk,
			mode => testMode,
      R => testR,
      load => testLoad,
      dataIn => testDataIn,
      dataOut => testDataOut
		) ;
		PROCESS
      BEGIN
        testClk <= '0';
				FOR i IN 0 TO testcases_count-1 LOOP
					testEn <= casesEn(i);
					testMode <= casesMode(i);
          testR <= casesR(i);
          testLoad <= casesLoad(i);
          testDataIn <= casesDataIn(i);
          WAIT FOR 5 ns;
          testClk <= '1';
          WAIT FOR 5 ns;
          testClk <= '0';

					ASSERT(testDataOut = casesDataOut(i))
					REPORT "ASSERTION FAILED AT CASE"
					SEVERITY ERROR;
				END LOOP;
				WAIT;
		END PROCESS;

END ARCHITECTURE;
