library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;

use work.simplearithmetic_ether_test_writer_pgk.all;

entity simplearithmetic_ether_test_writer_et is
generic ( 
  FileName : string := "./simplearithmetic_ether_test_out.csv"
);
port (
  clk : in std_logic ;
  data : in simplearithmetic_ether_test_writer_rec
);
end entity;

architecture Behavioral of simplearithmetic_ether_test_writer_et is 
constant  NUM_COL : integer := 8 ;
signal data_int : c_integer_array(NUM_COL downto 0)  := (others=>0)  ;
begin

csv_w : entity  work.csv_write_file 
    generic map (
         FileName => FileName,
         HeaderLines=> "rxdata; rxdatavalid; rxdatalast; rxdataready; txdataout; txdatavalid; txdatalast; txdataready",
         NUM_COL =>   NUM_COL ) 
    port map(
         clk => clk, 
         Rows => data_int
    );

slv_to_integer(data.rxdata, data_int(0) );
sl_to_integer(data.rxdatavalid, data_int(1) );
sl_to_integer(data.rxdatalast, data_int(2) );
sl_to_integer(data.rxdataready, data_int(3) );
slv_to_integer(data.txdataout, data_int(4) );
sl_to_integer(data.txdatavalid, data_int(5) );
sl_to_integer(data.txdatalast, data_int(6) );
sl_to_integer(data.txdataready, data_int(7) );
end Behavioral;