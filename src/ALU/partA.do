vsim work.parta
# vsim work.parta 
# Start time: 02:40:16 on Oct 28,2020
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading work.parta(default)
# ** Warning: (vsim-3473) Component instance "fa1 : sixteenBitFA" is not bound.
#    Time: 0 ps  Iteration: 0  Instance: /parta File: /d/cmp_3a/Computer_Architecture/labs/lab2/requirement/partA.vhd
add wave -position insertpoint  \
sim:/parta/A \
sim:/parta/B \
sim:/parta/Cin \
sim:/parta/S \
sim:/parta/F \
sim:/parta/Cout \

force -freeze sim:/parta/A 16#0F0F 0
force -freeze sim:/parta/S 00 0
force -freeze sim:/parta/Cin 0 0
run

force -freeze sim:/parta/B 16#0001 0
force -freeze sim:/parta/S 01 0
run

force -freeze sim:/parta/A 16#FFFF 0
run

force -freeze sim:/parta/S 10 0
run

noforce sim:/parta/B
force -freeze sim:/parta/S 11 0
run

force -freeze sim:/parta/Cin 1 0
force -freeze sim:/parta/A 16#0F0E 0
force -freeze sim:/parta/S 00 0
run

force -freeze sim:/parta/A 16#FFFF 0
force -freeze sim:/parta/S 01 0
force -freeze sim:/parta/B 16#0001 0
run

force -freeze sim:/parta/A 16#0F0F 0
force -freeze sim:/parta/S 10 0
run

noforce sim:/parta/A
noforce sim:/parta/B
force -freeze sim:/parta/S 11 0
run