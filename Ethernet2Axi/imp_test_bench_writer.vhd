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

entity Imp_test_bench_writer is 
  generic ( 
    COLNum : integer := 10

  );
  port(
    Clk      : in  sl;
    -- Incoming data
    tXData      : out  slv(31 downto 0);
    txDataValid : out sl;
    txDataLast  : out  sl;
    txDataReady : in sl;
    data_in     : in Word32Array(COLNum -1 downto 0) := (others => (others => '0'));
    Valid      : in sl
  );
end entity;

architecture Behavioral of Imp_test_bench_writer is 
     signal  i_data_in     : Word32Array(COLNum -1 downto 0) := (others => (others => '0'));
     signal in_buffer_readEnablde : sl := '0';
     signal in_buffer_empty_v : slv (COLNum -1 downto 0) := (others =>  '0');
     signal in_buffer_empty : sl  := '0';
     signal  i_fifo_out_m2s :  axi_stream_32_m2s := axi_stream_32_m2s_null;
     signal  i_fifo_out_s2m :  axi_stream_32_s2m := axi_stream_32_s2m_null;
     
     function and_reduct(slv : in std_logic_vector) return std_logic is
       variable res_v : std_logic := '1';  -- Null slv vector will also return '1'
     begin
       for i in slv'range loop
         res_v := res_v and slv(i);
       end loop;
       return res_v;
     end function;
   begin
     
     tXData <= i_fifo_out_m2s.data;
     txDataValid <= i_fifo_out_m2s.valid;
     txDataLast <= i_fifo_out_m2s.last;
     i_fifo_out_s2m.ready <= txDataReady;
  
  seq_out : process (Clk) is
    variable  fifo :  FIFO_nativ_stream_reader_32_slave := FIFO_nativ_stream_reader_32_slave_null;
    variable index : integer := COLNum;
    variable  dummy_data :  slv(31 downto 0) := (others => '0');
    variable out_fifo : axi_stream_32_master_stream := axi_stream_32_master_stream_null;
    
  begin
    if rising_edge(clk) then 

    
      pull_axi_stream_32_master_stream(out_fifo , i_fifo_out_s2m);
      in_buffer_readEnablde <= '0';

        
        if ready_to_send(out_fifo)  and index <= (COLNum -1) then 
          send_data(out_fifo,i_data_in(index));
          
          if index = (COLNum -1) then  
            Send_end_Of_Stream(out_fifo);
          end if;
          index := index + 1;
        end if;
        
        if in_buffer_empty = '0' and index > (COLNum -1) then
          index :=0;
        end if ;

        if in_buffer_empty = '0' and index = COLNum-2 then
          in_buffer_readEnablde <= '1';
         
        end if ;
        
      push_axi_stream_32_master_stream(out_fifo, i_fifo_out_m2s);
    
    end if;
  end process;

  
  gen_DAC_CONTROL: for i in 0 to (COLNum -1) generate

    fifo_i : entity work.fifo_cc generic map (
      DATA_WIDTH => 32,
      DEPTH => 5 

    ) port map (
      clk   => clk,
      rst   => '0',
      din   => data_in(i),
      wen   =>  valid,
      full  => open,
      ren   => in_buffer_readEnablde,
      dout  => i_data_in(i),
      empty => in_buffer_empty_v(i)
    );

  end generate gen_DAC_CONTROL;
  
  in_buffer_empty <= and_reduct(in_buffer_empty_v);

end architecture;