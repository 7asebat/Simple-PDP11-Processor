library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity OffsetDecoder is 
  generic(OFFSET_SIZE: INTEGER := 8;
          REG_SIZE: INTEGER := 16); 

  port(IR_bits: in std_logic_vector(OFFSET_SIZE-1 downto 0);
       offset: out std_logic_vector(REG_SIZE-1 downto 0));

end entity;

architecture main of OffsetDecoder is 
  constant OFFSET_POSITIVE: std_logic_vector(REG_SIZE-OFFSET_SIZE-1 downto 0) := (OTHERS => '0');
  constant OFFSET_NEGATIVE: std_logic_vector(REG_SIZE-OFFSET_SIZE-1 downto 0) := (OTHERS => '1');

begin
  -- Cascade negative bits throughout the offset
  offset(REG_SIZE-1 downto OFFSET_SIZE) <= 
    OFFSET_NEGATIVE when IR_bits(OFFSET_SIZE-1) = '1' else
    OFFSET_POSITIVE;
  
  offset(OFFSET_SIZE-1 downto 0) <= IR_bits;
end architecture;
