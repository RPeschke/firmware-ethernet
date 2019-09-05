
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.UtilityPkg.all;
use work.axiDWORDbi_p.all;
use work.type_conversions_pgk.all;
use work.simplearithmetictest_writer_pgk.all;
use work.simplearithmetictest_reader_pgk.all;
use work.Imp_test_bench_pgk.all;

entity simpleArithmetic_ether_test is 
port ( 
  -- User clock and reset
  clk         : in  std_logic;
  -- Incoming data
  rxData      : in  std_logic_vector(31 downto 0);
  rxDataValid : in  std_logic;
  rxDataLast  : in  std_logic;
  rxDataReady : out std_logic;
  -- Outgoing response
  txDataOut   : out std_logic_vector(31 downto 0);
  txDataValid : out std_logic;
  txDataLast  : out std_logic;
  txDataReady : in  std_logic
); 

end simpleArithmetic_ether_test;

architecture rtl of simpleArithmetic_ether_test is
   
  signal  txDataOut1   : std_logic_vector(31 downto 0) := (others => '0');
  signal  txDataValid1 : std_logic := '0';
  signal  txDataLast1  : std_logic := '0';
  signal  txDataReady1 : std_logic := '0';
    
     constant COLNum : integer := 4;
     signal i_data :  Word32Array(COLNum -1 downto 0) := (others => (others => '0'));
     signal i_valid      : sl := '0';
     -- signal i_controls_out :  Word32Array(4 downto 0) := (others => (others => '0'));
     signal i_controls_out    : Imp_test_bench_reader_Control_t  := Imp_test_bench_reader_Control_t_null;

     constant COLNum_out : integer := 6;
     signal i_data_out :  Word32Array(COLNum_out -1 downto 0) := (others => (others => '0'));
     
  
     signal data_in  : simplearithmetictest_reader_rec := simplearithmetictest_reader_rec_null;
     signal data_out : simplearithmetictest_writer_rec := simplearithmetictest_writer_rec_null;
begin
  
u_reader : entity work.Imp_test_bench_reader_dummy
generic map (
  COLNum => COLNum 
) port map (
  Clk       => clk,
  -- Incoming data
  rxData      => rxData,
  rxDataValid => rxDataValid,
  rxDataLast  => rxDataLast,
  rxDataReady => rxDataReady,
  data_out    => i_data,
  controls_out => i_controls_out,
  valid => i_valid
);

u_writer : entity work.Imp_test_bench_writer 
generic map (
  COLNum => COLNum_out ,
  FIFO_DEPTH => 10
) port map (
  Clk      => clk,
  -- Incoming data
  tXData      =>  txDataOut1,
  txDataValid =>  txDataValid1,
  txDataLast  =>  txDataLast1,
  txDataReady =>  txDataReady1,
  data_in    => i_data_out,
  controls_in => i_controls_out,
  Valid      => i_valid
);

throt: entity work.axiStreamThrottle   
generic map (
  max_counter => 10 
)  port map (
  clk           => clk,
  rxData        => txDataOut1,
  rxDataValid   => txDataValid1,
  rxDataLast    => txDataLast1,
  rxDataReady   => txDataReady1,

  tXData          => txDataOut,
  txDataValid     => txDataValid,
  txDataLast      => txDataLast,
  txDataReady     => txDataReady
);

-- <DUT>
DUT :  entity work.simplearithmetictest port map(
  clk => clk,
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
--i_data_out(0) <= i_controls_out(0);
--i_data_out(1) <= i_controls_out(1);
--i_data_out(2) <= i_controls_out(2);
--i_data_out(3) <= i_controls_out(3);
--i_data_out(4) <= i_controls_out(4);

--slv_to_slv( i_controls_out(0) ,i_data_out(0) );
--slv_to_slv( i_controls_out(1) ,i_data_out(1) );
--slv_to_slv( i_controls_out(2) ,i_data_out(2) );
--slv_to_slv( i_controls_out(3) ,i_data_out(3) );
--slv_to_slv( i_controls_out(4) ,i_data_out(4) );

--i_data_out(5) <= i_data(0);
--i_data_out(6) <= i_data(1);
--i_data_out(7) <= i_data(2);
--i_data_out(8) <= i_data(3);
slv_to_slv( i_data(0) ,i_data_out(0) );
slv_to_slv( i_data(1) ,i_data_out(1) );
slv_to_slv( i_data(2) ,i_data_out(2) );
slv_to_slv( i_data(3) ,i_data_out(3) );

-- </connect_input_output>
end  rtl ;