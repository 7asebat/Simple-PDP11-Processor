Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PLA is
	generic(n: integer := 16);
	port(
	IR, controlStepCounter, statusRegister : in std_logic_vector(n-1 downto 0);
	load : out std_logic_vector(n-1 downto 0);
	halt: out std_logic
	);
end entity PLA;

architecture default of PLA is
	signal partAOutput, partBOutput, partCOutput, partDOutput : std_logic_vector(n-1 downto 0);
	signal partACarry, partCCarry, partDCarry : std_logic;	
	signal status_N, status_Z, status_V, status_C : std_logic;
begin
	status_N <= statusRegister(0);
	status_Z <= statusRegister(1);
	status_V <= statusRegister(2);
	status_C <= statusRegister(3);

	PROCESS (IR, controlStepCounter)
		-- DOUBLE OPERANDS
		VARIABLE MOV_INSTRUCTION : std_logic_vector(3 downto 0) := "0000";
		VARIABLE ADD_INSTRUCTION : std_logic_vector(3 downto 0) := "0001";
		VARIABLE ADC_INSTRUCTION : std_logic_vector(3 downto 0) := "0010";
		VARIABLE SUB_INSTRUCTION : std_logic_vector(3 downto 0) := "0011";
		VARIABLE SBC_INSTRUCTION : std_logic_vector(3 downto 0) := "0100";
		VARIABLE AND_INSTRUCTION : std_logic_vector(3 downto 0) := "0101";
		VARIABLE OR_INSTRUCTION : std_logic_vector(3 downto 0)  := "0110";
		VARIABLE XOR_INSTRUCTION : std_logic_vector(3 downto 0) := "0111";
		VARIABLE CMP_INSTRUCTION : std_logic_vector(3 downto 0) := "1000";

		-- ADDRESSING MODES
		VARIABLE REG_DIRECT					: std_logic_vector(2 DOWNTO 0) := '000';
		VARIABLE REG_INDIRECT				: std_logic_vector(2 DOWNTO 0) := '001';
		VARIABLE AUTO_INCREMENT				: std_logic_vector(2 DOWNTO 0) := '010';
		VARIABLE AUTO_INCREMENT_IDIRECT		: std_logic_vector(2 DOWNTO 0) := '011';
		VARIABLE AUTO_DECREMENT				: std_logic_vector(2 DOWNTO 0) := '100';
		VARIABLE AUTO_DECREMENT_INDIRECT	: std_logic_vector(2 DOWNTO 0) := '101';
		VARIABLE INDEXED					: std_logic_vector(2 DOWNTO 0) := '110';
		VARIABLE INDEXED_INDIRECT			: std_logic_vector(2 DOWNTO 0) := '111';

	BEGIN
		IF IR(n-1 DOWNTO n-4) = "1001" AND (signed(controlStepCounter) = 3) THEN
			-- one op instruction
			

			-- REVISIT THE INDICES
			-- destination fetching
			IF IR(n-9 DOWNTO n-11) = REG_DIRECT THEN
				-- reg direct
				load <= std_logic_vector(to_unsigned(5, load'length));
		
			ELSIF IR(n-9 DOWNTO n-11) = REG_INDIRECT THEN
				-- reg indirect instruction
				load <= std_logic_vector(to_unsigned(7, load'length));
			
			ELSIF IR(n-9 DOWNTO n-11) = AUTO_INCREMENT THEN
				-- auto increment instruction [SHOULD HANDLE DIRECT AND INDIRECT]
				load <= std_logic_vector(to_unsigned(9, load'length));

			ELSIF IR(n-9 DOWNTO n-11) = AUTO_DECREMENT THEN
				-- auto decrement instruction [SHOULD HANDLE DIRECT AND INDIRECT]
				load <= std_logic_vector(to_unsigned(12, load'length));

			ELSIF IR(n-9 DOWNTO n-11) = INDEXED THEN
				-- indexed instruction [SHOULD HANDLE DIRECT AND INDIRECT]
				load <= std_logic_vector(to_unsigned(15, load'length));
			END IF;
				
			

		ELSIF  IR(n-1 DOWNTO 14) = "11" THEN
			-- branch instruction

			IF (signed(controlStepCounter) = 3) THEN -- go to corresponding branch instruction
				IF IR(n-5 DOWNTO n-7) = "000" THEN
					-- BR instruction
					load <= -- row 92 (Branch Offset)
				ELSIF IR(n-5 DOWNTO n-7) = "001" THEN
					-- BEQ instruction
					IF status_Z = '1' THEN
						load <= -- row 92 (Branch Offset)
					ELSE
						load <= (OTHERS => '0'); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "010" THEN
					-- BNE instruction
					IF status_Z = '0' THEN
						load <= -- row 92 (Branch Offset)
					ELSE
						load <= (OTHERS => '0'); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "011" THEN
					-- BLO instruction
					IF status_C = '1' THEN
						load <= -- row 92 (Branch Offset)
					ELSE
						load <= (OTHERS => '0'); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "100" THEN
					-- BLS instruction
					IF status_C = 0 OR status_Z = 1 THEN
						load <= -- row 92 (Branch Offset)
					ELSE
						load <= (OTHERS => '0'); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "101" THEN
					-- BHI instruction
					IF status_C = 1 THEN
						load <= -- row 92 (Branch Offset)
					ELSE
						load <= (OTHERS => '0'); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "110" THEN
					-- BHS instruction
					IF status_C = 1 OR status_Z = 1 THEN
						load <= -- row 92 (Branch Offset)
					ELSE
						load <= (OTHERS => '0'); -- END
					END IF;
				END IF;
			END IF;
			
			IF (signed(controlStepCounter) = 6) THEN -- row 94: µ-PC <= PLA(IR)$ [Double Operand]::ADD SRC, DST
				load <= -- row 48 (ADD SRC, DST)
			END IF;

			IF (signed(controlStepCounter) = 9) THEN -- row 50: µ-PC <= PLA(IR)$ [Move Z to PC]
				load <= -- row 95 (MOV Z to PC)
			END IF;

			IF (signed(controlStepCounter) = 11) THEN -- row 96: END
				load <= (OTHERS => '0')-- row 95 (MOV Z to PC)
			END IF;

		
		ELSIF IR(n-1 DOWNTO 12) = "1010" THEN
			-- no op instruction
			IF IR(n-5 DOWNTO n-8) = "0000" THEN
				halt <= '1';
			ELSIF IR(n-5 DOWNTO n-8) = "0001" THEN
				load <= (OTHERS => '0');
			ELSIF IR(n-5 DOWNTO n-8) = "0010" THEN
				-- RESET instruction (CANCELLED)
			END IF;

			
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
			END IF;

			
		
		
		-- DOUBLE OP INSTRUCTIONS
		ELSIF (
			IR(n-1 DOWNTO n-4) = "0000" OR
			IR(n-1 DOWNTO n-4) = "0001" OR
			IR(n-1 DOWNTO n-4) = "0010" OR
			IR(n-1 DOWNTO n-4) = "0011" OR
			IR(n-1 DOWNTO n-4) = "0100" OR
			IR(n-1 DOWNTO n-4) = "0101" OR
			IR(n-1 DOWNTO n-4) = "0110" OR
			IR(n-1 DOWNTO n-4) = "0111" OR
			IR(n-1 DOWNTO n-4) = "1000"
		) THEN
			
			-- FIRST STEP: SOURCE FETCHING
			IF (signed(controlStepCounter) = 3) THEN
				--SOURCE FETCHING
				IF IR(n-5 DOWNTO n-7) = REG_DIRECT THEN
					-- reg direct
					load <= std_logic_vector(to_unsigned(4, load'length));
			
				ELSIF IR(n-5 DOWNTO n-7) = REG_INDIRECT THEN
					-- reg indirect instruction
					load <= std_logic_vector(to_unsigned(6, load'length));
				
				ELSIF IR(n-5 DOWNTO n-7) = AUTO_INCREMENT THEN
					-- auto increment instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(8, load'length));

				ELSIF IR(n-5 DOWNTO n-7) = AUTO_DECREMENT THEN
					-- auto decrement instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(11, load'length));

				ELSIF IR(n-5 DOWNTO n-7) = INDEXED THEN
					-- indexed instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(14, load'length));
				END IF;
			END IF;

			-- SECOND STEP: DEST FETCHING
			
			-- if SRC is reg direct and CSC is 5 go to dest fetching
			IF  signed(controlStepCounter) = 5 AND IR(n-5 DOWNTO n-7) = "000" THEN
				
				--DEST FETCHING
				IF IR(n-11 DOWNTO n-13) = REG_DIRECT THEN
					-- reg direct
					load <= std_logic_vector(to_unsigned(22, load'length));
			
				ELSIF IR(n-11 DOWNTO n-13) = REG_INDIRECT THEN
					-- reg indirect instruction
					load <= std_logic_vector(to_unsigned(24, load'length));
				
				ELSIF IR(n-11 DOWNTO n-13) = AUTO_INCREMENT THEN
					-- auto increment instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(26, load'length));

				ELSIF IR(n-11 DOWNTO n-13) = AUTO_DECREMENT THEN
					-- auto decrement instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(29, load'length));

				ELSIF IR(n-11 DOWNTO n-13) = INDEXED THEN
					-- indexed instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(32, load'length));
				END IF;

			END IF;

			-- if SRC is reg direct and CSC is 7 go to dest fetching
			IF  signed(controlStepCounter) = 7 AND IR(n-5 DOWNTO n-7) = "001" THEN
				load <= std_logic_vector(to_unsigned(21, load'length))
			END IF;

			-- if SRC is reg direct and CSC is 7 go to dest fetching
			IF  (
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = "010") OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = "100") OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = "110")
			) THEN
				load <= std_logic_vector(to_unsigned(20, load'length))
			END IF;

			IF signed(controlStepCounter) = 23 THEN
				-- JUMP TO OPERAND INSTRUCTION
				
				-- CHECKING INSTRUCTION
				IF IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION THEN
					-- MOV INSTRUCTION
					load <= std_logic_vector(to_unsigned(41, load'length))

				ELSIF IR(n-1 DOWNTO n-4) = ADD_INSTRUCTION THEN
					-- ADD INSTRUCTION
					load <= std_logic_vector(to_unsigned(43, load'length))

				ELSIF IR(n-1 DOWNTO n-4) = ADC_INSTRUCTION THEN
					-- ADC INSTRUCTION
					load <= std_logic_vector(to_unsigned(46, load'length))

				ELSIF IR(n-1 DOWNTO n-4) = SUB_INSTRUCTION THEN
					-- SUB INSTRUCTION
					load <= std_logic_vector(to_unsigned(49, load'length))

				ELSIF IR(n-1 DOWNTO n-4) = SBC_INSTRUCTION THEN
					-- SBC INSTRUCTION
					load <= std_logic_vector(to_unsigned(52, load'length))

				ELSIF IR(n-1 DOWNTO n-4) = AND_INSTRUCTION THEN
					-- AND INSTRUCTION
					load <= std_logic_vector(to_unsigned(55, load'length))

				ELSIF IR(n-1 DOWNTO n-4) = OR_INSTRUCTION THEN
					-- OR INSTRUCTION
					load <= std_logic_vector(to_unsigned(58, load'length))

				ELSIF IR(n-1 DOWNTO n-4) = XOR_INSTRUCTION THEN
					-- XOR INSTRUCTION
					load <= std_logic_vector(to_unsigned(61, load'length))

				ELSIF IR(n-1 DOWNTO n-4) = CMP_INSTRUCTION THEN
					-- CMP INSTRUCTION
					load <= std_logic_vector(to_unsigned(64, load'length))

				END IF;
			END IF;

			IF signed(controlStepCounter) = 25 THEN
				load <= std_logic_vector(to_unsigned(39, load'length))
			END IF;

			IF (
				signed(controlStepCounter) = 28 OR
				signed(controlStepCounter) = 31 OR
				signed(controlStepCounter) = 37
			) THEN
				load <= std_logic_vector(to_unsigned(38, load'length))
			END IF;

			IF (
				signed(controlStepCounter) = 42 OR
				signed(controlStepCounter) = 45 OR
				signed(controlStepCounter) = 48 OR
				signed(controlStepCounter) = 51 OR
				signed(controlStepCounter) = 54 OR
				signed(controlStepCounter) = 57 OR
				signed(controlStepCounter) = 60 OR
				signed(controlStepCounter) = 63 OR
			) THEN

				-- DEST FETCHING
				IF IR(n-11 DOWNTO n-13) = "000" THEN
					-- reg direct
					load <= std_logic_vector(to_unsigned(118, load'length));
				ELSE 
					load <= std_logic_vector(to_unsigned(120, load'length));
				END IF;
			END IF;

		ELSIF  THEN
		
		ELSE
		END IF;
	END PROCESS;
end architecture;