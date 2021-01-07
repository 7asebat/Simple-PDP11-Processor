library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity decoder is
generic (
    INPUT_SIZE: integer := 2
);
    port(
        A : in std_logic_vector (INPUT_SIZE-1 downto 0);
        F : out std_logic_vector ((2**INPUT_SIZE)-1 downto 0);
        EN : in std_logic
    );
end decoder;

architecture decoder_arch of decoder is
begin

    process(A,EN)
    begin
        F <= (others=>'0');
        if(EN = '1') then
            F(to_integer(unsigned(A))) <= '1';
        end if;
    end process;

end decoder_arch;

-- ===================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder_tb is
end decoder_tb;

architecture decoder_tb_arch of decoder_tb is
    constant input_size: integer := 4;
	constant testcases_count: integer := 3;

    type typeA IS ARRAY (0 TO testcases_count-1) of std_logic_vector(input_size-1 DOWNTO 0);
	type typeF IS ARRAY (0 TO testcases_count-1) of std_logic_vector((2**input_size)-1 DOWNTO 0);
    type typeEn IS ARRAY (0 TO testcases_count-1) of std_logic;
    
    constant casesA : typeA :=
           (x"B", x"7" , x"F");
    constant casesF : typeF :=
           (x"0800" , x"0000", x"8000");
    constant casesEn : typeEn :=
           ('1', '0', '1');

    signal testA: std_logic_vector(input_size-1 DOWNTO 0);
    signal testF: std_logic_vector((2**input_size)-1 DOWNTO 0);
	signal testEn: std_logic;

begin
    decoder: entity work.decoder(decoder_arch)
            generic map(input_size)
            port map(
                A => testA,
                F => testF,
                EN => testEn
            );
            
            process
                begin
                    for i in 0 to testcases_count-1 loop
                        testA <= casesA(i);
                        testEn <= casesEn(i);

                        wait for 5 ns;

                        assert(testF = casesF(i))
                        report "Assertion failed at case"
                        severity ERROR;
                    end loop;
                    wait;
                end process;

end decoder_tb_arch;