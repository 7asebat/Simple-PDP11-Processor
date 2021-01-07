vsim work.decoder_tb(decoder_tb_arch)
add wave -position insertpoint  \
sim:/decoder_tb/*

run -all