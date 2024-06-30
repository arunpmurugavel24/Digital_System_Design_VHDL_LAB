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
    Port (enab, clk, res : in bit;
        Inst_input : in bit_vector(31 downto 0);
        Inst_output : out bit_vector(31 downto 0));
end Inst_holder;

architecture Behavioral of Inst_holder is
    signal Inst_Reg : bit_vector(31 downto 0);
begin
    --inst_output should always be the saved Data in Inst_Reg 
    inst_output <= Inst_Reg;
    --Process for updating Reg
    process(clk, res)
    begin
        --asynchron reset
        if res = '1' then
            Inst_Reg <= x"0000_0000";
        else
            if clk = '1' AND clk'event AND enab = '1' then
                --Put Input into Reg
                inst_Reg <= inst_input;
            end if;
        end if;
    end process;
end Behavioral;
