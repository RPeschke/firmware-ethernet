


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.zero_supression_test_connection_writer_pgk.all;

entity zero_supression_test_connection_writer_et  is
    generic ( 
        FileName : string := "./zero_supression_test_connection_out.csv"
    ); port (
        clk : in std_logic ;
        data : in zero_supression_test_connection_writer_rec
    );
end entity;

architecture Behavioral of zero_supression_test_connection_writer_et is 
  constant  NUM_COL : integer := 23;
  signal data_int   : c_integer_array(NUM_COL - 1 downto 0)  := (others=>0);
begin

    csv_w : entity  work.csv_write_file 
        generic map (
            FileName => FileName,
            HeaderLines=> "rst; data_in_0; data_in_1; data_in_2; data_in_3; data_in_4; data_in_5; data_in_6; data_in_7; data_in_8; valid_in; tomanychangeserror_a2z; data_out_0; data_out_1; data_out_2; data_out_3; data_out_4; data_out_5; data_out_6; data_out_7; data_out_8; valid_out; tomanychangeserror_z2a",
            NUM_COL =>   NUM_COL 
        ) port map(
            clk => clk, 
            Rows => data_int
        );


  sl_to_integer(data.rst, data_int(0) );
  slv_to_integer(data.data_in(0), data_int(1) );
  slv_to_integer(data.data_in(1), data_int(2) );
  slv_to_integer(data.data_in(2), data_int(3) );
  slv_to_integer(data.data_in(3), data_int(4) );
  slv_to_integer(data.data_in(4), data_int(5) );
  slv_to_integer(data.data_in(5), data_int(6) );
  slv_to_integer(data.data_in(6), data_int(7) );
  slv_to_integer(data.data_in(7), data_int(8) );
  slv_to_integer(data.data_in(8), data_int(9) );
  sl_to_integer(data.valid_in, data_int(10) );
  sl_to_integer(data.tomanychangeserror_a2z, data_int(11) );
  slv_to_integer(data.data_out(0), data_int(12) );
  slv_to_integer(data.data_out(1), data_int(13) );
  slv_to_integer(data.data_out(2), data_int(14) );
  slv_to_integer(data.data_out(3), data_int(15) );
  slv_to_integer(data.data_out(4), data_int(16) );
  slv_to_integer(data.data_out(5), data_int(17) );
  slv_to_integer(data.data_out(6), data_int(18) );
  slv_to_integer(data.data_out(7), data_int(19) );
  slv_to_integer(data.data_out(8), data_int(20) );
  sl_to_integer(data.valid_out, data_int(21) );
  sl_to_integer(data.tomanychangeserror_z2a, data_int(22) );


end Behavioral;
    