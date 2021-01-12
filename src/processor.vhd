-- Working processor here
Library ieee;
Use ieee.std_logic_1164.all;


ENTITY PROCESSOR IS

END ENTITY;
ARCHITECTURE main OF PROCESSOR IS

-- CONSTANTS

CONSTANT BUS_SIZE: INTEGER := 16;
CONSTANT REG_SIZE: INTEGER := 16;
CONSTANT REG_COUNT: INTEGER := 8;

-- GENERAL PURPOSE REGISTERS

TYPE Rx_port_type IS ARRAY(0 TO REG_COUNT-1) of std_logic_vector(REG_SIZE-1 DOWNTO 0);
TYPE Rx_signal_type IS ARRAY(0 TO REG_COUNT-1) of std_logic;
SIGNAL Rx_in: Rx_port_type;
SIGNAL Rx_out: Rx_port_type;
SIGNAL Rx_en: Rx_signal_type;
SIGNAL Rx_reset: Rx_signal_type;

TYPE Tri_Rx_signal_type IS ARRAY(0 TO REG_COUNT-1) of std_logic;
SIGNAL Tri_Rx_en:  Tri_Rx_signal_type;

TYPE Tri_Rx_port_type IS ARRAY(0 TO REG_COUNT-1) of std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Tri_Rx_out: Tri_Rx_port_type;

-- INTERMEDIATE REGISTERS
SIGNAL INT_SRC_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL INT_SRC_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL INT_SRC_en: std_logic;
SIGNAL INT_SRC_reset: std_logic;

SIGNAL Tri_INT_SRC_en: std_logic;
SIGNAL Tri_INT_SRC_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);

SIGNAL INT_DST_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL INT_DST_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL INT_DST_en: std_logic;
SIGNAL INT_DST_reset: std_logic;

SIGNAL Tri_INT_DST_en: std_logic;
SIGNAL Tri_INT_DST_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);

-- STATUS REGISTER
SIGNAL Rstatus_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Rstatus_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Rstatus_en: std_logic;
SIGNAL Rstatus_reset: std_logic;

SIGNAL Tri_Rstatus_en: std_logic;
SIGNAL Tri_Rstatus_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);

-- INSTRUCTION REGISTER
SIGNAL IR_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL IR_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL IR_en: std_logic;
SIGNAL IR_reset: std_logic;

-- TODO: add address decoding circuit and connect it to bus

-- ALU REGISTERS
SIGNAL Ry_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Ry_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Ry_en: std_logic;
SIGNAL Ry_reset: std_logic;

SIGNAL Rz_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Rz_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Rz_en: std_logic;
SIGNAL Rz_reset: std_logic;

SIGNAL Tri_Rz_en: std_logic;
SIGNAL Tri_Rz_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);

-- CLK
SIGNAL clk : std_logic;

-- BUS
SIGNAL shared_bus : std_logic_vector(BUS_SIZE-1 DOWNTO 0);

BEGIN

-- REGISTERS

-- GENERAL PURPOSE
generate_Rx: FOR i IN 0 TO 7 GENERATE
	Rx: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP (clk, Rx_en(i), Rx_reset(i), shared_bus, Rx_out(i));
END GENERATE;
generate_Tri_Rx: FOR i IN 0 TO 7 GENERATE
  Tri_Rx: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_Rx_en(i), Rx_out(i), shared_bus);
END GENERATE;

-- INTERMEDIATE 
INTERMEDIATE_SRC: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, INT_SRC_en, INT_SRC_reset, shared_bus, INT_SRC_out);
Tri_INTERMEDIATE_SRC: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_INT_SRC_en, INT_SRC_out, shared_bus);

INTERMEDIATE_DST: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, INT_DST_en, INT_DST_reset, shared_bus, INT_DST_out);
Tri_INTERMEDIATE_DST: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_INT_DST_en, INT_DST_out, shared_bus);

-- STATUS
STATUS_REGISTER: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, Rstatus_en, Rstatus_reset, Rstatus_in, Rstatus_out); -- BUG: need to handle in signal
Tri_Rstatus: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_Rstatus_en, Rstatus_out, shared_bus);

-- IR
-- TODO: Add IR output circuit
IR: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, IR_en, IR_reset, shared_bus, IR_out); 

-- ALU REGISTERS
ALU_Y_REGISTER: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, Ry_en, Ry_reset, shared_bus, Ry_out);

ALU_Z_REGISTER: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, Rz_en, Rz_reset, Rz_in, Rz_out); 
Tri_Rz: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_INT_DST_en, INT_DST_out, shared_bus);



END ARCHITECTURE;
