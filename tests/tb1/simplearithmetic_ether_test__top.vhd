
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UNISIM;
  use UNISIM.VComponents.all;

  use work.UtilityPkg.all;
  use work.Eth1000BaseXPkg.all;
  use work.GigabitEthPkg.all;

  use work.simplearithmetic_ether_test_writer_pgk.all;
  use work.simplearithmetic_ether_test_reader_pgk.all;
  use work.type_conversions_pgk.all;
  
  
entity simplearithmetic_ether_test_top is
  port (
    -- Direct GT connections
    gtTxP        : out sl;
    gtTxN        : out sl;
    gtRxP        :  in sl;
    gtRxN        :  in sl;
    gtClkP       :  in sl;
    gtClkN       :  in sl;
    -- Alternative clock input
    fabClkP      :  in sl;
    fabClkN      :  in sl;
    -- SFP transceiver disable pin
    txDisable    : out sl
  );
end entity;

architecture rtl of simplearithmetic_ether_test_top is
  
  signal fabClk       : sl := '0';
  -- User Data interfaces
  signal  TxDataChannels :  DWORD := (others => '0');
  signal  TxDataValids   :  sl := '0';
  signal  TxDataLasts    :  sl := '0';
  signal  TxDataReadys   :  sl := '0';
  signal  RxDataChannels :  DWORD := (others => '0');
  signal  RxDataValids   :  sl := '0';
  signal  RxDataLasts    :  sl := '0';
  signal  RxDataReadys   :  sl := '0';
  
   constant COLNum : integer := 3;
   signal i_data :  Word32Array(COLNum -1 downto 0) := (others => (others => '0'));
   signal i_valid      : sl := '0';
   
   constant COLNum_out : integer := 3;
   signal i_data_out :  Word32Array(COLNum_out -1 downto 0) := (others => (others => '0'));
   

   signal data_in  : simplearithmetic_ether_test_reader_rec := simplearithmetic_ether_test_reader_rec_null;
   signal data_out : simplearithmetic_ether_test_writer_rec := simplearithmetic_ether_test_writer_rec_null;
begin
  
  U_IBUFGDS : IBUFGDS port map ( I => fabClkP, IB => fabClkN, O => fabClk);

  e2a : entity work.ethernet2axistream port map(
    clk => fabClk,
    
    -- Direct GT connections
    gtTxP        => gtTxP,
    gtTxN        => gtTxN,
    gtRxP        => gtRxP,
    gtRxN        => gtRxN,
    gtClkP       => gtClkP, 
    gtClkN       => gtClkN,
    
    

    -- SFP transceiver disable pin
    txDisable    => txDisable,
    -- axi stream output

    -- User Data interfaces
    TxDataChannels => TxDataChannels,
    TxDataValids   => TxDataValids,
    TxDataLasts    => TxDataLasts,
    TxDataReadys   => TxDataReadys,
    RxDataChannels => RxDataChannels,
    RxDataValids   => RxDataValids,
    RxDataLasts    => RxDataLasts,
    RxDataReadys   => RxDataReadys,

    EthernetIpAddr  => (3 => x"C0", 2 => x"A8", 1 => x"01", 0 => x"21"),
    udpPort        =>    x"07d1"  --  x"0x7d1" 
    
  );
  
  
  u_reader : entity work.Imp_test_bench_reader 
    generic map (
      COLNum => COLNum 
    ) port map (
      Clk       => fabClk,
      -- Incoming data
      rxData      => RxDataChannels,
      rxDataValid => RxDataValids,
      rxDataLast  => RxDataLasts,
      rxDataReady => RxDataReadys,
      data_out    => i_data,
      valid => i_valid
    );

  u_writer : entity work.Imp_test_bench_writer 
    generic map (
      COLNum => COLNum_out 
    ) port map (
      Clk      => fabClk,
      -- Incoming data
      tXData      =>  TxDataChannels,
      txDataValid =>  TxDataValids,
      txDataLast  =>  TxDataLasts,
      txDataReady =>  TxDataReadys,
      data_in    => i_data_out,
      Valid      => i_valid
    );



-- <DUT>
    DUT :  entity work.simplearithmetic_ether_test port map(
  clk => fabClk,
  rxdata => data_out.rxdata,
  rxdatavalid => data_out.rxdatavalid,
  rxdatalast => data_out.rxdatalast,
  rxdataready => data_out.rxdataready,
  txdataout => data_out.txdataout,
  txdatavalid => data_out.txdatavalid,
  txdatalast => data_out.txdatalast,
  txdataready => data_out.txdataready
);
-- </DUT>

--  <data_out_converter>

slv_to_slv(data_out.rxdata, i_data_out(0) );
sl_to_slv(data_out.rxdatavalid, i_data_out(1) );
sl_to_slv(data_out.rxdatalast, i_data_out(2) );
sl_to_slv(data_out.rxdataready, i_data_out(3) );
slv_to_slv(data_out.txdataout, i_data_out(4) );
sl_to_slv(data_out.txdatavalid, i_data_out(5) );
sl_to_slv(data_out.txdatalast, i_data_out(6) );
sl_to_slv(data_out.txdataready, i_data_out(7) );

--  </data_out_converter>

-- <data_in_converter> 

slv_to_slv(i_data(0), data_in.rxdata);
slv_to_sl(i_data(1), data_in.rxdatavalid);
slv_to_sl(i_data(2), data_in.rxdatalast);
slv_to_sl(i_data(3), data_in.txdataready);

--</data_in_converter>

-- <connect_input_output>

data_out.rxdata <= data_in.rxdata;
data_out.rxdatavalid <= data_in.rxdatavalid;
data_out.rxdatalast <= data_in.rxdatalast;
data_out.txdataready <= data_in.txdataready;

-- </connect_input_output>


end architecture;
