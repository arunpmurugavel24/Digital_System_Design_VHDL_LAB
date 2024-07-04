----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Yu-Hung Tsai
-- 
-- Create Date: 28.06.2024 14:49:21
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

entity Program_Memory is
    Port (
        clk        : in  BIT;
        mem_read   : in  BIT;
        addr       : in  BIT_VECTOR(15 downto 0);
        read_data  : out BIT_VECTOR(31 downto 0)
    );
end Program_Memory;

architecture Behavioral of Program_Memory is
    type memory_type is array (0 to 255) of BIT_VECTOR(31 downto 0); -- 256 x 32-bit memory
    signal memory : memory_type := (others => (others => '0'));
begin

    process(clk, mem_read, addr)
    begin
        if mem_read = '1' then
            read_data <= memory(to_integer(unsigned(addr(7 downto 0))));
        else
            read_data <= (others => '0');
        end if;
    end process;
end Behavioral;
