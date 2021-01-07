vsim work.partb
# vsim work.partb 
# Start time: 18:04:55 on Oct 27,2020
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading work.partb(default)
add wave -position insertpoint sim:/partb/*
force -freeze sim:/partb/A 16#F00F 0
force -freeze sim:/partb/B 16#000A 0
force -freeze sim:/partb/S 00 0
run
force -freeze sim:/partb/S 01 0
run
force -freeze sim:/partb/S 10 0
run
force -freeze sim:/partb/S 11 0
run