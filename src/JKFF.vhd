library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity JKFF is
  port(clock: in std_logic;
       reset: in std_logic;
       J:     in std_logic;
       K:     in std_logic;
       Q:     out std_logic);
end JKFF;

architecture JKFF_arch of JKFF is
  signal s_Q: std_logic;

begin
  process(clock, reset, J, K) 
    variable v_JK: std_logic_vector(1 downto 0);

  begin
    v_JK := J & K;

    if rising_edge(clock) then
      case v_JK is
        when "00" => s_Q <= s_Q;
        when "01" => s_Q <= '0';
        when "10" => s_Q <= '1';
        when others => s_Q <= not s_Q;
      end case;
    end if;

    if reset = '1' then
      s_Q <= '0';
    end if;
  end process;

  Q <= s_Q;
end JKFF_arch; -- JKFF_arch

-- ===================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.utility_pack.all;

entity JKFF_tb is
end JKFF_tb;

architecture JKFF_tb_arch of JKFF_tb is
  component JKFF is
  port(clock: in  std_logic;
       reset: in  std_logic;
       J:     in  std_logic;
       K:     in  std_logic;
       Q:     out std_logic);
  end component;

  signal t_clock: std_logic;
  signal t_reset: std_logic;
  signal t_J:     std_logic;
  signal t_K:     std_logic;
  signal t_Q:     std_logic;

  type testcases is array (0 to 4) of std_logic_vector(0 to 3);
  -- Reset, J, K, Q
  constant tests: testcases := (b"100_0",  -- Reset 
                                b"000_0",  -- No change
                                b"010_1",  -- Set
                                b"011_0",  -- Toggle
                                b"001_0"); -- Clear
begin
  process begin
    for i in tests'range loop

      t_reset <= tests(i)(0);
      t_J <= tests(i)(1);
      t_K <= tests(i)(2);

      t_clock <= '0';
      wait for 50 ns;
      t_clock <= '1';
      wait for 50 ns;

      assert(t_Q = tests(i)(3))
      report "received: " & std_logic'image(t_Q)
        & ", expected: " & to_string(tests(i)(3 to 3))
        & " for " & to_string(tests(i)(0 to 2))
      severity ERROR;
    end loop;
    wait;
  end process;
  tb: JKFF port map(t_clock, t_reset, t_J, t_K, t_Q);

end JKFF_tb_arch;