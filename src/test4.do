vsim work.processor

mem load -i ./test4.mem /processor/RAM/ram

add wave -dec -position insertpoint \
\
sim:/processor/Rx_out(7) \
sim:/processor/CTRL_COUNTER_out \
sim:/processor/uPC_out \
-hex \
sim:/processor/WMFC \
sim:/processor/MFC \
sim:/processor/RUN \
sim:/processor/clk \
\
sim:/processor/MIU_read \
sim:/processor/MIU_write \
sim:/processor/MIU_mem_write \
sim:/processor/MIU_mem_read \
\
\
-dec sim:/processor/MDR_out \
sim:/processor/MAR_out \
\
-hex sim:/processor/CTRL_SIGNALS \
sim:/processor/uIR_sig \
\
sim:/processor/IR_out \
sim:/processor/ALU_flags \
sim:/processor/ALU_F \
sim:/processor/ALU_Cin \
\
sim:/processor/shared_bus \
\
-dec sim:/processor/Rx_out \
sim:/processor/INT_SRC_out \
sim:/processor/INT_DST_out \
sim:/processor/Rstatus_out \


# sim:/processor/MDR_REGISTER/A_en \
# sim:/processor/MDR_REGISTER/A_in \
# sim:/processor/MDR_REGISTER/B_en \
# sim:/processor/MDR_REGISTER/B_in \
# sim:/processor/RAM/dataIn \
# sim:/processor/RAM/dataOut \

force -freeze sim:/processor/clk 1 0
force -freeze sim:/processor/uPC_reset 1 0
force -freeze sim:/processor/MIU_reset 1 0
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
noforce sim:/processor/MIU_reset
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
noforce sim:/processor/Rx_reset
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100

run 100ns;