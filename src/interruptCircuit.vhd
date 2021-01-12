library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity INTERRUPT is
    generic(
        OUT_SIZE: integer:= 8  
    );
    port(
        F: out std_logic_vector(OUT_SIZE-1 DOWNTO 0)
    );
end INTERRUPT;

architecture interrupt_arch of INTERRUPT is

begin
    F <= (others=>'1'); 

end interrupt_arch;