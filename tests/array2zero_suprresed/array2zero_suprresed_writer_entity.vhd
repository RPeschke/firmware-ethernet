


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.type_conversions_pgk.all;
use work.CSV_UtilityPkg.all;



use work.array2zero_suprresed_writer_pgk.all;

entity array2zero_suprresed_writer_et  is
    generic ( 
        FileName : string := "./array2zero_suprresed_out.csv"
    ); port (
        clk : in std_logic ;
        data : in array2zero_suprresed_writer_rec
    );
end entity;

architecture Behavioral of array2zero_suprresed_writer_et is 
  constant  NUM_COL : integer := 30;
  signal data_int   : c_integer_array(NUM_COL - 1 downto 0)  := (others=>0);
begin

    csv_w : entity  work.csv_write_file 
        generic map (
            FileName => FileName,
            HeaderLines=> "rst; data_in_0; data_in_1; data_in_2; data_in_3; data_in_4; data_in_5; data_in_6; data_in_7; data_in_8; valid; tomanychangeserror; zs_data_out_m2s_0_valid; zs_data_out_m2s_0_data_array_index; zs_data_out_m2s_0_data_time_index; zs_data_out_m2s_0_data_data; zs_data_out_m2s_0_last; zs_data_out_m2s_1_valid; zs_data_out_m2s_1_data_array_index; zs_data_out_m2s_1_data_time_index; zs_data_out_m2s_1_data_data; zs_data_out_m2s_1_last; zs_data_out_m2s_2_valid; zs_data_out_m2s_2_data_array_index; zs_data_out_m2s_2_data_time_index; zs_data_out_m2s_2_data_data; zs_data_out_m2s_2_last; zs_data_out_s2m_0_ready; zs_data_out_s2m_1_ready; zs_data_out_s2m_2_ready",
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
  sl_to_integer(data.valid, data_int(10) );
  sl_to_integer(data.tomanychangeserror, data_int(11) );
  sl_to_integer(data.zs_data_out_m2s(0).valid, data_int(12) );
  slv_to_integer(data.zs_data_out_m2s(0).data.array_index, data_int(13) );
  slv_to_integer(data.zs_data_out_m2s(0).data.time_index, data_int(14) );
  slv_to_integer(data.zs_data_out_m2s(0).data.data, data_int(15) );
  sl_to_integer(data.zs_data_out_m2s(0).last, data_int(16) );
  sl_to_integer(data.zs_data_out_m2s(1).valid, data_int(17) );
  slv_to_integer(data.zs_data_out_m2s(1).data.array_index, data_int(18) );
  slv_to_integer(data.zs_data_out_m2s(1).data.time_index, data_int(19) );
  slv_to_integer(data.zs_data_out_m2s(1).data.data, data_int(20) );
  sl_to_integer(data.zs_data_out_m2s(1).last, data_int(21) );
  sl_to_integer(data.zs_data_out_m2s(2).valid, data_int(22) );
  slv_to_integer(data.zs_data_out_m2s(2).data.array_index, data_int(23) );
  slv_to_integer(data.zs_data_out_m2s(2).data.time_index, data_int(24) );
  slv_to_integer(data.zs_data_out_m2s(2).data.data, data_int(25) );
  sl_to_integer(data.zs_data_out_m2s(2).last, data_int(26) );
  sl_to_integer(data.zs_data_out_s2m(0).ready, data_int(27) );
  sl_to_integer(data.zs_data_out_s2m(1).ready, data_int(28) );
  sl_to_integer(data.zs_data_out_s2m(2).ready, data_int(29) );


end Behavioral;
    