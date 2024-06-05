----------------------------------------------------------------------------------
-- University: Technical University of Munich
-- Student: Hian Zing Voon
-- 
-- Create Date: 31.05.2024 08:58:52
-- Design Name: mnemonics_package
-- Module Name: mnemonics_package - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Converts mnemonics like "ADD" or "XOR" to opcodes like "0110011" and output it in 'string'. It will
--              then be further converted from 'string' to 'bit_vector' using function 'stringToBitVector' from 'auxiliary_package.vhd'.
--              Categorised with guidelines from the RISCV pdf obtained from the class.
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

package mnemonics_pack is  -- Declaration of procedure
procedure mnemonics_opcode (
    variable mnemonics : in string(5 downto 1);
    variable opcode : out string(7 downto 1)
    );
end mnemonics_pack;

package body mnemonics_pack is  -- Content of procedure
-- Definition of opcode -- 
-- Source: RISCV-Spec pg. 130 --
procedure mnemonics_opcode (
    variable mnemonics : in string(5 downto 1);
    variable opcode : out string(7 downto 1)
    ) is
    begin
        -- switch case only uses integers; so have to resort to if-else case --
        
--        report("mnemonics: " & mnemonics);  -- debugging
        -- R-Type --
        if mnemonics = "SLL  " or mnemonics = "XOR  " or mnemonics = "SRL  " or mnemonics = "SRA  " or mnemonics = "OR   " or mnemonics = "AND  " or mnemonics = "ADD  " or mnemonics = "SUB  " or mnemonics = "SLT  " or mnemonics = "SLTU " then
            opcode := "0110011";
        
        -- I-Type --
        elsif mnemonics = "LB   " or mnemonics = "LH   " or mnemonics = "LW   " or mnemonics = "LBU  " or mnemonics = "LHU  " or mnemonics = "XORI " or mnemonics = "ORI  " or mnemonics = "ANDI " or mnemonics = "JALR " or mnemonics = "ADDI " or mnemonics = "SLTI " or mnemonics = "SLTIU" then
            if mnemonics = "LB   " or mnemonics = "LH   " or mnemonics = "LW   " or mnemonics = "LBU  " or mnemonics = "LHU  " then
                opcode := "0000011";
            elsif mnemonics = "JALR " then
                opcode := "1100111";
            else
                opcode := "0010011";
            end if;
        
        -- I-Type modified --
        elsif mnemonics = "SLLI " or mnemonics = "SRLI " or mnemonics = "SRAI " then
           opcode := "0010011";
        
        -- S-Type --
        elsif mnemonics = "SB   " or mnemonics = "SH   " or mnemonics = "SW   " then 
            opcode := "0100011";
        
        -- B-Type --
        elsif mnemonics = "BEQ " or mnemonics = "BNE  " or mnemonics = "BLT  " or mnemonics = "BGE  " or mnemonics = "BLTU " or mnemonics = "BGEU " then
            opcode := "1100011";
        
        -- U-Type --
        elsif mnemonics = "LUI  " or mnemonics = "AUIPC" then
            if mnemonics = "LUI  " then
                opcode := "0110111";
            else 
                opcode := "0010111";
            end if;
        
        -- J-type modified --
        elsif mnemonics = "JAL  " then
            opcode := "1101111";
        
        -- Stop code -- 
        elsif mnemonics = "stop " or mnemonics = "STOP " or mnemonics = "stop" or mnemonics = "STOP" then
            opcode := "1111111";
        
        -- else --
        else 
            opcode := "Error  ";
        end if;

end mnemonics_opcode;
end mnemonics_pack;