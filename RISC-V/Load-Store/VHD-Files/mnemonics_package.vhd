----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.05.2024 08:58:52
-- Design Name: Hian Zing Voon
-- Module Name: mnemonics_package - Behavioral
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
use STD.TEXTIO.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package mnemonics_pack is  -- Declaration of procedure
procedure mnemonics_opcode (
    variable opcode : out string(7 downto 1);
    variable mnemonics : inout string(5 downto 1));
end mnemonics_pack;

package body mnemonics_pack is  -- Content of procedure
-- Definition of opcode -- 
-- Source: RISCV-Spec pg. 130 --
procedure mnemonics_opcode (
    variable opcode : out string(7 downto 1);
    variable mnemonics : inout string(5 downto 1)) is
    begin
        -- switch case only uses integers; so have to resort to if-else case --
        if mnemonics = "LUI" then
            opcode := "0110111";
        elsif mnemonics = "AUIPC" then
            opcode := "0010111";
        elsif mnemonics = "JAL" then
            opcode := "1101111";
        elsif mnemonics = "JALR" then
            opcode := "1100111";
        elsif mnemonics = "BEQ" then
            opcode := "1100011";
        elsif mnemonics = "BNE" then
            opcode := "1100011";
        elsif mnemonics = "BLT" then
            opcode := "1100011";
        elsif mnemonics = "BGE" then
            opcode := "1100011";
        elsif mnemonics = "BLTU" then
            opcode := "1100011";
        elsif mnemonics = "BGEU" then
            opcode := "1100011";
        elsif mnemonics = "LB" then
            opcode := "0000011";
        elsif mnemonics = "LH" then
            opcode := "0000011";
        elsif mnemonics = "LW" then
            opcode := "0000011";
        elsif mnemonics = "LBU" then
            opcode := "0000011";
        elsif mnemonics = "LHU" then
            opcode := "0000011";
        elsif mnemonics = "SB" then
            opcode := "0100011";
        elsif mnemonics = "SH" then
            opcode := "0100011";
        elsif mnemonics = "SW" then
            opcode := "0100011";
        elsif mnemonics = "ADDI" then
            opcode := "0010011";
        elsif mnemonics = "SLTI" then
            opcode := "0010011";
        elsif mnemonics = "SLTIU" then
            opcode := "0010011";
        elsif mnemonics = "XORI" then
            opcode := "0010011";
        elsif mnemonics = "ORI" then
            opcode := "0010011";
        elsif mnemonics = "ANDI" then
            opcode := "0010011";
        elsif mnemonics = "SLLI" then
            opcode := "0010011";
        elsif mnemonics = "SRLI" then
            opcode := "0010011";
        elsif mnemonics = "SRAI" then
            opcode := "0010011";
        elsif mnemonics = "ADD" then
            opcode := "0110011";
        elsif mnemonics = "SUB" then
            opcode := "0110011";
        elsif mnemonics = "SLL" then
            opcode := "0110011";
        elsif mnemonics = "SLT" then
            opcode := "0110011";
        elsif mnemonics = "SLTU" then
            opcode := "0110011";
        elsif mnemonics = "XOR" then
            opcode := "0110011";
        elsif mnemonics = "SRL" then
            opcode := "0110011";
        elsif mnemonics = "SRA" then
            opcode := "0110011";
        elsif mnemonics = "OR" then
            opcode := "0110011";
        elsif mnemonics = "AND" then
            opcode := "0110011";
		else
		    opcode := "error";
    end if;

end mnemonics_opcode;
end mnemonics_pack;
        
        
        
--         if mnemonics = "LUI" then
--            opcode <= "0110111"
--        elsif mnemonics = "AUIPC" then
--            opcode <= "0010111"