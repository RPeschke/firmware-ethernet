library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.CSV_UtilityPkg.all;


-- Start Include user packages --
-- End Include user packages --

package simplearithmetictest_writer_pgk is
type simplearithmetictest_writer_rec is record 
  clk : std_logic;  
  multia_in : integer;  
  multib_in : integer;  
  multic_out : integer;  
end record;

constant simplearithmetictest_writer_rec_null : simplearithmetictest_writer_rec := ( 
  clk => '0',
  multia_in => integer_null,
  multib_in => integer_null,
  multic_out => integer_null);

end simplearithmetictest_writer_pgk;

package body simplearithmetictest_writer_pgk is

end package body simplearithmetictest_writer_pgk;