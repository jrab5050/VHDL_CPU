----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2024 03:18:04 PM
-- Design Name: 
-- Module Name: cpu_001 - Behavioral
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

entity cpu_001 is
    Port ( i_switches : in STD_LOGIC_VECTOR (15 downto 0);
           i_buttons : in STD_LOGIC_VECTOR (4 downto 0);
           i_cpu_clk : in STD_LOGIC;
           o_leds : out STD_LOGIC_VECTOR (15 downto 0);
           o_anodes_activate : out STD_LOGIC_VECTOR (3 downto 0);
           o_seven_segs : out STD_LOGIC_VECTOR (6 downto 0));
end cpu_001;

architecture Behavioral of cpu_001 is


signal counter : std_logic_vector(27 downto 0) := (others => '0');
constant DIVISOR : std_logic_vector(27 downto 0) := x"2FAF080";
signal toggle_1Hz : std_logic := '0';

signal reset : std_logic := '0';

signal w_loadPC : std_logic;
signal w_incPC : std_logic;
signal w_PCLdVal : std_logic_vector(11 downto 0);
signal w_ProgCtr : std_logic_vector(11 downto 0);

-- 7 Segment Display Signals
signal w_Anode_Activate : STD_LOGIC_VECTOR (3 downto 0);
signal w_SEG_out : STD_LOGIC_VECTOR (6 downto 0);

-- ROM Signals
signal w_ROM_Instruction : std_logic_vector(15 downto 0);
signal w_ROM_EN : std_logic := '1';

-- Register File Signals
signal w_ldRegF : std_logic;
signal w_regSel : std_logic_vector(3 downto 0);
signal w_RegFData : std_logic_vector(7 downto 0);
signal w_RegFData_out : std_logic_vector(7 downto 0);

-- Opcode decoder
signal OP_LRI		: std_logic;
signal OP_IOR		: std_logic;
signal OP_IOw		: std_logic;
signal OP_ARI		: std_logic;
signal OP_BEZ		: std_logic;
signal OP_BNZ		: std_logic;
signal OP_JMP		: std_logic;

-- Peripheral Bus
signal w_peripAddr : std_logic_vector(7 downto 0);
signal w_peripDataFromCPU : std_logic_vector(7 downto 0);
signal w_peripDataToCPU : std_logic_vector(7 downto 0) := x"00";
signal w_peripWr : std_logic;
signal w_peripRd : std_logic;

-- ALU
signal ALUDataOut : std_logic_vector(7 downto 0);

-- Grey Code Counter Signals
signal w_GreyCode : std_logic_vector(1 downto 0);

begin

    progCtr : entity work.ProgramCounter
    port map(
            i_clock => toggle_1Hz,
            i_reset => reset,
            i_loadPC => w_loadPC,
            i_incPC => w_incPC,
            i_PCLDVal => w_PCLdVal,
            o_ProgCtr => w_ProgCtr
    );
    
    SevenSeg : entity work.SevenSegmentDisplay
    port map(
     i_clock => i_cpu_clk,-- 100Mhz clock on Basys 3 FPGA board
     i_Display_Number => x"0" & w_ProgCtr, -- Item to display
     i_Anode_Activate => w_Anode_Activate,-- 4 Anode signals
     o_SEG_out => w_SEG_out
    );
    
    ROM : entity work.ROM
    Port map (   
        i_clock => toggle_1Hz,
        i_en   => w_ROM_EN,
        i_addr => w_ProgCtr,
        o_data => w_ROM_Instruction
   );     
   
   regFile : entity work.RegisterFile
    port map(
        i_clock => toggle_1Hz,
        i_ldRegF => w_ldRegF,
        i_regSel => w_regSel,
        i_RegFData => w_RegFData,
        o_RegFData => w_RegFData_out
    );
    
   GreyCodeCoutner : entity work.GreyCode   
    Port map(
       -- i_clock => i_cpu_clk, 
       i_clock => toggle_1Hz, 
       i_resetN => '1',
       o_GreyCode => w_GreyCode
       );

    OneHz_counter : process(i_cpu_clk)
    begin
        if(rising_edge(i_cpu_clk)) then
            if(counter = DIVISOR) then
                counter <= x"0000000";
                toggle_1Hz <= not toggle_1Hz;             
            else
                counter <= std_logic_vector(unsigned(counter)+1);
             end if;
        end if;
    end process;
    
    Scheduling : process(w_GreyCode, toggle_1Hz)
        variable v_currentInstruction : std_logic_vector(15 downto 0);
    begin
        if rising_edge(toggle_1Hz) then
            case w_GreyCode is
                when "00" =>
                    -- Fetch
                    w_ROM_EN <= '1';
                    v_currentInstruction := w_ROM_Instruction;
--                    w_ROM_EN <= '0';
                    w_incPC <= '1';
        
                when "01" =>
                    -- Decode

                    case v_currentInstruction(15 downto 12) is
                        when "0010" =>
                            OP_LRI <= '1';                     
                            OP_IOR <= '0';                     
                            OP_IOW <= '0';                     
                            OP_ARI <= '0';                     
                            OP_BEZ <= '0';                     
                            OP_BNZ <= '0';                     
                            OP_JMP <= '0'; 
                        when "0110" =>
                            OP_LRI <= '0';                     
                            OP_IOR <= '1';                     
                            OP_IOW <= '0';                     
                            OP_ARI <= '0';                     
                            OP_BEZ <= '0';                     
                            OP_BNZ <= '0';                     
                            OP_JMP <= '0';
                        when "0111" =>
                            OP_LRI <= '0';                     
                            OP_IOR <= '0';                     
                            OP_IOW <= '1';                     
                            OP_ARI <= '0';                     
                            OP_BEZ <= '0';                     
                            OP_BNZ <= '0';                     
                            OP_JMP <= '0';                          
                        when "1000" =>
                            OP_LRI <= '0';                     
                            OP_IOR <= '0';                     
                            OP_IOW <= '0';                     
                            OP_ARI <= '1';                     
                            OP_BEZ <= '0';                     
                            OP_BNZ <= '0';                     
                            OP_JMP <= '0';
                        when "1100" =>
                            OP_LRI <= '0';                     
                            OP_IOR <= '0';                     
                            OP_IOW <= '0';                     
                            OP_ARI <= '0';                     
                            OP_BEZ <= '1';                     
                            OP_BNZ <= '0';                     
                            OP_JMP <= '0';
                        when "1101" =>
                            OP_LRI <= '0';                     
                            OP_IOR <= '0';                     
                            OP_IOW <= '0';                     
                            OP_ARI <= '0';                     
                            OP_BEZ <= '0';                     
                            OP_BNZ <= '1';                     
                            OP_JMP <= '0';
                        when "1110" =>
                            OP_LRI <= '0';                     
                            OP_IOR <= '0';                     
                            OP_IOW <= '0';                     
                            OP_ARI <= '0';                     
                            OP_BEZ <= '0';                     
                            OP_BNZ <= '0';                     
                            OP_JMP <= '1';
                        when others =>
                            OP_LRI <= '0';                     
                            OP_IOR <= '0';                     
                            OP_IOW <= '0';                     
                            OP_ARI <= '0';                     
                            OP_BEZ <= '0';                     
                            OP_BNZ <= '0';                     
                            OP_JMP <= '0';                     
                    end case;
                    when "11" =>
                    -- Set control flags
                        if OP_IOR = '1' then
                            w_peripRd <= '1';
                            w_RegSel <= v_currentInstruction(15 downto 12);
                            w_ldRegF <= '1';
                            w_RegFData <= w_peripDataToCPU;
                        else 
                            w_peripRd <= '0';
                            w_ldRegF <= '0';
                            w_RegFData <= x"00";
                        end if;
                        
                        if OP_IOW = '1' then
                            w_peripWr <= '1';
                            w_RegSel <= v_currentInstruction(15 downto 12);
                            w_peripDataFromCPU <= w_RegFData_out;
                        else
                            w_peripWr <= '0';
                            w_peripDataFromCPU <= x"00";                     
                        end if;
                        
                        if OP_LRI = '1' then
                            w_LdRegF <= '1';
                            w_RegSel <= v_currentInstruction(15 downto 12);
                            w_RegFData <= v_currentInstruction(7 downto 0);
                        else
                            w_LdRegF <= '0';
                            w_RegFData <= x"00";                     
                        end if;
                        
                        if OP_ARI = '1' then
                            w_LdRegF <= '1';
                            w_RegSel <= v_currentInstruction(15 downto 12);
                            w_RegFData <= w_RegFData_out and v_currentInstruction(7 downto 0);
                        else
                            w_LdRegF <= '0';
                            w_RegFdata <= x"00";                      
                        end if;
                        
                        if OP_JMP = '1' then
                            w_loadPC <= '1';
                            w_PCLdVal <= v_currentInstruction(11 downto 0);
                        else
                            w_loadPC <= '0';
                            w_PCLdVal <= x"000";                     
                        end if;
                    when others =>
                            w_LdRegF <= '0';
                            w_RegFData <= x"00";
                            w_peripRd <= '0';
                            w_peripWr <= '0';
                            w_peripDataFromCPU <= x"00";                                         
                            OP_LRI <= '0';                     
                            OP_IOR <= '0';                     
                            OP_IOW <= '0';                     
                            OP_ARI <= '0';                     
                            OP_BEZ <= '0';                     
                            OP_BNZ <= '0';                     
                            OP_JMP <= '0';
                            w_ROM_EN <= '0';
                            w_incPC <= '0';

            end case;                 
        end if;     
    end process;

    
    o_seven_segs <= w_SEG_out;
    o_anodes_activate <= w_Anode_Activate;
--    o_leds <= w_ROM_Instruction when toggle_1Hz = '1' else x"5555";
    o_leds(15 downto 8) <= w_RegFData_out;
    o_leds(7 downto 0) <= w_ROM_EN & OP_LRI & OP_IOR & OP_IOW & OP_ARI & OP_BEZ & OP_BNZ & OP_JMP;
    

end Behavioral;
