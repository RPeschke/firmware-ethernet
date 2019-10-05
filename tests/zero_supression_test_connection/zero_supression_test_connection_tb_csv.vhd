

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;


use work.zero_supression_test_connection_writer_pgk.all;
use work.zero_supression_test_connection_reader_pgk.all;
entity zero_supression_test_connection_tb_csv is 
end entity;

architecture behavior of zero_supression_test_connection_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : zero_supression_test_connection_reader_rec := zero_supression_test_connection_reader_rec_null;
  signal data_out : zero_supression_test_connection_writer_rec := zero_supression_test_connection_writer_rec_null;

begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );

  csv_read : entity work.zero_supression_test_connection_reader_et 
    generic map (
        FileName => "./zero_supression_test_connection_tb_csv.csv" 
    ) port map (
        clk => clk ,data => data_in
    );
 
  csv_write : entity work.zero_supression_test_connection_writer_et
    generic map (
        FileName => "./zero_supression_test_connection_tb_csv_out.csv" 
    ) port map (
        clk => clk ,data => data_out
    );
  

data_out.rst <= data_in.rst;
data_out.data_in <= data_in.data_in;
data_out.valid_in <= data_in.valid_in;
data_out.ready_out <= data_in.ready_out;


DUT :  entity work.zero_supression_test_connection  port map(
    clk => clk,
      rst => data_out.rst,
  data_in => data_out.data_in,
  valid_in => data_out.valid_in,
  tomanychangeserror_a2z => data_out.tomanychangeserror_a2z,
  data_out => data_out.data_out,
  valid_out => data_out.valid_out,
  ready_out => data_out.ready_out,
  tomanychangeserror_z2a => data_out.tomanychangeserror_z2a
    );

end behavior;
    