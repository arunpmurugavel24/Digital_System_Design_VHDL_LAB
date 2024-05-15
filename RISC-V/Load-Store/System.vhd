----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/15/2024 04:24:26 PM
-- Design Name: 
-- Module Name: System - Behavioral
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
use work.cpu_defs_pack.all;

entity System is
--  empty for the moment
end System;

architecture Behavioral of System is
BEGIN
    PROCESS
        --Variable declaration
        --Register inside CPU
        variable Reg : reg_type;
        --Memory outside CPU
        variable Mem : mem_type;
        --Programm Counter Addresses are in integer format
        variable PC : Integer :=0;
        --Instruction is a 32Bit_vector, But we work it as Integer
        variable Inst : Integer RANGE 2**32-1 downto 0;
        --Decoded Instruction Parameter
        variable op : Integer RANGE 124 downto 3; --Biggest Nr. without bbb=111 is 11 110 11=124, smallest Nr is 00 000 11
        --For I-Type instruction
        variable imm : integer RANGE 4095 downto 0;
        variable rs : integer RANGE 31 downto 0;
        variable func3: integer RANGE 7 downto 0;
        variable rd : Integer Range 31 downto 0;
        variable load_addr : integer RANGE 2**15-1 downto 0;
        variable Data1 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data2 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data3 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data4 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data32Bit : Bit_vector(31 downto 0); --the final frankenstein Bitvector
        --For S-type instruction
        
        --For R-Type Instruction
        BEGIN
        --get Instruction
        Inst := Mem(PC);
        --PC count up
        PC := PC + 1;
        
        --decode Inst: get OP-CODE
        OP := Inst mod 128; --gets the last 7Bit as integer
        
        case OP is 
            --basic OP
            when code_nop => null; --no operation
            when code_stop => wait; --stop programm
            
            --Load OP
            when code_load =>
                --now func3 needs to be looked at, right shift 7+5=12 Bits and extract 3 Bits
                func3 := (Inst/2**12) mod 2**3;
                --now start load command depending on func3
                case func3 is 
                    when 0 =>
                        --Load byte
                        --get Parameters
                        imm := (Inst/2**20) mod 2**12; -- we want the 12 leftmost Bit from 32 Bit integer
                        rs := (Inst/2**15) mod 2**5;
                        rd := (Inst/2**7) mod 2**5;
                        --calculate source address
                        load_addr := TO_INTEGER(unsigned(Reg(rs))) + imm; --depending on data_type of Reg, it needs change
                        --Load Data from source address
                        Data1 := Mem(load_addr); --Depending on size of on address (8Bit, 16Bit, 32Bit) needs some change
                        --fill up to 32Bit with MSB of Data1
                        for i in 31 downto 8 LOOP
                            Data32Bit(i) := Data1(7);
                        end LOOP;
                        --fill in last 7 Bit
                        for i in 7 downto 0 LOOP
                            Data32Bit(i) := Data1(i);
                        end LOOP;
                        --save Data to rd
                        Reg(rd) := Data32Bit;
                        --end
                    when 1 =>
                        --Load Halfword
                        
                    when 2 =>
                        --Load Word
                        
                    when 3 => 
                        --Load byte unsigned
                        
                    when 4 =>
                        --Load Word unsigned
                        
                    when others =>
                        --error
                end case;
            when code_store=>
                --store decoding
            
            when others =>
                --Error
        end case;        
        
 
        END process;
end Behavioral;
