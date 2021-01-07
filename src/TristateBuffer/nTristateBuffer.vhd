Library ieee;
Use ieee.std_logic_1164.all;

ENTITY nTristateBuffer IS 
	GENERIC(n: INTEGER := 32);
	PORT(
		en: IN std_logic;
		A: IN std_logic_vector(n-1 DOWNTO 0);
		F: OUT std_logic_vector(n-1 DOWNTO 0)
	); 
END ENTITY;

ARCHITECTURE main OF nTristateBuffer IS
BEGIN

	WITH en SELECT F <=	
			A WHEN '1',
			(OTHERS => 'Z') WHEN OTHERS;
END ARCHITECTURE;