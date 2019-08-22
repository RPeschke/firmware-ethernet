library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;

  use work.simplearithmetic_ether_test_writer_pgk.all;
  use work.simplearithmetic_ether_test_reader_pgk.all;
entity simplearithmetic_ether_test_tb_csv is 
end simplearithmetic_ether_test_tb_csv;

architecture behavior of simplearithmetic_ether_test_tb_csv is 
  signal clk : std_logic := '0';
  signal data_in : simplearithmetic_ether_test_reader_rec := simplearithmetic_ether_test_reader_rec_null;
  signal data_out : simplearithmetic_ether_test_writer_rec := simplearithmetic_ether_test_writer_rec_null;


begin 

  clk_gen : entity work.ClockGenerator generic map ( CLOCK_period => 10 ns) port map ( clk => clk );
  csv_read : entity work.simplearithmetic_ether_test_reader_et generic map (FileName => "./simplearithmetic_ether_test_tb_csv.csv" ) port map (clk => clk ,data => data_in);
  csv_write : entity work.simplearithmetic_ether_test_writer_et generic map (FileName => "./simplearithmetic_ether_test_tb_csv_out.csv" ) port map (clk => clk ,data => data_out);

data_out.rxdata <= data_in.rxdata;
data_out.rxdatavalid <= data_in.rxdatavalid;
data_out.rxdatalast <= data_in.rxdatalast;
data_out.txdataready <= data_in.txdataready;


DUT :  entity work.simplearithmetic_ether_test port map(
  clk => clk,
  rxdata => data_out.rxdata,
  rxdatavalid => data_out.rxdatavalid,
  rxdatalast => data_out.rxdatalast,
  rxdataready => data_out.rxdataready,
  txdataout => data_out.txdataout,
  txdatavalid => data_out.txdatavalid,
  txdatalast => data_out.txdatalast,
  txdataready => data_out.txdataready
);
end behavior;
