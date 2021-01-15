Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;
use IEEE.math_real.all;

ENTITY nmROM IS 
  generic(n: integer := 256; m: integer:= 22);
	PORT(
    address: IN std_logic_vector(integer(ceil(log2(real(65536))))-1 DOWNTO 0);
    dataOut: OUT std_logic_vector(m-1 DOWNTO 0)
  ); 
END ENTITY;

ARCHITECTURE main OF nmRom IS
  TYPE rom_type IS ARRAY(0 TO n-1) of std_logic_vector(m-1 DOWNTO 0);
  SIGNAL rom: rom_type := (
    0      => "0001011010000010110100",
    1      => "0011001000011110000010",
    2      => "0010010000011110000000",
    3      => "0000000000011110000001",
    4      => "0100000001011110000000",
    5      => "0000000000011110000001",
    6      => "0100000010011110100010",
    7      => "0000000000011110000001",
    8      => "0100011010000010110110",
    9      => "0011100000011110000010",
    10     => "0000000000011110000001",
    11     => "0100011000000110010000",
    12     => "0011100010011110100010",
    13     => "0000000000011110000001",
    14     => "0001011010000010110100",
    15     => "0011001000011110000010",
    16     => "0010000000111110000000",
    17     => "0100011000000010000000",
    18     => "0011000010011110100010",
    19     => "0000000000011110000001",
    20     => "0010000010011110100010",
    21     => "0010000001011110000000",
    22     => "0000000000011110000001",
    23     => "0101000001111110000000",
    24     => "0000000000011110000001",
    25     => "0101000010011110100010",
    26     => "0000000000011110000001",
    27     => "0101011010000010110100",
    28     => "0011101000011110000010",
    29     => "0000000000011110000001",
    30     => "0101011000000110010000",
    31     => "0011101010011110100010",
    32     => "0000000000011110000001",
    33     => "0001011010000010110100",
    34     => "0011001000011110000010",
    35     => "0010000000111110000000",
    36     => "0101011000000010000000",
    37     => "0011000010011110100010",
    38     => "0000000000011110000001",
    39     => "0010000010011110100010",
    40     => "0010000001111110000000",
    41     => "0000000000011110000001",
    42     => "0110011000000010010000",
    43     => "0000000000011110000001",
    44     => "0110000000111110000000",
    45     => "0111011000000010000000",
    46     => "0000000000011110000001",
    47     => "0110000000111110000000",
    48     => "0111011000000010001000",
    49     => "0000000000011110000001",
    50     => "0111000000111110000000",
    51     => "0110011000000100000100",
    52     => "0000000000011110000001",
    53     => "0111000000111110000000",
    54     => "0110011000000100001100",
    55     => "0000000000011110000001",
    56     => "0110000000111110000000",
    57     => "0111011000001000000000",
    58     => "0000000000011110000001",
    59     => "0110000000111110000000",
    60     => "0111011000001010000000",
    61     => "0000000000011110000001",
    62     => "0110000000111110000000",
    63     => "0111011000001100000000",
    64     => "0000000000011110000001",
    65     => "0111000000111110000000",
    66     => "0110011000000100000100",
    67     => "0000000000011110000001",
    68     => "0111011000000010010100",
    69     => "0000000000011110000001",
    70     => "0111011000000110010000",
    71     => "0000000000011110000001",
    72     => "0111011000001000010000",
    73     => "0000000000011110000001",
    74     => "0111011000001110000000",
    75     => "0000000000011110000001",
    76     => "0111011000010000000000",
    77     => "0000000000011110000001",
    78     => "0111011000010010000000",
    79     => "0000000000011110000001",
    80     => "0111011000010110000000",
    81     => "0000000000011110000001",
    82     => "0111011000011000000000",
    83     => "0000000000011110000001",
    84     => "0111011000011010000000",
    85     => "0000000000011110000001",
    86     => "1000000001011110000000",
    87     => "0001000001111110000000",
    88     => "0000000000011110000001",
    89     => "0011001000011110000000",
    90     => "0000000000011110000001",
    91     => "0000000000000000000000",
    92     => "0000000000000000000000",
    93     => "0000000000011110000001",
    94     => "0001011010000010110100",
    95     => "0011001000011110000010",
    96     => "0010000001011110000010",
    97     => "0001000100011110000000",
    98     => "0000000000011110000001",
    99     => "0110001000011110000000",
    100    => "0000000000011110000001",
    101    => "1001000100011110000000",
    102    => "0000000000011110000001",
    103    => "0001000100011110000000",
    104    => "1010011000000110010000",
    105    => "0011111010011111000010",
    106    => "1011001000011110000000",
    107    => "0000000000011110000001",
    108    => "1010011010000010110100",
    109    => "0011111000011110000010",
    110    => "0010001000011110000000",
    111    => "0000000000011110000001",
    112    => "1010011010000010110100",
    113    => "0011111000011110000010",
    114    => "0010110000011110000000",
    115    => "0000000000011110000001",
    116    => "1010011000000110010000",
    117    => "0011111010011111000010",
    118    => "0000000000011110000001",
    119    => "0011101000011110000000",
    120    => "0000000000011110000001",
    121    => "0011000100011111000010",
    122    => "0000000000011110000001",
    OTHERS => "0000000000000000000000"
  );
BEGIN
  dataOut <= rom(to_integer(unsigned(address)));
END ARCHITECTURE;