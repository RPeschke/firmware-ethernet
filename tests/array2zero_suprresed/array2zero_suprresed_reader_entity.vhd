


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.array2zero_suprresed_reader_pgk.all;


entity array2zero_suprresed_reader_et  is
    generic (
        FileName : string := "./array2zero_suprresed_in.csv"
    );
    port (
        clk : in std_logic ;
        data : out array2zero_suprresed_reader_rec
    );
end entity;   

architecture Behavioral of array2zero_suprresed_reader_et is 

  constant  NUM_COL    : integer := 14;
  signal    csv_r_data : c_integer_array(NUM_COL -1 downto 0)  := (others=>0)  ;
begin

  csv_r :entity  work.csv_read_file 
    generic map (
        FileName =>  FileName, 
        NUM_COL => NUM_COL,
        useExternalClk=>true,
        HeaderLines =>  2
    ) port map (
        clk => clk,
        Rows => csv_r_data
    );

  integer_to_sl(csv_r_data(0), data.rst);
  integer_to_slv(csv_r_data(1), data.data_in(0));
  integer_to_slv(csv_r_data(2), data.data_in(1));
  integer_to_slv(csv_r_data(3), data.data_in(2));
  integer_to_slv(csv_r_data(4), data.data_in(3));
  integer_to_slv(csv_r_data(5), data.data_in(4));
  integer_to_slv(csv_r_data(6), data.data_in(5));
  integer_to_slv(csv_r_data(7), data.data_in(6));
  integer_to_slv(csv_r_data(8), data.data_in(7));
  integer_to_slv(csv_r_data(9), data.data_in(8));
  integer_to_sl(csv_r_data(10), data.valid);
  integer_to_sl(csv_r_data(11), data.zs_data_out_s2m(0).ready);
  integer_to_sl(csv_r_data(12), data.zs_data_out_s2m(1).ready);
  integer_to_sl(csv_r_data(13), data.zs_data_out_s2m(2).ready);


end Behavioral;
    