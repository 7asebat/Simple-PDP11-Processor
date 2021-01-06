library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Memory control unit
entity MIU is
  port(clock:     in  std_logic;
       rd:        in  std_logic;
       wr:        in  std_logic;
       mfc:       in  std_logic;
       wmfc:      in  std_logic;
       mem_read:  out std_logic;
       mem_write: out std_logic;
       run:       out std_logic);
end MIU;

architecture MIU_arch of MIU is
  component JKFF is
    port(clock: in  std_logic;
         J:     in  std_logic;
         K:     in  std_logic;
         Q:     out std_logic);
  end component;

  signal s_mem_read: std_logic;
  signal s_mem_write: std_logic;

begin
  run <= not (wmfc and (s_mem_read or s_mem_write) and not mfc);
  mem_read <= s_mem_read;
  mem_write <= s_mem_write;

  read_JKFF: JKFF port map(clock, rd, mfc, s_mem_read);
  write_JKFF: JKFF port map(clock, wr, mfc, s_mem_write);
end MIU_arch; -- MIU_arch

-- ===================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.utility_pack.all;

entity MIU_tb is
end MIU_tb;

architecture MIU_tb_arch of MIU_tb is
  component MIU is
  port(clock:     in  std_logic;
       rd:        in  std_logic; -- Read
       wr:        in  std_logic; -- Write
       mfc:       in  std_logic;
       wmfc:      in  std_logic;
       mem_read:  out std_logic;
       mem_write: out std_logic;
       run:       out std_logic);
  end component;

  signal t_clock:     std_logic;
  signal t_rd:        std_logic;
  signal t_wr:        std_logic;
  signal t_mfc:       std_logic;
  signal t_wmfc:      std_logic;
  signal t_mem_read:  std_logic;
  signal t_mem_write: std_logic;
  signal t_run:       std_logic;

  type testcases is array (0 to 9) of std_logic_vector(0 to 6);
  -- rd, wr, mfc, wmfc, memr, memw, run
  constant tests: testcases := (b"00_00_001",  -- Initial state
                                b"10_00_101",  -- Request read
                                b"10_01_100",  -- Wait for read
                                b"00_01_100",  -- Waiting for read
                                b"00_11_001",  -- Read complete

                                b"00_00_001",  -- Initial state
                                b"01_00_011",  -- Request write
                                b"01_01_010",  -- Wait for write
                                b"00_01_010",  -- Waiting for write
                                b"00_11_001"); -- Write complete
begin
  process 
    variable v_OP: std_logic_vector(0 to 2);
  begin
    v_OP := t_mem_read & t_mem_write & t_run;
    for i in tests'range loop

      t_rd <= tests(i)(0);
      t_wr <= tests(i)(1);
      t_mfc <= tests(i)(2);
      t_wmfc <= tests(i)(3);

      t_clock <= '0';
      wait for 50 ns;
      t_clock <= '1';
      wait for 50 ns;

      assert(v_OP = tests(i)(4 to 6))
      report "received: " & to_string(v_OP)
        & ", expected: " & to_string(tests(i)(4 to 6))
        & " for (" & to_string(tests(i)(0 to 3)) & ")"
      severity ERROR;

    end loop;
  end process;
  tb: MIU port map(t_clock, t_rd, t_wr, t_mfc, t_wmfc, t_mem_read, t_mem_write, t_run);

  end MIU_tb_arch;