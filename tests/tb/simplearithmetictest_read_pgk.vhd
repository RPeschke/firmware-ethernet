library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
-- End Include user packages --

package simplearithmetictest_reader_pgk is
type simplearithmetictest_reader_rec is record 
  clk : std_logic;  
  multia_in : integer;  
  multib_in : integer;  
end record;

constant simplearithmetictest_reader_rec_null : simplearithmetictest_reader_rec := ( 
  clk => '0',
  multia_in => integer_null,
  multib_in => integer_null);

end simplearithmetictest_reader_pgk;

package body simplearithmetictest_reader_pgk is

end package body simplearithmetictest_reader_pgk;