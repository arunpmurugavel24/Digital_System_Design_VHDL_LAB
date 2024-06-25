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
    Port (clk : in bit;
          res : in bit;
          rd1_addr : in bit_vector(4 downto 0);
          rd2_addr : in bit_vector(4 downto 0);
          wr_addr : in bit_vector(4 downto 0);
          rd1_data : out bit_vector(31 downto 0);
          rd2_data : out bit_vector(31 downto 0);
          wr_data : in bit_vector(31 downto 0);
          wr_enab : in bit);
          --clk and res?
end RegisterFile;

architecture Behavioral of RegisterFile is
    type Reg_Type is array 
    	(integer range 31 downto 1) of RegDataType; --donwto 1 because 0 is always 0
begin
    process(clk, res)
        --Register as Variable, Because Reg as Signal is time consuming for Synthesis
        variable reg : Reg_type;
        constant reg0 : bit_vector(31 downto 0) := b"0000_0000_0000_0000_0000_0000_0000_0000";  --always 0 and cant be changed
    begin
        if res = '1' then
        --Set every Register to 0
        reg := (others => b"0000_0000_0000_0000_0000_0000_0000_0000");
        else
            if rising_edge(clk) then
                --Output Part. Need to check if Reg0 is wanted
                if rd1_addr = b"0_0000" then
                    --Register 0
                    rd1_data <= reg0;
                else
                    --not reg0
                rd1_data <= reg(TO_INTEGER(unsigned(rd1_addr)));    --Output rs1
                end if;
                if rd2_addr = b"0_0000" then
                    --Register 0
                    rd2_data <= reg0;
                else
                    --not reg0
                rd2_data <= reg(TO_INTEGER(unsigned(rd2_addr)));    --Output rs2
                end if;
                
                --Write Part
                if wr_enab = '1' then   --Write to reg if wr_enab is true
                    Reg(TO_INTEGER(unsigned(wr_addr))) := wr_data; 
                end if; 
            end if;
        end if;
    end process;
end Behavioral;
