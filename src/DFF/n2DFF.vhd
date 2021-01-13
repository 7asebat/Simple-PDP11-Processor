library IEEE;
use ieee.std_logic_1164.all;

entity n2DFF is
  generic (SIZE: integer := 16);
  port(clk:   in  std_logic;
       reset: in  std_logic;

       A_en:  in  std_logic;
       A_in:  in  std_logic_vector(SIZE-1 downto 0);
       A_out: out std_logic_vector(SIZE-1 downto 0);

       B_en:  in  std_logic;
       B_in:  in  std_logic_vector(SIZE-1 downto 0);
       B_out: out std_logic_vector(SIZE-1 downto 0));
end entity;

architecture main of n2DFF is
  signal s_D: std_logic_vector(15 downto 0);
  signal s_Q: std_logic_vector(15 downto 0);
  signal s_en: std_logic;
begin
  A_out <= s_Q;
  B_out <= s_Q;

  -- Select input source based on enable
  s_D <= A_in when A_en = '1' 
    else B_in;

  s_en <= A_en or B_en;

  MAP_REGISTER: entity work.nDFF(main)
    generic map(SIZE) 
    port map(clk, s_en, reset, s_D, s_Q);

end main;

-- ===================================================================
library IEEE;
use ieee.std_logic_1164.all;
use work.utility_pack.all;

entity n2DFF_tb is
end n2DFF_tb;

-- MDR testbench
architecture main of n2DFF_tb is
  signal t_clock: std_logic;
  signal t_reset: std_logic;

  signal t_busEnable: std_logic;
  signal t_busIn:     std_logic_vector(15 downto 0);
  signal t_busOut:    std_logic_vector(15 downto 0);

  signal t_ramEnable: std_logic;
  signal t_ramIn:     std_logic_vector(15 downto 0);
  signal t_ramOut:    std_logic_vector(15 downto 0); 

  type TestInput is array (0 to 3) of std_logic_vector(0 to 40);
  -- Reset __ BUS __ RAM
  constant input_cases: TestInput := (b"1" & x"1_0000" & x"1_0000", -- Reset
                                      b"0" & x"0_0000" & x"1_0F0F", -- Read from memory
                                      b"0" & x"1_F0F0" & x"0_0000", -- Read from bus
                                      b"0" & x"1_F000" & x"1_000F"); -- Read from bus over memory

  type TestOutput is array (0 to 3) of std_logic_vector(15 downto 0);
  constant output_cases: TestOutput := (x"0000", x"0F0F", x"F0F0", x"F000");

begin
  process begin
    for i in input_cases'range loop
      t_reset <= input_cases(i)(0);

      t_busEnable <= input_cases(i)(4); -- @note 0x padding
      t_busIn <= input_cases(i)(5 to 20);

      t_ramEnable <= input_cases(i)(24); -- @note 0x padding
      t_ramIn <= input_cases(i)(25 to 40);

      t_clock <= '0';
      wait for 50 ns;
      t_clock <= '1';
      wait for 50 ns;
    
      assert((t_busOut = t_ramOut) and (t_busOut = output_cases(i)))
      report "received (" 
        & to_hstring(t_busOut) & "), "
        & "expected (" 
        & to_hstring(output_cases(i)) & ") "
        & "for (" 
        & to_string(input_cases(i)(0 to 0)) & ", "
        & to_hstring(input_cases(i)(1 to 20)) & ", "
        & to_hstring(input_cases(i)(21 to 40)) & ")"
      severity ERROR;

    end loop;
    wait;
  end process;

  tb: entity work.n2DFF(main) 
    generic map(16)
    port map(t_clock, t_reset, 
             t_busEnable, t_busIn, t_busOut,
             t_ramEnable, t_ramIn, t_ramOut);
end main;