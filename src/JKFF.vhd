library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity JKFF is
  port(clock: in std_logic;
       J: in std_logic;
       K: in std_logic;
       Q: out std_logic);
end JKFF;

architecture JKFF_arch of JKFF is
  signal s_Q: std_logic;

begin
  process(clock, J, K) 
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
       J:     in  std_logic;
       K:     in  std_logic;
       Q:     out std_logic);
  end component;

  signal t_clock: std_logic;
  signal t_J:     std_logic;
  signal t_K:     std_logic;
  signal t_Q:     std_logic;

  type testcases is array (0 to 4) of std_logic_vector(0 to 2);
  constant tests: testcases := (b"01_0", b"00_0", b"10_1", b"11_0", b"11_1"); -- J, K, Q
begin
  process begin
    for i in tests'range loop

      t_J <= tests(i)(0);
      t_K <= tests(i)(1);

      t_clock <= '0';
      wait for 50 ns;
      t_clock <= '1';
      wait for 50 ns;

      assert(t_Q = tests(i)(2))
      report "received: " & std_logic'image(t_Q)
        & ", expected: " & to_string(tests(i)(2 to 2))
        & " for (" & to_string(tests(i)(0 to 0))
        & ", " & to_string(tests(i)(1 to 1)) & ')'
      severity ERROR;
    end loop;
    wait;
  end process;
  tb: JKFF port map(t_clock, t_J, t_K, t_Q);

end JKFF_tb_arch;