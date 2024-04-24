----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2024 12:31:55 PM
-- Design Name: 
-- Module Name: ProgramCounter - Behavioral
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

entity ProgramCounter is
    Port ( 
            i_clock : in STD_LOGIC;
            i_reset : in STD_LOGIC;
            i_loadPC : in STD_LOGIC;
            i_incPC : in STD_LOGIC;
            i_PCLDVal : in STD_LOGIC_VECTOR (11 downto 0);
            o_ProgCtr : out STD_LOGIC_VECTOR (11 downto 0)
           );
end ProgramCounter;

architecture Behavioral of ProgramCounter is

signal w_loadPC: std_logic := '0';
signal w_incPC : std_logic := '0';
signal w_PCLdVal: std_logic_vector(11 downto 0) := x"000";
signal w_ProgCtr: std_logic_vector(11 downto 0) := x"000";

begin

    process(i_clock, i_reset)
    begin
        if i_reset = '1' then
            w_loadPC <= '0';
            w_incPC <= '0';
            w_PCLDVal <= x"000";
            w_ProgCtr <= x"000";
        elsif rising_edge(i_clock) then
            w_loadPC <= i_loadPC;
            w_incPC <= i_incPC;
            w_PCLDVal <= i_PCLDVal;
            if w_loadPC = '1' then
                w_ProgCtr <= w_PCLDVal;
            elsif w_incPC = '1' then
                w_ProgCtr <= std_logic_vector(unsigned(w_ProgCtr)+1);      
            end if;
        end if;
    end process;
    
    o_ProgCtr <= w_ProgCtr;


end Behavioral;
