

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;


use work.array2zero_suprresed_writer_pgk.all;
use work.array2zero_suprresed_reader_pgk.all;
entity array2zero_suprresed_tb_csv is 
end entity;

architecture behavior of array2zero_suprresed_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : array2zero_suprresed_reader_rec := array2zero_suprresed_reader_rec_null;
  signal data_out : array2zero_suprresed_writer_rec := array2zero_suprresed_writer_rec_null;

begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );

  csv_read : entity work.array2zero_suprresed_reader_et 
    generic map (
        FileName => "./array2zero_suprresed_tb_csv.csv" 
    ) port map (
        clk => clk ,data => data_in
    );
 
  csv_write : entity work.array2zero_suprresed_writer_et
    generic map (
        FileName => "./array2zero_suprresed_tb_csv_out.csv" 
    ) port map (
        clk => clk ,data => data_out
    );
  

data_out.rst <= data_in.rst;
data_out.data_in <= data_in.data_in;
data_out.valid <= data_in.valid;
data_out.zs_data_out_s2m <= data_in.zs_data_out_s2m;


DUT :  entity work.array2zero_suprresed  port map(
    clk => clk,
      rst => data_out.rst,
  data_in => data_out.data_in,
  valid => data_out.valid,
  tomanychangeserror => data_out.tomanychangeserror,
  zs_data_out_m2s => data_out.zs_data_out_m2s,
  zs_data_out_s2m => data_out.zs_data_out_s2m
    );

end behavior;
    