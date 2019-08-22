library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;

use work.simplearithmetictest_writer_pgk.all;

entity simplearithmetictest_writer_et is
generic ( 
  FileName : string := "./simplearithmetictest_out.csv"
);
port (
  clk : in std_logic ;
  data : in simplearithmetictest_writer_rec
);
end entity;

architecture Behavioral of simplearithmetictest_writer_et is 
constant  NUM_COL : integer := 3 ;
signal data_int : t_integer_array(NUM_COL downto 0)  := (others=>0)  ;
begin

csv_w : entity  work.csv_write_file 
    generic map (
         FileName => FileName,
         HeaderLines=> "multia_in; multib_in; multic_out",
         NUM_COL =>   NUM_COL ) 
    port map(
         clk => clk, 
         Rows => data_int
    );

integer_to_integer(data.multia_in, data_int(0) );
integer_to_integer(data.multib_in, data_int(1) );
integer_to_integer(data.multic_out, data_int(2) );
end Behavioral;