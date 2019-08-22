library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;

  use work.simplearithmetictest_writer_pgk.all;
  use work.simplearithmetictest_reader_pgk.all;
entity simplearithmetictest_tb_csv is 
end simplearithmetictest_tb_csv;

architecture behavior of simplearithmetictest_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : simplearithmetictest_reader_rec := simplearithmetictest_reader_rec_null;
  signal data_out : simplearithmetictest_writer_rec := simplearithmetictest_writer_rec_null;


begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );
  csv_read : entity work.simplearithmetictest_reader_et generic map (FileName => "./simplearithmetictest_tb_csv.csv" ) port map (clk => clk ,data => data_in);
  csv_write : entity work.simplearithmetictest_writer_et generic map (FileName => "./simplearithmetictest_tb_csv_out.csv" ) port map (clk => clk ,data => data_out);

data_out.multia_in <= data_in.multia_in;
data_out.multib_in <= data_in.multib_in;


DUT :  entity work.simplearithmetictest port map(
  clk => clk,
  multia_in => data_out.multia_in,
  multib_in => data_out.multib_in,
  multic_out => data_out.multic_out
);
end behavior;
