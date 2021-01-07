vsim work.partc
# vsim work.partc 
# Start time: 18:41:57 on Oct 27,2020
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading work.partc(default)
add wave -position insertpoint sim:/partc/*
force -freeze sim:/partc/A 16#F00F 0
force -freeze sim:/partc/S 00 0
run
force -freeze sim:/partc/S 01 0
run
force -freeze sim:/partc/A 16#F00A 0
run
force -freeze sim:/partc/A 16#F00F 0
force -freeze sim:/partc/S 10 0
force -freeze sim:/partc/Cin 0 0
run
force -freeze sim:/partc/Cin 1 0
run
force -freeze sim:/partc/S 11 0
noforce sim:/partc/Cin
run
