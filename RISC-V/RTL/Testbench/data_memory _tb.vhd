----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Yu-Hung Tsai
-- 
-- Create Date: 03.07.2024 12:34:51
-- Design Name: 
-- Module Name: Data_Memory Testbench
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DataMemory_tb is
end DataMemory_tb;

architecture Behavioral of DataMemory_tb is
    signal clk        : BIT := '0';
    signal mem_read   : BIT := '0';
    signal mem_write  : BIT := '0';
    signal funct3     : BIT_VECTOR(2 downto 0) := (others => '0');
    signal address    : BIT_VECTOR(7 downto 0) := (others => '0');
    signal write_data : BIT_VECTOR(7 downto 0) := (others => '0');
    signal read_data  : BIT_VECTOR(7 downto 0);

    component DataMemory
        Port (
            clk        : in  BIT;
            mem_read   : in  BIT;
            mem_write  : in  BIT;
            funct3     : in  BIT_VECTOR(2 downto 0);
            address    : in  BIT_VECTOR(7 downto 0);
            write_data : in  BIT_VECTOR(7 downto 0);
            read_data  : out BIT_VECTOR(7 downto 0)
        );
    end component;

begin
    uut: DataMemory
        Port map (
            clk => clk,
            mem_read => mem_read,
            mem_write => mem_write,
            funct3 => funct3,
            address => address,
            write_data => write_data,
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
        
        -- Write data to address 0x10
        mem_write <= '1';
        mem_read <= '0';
        funct3 <= "000"; -- SB (Store Byte)
        address <= "00010000"; -- 0x10
        write_data <= "10101010"; -- 0xAA
        wait for 20 ns;
        
        -- Disable write
        mem_write <= '0';
        wait for 20 ns;
        
        -- Read data from address 0x10
        mem_read <= '1';
        mem_write <= '0';
        funct3 <= "000"; -- LB (Load Byte)
        address <= "00010000"; -- 0x10
        wait for 20 ns;
        
        -- Check read data
        assert read_data = "10101010" report "Test failed: Read data does not match written data" severity error;
        
        -- Finish simulation
        wait;
    end process;

end Behavioral;
