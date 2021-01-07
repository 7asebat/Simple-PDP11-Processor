vsim work.alu
# vsim work.alu 
# Start time: 20:43:44 on Oct 27,2020
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading work.alu(default)
# Loading work.partb(default)
# Loading work.partc(default)
# Loading work.partd(default)
add wave -position insertpoint  \
sim:/alu/A \
sim:/alu/B \
sim:/alu/S \
sim:/alu/Cin \
sim:/alu/F \
sim:/alu/Cout

# partA

force -freeze sim:/alu/A 16#0F0F 0
force -freeze sim:/alu/S 0000 0
force -freeze sim:/alu/Cin 0 0
run

force -freeze sim:/alu/B 16#0001 0
force -freeze sim:/alu/S 0001 0
run

force -freeze sim:/alu/A 16#FFFF 0
run

force -freeze sim:/alu/S 0010 0
run

noforce sim:/alu/B
force -freeze sim:/alu/S 0011 0
run

force -freeze sim:/alu/Cin 1 0
force -freeze sim:/alu/A 16#0F0E 0
force -freeze sim:/alu/S 0000 0
run

force -freeze sim:/alu/A 16#FFFF 0
force -freeze sim:/alu/S 0001 0
force -freeze sim:/alu/B 16#0001 0
run

force -freeze sim:/alu/A 16#0F0F 0
force -freeze sim:/alu/S 0010 0
run

noforce sim:/alu/A
noforce sim:/alu/B
force -freeze sim:/alu/S 0011 0
run

force -freeze sim:/alu/A 16#0F0F 0
force -freeze sim:/alu/B 16#000A 0
force -freeze sim:/alu/S 0100 0
run

force -freeze sim:/alu/S 0101 0
run

force -freeze sim:/alu/S 0110 0
run

noforce sim:/alu/B
force -freeze sim:/alu/S 0111 0
run

force -freeze sim:/alu/S 1000 0
run

force -freeze sim:/alu/S 1001 0
run

noforce sim:/alu/A
force -freeze sim:/alu/S 1111 0
run

force -freeze sim:/alu/A 16#0F0F 0
force -freeze sim:/alu/S 1010 0
force -freeze sim:/alu/Cin 0 0
run

force -freeze sim:/alu/Cin 1 0
run

noforce sim:/alu/Cin
force -freeze sim:/alu/S 1100 0
run

force -freeze sim:/alu/A 16#F0F0 0
force -freeze sim:/alu/S 1101 0
run

force -freeze sim:/alu/Cin 0 0
force -freeze sim:/alu/S 1110 0
run

force -freeze sim:/alu/Cin 1 0
run

force -freeze sim:/alu/S 1011 0
noforce sim:/alu/Cin
run