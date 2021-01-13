Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;

ENTITY nCounter IS 
	GENERIC(n: INTEGER := 8);
	PORT(
		clk, en, mode, R, load: IN std_logic; -- mode: 0 increment, 1 decrement
		dataIn: IN std_logic_vector(n-1 DOWNTO 0);
		dataOut: OUT std_logic_vector(n-1 DOWNTO 0)
	); 
END ENTITY;

ARCHITECTURE main OF nCounter IS
BEGIN

PROCESS(clk, R)
VARIABLE cnt: unsigned(n-1 DOWNTO 0) := to_unsigned(0, n);
BEGIN
	IF (R = '1') THEN
		cnt := to_unsigned(0, cnt'length);
  ELSIF (rising_edge(clk) AND en = '1') THEN
    IF(load='1') THEN
      cnt := unsigned(dataIn);
    ELSE
      IF(mode='0') THEN
        cnt := cnt + 1;
      ELSIF(mode='1') THEN
        cnt := cnt - 1;
      END IF;
    END IF;
  END IF;
  
  dataOut <= std_logic_vector(cnt);
END PROCESS;

END ARCHITECTURE;