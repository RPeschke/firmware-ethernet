
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
  Clk      : in  sl;
  -- Incoming data
  rxData      : in  slv(31 downto 0);
  rxDataValid : in  sl;
  rxDataLast  : in  sl;
  rxDataReady : out sl;
  data_out    : out Word32Array(COLNum - 1 downto 0) := (others => (others => '0'));
  controls_out    : out Word32Array(3 downto 0) := (others => (others => '0'));
  valid : out sl
  );
end entity;


architecture rtl of Imp_test_bench_reader is
  

  
  
 
  

  signal axi_in_m2s : axi_stream_32_m2s := axi_stream_32_m2s_null;
  signal axi_in_s2m : axi_stream_32_s2m := axi_stream_32_s2m_null;

  
  signal fifo_w_s2m : FIFO_nativ_write_32_s2m := FIFO_nativ_write_32_s2m_null;

  signal fifo_w_m2s : FIFO_nativ_write_32_m2s := FIFO_nativ_write_32_m2s_null;
  signal fifo_r_m2s : FIFO_nativ_reader_32_m2s := FIFO_nativ_reader_32_m2s_null;
  signal fifo_r_s2m : FIFO_nativ_reader_32_s2m := FIFO_nativ_reader_32_s2m_null;
  signal i_data_out    :  Word32Array((COLNum -1) downto 0) := (others => (others => '0'));
  signal we          : sl := '0';
  signal Max_word : integer := 10;
  signal reset : sl := '0';

  signal  index_signal      : slv(31 downto 0) := (others => '0');
  signal  timestamp_signal      : slv(31 downto 0) := (others => '0');
  signal  packetCounter_signal      : slv(31 downto 0) := (others => '0');
begin
  axi_in_m2s.data <= rxData;
  axi_in_m2s.last <=rxDataLast;
  axi_in_m2s.valid <= rxDataValid;
  rxDataReady <= axi_in_s2m.ready;

  
  seq : process (Clk) is
    variable axi_in : axi_stream_32_slave_stream := axi_stream_32_slave_stream_null;

    variable Index : integer :=0;
    variable packetCounter : integer :=0;
    variable rxbuffer      : slv(31 downto 0) := (others => '0');
    variable timeStamp      : slv(31 downto 0) := (others => '0');
  begin
    if (rising_edge(Clk)) then

      pull_axi_stream_32_slave_stream(axi_in, axi_in_m2s);
      we <= '0';
      reset <= '0';

      fifo_r_s2m.read_enable <='0';
      if Index = 0 then 
        i_data_out  <= (others => (others => '0'));
      end if;

      
      if isReceivingData(axi_in) and packetCounter <= Max_word then 
        --b1  :=b1+ rxGetData(RXTX);
        read_data(axi_in,rxbuffer);
        i_data_out(Index) <=  rxbuffer;
        Index := Index + 1;
        if IsEndOfStream(axi_in) then 
          Index := 0;  
          if (packetCounter > 0) then
            we <=  '1';
          else 
            -- slv_to_integer(i_data_out(0) ,Max_word );
            Index := Index + 1;
            timeStamp := (others => '0');
          end if;
          
          packetCounter := packetCounter +1;
        end if;
      end if;
      
  




      
      
      if packetCounter > Max_word then 

        fifo_r_s2m.read_enable <='1';
      
        packetCounter := packetCounter +1;
      end if; 
     
      if packetCounter > 2* Max_word then 
        packetCounter := 0;
        reset <='1';
        packetCounter_signal <= packetCounter_signal +1;
      end if;
      
      
     push_axi_stream_32_slave_stream(axi_in,axi_in_s2m);
     valid <= fifo_r_s2m.read_enable;

     -- time Stamping
   
     timestamp_signal <= timeStamp;
     timeStamp := timeStamp + 1;
     if timeStamp > 1000000 then 
      timeStamp := (others => '0');
      reset <='1';
     end if;
     index_signal <= std_logic_vector(to_signed(Index, index_signal'length));
     -- // time Stamping
      --txData <=   b1;
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
  


  index_fifo_i : entity work.fifo_cc generic map (
    DATA_WIDTH => 32,
    DEPTH => 5 

  ) port map (
    clk   => clk,
    rst   => reset,
    din   => index_signal,
    wen   =>  we,
    full  => open,
    ren   => fifo_r_s2m.read_enable,
    dout  => controls_out(1),
    empty => open
  );


    timeStamp_fifo_i : entity work.fifo_cc generic map (
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

    packet_fifo_i : entity work.fifo_cc generic map (
      DATA_WIDTH => 32,
      DEPTH => 5 
  
    ) port map (
      clk   => clk,
      rst   => reset,
      din   => packetCounter_signal,
      wen   =>  we,
      full  => open,
      ren   => fifo_r_s2m.read_enable,
      dout  => controls_out(2),
      empty => open
    );
  
end architecture;
