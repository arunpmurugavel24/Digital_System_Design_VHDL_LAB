----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.07.2024 10:52:56
-- Design Name: 
-- Module Name: 3to1Mux - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Mux3to1 is
    Port (In0, In1, In2 : in bit_vector(31 downto 0);
          output : out bit_vector(31 downto 0);
          sel : in bit_vector(1 downto 0));
end Mux3to1;

architecture Behavioral of Mux3to1 is

begin
    process(in0, in1, in2, sel)
    begin
        case sel is
            when "00" =>
                output <= in0;
            when "01" =>
                output <= in1;
            when "10" =>
                output <= in2;
            when "11" =>
                output <= x"00_00_00_00";
        end case;
    end process;
end Behavioral;
