Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;
use IEEE.math_real.all;

ENTITY nmRam IS 
  GENERIC(
    n: INTEGER := 32;
    m: INTEGER := 32
  );
  PORT(
    clk: IN std_logic;
    MFC: OUT std_logic;
    read: in std_logic;
    write: in std_logic;
    address: IN std_logic_vector(integer(ceil(log2(real(n))))-1 DOWNTO 0);
    dataIn: IN std_logic_vector(m-1 DOWNTO 0);
    dataOut: OUT std_logic_vector(m-1 DOWNTO 0)
  ); 
END ENTITY;

ARCHITECTURE main OF nmRam IS
  constant DELAY: integer := 2;

  TYPE ram_type IS ARRAY(0 TO n-1) of std_logic_vector(m-1 DOWNTO 0);
  SIGNAL ram: ram_type := (
    -- initialize here 
    10 => (m-1 DOWNTO 8 => '0') & X"0A",
    9 => (m-1 DOWNTO 8 => '0') & X"09",
    8 => (m-1 DOWNTO 8 => '0') & X"08",
    7 => (m-1 DOWNTO 8 => '0') & X"07",
    OTHERS => ((m-1 DOWNTO 8 => '0') & X"00")
  );
BEGIN

-- Delay write operation by two clock cycles
PROCESS(clk)
  variable v_delay: natural range 0 to DELAY := 0;
BEGIN
  IF(rising_edge(clk)) THEN
    v_delay := v_delay + 1;
    
    if v_delay = DELAY then
      v_delay := 0;

      if write = '1' then
        ram(to_integer(unsigned(address))) <= dataIn;
        dataOut <= dataIn;
      elsif read = '1' then
        dataOut <= ram(to_integer(unsigned(address)));
      end if;

      MFC <= '1';
    else
      MFC <= '0';
    end if;

  end if;

end process;
end architecture;