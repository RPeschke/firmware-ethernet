
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
use work.utilitypkg.all;
use work.axidwordbi_p.all;
use work.type_conversions_pgk.all;
use work.imp_test_bench_pgk.all;
use work.xgen_axistream_zerosupression.all;
use work.xgen_rollingcounter.all;
use work.zerosupression_p.all;

-- End Include user packages --

package zero_supression_test_connection_writer_pgk is
  constant colnum :integer := 10;
  type zero_supression_test_connection_writer_rec is record
    rst : std_logic;  
    data_in : word32array ( colnum - 1 downto 0 );  
    valid_in : std_logic;  
    tomanychangeserror_a2z : std_logic;  
    data_out : word32array ( colnum - 1 downto 0 );  
    valid_out : std_logic;  
    ready_out : std_logic;  
    tomanychangeserror_z2a : std_logic;  

  end record;

  constant zero_supression_test_connection_writer_rec_null : zero_supression_test_connection_writer_rec := ( 
    rst => '0',
    data_in => ( others => ( others => '0' ) ),
    valid_in => '0',
    tomanychangeserror_a2z => '0',
    data_out => ( others => ( others => '0' ) ),
    valid_out => '0',
    ready_out => '1',
    tomanychangeserror_z2a => '0'
  );

end zero_supression_test_connection_writer_pgk;

package body zero_supression_test_connection_writer_pgk is

end package body zero_supression_test_connection_writer_pgk;

    