----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2024 18:48:29
-- Design Name: 
-- Module Name: Inst_holder - Behavioral
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


entity Inst_holder is
    Port (enab, clk : in bit;
        Inst_input : in bit_vector(31 downto 0);
        Inst_output : out bit_vector(31 downto 0));
end Inst_holder;

architecture Behavioral of Inst_holder is
begin
    process(clk)
    begin
        if clk = '1' AND clk'event AND enab = '1' then
            --Put Input to Output
            inst_output <= inst_input;
        end if;
    end process;
end Behavioral;
