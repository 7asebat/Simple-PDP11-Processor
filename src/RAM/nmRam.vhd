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
    0 => ("0000110111000000"),
    1 => ("0000000000001100"),
    2 => ("0000010111000001"),
    3 => ("0000000000001010"),
    4 => ("0000010000000011"),
    5 => ("0000100000000100"),
    6 => ("0000110000000101"),
    7 => ("0000000000000010"),
    8 => ("0000001000000010"),
    9 => ("0000011000000011"),
    10 => ("0000101000000100"),
    11 => ("0000111000000101"),
    12 => ("0000000000000010"),
    13 => ("1010000000000000"),
    14 => ("0000000000010010"),
    15 => ("0000000000000101"),
    16 => ("0000000000000001"),
    17 => ("0000000000010101"),
    18 => ("0000000000010101"),
    19 => ("0000000000010111"),
    20 => ("0000000000010110"),
    21 => ("0000000000001001"),
    22 => ("0000000000001010"),
    OTHERS => ((m-1 DOWNTO 8 => '0') & X"00")
  );
  SIGNAL s_mfc: std_logic := '0';
BEGIN

MFC <= s_mfc;

-- Delay write operation by two clock cycles
PROCESS(clk, read, write)
  variable v_delay: natural range 0 to DELAY := 0;
BEGIN
  IF(read = '0' AND write = '0') THEN
    v_delay := 0;
  END IF;

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

      s_mfc <= '1';
    else
      s_mfc <= '0';
    end if;
  end if;

end process;
end architecture;