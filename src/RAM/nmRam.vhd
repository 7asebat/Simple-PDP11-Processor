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
    1 => ("0000000000011111"),
    2 => ("0000110111010000"),
    3 => ("0000000000100101"),
    4 => ("0000110111010000"),
    5 => ("0000000000100011"),
    6 => ("0000110111100000"),
    7 => ("0000000000100010"),
    8 => ("0000110111110000"),
    9 => ("0000000000100001"),
    10 => ("0000000000000001"),
    11 => ("0000110111000000"),
    12 => ("0000000000010100"),
    13 => ("0000110111011000"),
    14 => ("0000000000011010"),
    15 => ("0000110111011000"),
    16 => ("0000000000011000"),
    17 => ("0000110111101000"),
    18 => ("0000000000010111"),
    19 => ("0000110111111000"),
    20 => ("0000000000010110"),
    21 => ("0000000000000001"),
    22 => ("0000110111000000"),
    23 => ("0000000000001001"),
    24 => ("0000010000000001"),
    25 => ("0000010000000001"),
    26 => ("0000010000000001"),
    27 => ("0000110111000000"),
    28 => ("0000000000001000"),
    29 => ("0000010000000001"),
    30 => ("0000010000000001"),
    31 => ("0000010000000001"),
    32 => ("1010000000000000"),
    33 => ("0000000000100010"),
    34 => ("0000000000000000"),
    35 => ("0000000000000000"),
    36 => ("0000000000000000"),
    37 => ("0000000000100110"),
    38 => ("0000000000000000"),
    39 => ("0000000000000000"),
    40 => ("0000000000000000"),
    41 => ("0000000000100110"),
    42 => ("0000000000100111"),
    43 => ("0000000000101000"),
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