----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Yu-Hung Tsai
-- 
-- Create Date: 28.06.2024 14:32:34
-- Design Name: 
-- Module Name: Data_Memory
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

entity Data_Memory is
    Port (
        clk        : in  BIT;
        mem_read   : in  BIT;
        mem_write  : in  BIT;
        funct3     : in  BIT_VECTOR(2 downto 0);
        address    : in  BIT_VECTOR(7 downto 0);
        write_data : in  BIT_VECTOR(7 downto 0);
        read_data  : out BIT_VECTOR(7 downto 0)
    );
end Data_Memory;


architecture Behavioral of Data_Memory is
    type memory_type is array (0 to 255) of BIT_VECTOR(7 downto 0); -- 256 x 8-bit memory
    signal memory : memory_type := (others => (others => '0'));
begin
    process(clk, mem_write, funct3, address, write_data)
    begin
        if clk = '1' and mem_write = '1' then
            case funct3 is
                when "000" => -- SB (Store Byte)
                    memory(to_integer(unsigned(address))) <= write_data;
                when others => null;
            end case;
        end if;
    end process;

    process(clk, mem_read, funct3, address)
    begin
        if mem_read = '1' then
            case funct3 is
                when "000" => -- LB (Load Byte)
                    read_data <= memory(to_integer(unsigned(address)));
                when others => read_data <= (others => '0');
            end case;
        else
            read_data <= (others => '0');
        end if;
    end process;

end Behavioral;
