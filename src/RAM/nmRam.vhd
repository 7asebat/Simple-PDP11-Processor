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
    MFC: OUT std_logic;
    clk: IN std_logic;
    wr: IN std_logic;
    address: IN std_logic_vector(integer(ceil(log2(real(n))))-1 DOWNTO 0);
    dataIn: IN std_logic_vector(m-1 DOWNTO 0);
    dataOut: OUT std_logic_vector(m-1 DOWNTO 0)
  ); 
END ENTITY;

ARCHITECTURE main OF nmRam IS
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

PROCESS(clk) IS
BEGIN

  IF(rising_edge(clk)) THEN
    IF(wr = '1') THEN
      ram(to_integer(unsigned(address))) <= dataIn;
      MFC <= '1';
    else
      MFC <= '0';
    END IF;
  END IF;
END PROCESS;
  dataOut <= ram(to_integer(unsigned(address)));
END ARCHITECTURE;