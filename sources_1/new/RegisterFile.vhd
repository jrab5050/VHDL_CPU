----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2024 01:32:05 PM
-- Design Name: 
-- Module Name: RegisterFile - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterFile is
    Port ( i_clock : in STD_LOGIC;
           i_ldRegF : in STD_LOGIC;
           i_regSel : in STD_LOGIC_VECTOR (3 downto 0);
           i_regFData : in STD_LOGIC_VECTOR (7 downto 0);
           o_regFData : out STD_LOGIC_VECTOR (7 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is

    type t_regFile is array (0 to 15) of std_logic_vector(7 downto 0); 

    signal w_regFile : t_regFile := (others => (others => '0'));
    
    signal w_RegFData_in : std_logic_vector(7 downto 0) := x"00";
    signal w_RegFData_out : std_logic_vector(7 downto 0) := x"00";
    signal w_regSel : std_logic_vector(3 downto 0) := x"0";
    signal w_ldRegF : std_logic := '0';


begin

    process(i_clock)
    begin
        if i_clock'event and i_clock='1' then
            w_RegFData_in <= i_RegFdata;
            w_regSel <= i_regSel;
            w_ldRegF <= i_ldRegF;
            
            if w_ldRegF = '1' then
                if unsigned(w_regSel) < x"D" then -- Write to register 0-C
                    w_regFile(to_integer(Unsigned(w_regSel))) <= w_RegFData_in(7 downto 0);
                elsif w_regSel = x"D" then -- read back 0
                    w_RegFData_out <= x"00";
                elsif w_regSel = x"E" then -- read back 1
                    w_RegFData_out <= x"01";
                elsif w_regSel = x"F" then -- read back FF
                    w_RegFData_out <= x"FF"; 
                end if;             
            else
                if unsigned(w_regSel) < x"D" then
                    w_RegFData_out <= w_regFile(to_integer(unsigned(w_regSel)));
                elsif w_regSel = x"D" then -- read back 0
                    w_RegFData_out <= x"00";
                elsif w_regSel = x"E" then -- read back 1
                    w_RegFData_out <= x"01";
                elsif w_regSel = x"F" then -- read back FF
                    w_RegFData_out <= x"FF"; 
                end if;             
            end if;
        end if;
    end process;
    
    o_RegFData <= w_RegFData_out;



end Behavioral;
