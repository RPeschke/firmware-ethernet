
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

library UNISIM;
  use UNISIM.VComponents.all;

  use work.UtilityPkg.all;
  use work.Eth1000BaseXPkg.all;
  use work.GigabitEthPkg.all;

  use work.simplearithmetictest_writer_pgk.all;
  use work.simplearithmetictest_reader_pgk.all;
  use work.type_conversions_pgk.all;
  use work.Imp_test_bench_pgk.all;
  
entity simplearithmetictest_top is
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

architecture rtl of simplearithmetictest_top is
  
  signal fabClk       : sl := '0';
  -- User Data interfaces
  signal  RxDataChannel :  DWORD := (others => '0');
  signal  RxDataValid   :  sl := '0';
  signal  RxDataLast    :  sl := '0';
  signal  RxDataReady   :  sl := '0';
  

  
  
  signal  TxDataChannel :  DWORD := (others => '0');
  signal  TxDataValid   :  sl := '0';
  signal  TxDataLast    :  sl := '0';
  signal  TxDataReady   :  sl := '0';
  

  signal  TxDataChannel1 :  DWORD := (others => '0');
  signal  TxDataValid1   :  sl := '0';
  signal  TxDataLast1    :  sl := '0';
  signal  TxDataReady1   :  sl := '0';
  

   constant COLNum : integer :=4;
   signal i_data :  Word32Array(COLNum -1 downto 0) := (others => (others => '0'));
   signal i_controls_out    : Imp_test_bench_reader_Control_t  := Imp_test_bench_reader_Control_t_null;
   signal i_valid      : sl := '0';
   
   constant COLNum_out : integer := 6;
   signal i_data_out :  Word32Array(COLNum_out -1 downto 0) := (others => (others => '0'));
   

   signal data_in  : simplearithmetictest_reader_rec := simplearithmetictest_reader_rec_null;
   signal data_out : simplearithmetictest_writer_rec := simplearithmetictest_writer_rec_null;
  
   signal test_data   : slv(31  downto 0);
	     constant NUM_IP_G        : integer := 2;
     

     signal clk62p5  : sl :='0';
  --   signal ethClk125    : sl;
     
     signal ethCoreMacAddr : MacAddrType := MAC_ADDR_DEFAULT_C;
     
     signal userRst     : sl;
     signal ethCoreIpAddr  : IpAddrType  := IP_ADDR_DEFAULT_C;
     constant ethCoreIpAddr1 : IpAddrType  := (3 => x"C0", 2 => x"A8", 1 => x"01", 0 => x"21");
     constant udpPort        :  slv(15 downto 0):=  x"07D1" ;
     signal tpData      : slv(31 downto 0);
     signal tpDataValid : sl;
     signal tpDataLast  : sl;
     signal tpDataReady : sl;
     
     -- Test registers
     -- Default is to send 1000 counter words once per second.
     signal waitCyclesHigh : slv(15 downto 0) := x"0773";
     signal waitCyclesLow  : slv(15 downto 0) := x"5940";
     signal numWords       : slv(15 downto 0) := x"02E9";
     
     
     -- User Data interfaces
     signal userTxDataChannels : Word32Array(NUM_IP_G-1 downto 0);
     signal userTxDataValids   : slv(NUM_IP_G-1 downto 0);
     signal userTxDataLasts    : slv(NUM_IP_G-1 downto 0);
     signal userTxDataReadys   : slv(NUM_IP_G-1 downto 0);
     signal userRxDataChannels : Word32Array(NUM_IP_G-1 downto 0);
     signal userRxDataValids   : slv(NUM_IP_G-1 downto 0);
     signal userRxDataLasts    : slv(NUM_IP_G-1 downto 0);
     signal userRxDataReadys   : slv(NUM_IP_G-1 downto 0);
	  
begin
  
  U_IBUFGDS : IBUFGDS port map ( I => fabClkP, IB => fabClkN, O => fabClk);


--	clk_div :process( fabClk) is 
--	
--	begin 
--	if rising_edge(fabClk) then
--		clk62p5  <= not clk62p5;
--	end if;
--	
--	end process;
--
--inFifo :   entity work.axi_fifo port map(
--  
--    m_aclk => clk62p5,
--    s_aclk => fabClk, 
--    s_aresetn => '0',
--    s_axis_tvalid => RxDataValids125,
--    s_axis_tready => RxDataReadys125,
--    s_axis_tdata => RxDataChannels125,
--    s_axis_tlast => RxDataLasts125,
--    m_axis_tvalid => RxDataValids62,
--    m_axis_tready => RxDataReadys62,
--    m_axis_tdata => RxDataChannels62,
--    m_axis_tlast => RxDataLasts62
--  
--);

--OutFifo :   entity work.axi_fifo port map(
--  
--    m_aclk => fabClk ,
--    s_aclk => clk62p5, 
--    s_aresetn => '0',
--    s_axis_tvalid => TxDataValids62,
--    s_axis_tready => TxDataReadys62,
--    s_axis_tdata => TxDataChannels62,
--    s_axis_tlast => TxDataLasts62,
--    m_axis_tvalid => TxDataValids125,
--    m_axis_tready => TxDataReadys125,
--    m_axis_tdata => TxDataChannels125,
--    m_axis_tlast => TxDataLasts125
--  
--);
--  

  --------------------------------
  -- Gigabit Ethernet Interface --
  --------------------------------
  U_S6EthTop : entity work.S6EthTop
    generic map (
      NUM_IP_G     => NUM_IP_G
    )
    port map (
      -- Direct GT connections
      gtTxP           => gtTxP,
      gtTxN           => gtTxN,
      gtRxP           => gtRxP,
      gtRxN           => gtRxN,
      gtClkP          => gtClkP,
      gtClkN          => gtClkN,
      -- Alternative clock input from fabric
      fabClkIn        => fabClk,
      -- SFP transceiver disable pin
      txDisable       => txDisable,
      -- Clocks out from Ethernet core
      ethUsrClk62     => clk62p5,
      ethUsrClk125    => open,
      -- Status and diagnostics out
      ethSync         => open,
      ethReady        => open,
      led             => open,
      -- Core settings in 
      macAddr         => ethCoreMacAddr,
      ipAddrs         => (0 => ethCoreIpAddr, 1 => ethCoreIpAddr1),
      udpPorts        => (0 => x"07D0",       1 => udpPort), --x7D0 = 2000,
      -- User clock inputs
      userClk         => clk62p5,
      userRstIn       => '0',
      userRstOut      => userRst,
      -- User data interfaces
      userTxData      => userTxDataChannels,
      userTxDataValid => userTxDataValids,
      userTxDataLast  => userTxDataLasts,
      userTxDataReady => userTxDataReadys,
      userRxData      => userRxDataChannels,
      userRxDataValid => userRxDataValids,
      userRxDataLast  => userRxDataLasts,
      userRxDataReady => userRxDataReadys
    );
  
  userTxDataChannels(0) <= tpData;
  userTxDataValids(0)   <= tpDataValid;
  userTxDataLasts(0)    <= tpDataLast;
  tpDataReady           <= userTxDataReadys(0);
  -- Note that the Channel 0 RX channels are unused here
  --userRxDataChannels;
  --userRxDataValids;
  --userRxDataLasts;
  userRxDataReadys(0) <= '1';
  
  
  U_TpGenTx : entity work.TpGenTx
    port map (
      -- User clock and reset
      userClk         => clk62p5,
      userRst         => userRst,
      -- Configuration
      waitCycles      => waitCyclesHigh & waitCyclesLow,
      numWords        => x"0000" & numWords,
      -- Connection to user logic
      userTxData      => tpData,
      userTxDataValid => tpDataValid,
      userTxDataLast  => tpDataLast,
      userTxDataReady => tpDataReady
    );
  
  userTxDataChannels(1) <=  TxDataChannel;
  userTxDataValids(1)   <=  TxDataValid;
  userTxDataLasts(1)    <=  TxDataLast;
  TxDataReady           <=  userTxDataReadys(1);
  
    
  RxDataChannel        <=  userRxDataChannels(1);
  RxDataValid          <=  userRxDataValids(1);
  RxDataLast           <=  userRxDataLasts(1);
  userRxDataReadys(1)      <=  RxDataReady;          
  

  


  


  u_reader : entity work.Imp_test_bench_reader
    generic map (
      COLNum => COLNum,
		FIFO_DEPTH => 11
    ) port map (
      Clk       => clk62p5,
      -- Incoming data
      rxData      => RxDataChannel,
      rxDataValid => RxDataValid,
      rxDataLast  => RxDataLast,
      rxDataReady => RxDataReady,
      data_out    => i_data,
      valid => i_valid,
      controls_out => i_controls_out
    );



throt: entity work.axiStreamThrottle   
generic map (
  max_counter => 10 ,
  wait_time   =>  100000
)  port map (
  clk           => clk62p5,
  rxData        => TxDataChannel1,
  rxDataValid   => txDataValid1,
  rxDataLast    => txDataLast1,
  rxDataReady   => txDataReady1,

  tXData          => TxDataChannel,
  txDataValid     => TxDataValid,
  txDataLast      => TxDataLast,
  txDataReady     => TxDataReady
);


  u_writer : entity work.Imp_test_bench_writer 
    generic map (
      COLNum => COLNum_out,
		FIFO_DEPTH => 11
		) port map (
      Clk      => clk62p5,
      -- Incoming data
      tXData      =>  TxDataChannel1,
      txDataValid =>  TxDataValid1,
      txDataLast  =>  TxDataLast1,
      txDataReady =>  TxDataReady1,
      data_in    => i_data_out,
      controls_in => i_controls_out,
      Valid      => i_valid
    );



-- <DUT>
    DUT :  entity work.simplearithmetictest port map(
  clk => clk62p5 ,
  multia_in => i_data(1),
  multib_in => i_data(2),
  multic_out => i_data_out(4),
  Controller => i_data_out(5)
);
-- </DUT>

--  <data_out_converter>


--integer_to_slv(data_out.multic_out, i_data_out(3) );
--i_data_out(4) <= test_data;
--  </data_out_converter>

-- <data_in_converter> 

--slv_to_integer(i_data(1), data_in.multia_in);
--slv_to_integer(i_data(2), data_in.multib_in);

--</data_in_converter>

-- <connect_input_output>




slv_to_slv( i_data(0) ,i_data_out(0) );
slv_to_slv( i_data(1) ,i_data_out(1) );
slv_to_slv( i_data(2) ,i_data_out(2) );
slv_to_slv( i_data(3) ,i_data_out(3) );



-- </connect_input_output>


end architecture;
