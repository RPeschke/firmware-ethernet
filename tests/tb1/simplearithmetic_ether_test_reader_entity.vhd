library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;

use work.simplearithmetic_ether_test_reader_pgk.all;

entity simplearithmetic_ether_test_reader_et is
generic ( 
  FileName : string := "./simplearithmetic_ether_test_in.csv"
);
port (
  clk : in std_logic ;
  data : out simplearithmetic_ether_test_reader_rec
);
end entity;

architecture Behavioral of simplearithmetic_ether_test_reader_et is 
constant  NUM_COL : integer := 4;
signal csv_r_data : t_integer_array(NUM_COL downto 0)  := (others=>0)  ;begin

csv_r :entity  work.csv_read_file 
    generic map (
       FileName =>  FileName, 
       NUM_COL => NUM_COL,
       useExternalClk=>true,
       HeaderLines =>  2
       )
        port map(
       clk => clk,
       Rows => csv_r_data
       );


integer_to_slv(csv_r_data(0), data.rxdata);
integer_to_sl(csv_r_data(1), data.rxdatavalid);
integer_to_sl(csv_r_data(2), data.rxdatalast);
integer_to_sl(csv_r_data(3), data.txdataready);
end Behavioral;