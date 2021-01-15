library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controlWordDecoder is
    port(
        uIR : in std_logic_vector(21 downto 0);
        IR: in std_logic_vector(15 downto 0);
        controlSignals : out std_logic_vector(61 downto 0)
    );
end controlWordDecoder;

architecture main of controlWordDecoder is
    signal F1,F5: std_logic_vector(3 downto 0);
    signal F2: std_logic_vector(2 downto 0);
    signal F3,F4,F6: std_logic_vector(1 downto 0);
    signal F8: std_logic_vector(1 downto 0);
    signal F7,F9,F10: std_logic;

    --F1 signals
    signal F1_decoder_en: std_logic;
    signal F1_decoder_out: std_logic_vector(15 downto 0);
    signal F1_decoded: std_logic_vector(10 downto 0);
    signal R_SRCout_decoder_out, R_DSTout_decoder_out: std_logic_vector(7 downto 0);
    signal R_DST_decoder_in: std_logic_vector(2 downto 0);
    --F2 signals
    signal F2_decoder_en: std_logic;
    signal F2_decoder_out: std_logic_vector(7 downto 0);
    signal F2_decoded: std_logic_vector(6 downto 0);
    signal R_SRCin_decoder_out, R_DSTin_decoder_out: std_logic_vector(7 downto 0);

    --F3 signals
    signal F3_decoder_en: std_logic;
    signal F3_decoder_out: std_logic_vector(3 downto 0);
    signal F3_decoded: std_logic_vector(1 downto 0);

    --F4 signals
    signal F4_decoder_en: std_logic;
    signal F4_decoder_out: std_logic_vector(3 downto 0);
    signal F4_decoded: std_logic_vector(2 downto 0);

    --F6 signals
    signal F6_decoder_en: std_logic;
    signal F6_decoder_out: std_logic_vector(3 downto 0);
    signal F6_decoded: std_logic_vector(1 downto 0); 

begin
    -- Initializing signals with uIR values
    F1 <= uIR(21 downto 18);
    F2 <= uIR(17 downto 15);
    F3 <= uIR(14 downto 13);
    F4 <= uIR(12 downto 11);
    F5 <= uIR(10 downto 7);
    F6 <= uIR(6 downto 5);
    F7 <= uIR(4);
    F8 <= uIR(3 downto 2); -- 00: CLR, 01: SET, 10: Carry flag, 11: !Carry flag
    F9 <= uIR(1);
    F10 <= uIR(0);

    --Decoding F1 signals
    F1_decoder_en <= '1';
    F1_decoder: entity work.decoder(decoder_arch) 
                generic map(4)
                port map(
                    A => F1,
                    F => F1_decoder_out,
                    EN => F1_decoder_en
                );

    --((InterruptAddress)out, SPout, (Status)out, (Address)out, DSTout, SRCout, (R_dst)out, (R_src)out, Zout, MDRout, PCout)
    F1_decoded <= F1_decoder_out(11 downto 1);

    R_SRCout_decoder:   entity work.decoder(decoder_arch)
                        generic map(3)
                        port map(
                            A => IR(8 downto 6),
                            F => R_SRCout_decoder_out,
                            EN => F1_decoded(3) --(R_src)out
                        );

    R_DST_decoder_in <= IR(4 downto 2) when( unsigned(IR(15 downto 12)) = 9) ELSE IR(2 downto 0);
    R_DSTout_decoder:   entity work.decoder(decoder_arch)
                        generic map(3)
                        port map(
                            A => R_DST_decoder_in,
                            F => R_DSTout_decoder_out,
                            EN => F1_decoded(4) --(R_dst)out
                        );    
    
    --Decoding F2 signals
    F2_decoder_en <= '1';
    F2_decoder: entity work.decoder(decoder_arch)
                generic map(3)
                port map(
                    A => F2,
                    F => F2_decoder_out,
                    EN => F2_decoder_en
                );
    
    --(SPin, (Status)in, (R_dst)in, (R_src)in, Zin, IRin, PCin)
    F2_decoded <= F2_decoder_out(7 downto 1);

    R_SRCin_decoder:    entity work.decoder(decoder_arch)
                        generic map(3)
                        port map(
                            A => IR(8 downto 6),
                            F => R_SRCin_decoder_out,
                            EN => F2_decoded(3) --(R_src)in
                        );

    R_DSTin_decoder:    entity work.decoder(decoder_arch)
                        generic map(3)
                        port map(
                            A => R_DST_decoder_in,
                            F => R_DSTin_decoder_out,
                            EN => F2_decoded(4) --(R_dst)in
                        );


    --Decoding F3 signals
    F3_decoder_en <= '1';
    F3_decoder: entity work.decoder(decoder_arch)
                generic map(2)
                port map(
                    A => F3,
                    F => F3_decoder_out,
                    EN => F3_decoder_en
                );
    
    --(MDRin, MARin)
    F3_decoded <= F3_decoder_out(2 downto 1);


    --Decoding F4 signals
    F4_decoder_en <= '1';
    F4_decoder: entity work.decoder(decoder_arch)
                generic map(2)
                port map(
                    A => F4,
                    F => F4_decoder_out,
                    EN => F4_decoder_en
                );
    
    --(DSTin, SRCin, Yin)
    F4_decoded <= F4_decoder_out(3 downto 1);
    

    --Decoding F6 signals
    F6_decoder_en <= '1';
    F6_decoder: entity work.decoder(decoder_arch)
                generic map(2)
                port map(
                    A => F6,
                    F => F6_decoder_out,
                    EN => F6_decoder_en
                );
    --(Write, Read)
    F6_decoded <= F6_decoder_out(2 downto 1);

    --F5, F7, F8, F9, F10 don't need decoders and can be connected directly to control signals 

-- (
    --     uBranch(0), WMFC(1), Carry(2-3), Clear_Y(4), Read(5), Write(6), ALU(7-10)
    --     Yin(11), SRCin(12), DSTin(13), MARin(14), MDRin(15), (Status)in(16), SPin(17), 
    --     R0dst_in(18), R1dst_in(19), R2dst_in(20), R3dst_in(21), R4dst_in(22), R5dst_in(23), R6dst_in(24),
    --     R7dst_in(25), R0src_in(26), R1src_in(27), R2src_in(28), R3src_in(29), R4src_in(30), R5src_in(31), R6src_in(32),
    --     R7src_in(33), PCin(34), IRin(35), Zin(36), (SRC)out(37), (DST)out(38), (Address)out(39), (Status)out(40), 
    --     (SP)out(41), (Interrupt Address)out(42), R0dst_out(43), R1dst_out(44), R2dst_out(45), R3dst_out(46), R4dst_out(47), R5dst_out(48),
    --     R6dst_out(49),R7dst_out(50), R0src_out(51), R1src_out(52), R3src_out(53), R3src_out(54), R4src_out(55), R5src_out(56), 
    --     R6src_out(57), R7src_out(58), PCout(59), MDRout(60), Zout(61)
    -- )
    
    --Assigning outputs to controlsignals vector
    controlSignals(0) <= F10;
    controlSignals(1) <= F9;
    controlSignals(3 downto 2) <= F8;
    controlSignals(4) <= F7;
    controlSignals(6 downto 5) <= F6_decoded;
    controlSignals(10 downto 7) <= F5;
    controlSignals(13 downto 11) <= F4_decoded;
    controlSignals(15 downto 14) <= F3_decoded;
    controlSignals(17 downto 16) <= F2_decoded(6 downto 5);
    controlSignals(25 downto 18) <= R_DSTin_decoder_out;
    controlSignals(33 downto 26) <= R_SRCin_decoder_out;
    controlSignals(36 downto 34) <= F2_decoded(2 downto 0);
    controlSignals(42 downto 37) <= F1_decoded(10 downto 5);
    controlSignals(50 downto 43) <= R_DSTout_decoder_out;
    controlSignals(58 downto 51) <= R_SRCout_decoder_out;
    controlSignals(61 downto 59) <= F1_decoded(2 downto 0);

end architecture;