----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Yu-Hung Tsai
-- 
-- Create Date: 03.07.2024 11:43:34
-- Design Name: 
-- Module Name: Program_Memory
-- Project Name:
-- Description:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.ALL;

entity ProgramMemory_tb is
end ProgramMemory_tb;

architecture Behavioral of ProgramMemory_tb is
    signal clk        : BIT := '0';
    signal mem_read   : BIT := '0';
    signal addr       : BIT_VECTOR(31 downto 0) := (others => '0');
    signal read_data  : BIT_VECTOR(31 downto 0);
    type memory_type is array (0 to 255) of BIT_VECTOR(31 downto 0); -- 256 x 32-bit memory
    signal memory : memory_type := (others => (others => '0'));
    
    
    component Program_Memory
        Port (
            clk        : in  BIT;
            mem_read   : in  BIT;
            addr       : in  BIT_VECTOR(31 downto 0);
            read_data  : out BIT_VECTOR(31 downto 0)
        );
    end component;

begin
    uut: Program_Memory
        Port map (
            clk => clk,
            mem_read => mem_read,
            addr => addr,
            read_data => read_data
        );

    -- Clock generation process
    clk_process: process
    begin
        while True loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize
        wait for 20 ns;
        
        -- Write initial data to the program memory for testing (not part of typical testbench but needed for this example)
        memory(16) <= "00000000000000000000000010101010"; -- Address 0x10
        memory(32) <= "00000000000000000000000011001100"; -- Address 0x20
        
        -- Read data from address 0x10
        mem_read <= '1';
        addr <= x"00000010"; -- 0x10
        wait for 20 ns;
        
        -- Check read data
        assert read_data = "00000000000000000000000010101010" report "Test failed: Read data at 0x10 does not match expected value" severity error;
        
        -- Read data from address 0x20
        addr <= x"00000020"; -- 0x20
        wait for 20 ns;
        
        -- Check read data
        assert read_data = "00000000000000000000000011001100" report "Test failed: Read data at 0x20 does not match expected value" severity error;
        
        -- Finish simulation
        wait;
    end process;

end Behavioral;
