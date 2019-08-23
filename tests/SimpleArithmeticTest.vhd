library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;

  
  
  

entity SimpleArithmeticTest is
    port (
        clk       : in std_logic := '0';
        multiA_in : in std_logic_vector(31 downto 0) := (others => '0') ;
        multiB_in : in std_logic_vector(31 downto 0) := (others => '0');
        MultiC_out : out std_logic_vector(31 downto 0) := (others => '0'); 
        Controller : out std_logic_vector(31 downto 0) := (others => '0')
    );
end SimpleArithmeticTest;

architecture rtl of SimpleArithmeticTest is
    signal index : std_logic_vector(31 downto 0) := (others => '0') ;--"00011111111111111111111111111111";
begin
    Controller <= index;
    process(clk) is 

    begin
        if rising_edge(clk) then 
            index <= index + 1;
            MultiC_out  <= multiA_in + multiB_in;
        end if;
    end process;

end rtl;
