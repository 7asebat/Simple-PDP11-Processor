LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.math_real.all;
use work.utility_pack.all;

ENTITY nmRam_TB IS
END nmRam_TB;

ARCHITECTURE main OF nmRam_TB IS
	CONSTANT testcases_count: INTEGER := 4;
  CONSTANT N: INTEGER := 32;
  CONSTANT M: INTEGER := 32;

	TYPE typeRW IS ARRAY(0 TO testcases_count-1) OF std_logic_vector(1 downto 0);
	TYPE typeAddress IS ARRAY(0 TO testcases_count-1) OF std_logic_vector(integer(ceil(log2(real(N))))-1 DOWNTO 0);
	TYPE typeDataIn IS ARRAY(0 TO testcases_count-1) OF std_logic_vector(M-1 DOWNTO 0);
	TYPE typeDataOut IS ARRAY(0 TO testcases_count-1) OF std_logic_vector(M-1 DOWNTO 0);

	CONSTANT casesRW : typeRW :=
					("01", "01" , "10" , "10");
	CONSTANT casesAddress : typeAddress :=
					("01010", "01001", "01010", "01001");
	CONSTANT casesDataIn : typeDataIn :=
					(x"000000AA", x"00000099", x"000000AA", x"00000099");
	CONSTANT casesDataOut : typeDataOut :=
					(x"000000AA", x"00000099", x"000000AA", x"00000099");

	SIGNAL testClk: std_logic;
	SIGNAL testMFC: std_logic;
	SIGNAL testRead: std_logic;
	SIGNAL testWrite: std_logic;
	SIGNAL testAddress: std_logic_vector(integer(ceil(log2(real(N))))-1 DOWNTO 0);
	SIGNAL testDataIn: std_logic_vector(M-1 DOWNTO 0);
	SIGNAL testDataOut: std_logic_vector(M-1 DOWNTO 0);

BEGIN
		ram: entity work.nmRAM
		GENERIC MAP(N, M) 
		PORT MAP(
			clk => testClk, 
			MFC => testMFC,
			read => testRead,
			write => testWrite,
			address => testAddress,
			dataIn => testDataIn,
			dataOut => testDataOut
		);
		

		PROCESS
			BEGIN
				FOR i IN 0 TO testcases_count-1 LOOP
					testRead <= casesRW(i)(1);
					testWrite <= casesRW(i)(0);
					testAddress <= casesAddress(i);
					testDataIn <= casesDataIn(i);
					WAIT FOR 5 ns;

					testClk <= '0';
					WAIT FOR 5 ns;
					testClk <= '1';
					WAIT FOR 5 ns;

					testClk <= '0';
					WAIT FOR 5 ns;
					testClk <= '1';
					WAIT FOR 5 ns;

					ASSERT(testDataOut = casesDataOut(i))
					REPORT "ASSERTION FAILED AT CASE " & integer'image(i)
						& " testDataIn " & to_hstring(testDataIn)
						& " testDataOut " & to_hstring(testDataOut)
						& " testAddress " & to_hstring(testAddress)
					SEVERITY ERROR;
				END LOOP;
				WAIT;
		END PROCESS;

END ARCHITECTURE;
