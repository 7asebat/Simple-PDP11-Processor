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
    wr: IN std_logic;
    address: IN std_logic_vector(integer(ceil(log2(real(n))))-1 DOWNTO 0);
    dataIn: IN std_logic_vector(m-1 DOWNTO 0);
    dataOut: OUT std_logic_vector(m-1 DOWNTO 0);
    MFC: OUT std_logic
  ); 
END ENTITY;

ARCHITECTURE main OF nmRam IS
  TYPE ram_type IS ARRAY(0 TO n-1) of std_logic_vector(m-1 DOWNTO 0);
  SIGNAL ram: ram_type := (
    -- initialize here 
    0 => ("0000110111000000"),
    1 => ("0000000000000100"),
    2 => ("0000110111000001"),
    3 => ("0000000000000011"),
    4 => ("0001000000000001"),
    5 => ("1010000000000000"),
    6 => ("0000000000000111"),
    7 => ("0000000000000101"),
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