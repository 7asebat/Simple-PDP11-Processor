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
		VARIABLE REG_DIRECT					: std_logic_vector(2 DOWNTO 0) := "000";
		VARIABLE REG_INDIRECT				: std_logic_vector(2 DOWNTO 0) := "001";
		VARIABLE AUTO_INCREMENT				: std_logic_vector(2 DOWNTO 0) := "010";
		VARIABLE AUTO_INCREMENT_INDIRECT		: std_logic_vector(2 DOWNTO 0) := "011";
		VARIABLE AUTO_DECREMENT				: std_logic_vector(2 DOWNTO 0) := "100";
		VARIABLE AUTO_DECREMENT_INDIRECT	: std_logic_vector(2 DOWNTO 0) := "101";
		VARIABLE INDEXED					: std_logic_vector(2 DOWNTO 0) := "110";
		VARIABLE INDEXED_INDIRECT			: std_logic_vector(2 DOWNTO 0) := "111";

		-- ONE OP OPERANDS ( Without pre one op )
		VARIABLE  INC_INSTRUCTION : std_logic_vector(3 downto 0) := "0000";
		VARIABLE  DEC_INSTRUCTION : std_logic_vector(3 downto 0) := "0001";
		VARIABLE  CLR_INSTRUCTION : std_logic_vector(3 downto 0) := "0010";
		VARIABLE  INV_INSTRUCTION : std_logic_vector(3 downto 0) := "0011";
		VARIABLE  LSR_INSTRUCTION : std_logic_vector(3 downto 0) := "0100";
		VARIABLE  ROR_INSTRUCTION : std_logic_vector(3 downto 0) := "0101";
		VARIABLE  ASR_INSTRUCTION : std_logic_vector(3 downto 0)  := "0110";
		VARIABLE  LSL_INSTRUCTION : std_logic_vector(3 downto 0) := "0111";
		VARIABLE  ROL_INSTRUCTION : std_logic_vector(3 downto 0) := "1000";

		-- Control Step Positions
		VARIABLE CONTROL_END : INTEGER := 0;

		VARIABLE CONTROL_SOURCE_DIRECT_REGISTER : INTEGER := 4;
		VARIABLE CONTROL_SOURCE_INDIRECT_REGISTER : INTEGER := 6;
		VARIABLE CONTROL_SOURCE_AUTOINCREMENT : INTEGER := 8;
		VARIABLE CONTROL_SOURCE_AUTODECREMENT : INTEGER := 11;
		VARIABLE CONTROL_SOURCE_INDEXED : INTEGER := 14;
		VARIABLE CONTROL_SOURCE_INDIRECT : INTEGER := 20;
		VARIABLE CONTROL_MOV_MDR_TO_SRC : INTEGER := 21;

		VARIABLE CONTROL_DESTINATION_DIRECT_REGISTER : INTEGER := 23;
		VARIABLE CONTROL_DESTINATION_INDIRECT_REGISTER : INTEGER := 25;
		VARIABLE CONTROL_DESTINATION_AUTOINCREMENT : INTEGER := 27;
		VARIABLE CONTROL_DESTINATION_AUTODECREMENT : INTEGER := 30;
		VARIABLE CONTROL_DESTINATION_INDEXED : INTEGER := 33;
		VARIABLE CONTROL_DESTINATION_INDIRECT : INTEGER := 39;
		VARIABLE CONTROL_MOV_MDR_TO_DST : INTEGER := 40;

		VARIABLE CONTROL_MOV : INTEGER := 42;
		VARIABLE CONTROL_ADD : INTEGER := 44;
		VARIABLE CONTROL_ADC : INTEGER := 47;
		VARIABLE CONTROL_SUB : INTEGER := 50;
		VARIABLE CONTROL_SBC : INTEGER := 53;
		VARIABLE CONTROL_AND : INTEGER := 56;
		VARIABLE CONTROL_OR  : INTEGER := 59;
		VARIABLE CONTROL_XOR : INTEGER := 62;
		VARIABLE CONTROL_CMP : INTEGER := 65;

		VARIABLE CONTROL_INC : INTEGER := 68;
		VARIABLE CONTROL_DEC : INTEGER := 70;
		VARIABLE CONTROL_CLR : INTEGER := 72;
		VARIABLE CONTROL_INV : INTEGER := 74;
		VARIABLE CONTROL_LSR : INTEGER := 76;
		VARIABLE CONTROL_ROR : INTEGER := 78;
		VARIABLE CONTROL_ASR : INTEGER := 80;
		VARIABLE CONTROL_LSL : INTEGER := 82;
		VARIABLE CONTROL_ROL : INTEGER := 84;

		VARIABLE CONTROL_BRANCH_OFFSET : INTEGER := 86;
		VARIABLE CONTROL_MOV_Z_TO_PC : INTEGER := 89;
		
		VARIABLE CONTROL_JSR : INTEGER := 94;
		VARIABLE CONTROL_JSR_AFTER_PUSH : INTEGER := 99;
		VARIABLE CONTROL_INTERRUPT : INTEGER := 101;
		VARIABLE CONTROL_INTERRUPT_AFTER_PUSH : INTEGER := 103;

		VARIABLE CONTROL_START_IRET : INTEGER := 108;
		VARIABLE CONTROL_START_RTS : INTEGER := 108;
		VARIABLE CONTROL_START_POP_PC : INTEGER := 108;

		VARIABLE CONTROL_CONTINUE_IRET : INTEGER := 112;

		VARIABLE CONTROL_PUSH : INTEGER := 116;
		
		VARIABLE CONTROL_DIRECT_REGISTER_MODE : INTEGER := 119;
		VARIABLE CONTROL_INDIRECT_WRITE_MODE : INTEGER := 121;

	BEGIN
		IF IR(n-1 DOWNTO n-4) = "1001" THEN
			-- one op instruction
			
			-- STEP ONE: FETCH DESTINATION
			IF (signed(controlStepCounter) = 3) THEN

				-- destination fetching
				IF IR(n-9 DOWNTO n-11) = REG_DIRECT THEN
					-- reg direct
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_DIRECT_REGISTER, load'length));
		
				ELSIF IR(n-9 DOWNTO n-11) = REG_INDIRECT THEN
					-- reg indirect instruction
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_INDIRECT_REGISTER, load'length));
				
				ELSIF IR(n-9 DOWNTO n-11) = AUTO_INCREMENT THEN
					-- auto increment instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_AUTOINCREMENT, load'length));

				ELSIF IR(n-9 DOWNTO n-11) = AUTO_DECREMENT THEN
					-- auto decrement instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_AUTODECREMENT, load'length));

				ELSIF IR(n-9 DOWNTO n-11) = INDEXED THEN
					-- indexed instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_INDEXED, load'length));
				END IF;

			END IF;

			IF signed(controlStepCounter) = 5 THEN
				-- JUMP TO OPERAND INSTRUCTION
				
				IF IR(n-9 DOWNTO n-11) = REG_DIRECT THEN

					-- GO TO THE INSTRUCTION
					IF IR(n-5 DOWNTO n-8) = INC_INSTRUCTION THEN
						load <= std_logic_vector(to_unsigned(CONTROL_INC, load'length));

					ELSIF IR(n-5 DOWNTO n-8) = DEC_INSTRUCTION THEN
						load <= std_logic_vector(to_unsigned(CONTROL_DEC, load'length));

					ELSIF IR(n-5 DOWNTO n-8) = CLR_INSTRUCTION THEN 
						load <= std_logic_vector(to_unsigned(CONTROL_CLR, load'length));

					ELSIF IR(n-5 DOWNTO n-8) = INV_INSTRUCTION THEN 
						load <= std_logic_vector(to_unsigned(CONTROL_INV, load'length));

					ELSIF IR(n-5 DOWNTO n-8) = LSR_INSTRUCTION THEN 
						load <= std_logic_vector(to_unsigned(CONTROL_LSR, load'length));

					ELSIF IR(n-5 DOWNTO n-8) = ROR_INSTRUCTION THEN 
						load <= std_logic_vector(to_unsigned(CONTROL_ROR, load'length));

					ELSIF IR(n-5 DOWNTO n-8) = ASR_INSTRUCTION THEN 
						load <= std_logic_vector(to_unsigned(CONTROL_ASR, load'length));

					ELSIF IR(n-5 DOWNTO n-8) = LSL_INSTRUCTION THEN
						load <= std_logic_vector(to_unsigned(CONTROL_LSL, load'length));

					ELSIF IR(n-5 DOWNTO n-8) = ROL_INSTRUCTION THEN
						load <= std_logic_vector(to_unsigned(CONTROL_ROL, load'length));
					END IF;  

				ELSIF  IR(n-9 DOWNTO n-11) = REG_INDIRECT THEN
					load <= std_logic_vector(to_unsigned(CONTROL_MOV_MDR_TO_DST, load'length));
				
				END IF;
			END IF;

			IF (
				( signed(controlStepCounter) = 6 AND IR(n-9 DOWNTO n-11) = AUTO_INCREMENT ) OR
				( signed(controlStepCounter) = 6 AND IR(n-9 DOWNTO n-11) = AUTO_DECREMENT ) OR 
				( signed(controlStepCounter) = 9 AND IR(n-9 DOWNTO n-11) = INDEXED )
			 ) THEN
				load <= std_logic_vector(to_unsigned(38, load'length));
			END IF;

			IF (
				( signed(controlStepCounter) = 9 AND IR(n-9 DOWNTO n-11) = AUTO_INCREMENT ) OR
				( signed(controlStepCounter) = 9 AND IR(n-9 DOWNTO n-11) = AUTO_DECREMENT ) OR
				( signed(controlStepCounter) = 12 AND IR(n-9 DOWNTO n-11) = INDEXED ) 
			) THEN
				-- GO TO THE INSTRUCTION
				IF IR(n-5 DOWNTO n-8) = INC_INSTRUCTION THEN
					load <= std_logic_vector(to_unsigned(CONTROL_INC, load'length));

				ELSIF IR(n-5 DOWNTO n-8) = DEC_INSTRUCTION THEN
					load <= std_logic_vector(to_unsigned(CONTROL_DEC, load'length));

				ELSIF IR(n-5 DOWNTO n-8) = CLR_INSTRUCTION THEN 
					load <= std_logic_vector(to_unsigned(CONTROL_CLR, load'length));

				ELSIF IR(n-5 DOWNTO n-8) = INV_INSTRUCTION THEN 
					load <= std_logic_vector(to_unsigned(CONTROL_INV, load'length));

				ELSIF IR(n-5 DOWNTO n-8) = LSR_INSTRUCTION THEN 
					load <= std_logic_vector(to_unsigned(CONTROL_LSR, load'length));

				ELSIF IR(n-5 DOWNTO n-8) = ROR_INSTRUCTION THEN 
					load <= std_logic_vector(to_unsigned(CONTROL_ROR, load'length));

				ELSIF IR(n-5 DOWNTO n-8) = ASR_INSTRUCTION THEN 
					load <= std_logic_vector(to_unsigned(CONTROL_ASR, load'length));

				ELSIF IR(n-5 DOWNTO n-8) = LSL_INSTRUCTION THEN
					load <= std_logic_vector(to_unsigned(CONTROL_LSL, load'length));

				ELSIF IR(n-5 DOWNTO n-8) = ROL_INSTRUCTION THEN
					load <= std_logic_vector(to_unsigned(CONTROL_ROL, load'length));
				END IF;
			END IF;

			IF  signed(controlStepCounter) > 12 THEN
				-- Move Z to Rdst
				IF IR(n-9 DOWNTO n-11) = REG_DIRECT THEN
					load <= std_logic_vector(to_unsigned(CONTROL_DIRECT_REGISTER_MODE, load'length));
				ELSE 
					load <= std_logic_vector(to_unsigned(CONTROL_INDIRECT_WRITE_MODE, load'length));
				END IF;
			END IF;
				
			

		ELSIF  IR(n-1 DOWNTO 14) = "11" THEN
			-- branch instruction

			IF (signed(controlStepCounter) = 3) THEN -- go to corresponding branch instruction
				IF IR(n-5 DOWNTO n-7) = "000" THEN
					-- BR instruction
					load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
				ELSIF IR(n-5 DOWNTO n-7) = "001" THEN
					-- BEQ instruction
					IF status_Z = '1' THEN
						load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
					ELSE
						load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "010" THEN
					-- BNE instruction
					IF status_Z = '0' THEN
						load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
					ELSE
						load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "011" THEN
					-- BLO instruction
					IF status_C = '1' THEN
						load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
					ELSE
						load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "100" THEN
					-- BLS instruction
					IF status_C = '0' OR status_Z = '1' THEN
						load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
					ELSE
						load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "101" THEN
					-- BHI instruction
					IF status_C = '1' THEN
						load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
					ELSE
						load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
					END IF;
				ELSIF IR(n-5 DOWNTO n-7) = "110" THEN
					-- BHS instruction
					IF status_C = '1' OR status_Z = '1' THEN
						load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
					ELSE
						load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
					END IF;
				END IF;
			END IF;
			
			IF (signed(controlStepCounter) = 6) THEN -- row 94: µ-PC <= PLA(IR)$ [Double Operand]::ADD SRC, DST
				load <= std_logic_vector(to_unsigned(CONTROL_ADD, load'length)); -- row 48 (ADD SRC, DST)
			END IF;

			IF (signed(controlStepCounter) = 9) THEN -- row 50: µ-PC <= PLA(IR)$ [Move Z to PC]
				load <= std_logic_vector(to_unsigned(CONTROL_MOV_Z_TO_PC, load'length)); -- row 95 (MOV Z to PC)
			END IF;

			IF (signed(controlStepCounter) = 11) THEN -- row 96: END
				load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- row 95 (MOV Z to PC)
			END IF;

		
		ELSIF IR(n-1 DOWNTO 12) = "1010" THEN
			-- no op instruction
			IF IR(n-5 DOWNTO n-8) = "0000" THEN
				-- HALT instruction
				halt <= '1';
			ELSIF IR(n-5 DOWNTO n-8) = "0001" THEN
				-- NOP instruction
				load <= std_logic_vector(to_unsigned(CONTROL_END, load'length));
			-- ELSIF IR(n-5 DOWNTO n-8) = "0010" THEN
			-- 	-- RESET instruction (CANCELLED)
			END IF;

			
		ELSIF IR(n-1 DOWNTO 12) = "1011" THEN
			-- jump instruction
			IF IR(n-5 DOWNTO n-8) = "0000" THEN
				-- JSR instruction
				IF signed(controlStepCounter) = 3 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_JSR, load'length)); -- row 102 (JSR)
				END IF;

				IF signed(ControlStepCounter) = 8 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_PUSH, load'length)); -- row 124 (PUSH)
				END IF;

				IF signed(ControlStepCounter) = 11 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_JSR_AFTER_PUSH, load'length)); -- row 107 (JSR AFTER PUSH)
				END IF;

				IF signed(ControlStepCounter) = 13 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
				END IF;

			ELSIF IR(n-5 DOWNTO n-8) = "0001" THEN
				-- RTS instruction
				IF signed(controlStepCounter) = 3 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_START_RTS, load'length)); -- row 116 (Start RTS)
				END IF;

				IF signed(ControlStepCounter) = 7 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
				END IF;
				
			ELSIF IR(n-5 DOWNTO n-8) = "0010" THEN
				-- INTERRUPT instruction
				IF signed(controlStepCounter) = 3 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_INTERRUPT, load'length)); -- row 109 (INTERRUPT)
				END IF;

				IF signed(ControlStepCounter) = 5 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_PUSH, load'length)); -- row 124 (PUSH)
				END IF;

				IF signed(ControlStepCounter) = 8 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_INTERRUPT_AFTER_PUSH, load'length)); -- row 111 (INTERRUPT AFTER PUSH)
				END IF;

				IF signed(ControlStepCounter) = 13 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
				END IF;

			ELSIF IR(n-5 DOWNTO n-8) = "0011" THEN
				-- IRET instruction
				IF signed(controlStepCounter) = 3 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_START_IRET, load'length)); -- row 116 (Start RTS)
				END IF;

				IF signed(ControlStepCounter) = 7 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_CONTINUE_IRET, load'length)); -- continue IRET
				END IF;

				IF signed(ControlStepCounter) = 11 THEN
					load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
				END IF;
			END IF;

			
		
		
		-- ########### DOUBLE OP INSTRUCTIONS ###########
		ELSIF (
			IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION OR
			IR(n-1 DOWNTO n-4) = ADD_INSTRUCTION OR
			IR(n-1 DOWNTO n-4) = ADC_INSTRUCTION OR
			IR(n-1 DOWNTO n-4) = SUB_INSTRUCTION OR
			IR(n-1 DOWNTO n-4) = SBC_INSTRUCTION OR
			IR(n-1 DOWNTO n-4) = AND_INSTRUCTION OR
			IR(n-1 DOWNTO n-4) = OR_INSTRUCTION OR
			IR(n-1 DOWNTO n-4) = XOR_INSTRUCTION OR
			IR(n-1 DOWNTO n-4) = CMP_INSTRUCTION
		) THEN
			
			-- FIRST STEP: SOURCE FETCHING
			IF (signed(controlStepCounter) = 3) THEN
				--SOURCE FETCHING
				IF IR(n-5 DOWNTO n-7) = REG_DIRECT THEN
					-- reg direct
					load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_DIRECT_REGISTER, load'length));
			
				ELSIF IR(n-5 DOWNTO n-7) = REG_INDIRECT THEN
					-- reg indirect instruction
					load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_INDIRECT_REGISTER, load'length));
				
				ELSIF IR(n-5 DOWNTO n-7) = AUTO_INCREMENT THEN
					-- auto increment instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_AUTOINCREMENT, load'length));

				ELSIF IR(n-5 DOWNTO n-7) = AUTO_DECREMENT THEN
					-- auto decrement instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_AUTODECREMENT, load'length));

				ELSIF IR(n-5 DOWNTO n-7) = INDEXED THEN
					-- indexed instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_INDEXED, load'length));
				END IF;
			END IF;

			

			-- if SRC is reg indirect and CSC is 7 go to dest fetching
			IF  (
				(signed(controlStepCounter) = 5 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT) OR
				(signed(controlStepCounter) = 6 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT) OR
				(signed(controlStepCounter) = 6 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT) OR
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = INDEXED)
			) THEN
				load <= std_logic_vector(to_unsigned(CONTROL_MOV_MDR_TO_SRC, load'length));
			END IF;

			-- if SRC is reg direct and CSC is 7 go to dest fetching
			IF  (
				(signed(controlStepCounter) = 6 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT) OR
				(signed(controlStepCounter) = 6 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT) OR
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT)
			) THEN
				load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_INDIRECT, load'length));
			END IF;


			-- SECOND STEP: DEST FETCHING [ Depends on src ]
			
			-- if SRC is reg direct and CSC is 5 go to dest fetching
			IF  (
				(signed(controlStepCounter) = 5 AND IR(n-5 DOWNTO n-7) = REG_DIRECT) OR
				(signed(controlStepCounter) = 7 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT) OR
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT) OR
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT) OR
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT) OR
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = INDEXED) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT)
			) THEN
				
				--DEST FETCHING
				IF IR(n-11 DOWNTO n-13) = REG_DIRECT THEN
					-- reg direct
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_DIRECT_REGISTER, load'length));
			
				ELSIF IR(n-11 DOWNTO n-13) = REG_INDIRECT THEN
					-- reg indirect instruction
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_INDIRECT_REGISTER, load'length));
				
				ELSIF IR(n-11 DOWNTO n-13) = AUTO_INCREMENT THEN
					-- auto increment instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_AUTOINCREMENT, load'length));

				ELSIF IR(n-11 DOWNTO n-13) = AUTO_DECREMENT THEN
					-- auto decrement instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_AUTODECREMENT, load'length));

				ELSIF IR(n-11 DOWNTO n-13) = INDEXED THEN
					-- indexed instruction [SHOULD HANDLE DIRECT AND INDIRECT]
					load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_INDEXED, load'length));
				END IF;

			END IF;
		
			IF(
				-- DEST IS REG_INDIRECT
				(signed(controlStepCounter) = 7 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT )
			) THEN
				load <= std_logic_vector(to_unsigned(CONTROL_MOV_MDR_TO_DST, load'length));
			END IF;

			IF(
				-- DEST IS AUTO_INCREMENT
				(signed(controlStepCounter) = 8 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR

				-- DEST IS AUTO_INCREMENT_INDIRECT
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR

				-- DEST IS AUTO_DECREMENT
				(signed(controlStepCounter) = 8 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR

				-- DEST IS AUTO_DECREMENT
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR

				-- DEST IS INDEXED
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED )
			) THEN
				load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_INDIRECT, load'length));
			END IF;

			
			-- STEP 3: GO TO THE TWO OP INSTRUCTION
			IF (
				-- DEST IS REG_DIRECT
				(signed(controlStepCounter) = 7 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT ) OR
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT ) OR
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT ) OR
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT ) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_DIRECT ) OR
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT ) OR
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT ) OR

				-- DEST IS REG_INDIRECT
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT ) OR

				-- DEST IS AUTO_INCREMENT
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT ) OR

				-- DEST IS AUTO_INCREMENT_INDIRECT
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT ) OR

				-- DEST IS AUTO_DECREMENT
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT ) OR

				-- DEST IS AUTO_DECREMENT_INDIRECT
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT ) OR

				-- DEST IS INDEXED
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED ) OR
				(signed(controlStepCounter) = 22 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED )

			) THEN
				-- JUMP TO OPERAND INSTRUCTION
				
				-- CHECKING INSTRUCTION
				IF IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION THEN
					-- MOV INSTRUCTION
					load <= std_logic_vector(to_unsigned(CONTROL_MOV, load'length));

				ELSIF IR(n-1 DOWNTO n-4) = ADD_INSTRUCTION THEN
					-- ADD INSTRUCTION
					load <= std_logic_vector(to_unsigned(CONTROL_ADD, load'length));

				ELSIF IR(n-1 DOWNTO n-4) = ADC_INSTRUCTION THEN
					-- ADC INSTRUCTION
					load <= std_logic_vector(to_unsigned(CONTROL_ADC, load'length));

				ELSIF IR(n-1 DOWNTO n-4) = SUB_INSTRUCTION THEN
					-- SUB INSTRUCTION
					load <= std_logic_vector(to_unsigned(CONTROL_SUB, load'length));

				ELSIF IR(n-1 DOWNTO n-4) = SBC_INSTRUCTION THEN
					-- SBC INSTRUCTION
					load <= std_logic_vector(to_unsigned(CONTROL_SBC, load'length));

				ELSIF IR(n-1 DOWNTO n-4) = AND_INSTRUCTION THEN
					-- AND INSTRUCTION
					load <= std_logic_vector(to_unsigned(CONTROL_AND, load'length));

				ELSIF IR(n-1 DOWNTO n-4) = OR_INSTRUCTION THEN
					-- OR INSTRUCTION
					load <= std_logic_vector(to_unsigned(CONTROL_OR, load'length));

				ELSIF IR(n-1 DOWNTO n-4) = XOR_INSTRUCTION THEN
					-- XOR INSTRUCTION
					load <= std_logic_vector(to_unsigned(CONTROL_XOR, load'length));

				ELSIF IR(n-1 DOWNTO n-4) = CMP_INSTRUCTION THEN
					-- CMP INSTRUCTION
					load <= std_logic_vector(to_unsigned(CONTROL_CMP, load'length));

				END IF;
			END IF;

			IF (
				-- DEST IS REG_DIRECT
				(signed(controlStepCounter) = 8 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS REG_INDIRECT
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS AUTO_INCREMENT
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				

				-- DEST IS AUTO_INCREMENT_INDIRECT
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS AUTO_DECREMENT
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS AUTO_DECREMENT_INDIRECT
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS INDEXED
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = INDEXED AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 22 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 23 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-----------------------------------------------------
				-- DEST IS REG_DIRECT
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS REG_INDIRECT
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS AUTO_INCREMENT
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS AUTO_INCREMENT_INDIRECT
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 22 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS AUTO_DECREMENT
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS AUTO_DECREMENT_INDIRECT
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 22 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS INDEXED
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = INDEXED AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 23 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 24 AND IR(n-5 DOWNTO n-7) = INDEXED_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION)

			) THEN

				-- DEST FETCHING
				IF IR(n-11 DOWNTO n-13) = "000" THEN
					-- reg direct
					load <= std_logic_vector(to_unsigned(CONTROL_DIRECT_REGISTER_MODE, load'length));
				ELSE 
					load <= std_logic_vector(to_unsigned(CONTROL_INDIRECT_WRITE_MODE, load'length));
				END IF;
			END IF;


			IF (
				-- DEST IS REG_DIRECT
				(signed(controlStepCounter) = 9 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS REG_INDIRECT
				(signed(controlStepCounter) = 11 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS AUTO_INCREMENT
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS AUTO_INCREMENT_INDIRECT
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS AUTO_DECREMENT
				(signed(controlStepCounter) = 13 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS AUTO_DECREMENT_INDIRECT
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-- DEST IS INDEXED
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = INDEXED AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 20 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 23 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) = MOV_INSTRUCTION) OR

				-----------------------------------------------------
				-- DEST IS REG_DIRECT
				(signed(controlStepCounter) = 10 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_DIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS REG_INDIRECT
				(signed(controlStepCounter) = 12 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = REG_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS AUTO_INCREMENT
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS AUTO_INCREMENT_INDIRECT
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 22 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_INCREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS AUTO_DECREMENT
				(signed(controlStepCounter) = 14 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 16 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 18 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS AUTO_DECREMENT_INDIRECT
				(signed(controlStepCounter) = 15 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 22 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = AUTO_DECREMENT_INDIRECT  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR

				-- DEST IS INDEXED
				(signed(controlStepCounter) = 17 AND IR(n-5 DOWNTO n-7) = REG_DIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 19 AND IR(n-5 DOWNTO n-7) = REG_INDIRECT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = AUTO_INCREMENT AND IR(n-11 DOWNTO n-13) = INDEXED AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION ) OR
				(signed(controlStepCounter) = 21 AND IR(n-5 DOWNTO n-7) = AUTO_DECREMENT AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION) OR
				(signed(controlStepCounter) = 24 AND IR(n-5 DOWNTO n-7) = INDEXED AND IR(n-11 DOWNTO n-13) = INDEXED  AND IR(n-1 DOWNTO n-4) /= MOV_INSTRUCTION)

			) THEN
				load <= (OTHERS => '0');
			END IF;

		ELSE
		END IF;
	END PROCESS;
end architecture;