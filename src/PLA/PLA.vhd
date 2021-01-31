Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PLA is
  generic(n: integer := 16; m: integer:= 8);
  port(IR, controlStepCounter, statusRegister: in std_logic_vector(n-1 downto 0);
       interrupt: in std_logic;
       load: out std_logic_vector(m-1 downto 0);
       halt: out std_logic);
end entity PLA;

architecture main of PLA is
  signal partAOutput, partBOutput, partCOutput, partDOutput: std_logic_vector(n-1 downto 0);
  signal partACarry, partCCarry, partDCarry: std_logic;	
  signal status_N, status_Z, status_C: std_logic;

  alias IR_opcode: std_logic_vector(3 downto 0) is IR(n-1 downto n-4);

  alias IR_source_adr: std_logic_vector(2 downto 0) is IR(n-5 downto n-7);
  alias IR_destination_adr: std_logic_vector(2 downto 0) is IR(n-11 DOWNTO n-13);

  alias IR_one_op_adr: std_logic_vector(2 downto 0) is IR(n-9 DOWNTO n-11);
  alias IR_one_op_opcode: std_logic_vector(3 downto 0) is IR(n-5 DOWNTO n-8);

  alias IR_branch_opcode: std_logic_vector(1 downto 0) is IR(n-1 DOWNTO n-2);
  alias IR_branch_mode: std_logic_vector(2 downto 0) is IR(n-3 DOWNTO n-5);

  -- Branch mode
  constant BRANCH_BR: std_logic_vector(2 DOWNTO 0)  := "000";
  constant BRANCH_BEQ: std_logic_vector(2 DOWNTO 0) := "001";
  constant BRANCH_BNE: std_logic_vector(2 DOWNTO 0) := "010";
  constant BRANCH_BLO: std_logic_vector(2 DOWNTO 0) := "011";
  constant BRANCH_BLS: std_logic_vector(2 DOWNTO 0) := "100";
  constant BRANCH_BHI: std_logic_vector(2 DOWNTO 0) := "101";
  constant BRANCH_BHS: std_logic_vector(2 DOWNTO 0) := "110";

  -- OPCODES
  constant OPCODE_MOV: std_logic_vector(3 downto 0)    := "0000";
  constant OPCODE_ADD: std_logic_vector(3 downto 0)    := "0001";
  constant OPCODE_ADC: std_logic_vector(3 downto 0)    := "0010";
  constant OPCODE_SUB: std_logic_vector(3 downto 0)    := "0011";
  constant OPCODE_SBC: std_logic_vector(3 downto 0)    := "0100";
  constant OPCODE_AND: std_logic_vector(3 downto 0)    := "0101";
  constant OPCODE_OR: std_logic_vector(3 downto 0)     := "0110";
  constant OPCODE_XOR: std_logic_vector(3 downto 0)    := "0111";
  constant OPCODE_CMP: std_logic_vector(3 downto 0)    := "1000";
  -- ONE OP OPERANDS ( Without pre one op )
  constant OPCODE_ONE_OP: std_logic_vector(3 downto 0) := "1001";
  constant OPCODE_INC: std_logic_vector(3 downto 0)    := "0000";
  constant OPCODE_DEC: std_logic_vector(3 downto 0)    := "0001";
  constant OPCODE_CLR: std_logic_vector(3 downto 0)    := "0010";
  constant OPCODE_INV: std_logic_vector(3 downto 0)    := "0011";
  constant OPCODE_LSR: std_logic_vector(3 downto 0)    := "0100";
  constant OPCODE_ROR: std_logic_vector(3 downto 0)    := "0101";
  constant OPCODE_ASR: std_logic_vector(3 downto 0)    := "0110";
  constant OPCODE_LSL: std_logic_vector(3 downto 0)    := "0111";
  constant OPCODE_ROL: std_logic_vector(3 downto 0)    := "1000";
  -- NO OP instructions
  constant OPCODE_NO_OP: std_logic_vector(3 downto 0)  := "1010";
  constant OPCODE_HLT: std_logic_vector(3 downto 0)    := "0000";
  constant OPCODE_NOP: std_logic_vector(3 downto 0)    := "0001";
  -- JMP instructions
  constant OPCODE_JMP:  std_logic_vector(3 downto 0) := "1011";
  constant OPCODE_JSR:  std_logic_vector(3 downto 0) := "0000";
  constant OPCODE_RTS:  std_logic_vector(3 downto 0) := "0001";
  constant OPCODE_INT:  std_logic_vector(3 downto 0) := "0010";
  constant OPCODE_IRET: std_logic_vector(3 downto 0) := "0011";

  -- ADDRESSING MODES
  constant ADR_REG_DIRECT: std_logic_vector(2 DOWNTO 0)              := "000";
  constant ADR_REG_INDIRECT: std_logic_vector(2 DOWNTO 0)            := "001";
  constant ADR_AUTO_INCREMENT: std_logic_vector(2 DOWNTO 0)          := "010";
  constant ADR_AUTO_INCREMENT_INDIRECT: std_logic_vector(2 DOWNTO 0) := "011";
  constant ADR_AUTO_DECREMENT: std_logic_vector(2 DOWNTO 0)          := "100";
  constant ADR_AUTO_DECREMENT_INDIRECT: std_logic_vector(2 DOWNTO 0) := "101";
  constant ADR_INDEXED: std_logic_vector(2 DOWNTO 0)                 := "110";
  constant ADR_INDEXED_INDIRECT: std_logic_vector(2 DOWNTO 0)        := "111";

  -- Control Step Positions
  constant CONTROL_END:                      INTEGER := 0;
  constant CONTROL_SOURCE_DIRECT_REGISTER:   INTEGER := 4;
  constant CONTROL_SOURCE_INDIRECT_REGISTER: INTEGER := 6;
  constant CONTROL_SOURCE_AUTOINCREMENT:     INTEGER := 8;
  constant CONTROL_SOURCE_AUTODECREMENT:     INTEGER := 11;
  constant CONTROL_SOURCE_ADR_INDEXED:       INTEGER := 14;
  constant CONTROL_SOURCE_INDIRECT:          INTEGER := 20;
  constant CONTROL_MOV_MDR_TO_SRC:           INTEGER := 21;
  
  constant CONTROL_DESTINATION_DIRECT_REGISTER:   INTEGER := 23;
  constant CONTROL_DESTINATION_INDIRECT_REGISTER: INTEGER := 25;
  constant CONTROL_DESTINATION_AUTOINCREMENT:     INTEGER := 27;
  constant CONTROL_DESTINATION_AUTODECREMENT:     INTEGER := 30;
  constant CONTROL_DESTINATION_ADR_INDEXED:       INTEGER := 33;
  constant CONTROL_DESTINATION_INDIRECT:          INTEGER := 39;
  constant CONTROL_MOV_MDR_TO_DST:                INTEGER := 40;
  
  constant CONTROL_MOV: INTEGER := 42;
  constant CONTROL_ADD: INTEGER := 44;
  constant CONTROL_ADC: INTEGER := 47;
  constant CONTROL_SUB: INTEGER := 50;
  constant CONTROL_SBC: INTEGER := 53;
  constant CONTROL_AND: INTEGER := 56;
  constant CONTROL_OR:  INTEGER := 59;
  constant CONTROL_XOR: INTEGER := 62;
  constant CONTROL_CMP: INTEGER := 65;
  
  constant CONTROL_INC: INTEGER := 68;
  constant CONTROL_DEC: INTEGER := 70;
  constant CONTROL_CLR: INTEGER := 72;
  constant CONTROL_INV: INTEGER := 74;
  constant CONTROL_LSR: INTEGER := 76;
  constant CONTROL_ROR: INTEGER := 78;
  constant CONTROL_ASR: INTEGER := 80;
  constant CONTROL_LSL: INTEGER := 82;
  constant CONTROL_ROL: INTEGER := 84;
  
  constant CONTROL_BRANCH_OFFSET: INTEGER := 86;
  constant CONTROL_MOV_Z_TO_PC:   INTEGER := 89;
  
  constant CONTROL_JSR:                  INTEGER := 94;
  constant CONTROL_JSR_AFTER_PUSH:       INTEGER := 99;
  constant CONTROL_INTERRUPT:            INTEGER := 101;
  constant CONTROL_INTERRUPT_AFTER_PUSH: INTEGER := 103;
  
  constant CONTROL_START_IRET:    INTEGER := 108;
  constant CONTROL_START_RTS:     INTEGER := 108;
  constant CONTROL_START_POP_PC:  INTEGER := 108;
  constant CONTROL_CONTINUE_IRET: INTEGER := 112;
  
  constant CONTROL_PUSH: INTEGER := 116;
  
  constant CONTROL_DIRECT_REGISTER_MODE: INTEGER := 119;
  constant CONTROL_INDIRECT_WRITE_MODE:  INTEGER := 121;

begin
  status_N <= statusRegister(0);
  status_C <= statusRegister(1);
  status_Z <= statusRegister(2);

  PROCESS (IR, controlStepCounter)
    variable controlStep: integer;
    variable handlingInterrupt: std_logic := '0';

  BEGIN
    controlStep := to_integer(signed(controlStepCounter));

    -- Handle interrupts only at the start of a new instruction
    if controlStep = 0 then
      handlingInterrupt := interrupt;
    end if;

    if handlingInterrupt = '1' THEN
      case controlStep is
        when 0 =>
          load <= std_logic_vector(to_unsigned(CONTROL_INTERRUPT, load'length)); -- row 109 (INTERRUPT)
        when 2 =>
          load <= std_logic_vector(to_unsigned(CONTROL_PUSH, load'length)); -- row 124 (PUSH)
        when 5 =>
          load <= std_logic_vector(to_unsigned(CONTROL_INTERRUPT_AFTER_PUSH, load'length)); -- row 111 (INTERRUPT AFTER PUSH)
        when 10 =>
          load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
        when others => null;
      end case;
    else
    -- one op instruction
    IF IR_opcode = OPCODE_ONE_OP THEN
      -- STEP ONE: FETCH DESTINATION
      IF (controlStep = 3) THEN
        case IR_one_op_adr is
        when ADR_REG_DIRECT =>
          -- destination fetching
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_DIRECT_REGISTER, load'length));
    
        when ADR_REG_INDIRECT =>
          -- reg indirect instruction
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_INDIRECT_REGISTER, load'length));
        
        when ADR_AUTO_INCREMENT | ADR_AUTO_INCREMENT_INDIRECT =>
          -- auto increment instruction [SHOULD HANDLE DIRECT AND INDIRECT]
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_AUTOINCREMENT, load'length));

        when ADR_AUTO_DECREMENT | ADR_AUTO_DECREMENT_INDIRECT =>
          -- auto decrement instruction [SHOULD HANDLE DIRECT AND INDIRECT]
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_AUTODECREMENT, load'length));

        when ADR_INDEXED | ADR_INDEXED_INDIRECT => -- NOTE: should we add ADR_INDEXED indirect here?
          -- ADR_INDEXED instruction [SHOULD HANDLE DIRECT AND INDIRECT]
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_ADR_INDEXED, load'length));
        
        when others => null;
        end case;
      END IF;

      IF (
        ( controlStep = 5 AND IR_one_op_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 6 AND IR_one_op_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 6 AND IR_one_op_adr = ADR_AUTO_DECREMENT ) OR 
        ( controlStep = 9 AND IR_one_op_adr = ADR_INDEXED )
       ) THEN
        load <= std_logic_vector(to_unsigned(CONTROL_MOV_MDR_TO_DST, load'length));
      END IF;
      
      IF (
        ( controlStep = 7  AND IR_one_op_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 7  AND IR_one_op_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR 
        ( controlStep = 10 AND IR_one_op_adr = ADR_INDEXED_INDIRECT )
       ) THEN
        load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_INDIRECT, load'length));
      END IF;

      -- GO TO INSTRUCTION
      IF (
        ( controlStep = 5  AND IR_one_op_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 7  AND IR_one_op_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 8  AND IR_one_op_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 8  AND IR_one_op_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 11 AND IR_one_op_adr = ADR_INDEXED ) OR
        ( controlStep = 9  AND IR_one_op_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 9  AND IR_one_op_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 12 AND IR_one_op_adr = ADR_INDEXED_INDIRECT )
      ) THEN
        -- GO TO THE INSTRUCTION
        case IR_one_op_opcode is
        when OPCODE_INC =>
          load <= std_logic_vector(to_unsigned(CONTROL_INC, load'length));

        when OPCODE_DEC =>
          load <= std_logic_vector(to_unsigned(CONTROL_DEC, load'length));

        when OPCODE_CLR =>
          load <= std_logic_vector(to_unsigned(CONTROL_CLR, load'length));

        when OPCODE_INV =>
          load <= std_logic_vector(to_unsigned(CONTROL_INV, load'length));

        when OPCODE_LSR =>
          load <= std_logic_vector(to_unsigned(CONTROL_LSR, load'length));

        when OPCODE_ROR =>
          load <= std_logic_vector(to_unsigned(CONTROL_ROR, load'length));

        when OPCODE_ASR =>
          load <= std_logic_vector(to_unsigned(CONTROL_ASR, load'length));

        when OPCODE_LSL =>
          load <= std_logic_vector(to_unsigned(CONTROL_LSL, load'length));

        when OPCODE_ROL =>
          load <= std_logic_vector(to_unsigned(CONTROL_ROL, load'length));
        
        when others => null;
        end case;
      END IF;

      IF (
        ( controlStep = 7  AND IR_one_op_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 9  AND IR_one_op_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 10 AND IR_one_op_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 10 AND IR_one_op_adr = ADR_AUTO_DECREMENT ) OR 
        ( controlStep = 13 AND IR_one_op_adr = ADR_INDEXED ) OR
        ( controlStep = 11 AND IR_one_op_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 11 AND IR_one_op_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR 
        ( controlStep = 14 AND IR_one_op_adr = ADR_INDEXED_INDIRECT )
      ) THEN -- BUG: should be >= 10
        -- Move Z to Rdst
        IF IR_one_op_adr = ADR_REG_DIRECT THEN
          load <= std_logic_vector(to_unsigned(CONTROL_DIRECT_REGISTER_MODE, load'length));
        ELSE 
          load <= std_logic_vector(to_unsigned(CONTROL_INDIRECT_WRITE_MODE, load'length));
        END IF;
      END IF;

      IF (
        ( controlStep = 9  AND IR_one_op_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 11 AND IR_one_op_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 12 AND IR_one_op_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 12 AND IR_one_op_adr = ADR_AUTO_DECREMENT ) OR 
        ( controlStep = 15 AND IR_one_op_adr = ADR_INDEXED ) OR
        ( controlStep = 13 AND IR_one_op_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 13 AND IR_one_op_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR 
        ( controlStep = 16 AND IR_one_op_adr = ADR_INDEXED_INDIRECT )
      ) THEN
        -- GO TO END	
        load <= (OTHERS => '0');
      END IF;
        
    ELSIF IR_branch_opcode = "11" THEN -- REVISED
      case controlStep is
      when 3 => -- go to corresponding branch instruction
        case IR_branch_mode is
        when BRANCH_BR =>
          load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset

        when BRANCH_BEQ =>
          IF status_Z = '1' THEN
            load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
          ELSE
            load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
          END IF;

        when BRANCH_BNE =>
          IF status_Z = '0' THEN
            load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
          ELSE
            load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
          END IF;

        when BRANCH_BLO =>
          IF status_C = '0' THEN
            load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
          ELSE
            load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
          END IF;

        when BRANCH_BLS =>
          IF status_C = '0' OR status_Z = '1' THEN
            load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
          ELSE
            load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
          END IF;

        when BRANCH_BHI =>
          IF status_C = '1' THEN
            load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
          ELSE
            load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
          END IF;

        when BRANCH_BHS =>
          IF status_C = '1' OR status_Z = '1' THEN
            load <= std_logic_vector(to_unsigned(CONTROL_BRANCH_OFFSET, load'length)); -- Branch Offset
          ELSE
            load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
          END IF;
        when others => null;
        end case;

      when 6 => -- 88: µ-PC <= PLA(IR)$ [Double Operand]::ADD SRC, DST
        load <= std_logic_vector(to_unsigned(CONTROL_ADD, load'length)); -- 44: ADD SRC, DST
      
      when 9 => -- 46: µ-PC <= PLA(IR)$ [Move Z to PC] if BranchOffset
        load <= std_logic_vector(to_unsigned(CONTROL_MOV_Z_TO_PC, load'length)); -- 89: MOV Z to PC

      when 11 => -- 90: µ-PC <= PLA(IR)$ END
        load <= std_logic_vector(to_unsigned(CONTROL_END, load'length));
      
      when others => null;
      end case;
    
    ELSIF IR_opcode = OPCODE_NO_OP THEN -- REVISED
      case IR_one_op_opcode is
      when OPCODE_HLT =>
        halt <= '1';

      when OPCODE_NOP =>
        load <= std_logic_vector(to_unsigned(CONTROL_END, load'length));

      when others => null;
      end case;

      
    ELSIF IR_opcode = OPCODE_JMP THEN -- REVISED
      -- jump instruction
      case IR_one_op_opcode is
      when OPCODE_JSR =>
        case controlStep is
        when 3 =>
          load <= std_logic_vector(to_unsigned(CONTROL_JSR, load'length)); -- row 102 (JSR)
        when 8 =>
          load <= std_logic_vector(to_unsigned(CONTROL_PUSH, load'length)); -- row 124 (PUSH)
        when 11 =>
          load <= std_logic_vector(to_unsigned(CONTROL_JSR_AFTER_PUSH, load'length)); -- row 107 (JSR AFTER PUSH)
        when 13 =>
          load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
        when others => null;
        end case;

      when OPCODE_RTS =>
        case controlStep is
        when 3 =>
          load <= std_logic_vector(to_unsigned(CONTROL_START_RTS, load'length)); -- row 116 (Start RTS)
        when 7 =>
          load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
        when others => null;
        end case;
        
      when OPCODE_INT =>
        case controlStep is
        when 3 =>
          load <= std_logic_vector(to_unsigned(CONTROL_INTERRUPT, load'length)); -- row 109 (INTERRUPT)
        when 5 =>
          load <= std_logic_vector(to_unsigned(CONTROL_PUSH, load'length)); -- row 124 (PUSH)
        when 8 =>
          load <= std_logic_vector(to_unsigned(CONTROL_INTERRUPT_AFTER_PUSH, load'length)); -- row 111 (INTERRUPT AFTER PUSH)
        when 13 =>
          load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
        when others => null;
        end case;

      when OPCODE_IRET =>
        case controlStep is
        when 3 =>
          load <= std_logic_vector(to_unsigned(CONTROL_START_IRET, load'length)); -- row 116 (Start RTS)
        when 7 =>
          load <= std_logic_vector(to_unsigned(CONTROL_CONTINUE_IRET, load'length)); -- continue IRET
        when 11 =>
          load <= std_logic_vector(to_unsigned(CONTROL_END, load'length)); -- END
        when others => null;
        end case;

      when others => null;
      end case;
    -- ########### DOUBLE OP INSTRUCTIONS ###########
    ELSIF (
      IR_opcode = OPCODE_MOV OR
      IR_opcode = OPCODE_ADD OR
      IR_opcode = OPCODE_ADC OR
      IR_opcode = OPCODE_SUB OR
      IR_opcode = OPCODE_SBC OR
      IR_opcode = OPCODE_AND OR
      IR_opcode = OPCODE_OR OR
      IR_opcode = OPCODE_XOR OR
      IR_opcode = OPCODE_CMP
    ) THEN
      
      -- FIRST STEP: SOURCE FETCHING
      IF (controlStep = 3) THEN
        --SOURCE FETCHING
        case IR_source_adr is
        when ADR_REG_DIRECT =>
          -- reg direct
          load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_DIRECT_REGISTER, load'length));
      
        when ADR_REG_INDIRECT =>
          -- reg indirect instruction
          load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_INDIRECT_REGISTER, load'length));
        
        when ADR_AUTO_INCREMENT | ADR_AUTO_INCREMENT_INDIRECT =>
          -- auto increment instruction [SHOULD HANDLE DIRECT AND INDIRECT]
          load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_AUTOINCREMENT, load'length));

        when ADR_AUTO_DECREMENT | ADR_AUTO_DECREMENT_INDIRECT =>
          -- auto decrement instruction [SHOULD HANDLE DIRECT AND INDIRECT]
          load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_AUTODECREMENT, load'length));

        when ADR_INDEXED | ADR_INDEXED_INDIRECT =>
          -- ADR_INDEXED instruction [SHOULD HANDLE DIRECT AND INDIRECT]
          load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_ADR_INDEXED, load'length));
        
        when others => null;
        end case;
      END IF;

      -- if SRC is reg indirect and CSC is 7 go to dest fetching
      IF (
        (controlStep = 5 AND IR_source_adr = ADR_REG_INDIRECT) OR
        (controlStep = 6 AND IR_source_adr = ADR_AUTO_INCREMENT) OR
        (controlStep = 6 AND IR_source_adr = ADR_AUTO_DECREMENT) OR
        (controlStep = 9 AND IR_source_adr = ADR_INDEXED)
      ) THEN
        load <= std_logic_vector(to_unsigned(CONTROL_MOV_MDR_TO_SRC, load'length));
      END IF;

      -- if SRC is reg direct and CSC is 7 go to dest fetching
      IF (
        (controlStep = 6 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT) OR
        (controlStep = 6 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT) OR
        (controlStep = 9 AND IR_source_adr = ADR_INDEXED_INDIRECT)
      ) THEN
        load <= std_logic_vector(to_unsigned(CONTROL_SOURCE_INDIRECT, load'length));
      END IF;

      -- SECOND STEP: DEST FETCHING [ Depends on src ]
      IF (
        (controlStep = 5  AND IR_source_adr = ADR_REG_DIRECT) OR
        (controlStep = 7  AND IR_source_adr = ADR_REG_INDIRECT) OR
        (controlStep = 8  AND IR_source_adr = ADR_AUTO_INCREMENT) OR -- BUG: controlStepCounter should be 8?
        (controlStep = 9  AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT) OR --BUG: controlStepCounter should be 9?
        (controlStep = 8  AND IR_source_adr = ADR_AUTO_DECREMENT) OR -- BUG: controlStepCounter should be 8?
        (controlStep = 9  AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT) OR -- BUG: controlStepCounter should be 9?
        (controlStep = 11 AND IR_source_adr = ADR_INDEXED) OR
        (controlStep = 12 AND IR_source_adr = ADR_INDEXED_INDIRECT)
      ) THEN
        --DEST FETCHING
        case IR_destination_adr is
        when ADR_REG_DIRECT =>
          -- reg direct
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_DIRECT_REGISTER, load'length));
      
        when ADR_REG_INDIRECT =>
          -- reg indirect instruction
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_INDIRECT_REGISTER, load'length));
        
        when ADR_AUTO_INCREMENT | ADR_AUTO_INCREMENT_INDIRECT =>
          -- auto increment instruction [SHOULD HANDLE DIRECT AND INDIRECT]
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_AUTOINCREMENT, load'length));

        when ADR_AUTO_DECREMENT | ADR_AUTO_DECREMENT_INDIRECT =>
          -- auto decrement instruction [SHOULD HANDLE DIRECT AND INDIRECT]
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_AUTODECREMENT, load'length));

        when ADR_INDEXED | ADR_INDEXED_INDIRECT =>
          -- ADR_INDEXED instruction [SHOULD HANDLE DIRECT AND INDIRECT]
          load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_ADR_INDEXED, load'length));

        when others => null;
        end case;
      END IF;
    
      IF (
        -- DEST IS ADR_REG_INDIRECT
        ( controlStep = 7  AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 9  AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 10 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 10 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_INDIRECT ) OR

        -- DEST IS ADR_AUTO_INCREMENT
        ( controlStep = 8  AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 10 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR

        -- DEST IS ADR_AUTO_DECREMENT
        ( controlStep = 8  AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 10 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR

        -- DEST IS ADR_INDEXED
        ( controlStep = 11 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED )
      ) THEN
        load <= std_logic_vector(to_unsigned(CONTROL_MOV_MDR_TO_DST, load'length));
      END IF;

      IF (
        -- DEST IS ADR_AUTO_INCREMENT_INDIRECT
        ( controlStep = 8  AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 10 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR

        -- DEST IS ADR_AUTO_DECREMENT_INDIRECT
        ( controlStep = 8  AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 10 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR

        -- DEST IS ADR_INDEXED_INDIRECT
        ( controlStep = 11 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED_INDIRECT )

      ) THEN
        load <= std_logic_vector(to_unsigned(CONTROL_DESTINATION_INDIRECT, load'length));
      END IF;
      
      -- STEP 3: GO TO THE TWO OP INSTRUCTION
      IF (
        -- DEST IS ADR_REG_DIRECT
        ( controlStep = 7  AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 9  AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 10 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 10 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_DIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_DIRECT ) OR

        -- DEST IS ADR_REG_INDIRECT
        ( controlStep = 9  AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_INDIRECT ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_INDIRECT ) OR

        -- DEST IS ADR_AUTO_INCREMENT
        ( controlStep = 10 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT ) OR

        -- DEST IS ADR_AUTO_DECREMENT
        ( controlStep = 10 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT ) OR

        -- DEST IS ADR_INDEXED
        ( controlStep = 13 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED ) OR

        -- DEST IS ADR_AUTO_INCREMENT_INDIRECT
        ( controlStep = 11 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT ) OR

        -- DEST IS ADR_AUTO_DECREMENT_INDIRECT
        ( controlStep = 11 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT ) OR

        -- DEST IS ADR_INDEXED_INDIRECT
        ( controlStep = 14 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED_INDIRECT ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED_INDIRECT )
        ) THEN
        -- JUMP TO OPERAND INSTRUCTION
        
        -- CHECKING INSTRUCTION
        IF IR_opcode = OPCODE_MOV THEN
          -- MOV INSTRUCTION
          load <= std_logic_vector(to_unsigned(CONTROL_MOV, load'length));

        ELSIF IR_opcode = OPCODE_ADD THEN
          -- ADD INSTRUCTION
          load <= std_logic_vector(to_unsigned(CONTROL_ADD, load'length));

        ELSIF IR_opcode = OPCODE_ADC THEN
          -- ADC INSTRUCTION
          load <= std_logic_vector(to_unsigned(CONTROL_ADC, load'length));

        ELSIF IR_opcode = OPCODE_SUB THEN
          -- SUB INSTRUCTION
          load <= std_logic_vector(to_unsigned(CONTROL_SUB, load'length));

        ELSIF IR_opcode = OPCODE_SBC THEN
          -- SBC INSTRUCTION
          load <= std_logic_vector(to_unsigned(CONTROL_SBC, load'length));

        ELSIF IR_opcode = OPCODE_AND THEN
          -- AND INSTRUCTION
          load <= std_logic_vector(to_unsigned(CONTROL_AND, load'length));

        ELSIF IR_opcode = OPCODE_OR THEN
          -- OR INSTRUCTION
          load <= std_logic_vector(to_unsigned(CONTROL_OR, load'length));

        ELSIF IR_opcode = OPCODE_XOR THEN
          -- XOR INSTRUCTION
          load <= std_logic_vector(to_unsigned(CONTROL_XOR, load'length));

        ELSIF IR_opcode = OPCODE_CMP THEN
          -- CMP INSTRUCTION
          load <= std_logic_vector(to_unsigned(CONTROL_CMP, load'length));

        END IF;
      END IF;

      IF (
        -- DEST IS ADR_REG_DIRECT
        ( controlStep = 9  AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 11 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_REG_INDIRECT
        ( controlStep = 11 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_INCREMENT
        ( controlStep = 12 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        

        -- DEST IS ADR_AUTO_INCREMENT_INDIRECT
        ( controlStep = 13 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_DECREMENT
        ( controlStep = 12 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_DECREMENT_INDIRECT
        ( controlStep = 13 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_INDEXED
        ( controlStep = 15 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_INDEXED_INDIRECT
        ( controlStep = 16 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 23 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR

        -----------------------------------------------------
        -- DEST IS ADR_REG_DIRECT
        ( controlStep = 10 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 12 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_REG_INDIRECT
        ( controlStep = 12 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_INCREMENT
        ( controlStep = 13 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        

        -- DEST IS ADR_AUTO_INCREMENT_INDIRECT
        ( controlStep = 14 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_DECREMENT
        ( controlStep = 13 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_DECREMENT_INDIRECT
        ( controlStep = 14 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_INDEXED
        ( controlStep = 16 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 23 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_INDEXED_INDIRECT
        ( controlStep = 17 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 23 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 24 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV )
      ) THEN
        IF IR_opcode = OPCODE_CMP THEN
          load <= (OTHERS => '0');
        else
          IF IR_destination_adr = ADR_REG_DIRECT THEN
            -- reg direct
            load <= std_logic_vector(to_unsigned(CONTROL_DIRECT_REGISTER_MODE, load'length));
          ELSE 
            load <= std_logic_vector(to_unsigned(CONTROL_INDIRECT_WRITE_MODE, load'length));
          END IF;
        END IF;
        -- DEST FETCHING
      END IF;

      IF (
        -- DEST IS ADR_REG_DIRECT
        ( controlStep = 11 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 13 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_REG_INDIRECT
        ( controlStep = 13 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_INCREMENT
        ( controlStep = 14 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode = OPCODE_MOV ) OR
        

        -- DEST IS ADR_AUTO_INCREMENT_INDIRECT
        ( controlStep = 15 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_DECREMENT
        ( controlStep = 14 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_DECREMENT_INDIRECT
        ( controlStep = 15 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_INDEXED
        ( controlStep = 17 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 23 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 24 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode = OPCODE_MOV ) OR

        -- DEST IS ADR_INDEXED_INDIRECT
        ( controlStep = 18 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 24 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR
        ( controlStep = 25 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode = OPCODE_MOV ) OR


        -----------------------------------------------------
        -- DEST IS ADR_REG_DIRECT
        ( controlStep = 12 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 14 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 15 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_DIRECT              AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_REG_INDIRECT
        ( controlStep = 14 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 16 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_REG_INDIRECT            AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_INCREMENT
        ( controlStep = 15 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        

        -- DEST IS ADR_AUTO_INCREMENT_INDIRECT
        ( controlStep = 16 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 23 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_DECREMENT
        ( controlStep = 15 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 17 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT          AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_AUTO_DECREMENT_INDIRECT
        ( controlStep = 16 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 18 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 19 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 23 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_opcode /= OPCODE_MOV ) OR

        -- DEST IS ADR_INDEXED
        ( controlStep = 18 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 20 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 24 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 25 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED                 AND IR_opcode /= OPCODE_MOV ) OR
        
        -- DEST IS ADR_INDEXED_INDIRECT
        ( controlStep = 19 AND IR_source_adr = ADR_REG_DIRECT              AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 21 AND IR_source_adr = ADR_REG_INDIRECT            AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_AUTO_INCREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 23 AND IR_source_adr = ADR_AUTO_INCREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 22 AND IR_source_adr = ADR_AUTO_DECREMENT          AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 23 AND IR_source_adr = ADR_AUTO_DECREMENT_INDIRECT AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 25 AND IR_source_adr = ADR_INDEXED                 AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV ) OR
        ( controlStep = 26 AND IR_source_adr = ADR_INDEXED_INDIRECT        AND IR_destination_adr = ADR_INDEXED_INDIRECT        AND IR_opcode /= OPCODE_MOV )
        
      ) THEN
        load <= (OTHERS => '0');
      END IF;

    END IF;
    end if;
  END PROCESS;
end architecture;