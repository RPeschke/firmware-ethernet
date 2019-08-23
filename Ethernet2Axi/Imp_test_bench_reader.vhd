
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.UtilityPkg.all;
use work.axiDWORDbi_p.all;
use work.fifo_cc_pgk_32.all;
use work.type_conversions_pgk.all;
use work.axi_stream_pgk_32.all;

entity Imp_test_bench_reader is 
generic ( 
  COLNum : integer := 10
        
);
port(
Clk      : in  sl := '0';
-- Incoming data
rxData      : in  slv(31 downto 0) := (others => '0');
rxDataValid : in  sl := '0';
rxDataLast  : in  sl := '0';
rxDataReady : out sl := '0';
data_out    : out Word32Array(COLNum - 1 downto 0) := (others => (others => '0'));
controls_out    : out Word32Array(3 downto 0) := (others => (others => '0'));
valid : out sl := '0'
);
end entity;


architecture rtl of Imp_test_bench_reader is


type state_t is (idle,process_header,make_packet,early_stream_ending, late_stream_ending, send,wait_for_idle);

signal reader_state : state_t := idle;



signal  timestamp_signal      : slv(31 downto 0) := (others => '0');
signal  timeOut_signal      : slv(31 downto 0) := (others => '0');

signal  max_Packet_nr_signal      : slv(31 downto 0) := (others => '0');
signal  numStream_signal      : slv(31 downto 0) := (others => '0');
signal reset : sl := '0';

signal axi_in_m2s : axi_stream_32_m2s := axi_stream_32_m2s_null;
signal axi_in_s2m : axi_stream_32_s2m := axi_stream_32_s2m_null;





signal fifo_r_m2s : FIFO_nativ_reader_32_m2s := FIFO_nativ_reader_32_m2s_null;
signal fifo_r_s2m : FIFO_nativ_reader_32_s2m := FIFO_nativ_reader_32_s2m_null;
signal i_data_out    :  Word32Array((COLNum -1) downto 0) := (others => (others => '0'));
signal we          : sl := '0';


begin
axi_in_m2s.data <= rxData;
axi_in_m2s.last <=rxDataLast;
axi_in_m2s.valid <= rxDataValid;
rxDataReady <= axi_in_s2m.ready;


seq : process (Clk) is
  variable axi_in : axi_stream_32_slave_stream := axi_stream_32_slave_stream_null;
  variable int_buffer : integer :=0;
  variable Index : integer :=0;
  variable packetCounter : integer :=0;
  variable rxbuffer      : slv(31 downto 0) := (others => '0');
begin
  if (rising_edge(Clk)) then

    pull_axi_stream_32_slave_stream(axi_in, axi_in_m2s);
    we <= '0';
    reset <= '0';
    fifo_r_s2m.read_enable <='0';
    valid <= '0';
    timestamp_signal <= timestamp_signal +1;
    timeOut_signal <= timeOut_signal + 1;
    if reader_state = idle then 
        i_data_out  <= (others => (others => '0'));
        max_Packet_nr_signal <= (others => '0');
        numStream_signal <= (others => '0');
        if isReceivingData(axi_in)  then 
            timeOut_signal <= (others => '0');
            reader_state <= process_header;
            timestamp_signal <= (others => '0');
            Index := 0;
            packetCounter := 0;
        end if;
    elsif reader_state = process_header then
      if isReceivingData(axi_in) then 
        timeOut_signal <= (others => '0');
        read_data(axi_in,rxbuffer);
        if index = 0 then 
          max_Packet_nr_signal <= rxbuffer;
         
        elsif index = 1 then
          numStream_signal <= rxbuffer;
        end if;

        Index := Index + 1;

        if IsEndOfStream(axi_in) then 
          reader_state <= make_packet;
          Index := 0;
        end if;
      end if;

    elsif reader_state = make_packet then
        if index = 0 then 
          i_data_out  <= (others => (others => '0'));
        end if;
        if isReceivingData(axi_in) then 
          read_data(axi_in,rxbuffer);
          timeOut_signal <= (others => '0');
          i_data_out(Index) <=  rxbuffer;
          Index := Index + 1;
          
          if IsEndOfStream(axi_in) and Index >= COLNum then
            -- normal Stream ending
            index := 0;
            packetCounter :=packetCounter +1;
            we <=  '1';
         
          elsif  Index >= COLNum then
            -- late stream ebnding
            reader_state <=  late_stream_ending;
          elsif  IsEndOfStream(axi_in) then
            -- early stream ending
            reader_state <= early_stream_ending;
          end if ;

          if packetCounter >= max_Packet_nr_signal then 
            packetCounter := 0;
            reader_state <= send;
          end if;
                                  
        elsif timeOut_signal >  10000000   then
          packetCounter := 0;
          reader_state <= send;
        end if;
    elsif reader_state = early_stream_ending then
      i_data_out(Index) <=  (others => '0');
      Index := Index + 1;
      if  Index >= COLNum then
        index := 0;
        packetCounter :=packetCounter +1;
        we <=  '1';
        reader_state <=  make_packet;
      end if ;
    elsif reader_state = late_stream_ending then
      -- Flushing stream
      if isReceivingData(axi_in) then 
        read_data(axi_in,rxbuffer);
        timeOut_signal <= (others => '0');
        if IsEndOfStream(axi_in) then 
          index := 0;
          packetCounter :=packetCounter +1;
          we <=  '1';
          reader_state <=  make_packet;
        end if;
      end if;

    elsif reader_state = send then
        if fifo_r_s2m.read_enable ='1' then 
          valid <= '1';
        end if;
        fifo_r_s2m.read_enable <='1';
        
    
        packetCounter := packetCounter +1;
        if packetCounter >= max_Packet_nr_signal then 
            packetCounter := 0;
            reader_state <= wait_for_idle;
            reset <= '1';
        end if;
    elsif reader_state = wait_for_idle then
        
        if timeOut_signal > 200000 then 
            reader_state <= idle;


        end if;

        if isReceivingData(axi_in) then 
          read_data(axi_in,rxbuffer);
        end if;

    end if;

    
    -- flush input


    push_axi_stream_32_slave_stream(axi_in,axi_in_s2m);
  
    
  end if;
end process seq;


gen_DAC_CONTROL: for i in 1 to (COLNum -1) generate

fifo_i : entity work.fifo_cc generic map (
  DATA_WIDTH => 32,
  DEPTH => 5 
  
) port map (
  clk   => clk,
  rst   => reset,
  din   => i_data_out(i),
  wen   =>  we,
  full  => open,
  ren   => fifo_r_s2m.read_enable,
  dout  => data_out(i),
  empty => open
);

end generate gen_DAC_CONTROL;

fifo_i : entity work.fifo_cc generic map (
  DATA_WIDTH => 32,
  DEPTH => 5 

) port map (
  clk   => clk,
  rst   => reset,
  din   => i_data_out(0),
  wen   =>  we,
  full  => open,
  ren   => fifo_r_s2m.read_enable,
  dout  => fifo_r_m2s.data,
  empty => fifo_r_m2s.empty
);

data_out(0) <=  fifo_r_m2s.data;


timestamp_fifo_i : entity work.fifo_cc generic map (
  DATA_WIDTH => 32,
  DEPTH => 5 
  
) port map (
  clk   => clk,
  rst   => reset,
  din   => timestamp_signal,
  wen   =>  we,
  full  => open,
  ren   => fifo_r_s2m.read_enable,
  dout  => controls_out(0),
  empty => open
);
controls_out(1) <= timestamp_signal;
controls_out(2) <= max_Packet_nr_signal;
controls_out(3) <= numStream_signal;
end architecture;
