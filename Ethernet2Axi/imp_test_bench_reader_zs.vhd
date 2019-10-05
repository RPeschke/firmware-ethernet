
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;

  use work.UtilityPkg.all;
  use work.axiDWORDbi_p.all;

  use work.type_conversions_pgk.all;

  use work.Imp_test_bench_pgk.all;

  use work.xgen_axiStream_64.all;
  use work.type_conversions_pgk.all;
  use work.xgen_rollingCounter.all;

entity imp_test_bench_reader_zs is
  generic ( 
    COLNum : integer := 10;
    FIFO_DEPTH : integer := 10;
    MaxChanges  : integer := 10
  );
  port(
    Clk      : in  sl := '0';
    -- Incoming data
    rxData          : in  slv(31 downto 0) := (others => '0');
    rxDataValid     : in  sl := '0';
    rxDataLast      : in  sl := '0';
    rxDataReady     : out sl := '0';
    data_out        : out Word32Array(COLNum - 1 downto 0) := (others => (others => '0'));
    controls_out    : out Imp_test_bench_reader_Control_t  := Imp_test_bench_reader_Control_t_null;
    valid : out sl := '0'
  );
end entity;

architecture rtl of imp_test_bench_reader_zs is
  type state_t is (
    fillFifo,
    send,
    wait_for_idle,
    FIFO_FULL
  );
  signal s_reader_state : state_t := fillFifo;
  signal  rst : sl := '0';
  signal i_data_out       :  Word32Array((COLNum -1)+2 downto 0) := (others => (others => '0'));
  signal i_data_out_old       :  Word32Array((COLNum -1)+2 downto 0) := (others => (others => '0'));
  signal i_data_out_valid : sl := '0';

  signal zs_data_in_m2s : axisStream_64_m2s_a(MaxChanges - 1 downto 0) := (others =>axisStream_64_m2s_null);
  signal zs_data_in_s2m : axisStream_64_s2m_a(MaxChanges - 1 downto 0) := (others =>axisStream_64_s2m_null);

  signal zs_data_out_m2s : axisStream_64_m2s_a(MaxChanges - 1 downto 0) := (others =>axisStream_64_m2s_null);
  signal zs_data_out_s2m : axisStream_64_s2m_a(MaxChanges - 1 downto 0) := (others =>axisStream_64_s2m_null);

  type axisStream_64_m2s is record 
    array_index : STD_LOGIC_VECTOR(15 downto 0); 
    time_index  : STD_LOGIC_VECTOR(15 downto 0); 
    data        : std_logic_vector(31 downto 0); 
  end record;

begin

  des : entity work.StreamDeserializer generic map (
    COLNum => COLNum + 2
  ) port map ( 
    Clk    => Clk,
    -- Incoming data
    rxData      => rxData,
    rxDataValid => rxDataValid,
    rxDataLast  => rxDataLast,
    rxDataReady => rxDataReady,
    data_out    => i_data_out,
    valid       => i_data_out_valid
  );


  send_data_from_fifo: process(clk) is
    variable packet_nr : slv(15 downto 0) := (others => '0');
    variable  v_fifo_counter : rollingCounter := rollingCounter_null;
    variable RX: axisStream_64_slave_a(MaxChanges - 1 downto 0):= (others => axisStream_64_slave_null);
    variable array_index : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');  
    variable time_index  : STD_LOGIC_VECTOR(15 downto 0):= (others => '0');  
    variable data        : std_logic_vector(31 downto 0):= (others => '0');  
    variable buff        : std_logic_vector(63 downto 0):= (others => '0');  

  begin 
    if (rising_edge(Clk)) then
      for i in 0 to MaxChanges - 1 loop 
        pull(RX(i) , zs_data_out_m2s(i));
      end loop;


      if s_reader_state = send then
        if isReceivingData(RX(v_fifo_counter.Counter)) then 
          read_data(RX(v_fifo_counter.Counter), buff);
          array_index:= buff(63 downto 48);
          time_index :=  buff(47 downto 32);
          data :=  buff(31 downto 0);
          if time_index = packet_nr then
            
          end if;
        end if;
      end if;


      for i in 0 to MaxChanges - 1 loop 
        push(RX(i) , zs_data_out_s2m(i));
      end loop;

    end if;
  end process;

  genFifo : for i in 0 to MaxChanges -1 generate
    dataFifo : entity work.fifo_cc_axi generic map(
      DATA_WIDTH => 64,
      DEPTH => FIFO_DEPTH
    ) port map (
      clk       => clk,
      rst       => rst, 
      RX_Data   => zs_data_in_m2s(i).data,
      RX_Valid  => zs_data_in_m2s(i).valid,
      RX_Last   => zs_data_in_m2s(i).valid,
      RX_Ready  => zs_data_in_s2m(i).ready,

      TX_Data   => zs_data_out_m2s(i).data,
      TX_Valid  => zs_data_out_m2s(i).valid,
      TX_Last   => zs_data_out_m2s(i).last,
      TX_Ready  => zs_data_out_s2m(i).ready
    );


  end generate genFifo;
end architecture;