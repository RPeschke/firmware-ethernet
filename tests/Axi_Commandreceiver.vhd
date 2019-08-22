---------------------------------------------------------------------------------
-- Title         : Command Interpreter
-- Project       : General Purpose Core
---------------------------------------------------------------------------------
-- File          : CommandInterpreter.vhd
-- Author        : Kurtis Nishimura
---------------------------------------------------------------------------------
-- Description:
-- Packet parser for old Belle II format.
-- See: http://www.phys.hawaii.edu/~kurtisn/doku.php?id=itop:documentation:data_format
---------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use work.UtilityPkg.all;
  use work.axiDWORDbi_p.all;
  use work.type_conversions_pgk.all;


entity Axi_CommandInterpreter is 
  port ( 
    -- User clock and reset
    usrClk      : in  sl;
    -- Incoming data
    rxData      : in  DWORD;
    rxDataValid : in  sl;
    rxDataLast  : in  sl;
    rxDataReady : out sl;
    -- Outgoing response
    txData      : out DWORD;
    txDataValid : out sl;
    txDataLast  : out sl;
    txDataReady : in  sl
  ); 
end Axi_CommandInterpreter;

-- Define architecture
architecture rtl of Axi_CommandInterpreter is
  type StateType     is (IDLE_S,RECEIVING,CALCULATE0,CALCULATE1 ,SENDING);

  signal state : StateType := IDLE_S;
  signal multiA_in : integer  := 0;
  signal multiB_in : integer  := 0;
  signal MultiC_out : integer  := 0;

  signal  slv_multiA_in : DWORD;
  signal  slv_multiB_in : DWORD;
  signal  slv_MultiC_out : DWORD;
begin

  dut : entity work.SimpleArithmeticTest port map(

    clk      => usrClk,
    multiA_in => multiA_in,
    multiB_in => multiB_in,
    MultiC_out => MultiC_out
  );

  seq : process (usrClk) is
    variable RXTX : AxiRXTXMaster_axiDWordBi := AxiRXTXMaster_axiDWordBi_null;
	 variable Bufer1 : Word32Array(10 downto 0);  
    variable Index : integer :=0;
	 variable Max_Index : integer :=0;
	 variable b1 : DWORD := (others => '0');
  begin
    if (rising_edge(usrClk)) then
     
		AxiPullData(RXTX, txDataReady , rxData ,rxDataValid ,rxDataLast);
      
      if IsValid(RXTX.rx) and  (state = IDLE_S or state = RECEIVING) then 
		  --b1  :=b1+ rxGetData(RXTX);
		  Bufer1(Index) := rxGetData(RXTX);
        Index := Index + 1;
        state <= RECEIVING;
        if rxIsLast(RXTX) then 
          state <= CALCULATE0;
			 Max_Index := index;
          Index := 0;
        end if;
      end if;
      slv_multiA_in <= Bufer1(1);
      slv_multiB_in <= Bufer1(2);
      Bufer1(3)     := slv_MultiC_out;

      if (state = CALCULATE0) then 
        slv_to_integer(slv_multiA_in, multiA_in);
        slv_to_integer(slv_multiB_in, multiB_in);
        state <= CALCULATE1;
      end if;
      if (state = CALCULATE1) then 
        integer_to_slv(MultiC_out, slv_MultiC_out );
        state <= SENDING;
      end if;
      
      if state = SENDING and txIsReady(RXTX) then 
			
        
		 -- txSetData(RXTX,b1);
		 b1:= Bufer1(Index);
		   txSetData(RXTX, b1);
        Index := Index + 1;
        if Index  = Max_Index then 
		    txSetLast(RXTX);

          state <= IDLE_S;
			 
			 Index := 0;
        end if;
        
      end if;
      
      
      
      if state/= SENDING then 
			rxSetReady(RXTX);        
      end if;
      
 
		AxiPushData(RXTX , rxDataReady, txData , txDataValid,txDataLast);
		
		--txData <=   b1;
    end if;
  end process seq;

end rtl;
