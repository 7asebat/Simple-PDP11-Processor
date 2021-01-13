Library ieee;
Use ieee.std_logic_1164.all;

ENTITY ALU IS 
	GENERIC(n: INTEGER := 16);
	PORT(
			A, B: IN std_logic_vector(n-1 DOWNTO 0);
			S: IN std_logic_vector(3 DOWNTO 0);
			Cin: IN std_logic;
			F: OUT std_logic_vector(n-1 DOWNTO 0);
			flag: out std_logic_vector(2 downto 0) -- Z, C, N
	);
END ENTITY;

ARCHITECTURE default OF ALU IS
	COMPONENT partA IS
	GENERIC (n: INTEGER := 16);
	PORT(
		A, B: IN std_logic_vector(n-1 DOWNTO 0);
		Cin: IN std_logic;
		S: IN std_logic_vector(n-1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0);
		Cout: OUT std_logic
	);
	END COMPONENT;
	
	SIGNAL Cout0: std_logic;
	SIGNAL F0: std_logic_vector(n-1 DOWNTO 0);

	COMPONENT partB IS
	GENERIC (n: INTEGER := 16);
	PORT(
		A,B: IN std_logic_vector(n-1 DOWNTO 0);
		S: IN std_logic_vector(1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0)
	);
	END COMPONENT;

	SIGNAL F1: std_logic_vector(n-1 DOWNTO 0);

	COMPONENT partC IS 
	GENERIC (n: INTEGER := 16);
	PORT(
		A: IN std_logic_vector(n-1 DOWNTO 0);
		Cin: IN std_logic;
		S: IN std_logic_vector(1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0);
		Cout: OUT std_logic
	);
	END COMPONENT;

	SIGNAL F2: std_logic_vector(n-1 DOWNTO 0);
	SIGNAL Cout2: std_logic;

	COMPONENT partD IS 
	GENERIC (n: INTEGER := 16);
	PORT(
		A: IN std_logic_vector(n-1 DOWNTO 0);
		Cin: IN std_logic;
		S: IN std_logic_vector(1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0);
		Cout: OUT std_logic
	);
	END COMPONENT;

	SIGNAL F3: std_logic_vector(n-1 DOWNTO 0);
	SIGNAL Cout3: std_logic;

	SIGNAL s_F: std_logic_vector(15 downto 0);
	SIGNAL s_Cout: std_logic;
BEGIN

pA: partA GENERIC MAP(n) PORT MAP(A, B, Cin, S(1 DOWNTO 0), F0, Cout0);
pB: partB GENERIC MAP(n) PORT MAP(A, B, S(1 DOWNTO 0), F1);
pC: partC GENERIC MAP(n) PORT MAP(A, Cin, S(1 DOWNTO 0), F2, Cout2);
pD: partD GENERIC MAP(n) PORT MAP(A, Cin, S(1 DOWNTO 0), F3, Cout3);

F <= s_F;
WITH S(3 DOWNTO 2) SELECT
	s_F <= 	F0 WHEN "00",
					F1 WHEN "01",
					F2 WHEN "10",
					F3 WHEN "11",
					(OTHERS => 'U') WHEN OTHERS;

WITH S(3 DOWNTO 2) SELECT
	s_Cout <= Cout0 WHEN "00",
						Cout2 WHEN "10",
						Cout3 WHEN "11",
						'U' WHEN OTHERS;

with s_F select
	flag(2) <= '1' when x"0000",
						 '0' when others;

flag(1) <= '0' when s_Cout = 'U' else s_Cout;
flag(0) <= s_F(15);

END ARCHITECTURE;

-- ===================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.utility_pack.all;

entity ALU_tb is
end ALU_tb;

architecture ALU_tb_arch of ALU_tb is
  component ALU is
		port(A, B: IN std_logic_vector(15 DOWNTO 0);
				 S: IN std_logic_vector(3 DOWNTO 0);
				 Cin: IN std_logic;
				 F: OUT std_logic_vector(15 DOWNTO 0);
				 flag: out std_logic_vector(2 downto 0)); -- Z, C, N
  end component;

  signal t_Cin:  std_logic;
  signal t_A:    std_logic_vector(15 downto 0);
  signal t_B:    std_logic_vector(15 downto 0);
	signal t_S:    std_logic_vector(3 downto 0);

  signal t_F:    std_logic_vector(15 downto 0);
  signal t_flag: std_logic_vector(2 downto 0);

  type TestInput is array (0 to 15) of std_logic_vector(0 to 39);
	-- Cin __ A __ B __ S
  constant test_input: TestInput := (
		x"0_0F0F_0000_0",  -- A + Cin

		x"1_0F0F_0011_1",  -- A + B + Cin

		x"1_0F0F_0F10_2",  -- A - B - (!Cin)

		x"0_0001_0000_3",  -- (A - 1) & (!Cin)

		x"0_0F0F_0FF0_4",  -- A & B

		x"0_0F0F_00F0_5",  -- A | B

		x"0_0F0F_00FF_6",  -- A ^ B

		x"0_0F0F_0000_7",  -- !A

		x"0_0F0F_0000_8",  -- LSR A

		x"0_0F0F_0000_9",  -- ROR A

		x"0_0F0F_0000_A",  -- RRC A

		x"0_0F0F_0000_B",  -- ASR A

		x"0_0F0F_0000_C",  -- LSL A

		x"0_0F0F_0000_D",  -- ROL A

		x"1_0F0F_0000_E",  -- RLC A

		x"0_0F0F_0000_F"   -- 0000
	);

	type TestOutput is array (0 to 15) of std_logic_vector(18 downto 0);
	-- Flag(Z, C, N) __ F
	constant test_output: TestOutput := (
		b"000" & x"0F0F",  -- A + Cin

		b"000" & x"0F21",  -- A + B + Cin

		b"001" & x"FFFF",  -- A - B - (!Cin)

		b"110" & x"0000",  -- (A - 1) & (!Cin), @note Not sure about the zero, carry flags here

		b"000" & x"0F00",  -- A & B

		b"000" & x"0FFF",  -- A | B

		b"000" & x"0FF0",  -- A ^ B

		b"001" & x"F0F0",  -- !A

		b"010" & x"0787",  -- LSR A

		b"011" & x"8787",  -- ROR A, @note Not sure about carry flag

		b"010" & x"0787",  -- RRC A

		b"010" & x"0787",  -- ASR A

		b"000" & x"1E1E",  -- LSL A
		
		b"000" & x"1E1E",  -- ROL A

		b"000" & x"1E1F",  -- RLC A
		
		b"100" & x"0000"   -- 0000
	);
begin
  process 
    variable v_OP: std_logic_vector(18 downto 0);
  begin
		for i in test_input'range loop
			t_Cin <= test_input(i)(3); -- @note first 3 bits are hexadecimal padding
			t_A <= test_input(i)(4 to 19);
			t_B <= test_input(i)(20 to 35);
			t_S <= test_input(i)(36 to 39);

			v_OP := t_flag & t_F;

			wait for 50 ns;
      assert(t_flag & t_f = test_output(i))
			report "received (" 
				& to_string(t_flag) & ", " 
				& to_hstring(t_F) & "), " 
				& "expected (" 
				& to_string(test_output(i)(18 downto 16)) & ", " 
				& to_hstring(test_output(i)(15 downto 0)) & ") " 
				& "for (" 
				& to_hstring(test_input(i)(0 to 3)) & ", " 
				& to_hstring(test_input(i)(4 to 19)) & ", " 
				& to_hstring(test_input(i)(20 to 35)) & ", " 
				& to_hstring(test_input(i)(36 to 39)) & ")";
      severity ERROR;

		end loop;
		wait;

  end process;
  tb: ALU port map(t_A, t_B, t_S, t_Cin, t_F, t_flag);

  end ALU_tb_arch;
