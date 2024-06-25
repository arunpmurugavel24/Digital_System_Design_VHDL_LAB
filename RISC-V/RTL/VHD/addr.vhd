----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Yu-Hung Tsai
-- 
-- Create Date: 24.05.2024 14:56:31
-- Design Name: 
-- Module Name: addr_RTL
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

entity add12 is
    Port ( c_in  : in  BIT;
           a     : in  BIT_VECTOR (11 downto 0);
           b     : in  BIT_VECTOR (11 downto 0);
           d_out : out BIT_VECTOR (11 downto 0);
           c_out : out BIT);
end add12;

architecture RTL of add12 is
begin
    process(a, b, c_in)
        variable a_and_b, a_xor_b, abc : BIT_VECTOR (11 downto 0);
        variable c : BIT_VECTOR (12 downto 0);
    begin
        c(0) := c_in;
        for i in 0 to 11 loop
            a_and_b(i) := a(i) and b(i);
            a_xor_b(i) := a(i) xor b(i);
            abc(i) := c(i) and a_xor_b(i);
            d_out(i) <= c(i) xor a_xor_b(i);
            c(i+1) := a_and_b(i) or abc(i);
        end loop;
        c_out <= c(12);
        -- negative and overflow handling can be added here
    end process;
end RTL;
