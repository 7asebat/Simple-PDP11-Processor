vsim work.processor
# vsim work.processor 
# Start time: 21:18:10 on Jan 13,2021
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading ieee.math_real(body)
# Loading work.processor(main)
# Loading work.ndff(main)
# Loading work.ntristatebuffer(main)
# Loading work.n2dff(main)
# Loading work.alu(main)
# Loading work.parta(default)
# Loading work.nbitfa(default)
# Loading work.onebitfa(default)
# Loading work.partb(default)
# Loading work.partc(default)
# Loading work.partd(default)
# Loading work.nmram(main)
# Loading work.ncounter(main)
# Loading work.pla(main)
# Loading work.nmrom(main)
# Loading work.controlworddecoder(main)
# Loading work.decoder(decoder_arch)
add wave -position insertpoint  \
sim:/processor/WMFC \
sim:/processor/uPC_reset \
sim:/processor/uPC_out \
sim:/processor/uPC_mode \
sim:/processor/uPC_load \
sim:/processor/uPC_in \
sim:/processor/uPC_en \
sim:/processor/uIR_sig \
sim:/processor/Tri_Rz_out \
sim:/processor/Tri_Rz_en \
sim:/processor/Tri_Rx_out \
sim:/processor/Tri_Rx_en \
sim:/processor/Tri_Rstatus_out \
sim:/processor/Tri_Rstatus_en \
sim:/processor/Tri_MDR_en \
sim:/processor/Tri_INT_SRC_out \
sim:/processor/Tri_INT_SRC_en \
sim:/processor/Tri_INT_DST_out \
sim:/processor/Tri_INT_DST_en \
sim:/processor/shared_bus \
sim:/processor/Rz_reset \
sim:/processor/Rz_out \
sim:/processor/Rz_in \
sim:/processor/Rz_en \
sim:/processor/Ry_reset \
sim:/processor/Ry_out \
sim:/processor/Ry_in \
sim:/processor/Ry_en \
sim:/processor/Rx_reset \
sim:/processor/Rx_out \
sim:/processor/Rx_in \
sim:/processor/Rx_en \
sim:/processor/Rstatus_reset \
sim:/processor/Rstatus_out \
sim:/processor/Rstatus_bus_in \
sim:/processor/Rstatus_bus_en \
sim:/processor/Rstatus_alu_in \
sim:/processor/Rstatus_alu_en \
sim:/processor/RAM_write \
sim:/processor/RAM_read \
sim:/processor/RAM_MFC \
sim:/processor/MDR_reset \
sim:/processor/MDR_ram_in \
sim:/processor/MDR_ram_en \
sim:/processor/MDR_out \
sim:/processor/MDR_bus_in \
sim:/processor/MDR_bus_en \
sim:/processor/MAR_reset \
sim:/processor/MAR_out \
sim:/processor/MAR_in \
sim:/processor/MAR_en \
sim:/processor/IR_reset \
sim:/processor/IR_out \
sim:/processor/IR_in \
sim:/processor/IR_en \
sim:/processor/INT_SRC_reset \
sim:/processor/INT_SRC_out \
sim:/processor/INT_SRC_in \
sim:/processor/INT_SRC_en \
sim:/processor/INT_DST_reset \
sim:/processor/INT_DST_out \
sim:/processor/INT_DST_in \
sim:/processor/INT_DST_en \
sim:/processor/HALT_reset \
sim:/processor/HALT_out \
sim:/processor/HALT_in \
sim:/processor/HALT_en \
sim:/processor/CTRL_SIGNALS \
sim:/processor/CTRL_COUNTER_reset \
sim:/processor/CTRL_COUNTER_out \
sim:/processor/CTRL_COUNTER_mode \
sim:/processor/CTRL_COUNTER_load \
sim:/processor/CTRL_COUNTER_in \
sim:/processor/CTRL_COUNTER_en \
sim:/processor/clk \
sim:/processor/ALU_flags \
sim:/processor/ALU_F \
sim:/processor/ALU_Cin
force -freeze sim:/processor/uPC_reset 1 0
force -freeze sim:/processor/Rz_reset 1 0
force -freeze sim:/processor/Ry_reset 1 0
force -freeze sim:/processor/Rstatus_reset 1 0
force -freeze sim:/processor/MDR_reset 1 0
force -freeze sim:/processor/MAR_reset 1 0
force -freeze sim:/processor/IR_reset 1 0
force -freeze sim:/processor/INT_SRC_reset 1 0
force -freeze sim:/processor/INT_DST_reset 1 0
force -freeze sim:/processor/HALT_reset 1 0
force -freeze sim:/processor/CTRL_COUNTER_reset 1 0
force -freeze sim:/processor/Rx_reset 11111111 0
run
noforce sim:/processor/uPC_reset
noforce sim:/processor/Rz_reset
noforce sim:/processor/Ry_reset
noforce sim:/processor/Rx_reset
noforce sim:/processor/Rstatus_reset
noforce sim:/processor/MDR_reset
noforce sim:/processor/MAR_reset
noforce sim:/processor/IR_reset
noforce sim:/processor/INT_SRC_reset
noforce sim:/processor/INT_DST_reset
noforce sim:/processor/HALT_reset
noforce sim:/processor/CTRL_COUNTER_reset
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100