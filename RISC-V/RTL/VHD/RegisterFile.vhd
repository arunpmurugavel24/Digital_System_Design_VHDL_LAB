----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.06.2024 12:55:36
-- Design Name: 
-- Module Name: Register - Behavioral
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
use IEEE.numeric_bit.all;
use work.cpu_defs_pack.all;



entity RegisterFile is
    Port (rd1_addr : in bit_vector(4 downto 0);
          rd2_addr : in bit_vector(4 downto 0);
          wr_addr : in bit_vector(4 downto 0);
          rd1_data : out bit_vector(31 downto 0);
          rd2_data : out bit_vector(31 downto 0);
          wr_data : in bit_vector(31 downto 0);
          wr_enab : in bit);
          --clk and res?
end RegisterFile;

architecture Behavioral of RegisterFile is
    signal reg : Reg_Type;
begin
    process
    begin
        --!!!!!!
        --wait on; --clock???; if not, then sensitivity list for all inputs
        --!!!!!!
        rd1_data <= reg(TO_INTEGER(unsigned(rd1_addr)));
        rd2_data <= reg(TO_INTEGER(unsigned(rd2_addr)));
        
        if wr_enab = '1' then
            Reg(TO_INTEGER(unsigned(wr_addr))) <= wr_data; 
        end if; 
    
    end process;
end Behavioral;
