Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PLA is
	generic(n: integer := 16);
	port(
	IR, controlStepCounter, statusRegister : in std_logic_vector(n-1 downto 0);
	load : out std_logic_vector(n-1 downto 0));
end entity PLA;

architecture default of PLA is
	signal partAOutput, partBOutput, partCOutput, partDOutput : std_logic_vector(n-1 downto 0);
	signal partACarry, partCCarry, partDCarry : std_logic;	

begin
	PROCESS (IR)

	BEGIN
		IF IR(n-1 DOWNTO n-4) = "1001" && (signed(controlStepCounter) = 3) THEN
			-- one op instruction
			
			-- destination fetching
			IF IR(n-9 DOWNTO n-11) = "000" THEN
				-- reg direct
			ELSIF IR(n-9 DOWNTO n-11) = "001" THEN
				-- reg indirect instruction
			ELSIF IR(n-9 DOWNTO n-11) = "010" THEN
				-- auto increment instruction
			ELSIF IR(n-9 DOWNTO n-11) = "011" THEN
				-- auto increment indirect instruction
			ELSIF IR(n-9 DOWNTO n-11) = "100" THEN
				-- auto decrement instruction
			ELSIF IR(n-9 DOWNTO n-11) = "101" THEN
				-- auto decrement indirect instruction
			ELSIF IR(n-9 DOWNTO n-11) = "110" THEN
				-- indexed instruction
			ELSIF IR(n-9 DOWNTO n-11) = "111" THEN
				-- indexed indirect instruction
			

		ELSIF  IR(n-1 DOWNTO 14) = "11" THEN
			-- branch instruction
			IF IR(n-5 DOWNTO n-7) = "000" THEN
				-- BR instruction
			ELSIF IR(n-5 DOWNTO n-7) = "001" THEN
				-- BEQ instruction
			ELSIF IR(n-5 DOWNTO n-7) = "010" THEN
				-- BNE instruction
			ELSIF IR(n-5 DOWNTO n-7) = "011" THEN
				-- BLO instruction
			ELSIF IR(n-5 DOWNTO n-7) = "100" THEN
				-- BLS instruction
			ELSIF IR(n-5 DOWNTO n-7) = "101" THEN
				-- BHI instruction
			ELSIF IR(n-5 DOWNTO n-7) = "110" THEN
				-- BHS instruction
			
		
		ELSIF IR(n-1 DOWNTO 12) = "1010" THEN
			-- no op instruction
			IF IR(n-5 DOWNTO n-8) = "0000" THEN
				-- HLT instruction
			ELSIF IR(n-5 DOWNTO n-8) = "0001" THEN
				-- NOP instruction
			ELSIF IR(n-5 DOWNTO n-8) = "0010" THEN
				-- RESET instruction

			
		ELSIF IR(n-1 DOWNTO 12) = "1011" THEN
			-- jump instruction
			IF IR(n-5 DOWNTO n-8) = "0000" THEN
				-- JSR instruction
			ELSIF IR(n-5 DOWNTO n-8) = "0001" THEN
				-- RTS instruction
			ELSIF IR(n-5 DOWNTO n-8) = "0010" THEN
				-- INTERRUPT instruction
			ELSIF IR(n-5 DOWNTO n-8) = "0011" THEN
				-- IRET instruction

			
		ELSIF IR(n-1 DOWNTO 12) = "0000" THEN
			-- MOV instruction
			
		ELSIF IR(n-1 DOWNTO 12) = "0001" THEN
			-- ADD instruction
			
		ELSIF IR(n-1 DOWNTO 12) = "0010" THEN
			-- ADC instruction
			
		ELSIF IR(n-1 DOWNTO 12) = "0011" THEN
			-- SUB instruction
			

		ELSIF IR(n-1 DOWNTO 12) = "0100" THEN
			-- SBC instruction
			
		ELSIF IR(n-1 DOWNTO 12) = "0101" THEN
			-- AND instruction
			
		ELSIF IR(n-1 DOWNTO 12) = "0110" THEN
			-- OR instruction
			
		ELSIF IR(n-1 DOWNTO 12) = "0111" THEN
			-- XOR instruction
			

		ELSIF IR(n-1 DOWNTO 12) = "1000" THEN
			-- CMP instruction
			
		
		
		ELSE
		END IF;
	END PROCESS;
end architecture;