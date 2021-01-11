LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.math_real.all;

ENTITY nmRam_TB IS
END nmRam_TB;

ARCHITECTURE main OF nmRam_TB IS
	CONSTANT testcases_count: INTEGER := 4;
  CONSTANT N: INTEGER := 32;
  CONSTANT M: INTEGER := 32;

	TYPE typeWr IS ARRAY(0 TO testcases_count-1) OF std_logic;
	TYPE typeAddress IS ARRAY(0 TO testcases_count-1) OF std_logic_vector(integer(ceil(log2(real(N))))-1 DOWNTO 0);
	TYPE typeDataIn IS ARRAY(0 TO testcases_count-1) OF std_logic_vector(M-1 DOWNTO 0);
	TYPE typeDataOut IS ARRAY(0 TO testcases_count-1) OF std_logic_vector(M-1 DOWNTO 0);

	CONSTANT casesWr : typeWr :=
					('1', '0' , '1' , '0');
	CONSTANT casesAddress : typeAddress :=
					("01010", "01010", "01011", "01011");
	CONSTANT casesDataIn : typeDataIn :=
					(x"0000000A", x"0000000A", x"0000000B", x"0000000B");
	CONSTANT casesDataOut : typeDataOut :=
					(x"0000000A", x"0000000A", x"0000000B", x"0000000B");

	SIGNAL testClk: std_logic;
	SIGNAL testWr: std_logic;
	SIGNAL testAddress: std_logic_vector(integer(ceil(log2(real(N))))-1 DOWNTO 0);
	SIGNAL testDataIn: std_logic_vector(M-1 DOWNTO 0);
	SIGNAL testDataOut: std_logic_vector(M-1 DOWNTO 0);

	COMPONENT nmRAM IS
	GENERIC(
    n: INTEGER := 32;
    m: INTEGER := 32
  );
	PORT(
    clk: IN std_logic;
    wr: IN std_logic;
    address: IN std_logic_vector(integer(ceil(log2(real(n))))-1 DOWNTO 0);
    dataIn: IN std_logic_vector(m-1 DOWNTO 0);
    dataOut: OUT std_logic_vector(m-1 DOWNTO 0)
  );
	END COMPONENT;

BEGIN
		ram: nmRAM
		GENERIC MAP(N, M) 
		PORT MAP(
			clk => testClk, 
			wr => testWr,
			address => testAddress,
			dataIn => testDataIn,
			dataOut => testDataOut
		);
		

		PROCESS
			BEGIN
				testClk <= '0';

				FOR i IN 0 TO testcases_count-1 LOOP
					testWr <= casesWr(i);
					testAddress <= casesAddress(i);
					testDataIn <= casesDataIn(i);
					WAIT FOR 5 ns;

					testClk <= '1';
					WAIT FOR 5 ns;
					testClk <= '0';
					WAIT FOR 5 ns;

					ASSERT(testDataOut = casesDataOut(i))
					REPORT "ASSERTION FAILED AT CASE"
					SEVERITY ERROR;
				END LOOP;
				WAIT;
		END PROCESS;

END ARCHITECTURE;
