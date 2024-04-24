----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2024 12:47:34 AM
-- Design Name: 
-- Module Name: SevenSegmentDisplay - Behavioral
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

entity SevenSegmentDisplay is
    Port (
     i_clock : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
     i_Display_Number : in std_logic_vector(15 downto 0);
     i_Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
     o_SEG_out : out STD_LOGIC_VECTOR (6 downto 0)
     );-- Cathode patterns of 7-segment display
end SevenSegmentDisplay;

architecture Behavioral of SevenSegmentDisplay is

signal w_SEG_BCD : std_logic_vector(3 downto 0);
signal c_refresh_counter : std_logic_vector(19 downto 0); -- 10.5ms delay counter
signal c_seg_activating_counter : std_logic_vector(1 downto 0);
-- the other 2-bit for creating 4 LED-activating signals
-- count         0    ->  1  ->  2  ->  3
-- activates    LED1    LED2   LED3   LED4
-- and repea


begin
    -- VHDL code for BCD to 7-segment decoder
    -- Cathode patterns of the 7-segment LED display 
    --process(LED_BCD)
    process(w_SEG_BCD)
    begin
        case w_SEG_BCD is
        when "0000" => o_SEG_out <= "0000001"; -- "0"     
        when "0001" => o_SEG_out <= "1001111"; -- "1" 
        when "0010" => o_SEG_out <= "0010010"; -- "2" 
        when "0011" => o_SEG_out <= "0000110"; -- "3" 
        when "0100" => o_SEG_out <= "1001100"; -- "4" 
        when "0101" => o_SEG_out <= "0100100"; -- "5" 
        when "0110" => o_SEG_out <= "0100000"; -- "6" 
        when "0111" => o_SEG_out <= "0001111"; -- "7" 
        when "1000" => o_SEG_out <= "0000000"; -- "8"     
        when "1001" => o_SEG_out <= "0000100"; -- "9" 
        when "1010" => o_SEG_out <= "0000010"; -- a
        when "1011" => o_SEG_out <= "1100000"; -- b
        when "1100" => o_SEG_out <= "0110001"; -- C
        when "1101" => o_SEG_out <= "1000010"; -- d
        when "1110" => o_SEG_out <= "0110000"; -- E
        when "1111" => o_SEG_out <= "0111000"; -- F
        when others => o_SEG_out <= "0000000";
        end case;
    end process;

    process(i_clock)
    begin
       if(rising_edge(i_clock)) then
            c_refresh_counter <= std_logic_vector(unsigned(c_refresh_counter) + 1);
        end if;
    end process;

    c_seg_activating_counter <= c_refresh_counter(19 downto 18);

    process(c_seg_activating_counter)
    begin
        case c_seg_activating_counter is
            when "00" =>
                -- SEG1: ACTIVE 
                i_Anode_Activate <= "0111";
                w_SEG_BCD <= i_Display_Number(15 downto 12); -- First hex digit
            when "01" =>
                -- SEG2: ACTIVE
                i_Anode_Activate <= "1011";
                w_SEG_BCD <= i_Display_Number(11 downto 8); -- Second hex digit
            when "10" =>
                -- SEG3: ACTIVE
                i_Anode_Activate <= "1101";
                w_SEG_BCD <= i_Display_Number(7 downto 4); -- Third hex digit
            when "11" =>
                -- SEG4: ACTIVE
                i_Anode_Activate <= "1110";
                w_SEG_BCD <= i_Display_Number(3 downto 0); -- Fourth hex digit
            when others => i_Anode_Activate <= "1111";         
        end case;
    end process;

    -- i_Anode_Activate <= "0000";

end Behavioral;
