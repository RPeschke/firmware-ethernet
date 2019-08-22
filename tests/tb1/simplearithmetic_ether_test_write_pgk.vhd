library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
use work.utilitypkg.all;
use work.axidwordbi_p.all;
use work.type_conversions_pgk.all;
use work.simplearithmetictest_writer_pgk.all;
use work.simplearithmetictest_reader_pgk.all;
-- End Include user packages --

package simplearithmetic_ether_test_writer_pgk is
type simplearithmetic_ether_test_writer_rec is record 
  clk : std_logic;  
  rxdata : std_logic_vector ( 31 downto 0 );  
  rxdatavalid : std_logic;  
  rxdatalast : std_logic;  
  rxdataready : std_logic;  
  txdataout : std_logic_vector ( 31 downto 0 );  
  txdatavalid : std_logic;  
  txdatalast : std_logic;  
  txdataready : std_logic;  
end record;

constant simplearithmetic_ether_test_writer_rec_null : simplearithmetic_ether_test_writer_rec := ( 
  clk => '0',
  rxdata => (others => '0'),
  rxdatavalid => '0',
  rxdatalast => '0',
  rxdataready => '0',
  txdataout => (others => '0'),
  txdatavalid => '0',
  txdatalast => '0',
  txdataready => '0');

end simplearithmetic_ether_test_writer_pgk;

package body simplearithmetic_ether_test_writer_pgk is

end package body simplearithmetic_ether_test_writer_pgk;