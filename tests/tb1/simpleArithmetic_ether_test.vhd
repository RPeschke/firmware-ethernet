
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.UtilityPkg.all;
use work.axiDWORDbi_p.all;
use work.type_conversions_pgk.all;
use work.simplearithmetictest_writer_pgk.all;
use work.simplearithmetictest_reader_pgk.all;


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
   

    
     constant COLNum : integer := 3;
     signal i_data :  Word32Array(COLNum -1 downto 0) := (others => (others => '0'));
     signal i_valid      : sl := '0';
     
     constant COLNum_out : integer := 3;
     signal i_data_out :  Word32Array(COLNum_out -1 downto 0) := (others => (others => '0'));
     
  
     signal data_in  : simplearithmetictest_reader_rec := simplearithmetictest_reader_rec_null;
     signal data_out : simplearithmetictest_writer_rec := simplearithmetictest_writer_rec_null;
begin
  
u_reader : entity work.Imp_test_bench_reader 
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
  valid => i_valid
);

u_writer : entity work.Imp_test_bench_writer 
generic map (
  COLNum => COLNum_out 
) port map (
  Clk      => clk,
  -- Incoming data
  tXData      =>  txDataOut,
  txDataValid =>  txDataValid,
  txDataLast  =>  txDataLast,
  txDataReady =>  txDataReady,
  data_in    => i_data_out,
  Valid      => i_valid
);



-- <DUT>
DUT :  entity work.simplearithmetictest port map(
clk => clk,
multia_in => data_out.multia_in,
multib_in => data_out.multib_in,
multic_out => data_out.multic_out
);
-- </DUT>

--  <data_out_converter>


integer_to_slv(data_out.multic_out, i_data_out(2) );

--  </data_out_converter>

-- <data_in_converter> 

slv_to_integer(i_data(0), data_in.multia_in);
slv_to_integer(i_data(1), data_in.multib_in);

--</data_in_converter>

-- <connect_input_output>
i_data_out(0) <= i_data(0);
i_data_out(1) <= i_data(1);


-- </connect_input_output>
end  rtl ;