----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.06.2024 23:20:37
-- Design Name: 
-- Module Name: inst_holder_tb - Behavioral
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

entity inst_holder_tb is
--  Port ( );
end inst_holder_tb;

architecture Behavioral of inst_holder_tb is
    component Inst_holder
    Port (enab, clk, res : in bit;
        Inst_input : in bit_vector(31 downto 0);
        Inst_output : out bit_vector(31 downto 0));
    end component;
    
    signal enab, clk, res :  bit;
    signal Inst_input :  bit_vector(31 downto 0);
    signal Inst_output :  bit_vector(31 downto 0);
begin
    UUT : Inst_holder Port Map (enab, clk, res, Inst_input, Inst_output);
    
    clk_pro : process
    begin 
        clk <= not clk;
        wait for 25ns;
    end process;
    
    stimuli : process
    begin
        wait for 50ns;
        res <= '1';
        wait for 100ns;
        res <= '0';
        wait for 50ns;
        Inst_input <= x"4589_a2bb";
        wait for 50ns;
        enab <= '1';
        wait for 50ns;
        enab <= '0';
        wait for 50ns;
        Inst_input <= x"1111_1111";
        wait for 50ns;
        enab <= '1';
        wait for 50ns;
        enab <= '0';
        wait for 50ns;
        Inst_input <= x"ffff_ffff";
        wait for 50ns;
        enab <= '1';
        wait for 50ns;
        enab <= '0';
        wait for 50ns;
        res <= '1';
        wait for 150ns;
        res <= '0';
        wait;
    end process;
end Behavioral;
