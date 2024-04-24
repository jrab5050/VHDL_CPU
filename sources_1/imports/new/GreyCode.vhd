----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2024 12:01:04 PM
-- Design Name: 
-- Module Name: GreyCode - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GreyCode is
    Port ( i_clock : in STD_LOGIC;
           i_resetN : in STD_LOGIC := '1';
           o_GreyCode : inout STD_LOGIC_VECTOR (1 downto 0));
end GreyCode;

architecture Behavioral of GreyCode is

signal w_greyCode : std_logic_vector(1 downto 0);

begin

    w_greyCode <=   "00" when (i_resetN = '0') else
                    "01" when (o_greyCode = "00") else
                    "11" when (o_greyCode = "01") else
                    "10" when (o_greyCode = "11") else
                    "00";
                    
                
    process(i_clock)
    begin
        if rising_edge(i_clock) then
            o_greyCode <= w_greyCode;
        end if;
    end process;

end Behavioral;
