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
CONSTANT ALU_F_SIZE: INTEGER := 4;
CONSTANT ALU_SIZE : INTEGER := 16;
CONSTANT FLAGS_COUNT: INTEGER := 3;
CONSTANT COUNTER_SIZE: INTEGER := 16;
CONSTANT PLA_LOAD_SIZE: INTEGER := 16;
CONSTANT CTRL_WORD_SIZE: INTEGER := 21;
CONSTANT CTRL_SIGNALS_SIZE: INTEGER := 61;
CONSTANT RAM_SIZE: INTEGER := 65536;
CONSTANT RAM_WIDTH: INTEGER := 16;

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
SIGNAL Rstatus_bus_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Rstatus_alu_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Rstatus_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL Rstatus_bus_en: std_logic;
SIGNAL Rstatus_alu_en: std_logic;
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

-- ALU

SIGNAL ALU_F: std_logic_vector(ALU_F_SIZE-1 DOWNTO 0);
SIGNAL ALU_Cin: std_logic;
SIGNAL ALU_flags: std_logic_vector(FLAGS_COUNT-1 DOWNTO 0);

-- MEMORY REGISTERS
SIGNAL MDR_bus_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL MDR_ram_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL MDR_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL MDR_bus_en: std_logic;
SIGNAL MDR_ram_en: std_logic;
SIGNAL MDR_reset: std_logic;

SIGNAL Tri_MDR_en: std_logic;
SIGNAL Tri_MDR_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);

SIGNAL MAR_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL MAR_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL MAR_en: std_logic;
SIGNAL MAR_reset: std_logic;

-- CONTROL STEP COUNTER

SIGNAL CTRL_COUNTER_en: std_logic;
SIGNAL CTRL_COUNTER_reset: std_logic;
SIGNAL CTRL_COUNTER_mode: std_logic;
SIGNAL CTRL_COUNTER_load: std_logic;
SIGNAL CTRL_COUNTER_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL CTRL_COUNTER_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);

-- uPC

SIGNAL uPC_en: std_logic;
SIGNAL uPC_reset: std_logic;
SIGNAL uPC_mode: std_logic;
SIGNAL uPC_load: std_logic;
SIGNAL uPC_in: std_logic_vector(REG_SIZE-1 DOWNTO 0);
SIGNAL uPC_out: std_logic_vector(REG_SIZE-1 DOWNTO 0);

-- HALT
SIGNAL HALT_in: std_logic_vector(0 DOWNTO 0);
SIGNAL HALT_out: std_logic_vector(0 DOWNTO 0);
SIGNAL HALT_en: std_logic;
SIGNAL HALT_reset: std_logic;

-- RAM
SIGNAL RAM_read: std_logic;
SIGNAL RAM_write: std_logic;
SIGNAL RAM_MFC: std_logic;

-- uIR
SIGNAL uIR_sig: std_logic_vector(CTRL_WORD_SIZE-1 DOWNTO 0);

-- CONTROL SIGNALS
SIGNAL CTRL_SIGNALS: std_logic_vector(CTRL_SIGNALS_SIZE-1 DOWNTO 0);

-- WMFC
SIGNAL WMFC: std_logic;

-- CLK
SIGNAL clk : std_logic;

-- BUS
SIGNAL shared_bus : std_logic_vector(BUS_SIZE-1 DOWNTO 0);

-- GLOBAL RESET
SIGNAL reset_all: std_logic;
-- TODO: wassal le reset_all

BEGIN

-- REGISTERS

-- GENERAL PURPOSE
generate_Rx: FOR i IN 0 TO 7 GENERATE
  Rx: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP (clk, Rx_en(i), Rx_reset(i), Rx_in(i), Rx_out(i));
  Rx_in(i) <= shared_bus;
END GENERATE;
generate_Tri_Rx: FOR i IN 0 TO 7 GENERATE
  Tri_Rx: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_Rx_en(i), Rx_out(i), Tri_RX_out(i));
  shared_bus <= Tri_Rx_out(i);
END GENERATE;

-- INTERMEDIATE 
INTERMEDIATE_SRC: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, INT_SRC_en, INT_SRC_reset, INT_SRC_in, INT_SRC_out);
INT_SRC_in <= shared_bus;
Tri_INTERMEDIATE_SRC: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_INT_SRC_en, INT_SRC_out, Tri_INT_SRC_out);
shared_bus <= Tri_INT_SRC_out;

INTERMEDIATE_DST: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, INT_DST_en, INT_DST_reset, INT_DST_in, INT_DST_out);
INT_DST_in <= shared_bus;
Tri_INTERMEDIATE_DST: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_INT_DST_en, INT_DST_out, Tri_INT_DST_out);
shared_bus <= Tri_INT_DST_out;

-- STATUS
-- DONE: need to handle status in signal
STATUS_REGISTER: ENTITY work.n2DFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, Rstatus_reset, Rstatus_bus_en, Rstatus_bus_in, Rstatus_alu_en, Rstatus_alu_in, Rstatus_out);
Rstatus_bus_in <= shared_bus;
Rstatus_alu_en <= not(ALU_F(3) AND ALU_F(2) AND ALU_F(1) AND ALU_F(0)); -- Rstatus_alu_en =  ALU_F!=1111
Rstatus_alu_in <= ("0000000000000" & ALU_flags);
Tri_Rstatus: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_Rstatus_en, Rstatus_out, Tri_Rstatus_out);
shared_bus <= Tri_Rstatus_out;

-- IR
-- TODO: Add IR output circuit
IR: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, IR_en, IR_reset, IR_in, IR_out); 
IR_in <= shared_bus;

-- ALU REGISTERS
ALU_Y_REGISTER: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, Ry_en, Ry_reset, Ry_in, Ry_out);
Ry_in <= shared_bus;


ALU_Z_REGISTER: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, Rz_en, Rz_reset, Rz_in, Rz_out); 
Tri_Rz: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_Rz_en, Rz_out, Tri_Rz_out);
shared_bus <= Tri_Rz_out;

-- ALU
ALU: ENTITY work.ALU(main) GENERIC MAP(ALU_SIZE) PORT MAP(Ry_out, shared_bus, ALU_F, ALU_Cin, Rz_in, ALU_flags);

-- RAM MEMORY

RAM: ENTITY work.nmRam(main) GENERIC MAP(RAM_SIZE, RAM_WIDTH) PORT MAP(clk, RAM_write, MAR_out, MDR_out, MDR_ram_in, RAM_MFC);

-- MEMORY REGISTERS
-- DONE: need to handle MDR in signal
MDR_REGISTER: ENTITY work.n2DFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, MDR_reset, MDR_bus_en, MDR_bus_in, MDR_ram_en, MDR_ram_in, MDR_out);
MDR_ram_en <= RAM_read; -- BUG: should be connected with MFC instead?
Tri_MDR: ENTITY work.nTristateBuffer(main) GENERIC MAP(REG_SIZE) PORT MAP (Tri_MDR_en, MDR_out, Tri_MDR_out);
shared_bus <= Tri_MDR_out;

MAR_REGISTER: ENTITY work.nDFF(main) GENERIC MAP(REG_SIZE) PORT MAP(clk, MAR_en, MAR_reset, MAR_in, MAR_out);
MAR_in <= shared_bus;

-- TODO: ADD Interrupt Address Logic Circuit

-- CONTROL STEP COUNTER
CONTROL_STEP_COUNTER: ENTITY work.nCounter(main) GENERIC MAP(COUNTER_SIZE) PORT MAP(clk, CTRL_COUNTER_en, CTRL_COUNTER_mode, CTRL_COUNTER_reset, CTRL_COUNTER_load, CTRL_COUNTER_in, CTRL_COUNTER_out);
CTRL_COUNTER_mode <= '0';
CTRL_COUNTER_en <= '1';

-- PLA
PLA: ENTITY work.PLA(main) GENERIC MAP(REG_SIZE, COUNTER_SIZE) PORT MAP(IR_out, CTRL_COUNTER_out, Rstatus_out, uPC_in, HALT_en);

-- uPC
uPC: ENTITY work.nCounter(main) GENERIC MAP(COUNTER_SIZE) PORT MAP(clk, uPC_en, uPC_mode, uPC_reset, uPC_load, uPC_in, uPC_out);

uPC_mode <= '0';
-- TODO: add RUN signal condition here
uPC_en <= (not (HALT_out(0)));

-- HALT
HALT_REG: ENTITY work.nDFF(main) GENERIC MAP(1) PORT MAP(clk, HALT_en, HALT_reset, HALT_in, HALT_out);
HALT_in <= "1";


-- ROM
ROM: ENTITY work.nmROM(main) PORT MAP(uPC_out, uIR_sig);

-- CONTROL_WORD_DECODER
CTRL_WORD_DECODER: ENTITY work.controlWordDecoder(main) PORT MAP(uIR_sig, IR_out, CTRL_SIGNALS);

-- DONE: Add Read and Write signals to RAM from CTRL_SIGNALS
uPC_load <= CTRL_SIGNALS(0);
WMFC <= CTRL_SIGNALS(1);
ALU_Cin <= CTRL_SIGNALS(2);
Ry_reset <= CTRL_SIGNALS(3);
RAM_read <= CTRL_SIGNALS(4);
RAM_write <= CTRL_SIGNALS(5);
ALU_F <= CTRL_SIGNALS(9 DOWNTO 6);
INT_DST_en <= CTRL_SIGNALS(10);
INT_SRC_en <= CTRL_SIGNALS(11);
Ry_en <= CTRL_SIGNALS(12);
MDR_bus_en <= CTRL_SIGNALS(13); -- DONE: make sure to edit this when MDR multiple inputs are handled
MAR_en <= CTRL_SIGNALS(14);
Rstatus_bus_en <= CTRL_SIGNALS(15); -- DOBE: make sure to edit this when status multiple inputs are handled

Rx_en(0) <= (CTRL_SIGNALS(17) OR CTRL_SIGNALS(25));
Rx_en(1) <= (CTRL_SIGNALS(18) OR CTRL_SIGNALS(26));
Rx_en(2) <= (CTRL_SIGNALS(19) OR CTRL_SIGNALS(27));
Rx_en(3) <= (CTRL_SIGNALS(20) OR CTRL_SIGNALS(28));
Rx_en(4) <= (CTRL_SIGNALS(21) OR CTRL_SIGNALS(29));
Rx_en(5) <= (CTRL_SIGNALS(22) OR CTRL_SIGNALS(30));
Rx_en(6) <= (CTRL_SIGNALS(23) OR CTRL_SIGNALS(31) OR CTRL_SIGNALS(16));
Rx_en(7) <= (CTRL_SIGNALS(24) OR CTRL_SIGNALS(32) OR CTRL_SIGNALS(33));

IR_en <= CTRL_SIGNALS(34);
Rz_en <= CTRL_SIGNALS(35);
Tri_INT_SRC_en <= CTRL_SIGNALS(36);
Tri_INT_DST_en <= CTRL_SIGNALS(37);
-- TODO: Add Address_out signal to IR decoding circuit
Tri_Rstatus_en <= CTRL_SIGNALS(39);

Tri_Rx_en(0) <= (CTRL_SIGNALS(42) OR CTRL_SIGNALS(50));
Tri_Rx_en(1) <= (CTRL_SIGNALS(43) OR CTRL_SIGNALS(51));
Tri_Rx_en(2) <= (CTRL_SIGNALS(44) OR CTRL_SIGNALS(52));
Tri_Rx_en(3) <= (CTRL_SIGNALS(45) OR CTRL_SIGNALS(53));
Tri_Rx_en(4) <= (CTRL_SIGNALS(46) OR CTRL_SIGNALS(54));
Tri_Rx_en(5) <= (CTRL_SIGNALS(47) OR CTRL_SIGNALS(55));
Tri_Rx_en(6) <= (CTRL_SIGNALS(48) OR CTRL_SIGNALS(56) OR CTRL_SIGNALS(40));
Tri_Rx_en(7) <= (CTRL_SIGNALS(49) OR CTRL_SIGNALS(57) OR CTRL_SIGNALS(58));

Tri_MDR_en <= CTRL_SIGNALS(59);
Rz_en <= CTRL_SIGNALS(60);



END ARCHITECTURE;
