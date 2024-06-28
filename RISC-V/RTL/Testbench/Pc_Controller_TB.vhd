----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.06.2024 13:39:53
-- Design Name: 
-- Module Name: Pc_Controller_TB - Behavioral
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
use IEEE.NUMERIC_bit.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Pc_Controller_TB is
--  Port ( );
end Pc_Controller_TB;

architecture Behavioral of Pc_Controller_TB is
    Component Pc_Ctrl 
        Port(enab_w, clk, res : in bit; --enables
            imm : in bit_vector(15 downto 0); --Address for a jump Instruction
            PC : out bit_vector(15 downto 0);    --Needs to be looked at if Adress room is big enough
            Alu_condition : in bit;              --Chosses if Pc is incremented by 1 or imm
            jmp_condition : in bit;               --If Jump Instructions is used, we need to use the Alu address
            Alu_adress : in bit_vector(31 downto 0) 
            );
    end component;
 
    signal clk, enabl_w, res, Alu_condition, jmp_condition : bit := '0';
    signal imm, PC : bit_vector(15 downto 0);
    signal Alu_Adress : bit_vector(31 downto 0);
begin
     
    UUT : Pc_ctrl Port Map (enabl_w, clk, res, imm, PC, Alu_condition, jmp_condition, Alu_Adress);
    
    clk_pro : process 
    begin
        clk <= not clk;
        wait for 25ns;
    end Process;
    
    test: process
    begin
        wait for 150ns;
        res <= '1';
        wait for 100ns;
        res <= '0';
        wait for 150ns; --should count up to 3
        imm <= bit_vector(TO_SIGNED(30, 16));
        Alu_condition <= '1';
        wait for 50ns;
        Alu_condition <= '0';
        wait for 100ns;
        Alu_adress <= b"0000_0000_0000_0000_0000_0001_0101_1100";
        jmp_condition <= '1';
        wait for 50 ns;
        jmp_condition <= '0';
        wait for 500ns;
        wait;
        
    end Process;
end Behavioral;
