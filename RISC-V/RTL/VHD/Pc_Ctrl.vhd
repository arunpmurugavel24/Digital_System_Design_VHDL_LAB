----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2024 19:41:54
-- Design Name: 
-- Module Name: Pc_Ctrl - Behavioral
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
use IEEE.NUMERIC_bit.ALL;


entity Pc_Ctrl is
    Port (enab_w, clk, res, incre : in bit; --enables
            new_address : in bit_vector(15 downto 0); --Address for a jump Instruction
            PC : out bit_vector(15 downto 0)    --Needs to be looked at if Adress room is big enough
            );
end Pc_Ctrl;

architecture Behavioral of Pc_Ctrl is
    signal count : unsigned(15 downto 0);   --the Intern PC
begin
    process(clk, res)
    begin
        if res = '1' then
            --Res counter
            count <= x"0";
        elsif clk = '1' AND clk'event AND incre = '1' then
            --Increment count by 4 8Bit-Addresses
            count <= count + 4;  
        elsif clk = '1' AND clk'event AND enab_w = '1' then
            --set count to new Address
            count <= unsigned(new_address);
        end if;
    end process;
end Behavioral;
