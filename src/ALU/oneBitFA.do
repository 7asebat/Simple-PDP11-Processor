vsim work.onebitfa(default)
# vsim work.onebitfa(default) 
# Start time: 00:55:41 on Oct 28,2020
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading work.onebitfa(default)
add wave -position insertpoint sim:/onebitfa/*
force -freeze sim:/onebitfa/A 0 0
force -freeze sim:/onebitfa/B 0 0
force -freeze sim:/onebitfa/Cin 0 0
run

force -freeze sim:/onebitfa/A 1 0
force -freeze sim:/onebitfa/B 0 0
force -freeze sim:/onebitfa/Cin 0 0
run

force -freeze sim:/onebitfa/A 0 0
force -freeze sim:/onebitfa/B 1 0
force -freeze sim:/onebitfa/Cin 0 0
run

force -freeze sim:/onebitfa/A 1 0
force -freeze sim:/onebitfa/B 1 0
force -freeze sim:/onebitfa/Cin 0 0
run

force -freeze sim:/onebitfa/A 0 0
force -freeze sim:/onebitfa/B 0 0
force -freeze sim:/onebitfa/Cin 1 0
run

force -freeze sim:/onebitfa/A 1 0
force -freeze sim:/onebitfa/B 0 0
force -freeze sim:/onebitfa/Cin 1 0
run

force -freeze sim:/onebitfa/A 0 0
force -freeze sim:/onebitfa/B 1 0
force -freeze sim:/onebitfa/Cin 1 0
run

force -freeze sim:/onebitfa/A 1 0
force -freeze sim:/onebitfa/B 1 0
force -freeze sim:/onebitfa/Cin 1 0
run