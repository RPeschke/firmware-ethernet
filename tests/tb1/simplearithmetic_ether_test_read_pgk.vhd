library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.UtilityPkg.all;


-- Start Include user packages --
use work.CSV_UtilityPkg.all;
use work.axidwordbi_p.all;
use work.type_conversions_pgk.all;
use work.simplearithmetictest_writer_pgk.all;
use work.simplearithmetictest_reader_pgk.all;
-- End Include user packages --

package simplearithmetic_ether_test_reader_pgk is
type simplearithmetic_ether_test_reader_rec is record 
  clk : std_logic;  
  rxdata : std_logic_vector ( 31 downto 0 );  
  rxdatavalid : std_logic;  
  rxdatalast : std_logic;  
  txdataready : std_logic;  
end record;

constant simplearithmetic_ether_test_reader_rec_null : simplearithmetic_ether_test_reader_rec := ( 
  clk => '0',
  rxdata => (others => '0'),
  rxdatavalid => '0',
  rxdatalast => '0',
  txdataready => '0');

end simplearithmetic_ether_test_reader_pgk;

package body simplearithmetic_ether_test_reader_pgk is

end package body simplearithmetic_ether_test_reader_pgk;