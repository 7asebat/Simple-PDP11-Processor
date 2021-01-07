vsim work.partd
# vsim work.partd 
# Start time: 19:35:58 on Oct 27,2020
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading work.partd(default)
add wave -position insertpoint sim:/partd/*
force -freeze sim:/partd/A 16#F00F 0
force -freeze sim:/partd/S 00 0
run
force -freeze sim:/partd/S 01 0
run
force -freeze sim:/partd/Cin 0 0
force -freeze sim:/partd/S 10 0
run
force -freeze sim:/partd/Cin 1 0
run
noforce sim:/partd/Cin
force -freeze sim:/partd/S 11 0
run