

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UNISIM;
  use UNISIM.VComponents.all;
  use work.UtilityPkg.all;

  use work.array2zero_suprresed_writer_pgk.all;
  use work.array2zero_suprresed_reader_pgk.all;
  use work.type_conversions_pgk.all;
  use work.Imp_test_bench_pgk.all;
  
entity array2zero_suprresed_eth is
  port (
    clk : in std_logic;
    TxDataChannel : out  DWORD := (others => '0');
    TxDataValid   : out  sl := '0';
    TxDataLast    : out  sl := '0';
    TxDataReady   : in   sl := '0';
    RxDataChannel : in   DWORD := (others => '0');
    RxDataValid   : in   sl := '0';
    RxDataLast    : in   sl := '0';
    RxDataReady   : out  sl := '0'
  );
end entity;

architecture rtl of array2zero_suprresed_eth is
  
  constant Throttel_max_counter : integer  := 10;
  constant Throttel_wait_time : integer := 100000;

  -- User Data interfaces



  signal  i_TxDataChannels :  DWORD := (others => '0');
  signal  i_TxDataValids   :  sl := '0';
  signal  i_TxDataLasts    :  sl := '0';
  signal  i_TxDataReadys   :  sl := '0';

  constant FIFO_DEPTH : integer := 10;
  constant COLNum : integer := 14;
  signal i_data :  Word32Array(COLNum -1 downto 0) := (others => (others => '0'));
  signal i_controls_out    : Imp_test_bench_reader_Control_t  := Imp_test_bench_reader_Control_t_null;
  signal i_valid      : sl := '0';
   
  constant COLNum_out : integer := 30;
  signal i_data_out :  Word32Array(COLNum_out -1 downto 0) := (others => (others => '0'));
   

  signal data_in  : array2zero_suprresed_reader_rec := array2zero_suprresed_reader_rec_null;
  signal data_out : array2zero_suprresed_writer_rec := array2zero_suprresed_writer_rec_null;
  
begin
  
  
  
  u_reader : entity work.Imp_test_bench_reader
    generic map (
      COLNum => COLNum ,
      FIFO_DEPTH => FIFO_DEPTH
    ) port map (
      Clk          => clk,
      -- Incoming data
      rxData       => RxDataChannel,
      rxDataValid  => RxDataValid,
      rxDataLast   => RxDataLast,
      rxDataReady  => RxDataReady,
      -- outgoing data
      data_out     => i_data,
      valid        => i_valid,
      controls_out => i_controls_out
    );

  u_writer : entity work.Imp_test_bench_writer 
    generic map (
      COLNum => COLNum_out,
      FIFO_DEPTH => FIFO_DEPTH
    ) port map (
      Clk      => clk,
      -- Outgoing  data
      tXData      =>  i_TxDataChannels,
      txDataValid =>  i_TxDataValids,
      txDataLast  =>  i_TxDataLasts,
      txDataReady =>  i_TxDataReadys,
      -- incomming data 
      data_in    => i_data_out,
      controls_in => i_controls_out,
      Valid      => i_valid
    );
throttel : entity work.axiStreamThrottle 
    generic map (
        max_counter => Throttel_max_counter,
        wait_time   => Throttel_wait_time
    ) port map (
        clk           => clk,

        rxData         =>  i_TxDataChannels,
        rxDataValid    =>  i_TxDataValids,
        rxDataLast     =>  i_TxDataLasts,
        rxDataReady    =>  i_TxDataReadys,

        tXData          => TxDataChannel,
        txDataValid     => TxDataValid,
        txDataLast      => TxDataLast,
        txDataReady     =>  TxDataReady
    );
-- <DUT>
    DUT :  entity work.array2zero_suprresed port map(
  clk => clk,
  rst => data_out.rst,
  data_in => data_out.data_in,
  valid => data_out.valid,
  tomanychangeserror => data_out.tomanychangeserror,
  zs_data_out_m2s => data_out.zs_data_out_m2s,
  zs_data_out_s2m => data_out.zs_data_out_s2m
);
-- </DUT>


--  <data_out_converter>

sl_to_slv(data_out.rst, i_data_out(0) );
slv ( 31 downto 0 )_to_slv(data_out.data_in(0), i_data_out(1) );
slv ( 31 downto 0 )_to_slv(data_out.data_in(1), i_data_out(2) );
slv ( 31 downto 0 )_to_slv(data_out.data_in(2), i_data_out(3) );
slv ( 31 downto 0 )_to_slv(data_out.data_in(3), i_data_out(4) );
slv ( 31 downto 0 )_to_slv(data_out.data_in(4), i_data_out(5) );
slv ( 31 downto 0 )_to_slv(data_out.data_in(5), i_data_out(6) );
slv ( 31 downto 0 )_to_slv(data_out.data_in(6), i_data_out(7) );
slv ( 31 downto 0 )_to_slv(data_out.data_in(7), i_data_out(8) );
slv ( 31 downto 0 )_to_slv(data_out.data_in(8), i_data_out(9) );
sl_to_slv(data_out.valid, i_data_out(10) );
sl_to_slv(data_out.tomanychangeserror, i_data_out(11) );
sl_to_slv(data_out.zs_data_out_m2s(0).valid, i_data_out(12) );
slv_to_slv(data_out.zs_data_out_m2s(0).data.array_index, i_data_out(13) );
slv_to_slv(data_out.zs_data_out_m2s(0).data.time_index, i_data_out(14) );
slv_to_slv(data_out.zs_data_out_m2s(0).data.data, i_data_out(15) );
sl_to_slv(data_out.zs_data_out_m2s(0).last, i_data_out(16) );
sl_to_slv(data_out.zs_data_out_m2s(1).valid, i_data_out(17) );
slv_to_slv(data_out.zs_data_out_m2s(1).data.array_index, i_data_out(18) );
slv_to_slv(data_out.zs_data_out_m2s(1).data.time_index, i_data_out(19) );
slv_to_slv(data_out.zs_data_out_m2s(1).data.data, i_data_out(20) );
sl_to_slv(data_out.zs_data_out_m2s(1).last, i_data_out(21) );
sl_to_slv(data_out.zs_data_out_m2s(2).valid, i_data_out(22) );
slv_to_slv(data_out.zs_data_out_m2s(2).data.array_index, i_data_out(23) );
slv_to_slv(data_out.zs_data_out_m2s(2).data.time_index, i_data_out(24) );
slv_to_slv(data_out.zs_data_out_m2s(2).data.data, i_data_out(25) );
sl_to_slv(data_out.zs_data_out_m2s(2).last, i_data_out(26) );
sl_to_slv(data_out.zs_data_out_s2m(0).ready, i_data_out(27) );
sl_to_slv(data_out.zs_data_out_s2m(1).ready, i_data_out(28) );
sl_to_slv(data_out.zs_data_out_s2m(2).ready, i_data_out(29) );

--  </data_out_converter>

-- <data_in_converter> 

slv_to_sl(i_data(0), data_in.rst);
slv_to_slv ( 31 downto 0 )(i_data(1), data_in.data_in(0));
slv_to_slv ( 31 downto 0 )(i_data(2), data_in.data_in(1));
slv_to_slv ( 31 downto 0 )(i_data(3), data_in.data_in(2));
slv_to_slv ( 31 downto 0 )(i_data(4), data_in.data_in(3));
slv_to_slv ( 31 downto 0 )(i_data(5), data_in.data_in(4));
slv_to_slv ( 31 downto 0 )(i_data(6), data_in.data_in(5));
slv_to_slv ( 31 downto 0 )(i_data(7), data_in.data_in(6));
slv_to_slv ( 31 downto 0 )(i_data(8), data_in.data_in(7));
slv_to_slv ( 31 downto 0 )(i_data(9), data_in.data_in(8));
slv_to_sl(i_data(10), data_in.valid);
slv_to_sl(i_data(11), data_in.zs_data_out_s2m(0).ready);
slv_to_sl(i_data(12), data_in.zs_data_out_s2m(1).ready);
slv_to_sl(i_data(13), data_in.zs_data_out_s2m(2).ready);

--</data_in_converter>

-- <connect_input_output>

data_out.rst <= data_in.rst;
data_out.data_in <= data_in.data_in;
data_out.valid <= data_in.valid;
data_out.zs_data_out_s2m <= data_in.zs_data_out_s2m;

-- </connect_input_output>


end architecture;
