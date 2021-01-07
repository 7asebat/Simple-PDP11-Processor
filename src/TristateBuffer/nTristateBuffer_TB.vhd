LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY nTristateBuffer_TB IS
END nTristateBuffer_TB;

ARCHITECTURE main OF nTristateBuffer_TB IS
	CONSTANT testcases_count: INTEGER := 3;
	CONSTANT buffer_size: INTEGER := 32;

	TYPE typeA IS ARRAY (0 TO testcases_count-1) of std_logic_vector(buffer_size-1 DOWNTO 0);
	TYPE typeF IS ARRAY (0 TO testcases_count-1) of std_logic_vector(buffer_size-1 DOWNTO 0);
	TYPE typeEn IS ARRAY (0 TO testcases_count-1) of std_logic;

	CONSTANT casesA : typeA :=
           (x"DDDDDDDD", x"FFFFFFFF" , x"FFFFFFFF");
	CONSTANT casesF : typeF :=
           (x"DDDDDDDD" , (OTHERS => 'Z'), x"FFFFFFFF");
	CONSTANT casesEn : typeEn :=
           ('1', '0', '1');

	SIGNAL testA, testF: std_logic_vector(buffer_size-1 DOWNTO 0);
	SIGNAL testEn: std_logic;

	COMPONENT nTristateBuffer IS
	GENERIC(n: INTEGER := 32);
	PORT(
		en: IN std_logic;
		A: IN std_logic_vector(n-1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0)
	); 
	END COMPONENT;

BEGIN
	triB: nTristateBuffer 
		GENERIC MAP(buffer_size) 
		PORT MAP(
			A => testA, 
			F => testF, 
			en => testEn
		) ;
		PROCESS
			BEGIN
				FOR i IN 0 TO testcases_count-1 LOOP
					testA <= casesA(i);
					testEn <= casesEn(i);

					WAIT FOR 5 ns;

					ASSERT(testF = casesF(i))
					REPORT "ASSERTION FAILED AT CASE"
					SEVERITY ERROR;

				END LOOP;
				WAIT;
		END PROCESS;

END ARCHITECTURE;