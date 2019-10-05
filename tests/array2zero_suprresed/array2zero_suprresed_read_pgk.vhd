
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

package array2zero_suprresed_reader_pgk is
  constant colnum  : integer := 10;
  constant maxchanges  : integer := 3;
  type array2zero_suprresed_reader_rec is record
    rst : std_logic;  
    data_in : word32array ( colnum - 1 downto 0 );  
    valid : std_logic;  
    zs_data_out_s2m : axisstream_zerosupression_s2m_a ( maxchanges - 1 downto 0 );  

  end record;

  constant array2zero_suprresed_reader_rec_null : array2zero_suprresed_reader_rec := ( 
    rst => '0',
    data_in => ( others => ( others => '0' ) ),
    valid => '0',
    zs_data_out_s2m => ( others =>axisstream_zerosupression_s2m_null )
  );

end array2zero_suprresed_reader_pgk;

package body array2zero_suprresed_reader_pgk is

end package body array2zero_suprresed_reader_pgk;

    