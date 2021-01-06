LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

PACKAGE utility_pack IS
  FUNCTION to_string (a: std_logic_vector) return string;
END PACKAGE utility_pack;


-- Package Body Section
PACKAGE BODY utility_pack IS

FUNCTION to_string (a: std_logic_vector) return string IS
  VARIABLE b:    string (1 to a'length) := (others => NUL);
  VARIABLE stri: integer := 1; 
  BEGIN
     for i in a'range loop
      b(stri) := std_logic'image(a((i)))(2);
      stri := stri+1;
     end loop;
  return b;
END FUNCTION;

END PACKAGE BODY utility_pack;
