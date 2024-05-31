----------------------------------------------------------------------------------
-- Company: Tiemo Schmidt, Hian Zing Voon, Yu-Hung Tsai
-- Engineer: 
-- 
-- Create Date: 05/15/2024 04:24:26 PM
-- Design Name:  
-- Module Name: System - Behavioral
-- Project Name: Risc V functional CPU 
-- Description: The TLE of a RISC V CPU. It contains the code to load the Instructions from
--              the Memory, decoding them and then perform them.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.all;       --for to_integer
use work.cpu_defs_pack.all;
use work.output_functions_pack.all;
use std.textio.all;
use work.mem_defs_pack.all;


entity System is
--  empty for the moment
end System;

architecture Behavioral of System is
BEGIN
    PROCESS
---------------------            
--MADE BY TIEMO SCHMITD            
---------------------  
    --Declarations
        --Output declarations
        file inputFile : text open read_mode is "C:\Users\hianz\Documents\git\Digital_System_Design_VHDL_LAB\RISC-V\Load-Store\InputFile.txt";
        file Outputfile : Text open write_mode is "C:\Users\hianz\Documents\git\Digital_System_Design_VHDL_LAB\RISC-V\Load-Store\trace.txt";
        variable l : line;
        
        
        --Variable declaration
        --Register inside CPU
        variable Reg : Reg_Type;
        --Memory outside CPU
        variable Mem : Mem_Type := (--0 => "00000000000000000000000000000000",
                                    0 => "01000000000000000000000111110111",
                                    1 => "00000000000000000000000001111111",    --!!!!TEST VALUES NEED TO BE DELETED
                                    64635 downto 64535 => "00010000000000100000000010000000",
                                    64735 downto 64636 => "10010000000000100000000010000000",
                                    others => "00000000000000000000000000000000");
   --!!!!!The Memory initialitation here (the function name)
        
        --Programm Counter Addresses are in integer format
        variable PC : Integer :=0;
        --Instruction is a 32Bit_vector, But we work it as Integer
        variable Inst : bit_vector(31 downto 0);             --working with int is too complicatet if you need to shift right a negativ nr 
        --Decoded Instruction Parameter
        variable OP : opcode_type;--Maybe integer or Opcode. Skript says Instruction is integer --Biggest Nr. without bbb=111 is 11 110 11=124, smallest Nr is 00 000 11
        variable ErrorOP : String(8 downto 1);
        --For I-Type instruction
        variable imm : integer RANGE 4095 downto 0;
        variable rs : integer RANGE 31 downto 0;
        variable func3: integer RANGE 7 downto 0;
        variable rd : Integer Range 31 downto 0;
        variable addr: integer Range 2**16-1 downto 0; --the adress given in the Instruction (8Bit-Steps)
        variable load_addr : integer RANGE 2**16-1 downto 0; --the calculated adress for the 32Bit Memory cell 
        variable Data : bit_vector(31 downto 0); --the whole bit_vector from Memory
        variable Data1 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data2 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data3 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data4 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data32Bit : Bit_vector(31 downto 0); --the final frankenstein Bitvector
        
        --For S-type instruction
        variable rs1 : integer RANGE 2**5-1 downto 0;
        variable rs2 : integer RANGE 2**5-1 downto 0;
        variable Immp1 : bit_vector(6 downto 0);        --first 7 Bit of Imm
        variable Immp2 : bit_vector(4 downto 0);        --senond(lower) part of Imm
        
        --For J-Type instruction Jump
        --rd is already defined
        variable InstBit : bit_vector (31 downto 0);    --Instruction as Bit, for easier disassamble     
        variable imm32Bit : bit_vector(31 downto 0) := "00000000000000000000000000000000";    --Immidiet need to be reorganized, easyer done as bit_vector
        variable immInteger : integer RANGE 2**20-1 downto 0;
        
        --For U-Type Instruction
        variable imm_lui: bit_vector(31 downto 0);
        
        --For R-Type Instruction
        -- For AUIPC Instruction 
        variable pc_offset: bit_vector(31 downto 0);
        variable new_pc   : bit_vector(31 downto 0);
        
        --Begin running the Programm  
        BEGIN
---------------------            
--MADE BY TIEMO SCHMITD            
---------------------
        --Inputfile to memory
        filetomemory(Inputfile, mem);
        --Create Output Header
        trace_Header(l, Outputfile);
        --get Instruction
        Inst := Mem(PC);  --The memory is defined as bit_vector, but the skript says that we work the instructions as integer
        --PC count up
        PC := PC + 1;
        
        --decode Inst: get OP-CODE
        OP := Inst(6 downto 0); --gets the last 7Bit as integer

        case OP is
         
            when code_stop => 
                --we implemented it as a way to stop the simulation and start the Mem_dump
                --opcode is the only illegal Opcode "111 1111"
                trace(l, Outputfile, PC, "stop", 0, 0, 0, 0);
                mem_dump(l, Outputfile, mem);
                wait; 
---------------------            
--MADE BY TIEMO SCHMITD            
---------------------       
            when code_load =>
                --we have Instruction Typ-L
                --get Parameters
                imm := TO_INTEGER(unsigned(Inst(31 downto 20))); -- we want the 12 leftmost Bit from 32 Bit integer (31 to 20)
                rs := TO_INTEGER(unsigned(Inst(19 downto 15)));
                rd := TO_INTEGER(unsigned(Inst(11 downto 7)));
                
                --calculate source address
                addr := TO_INTEGER(unsigned(Reg(rs))) + imm; --depending on data_type of Reg, it needs change
                load_addr := addr/4;         --calculates adress of the 32Bit-adress. decimal point will be cut off(round down) 
                --Load Data from source address
                Data := Mem(load_addr);    --Loads whole 32Bit Mem_cell
                
                --now func3 needs to be looked at, func starts at bit 12, so we need to shift 11 times right
                func3 := TO_INTEGER(unsigned(Inst(14 downto 12)));
                --now start load command depending on func3
                case func3 is 
                    when 0 =>
                    --Load byte
                        --   (line, File,       PC, OP-Code,       imm, rs1,rs2,rd) 
                        trace(l,    Outputfile, PC, string'("LB"), imm, rs, 0,  rd);
                        --Needs to get the correct part of the 32Bit Mem_cell (Differenz=0: load first 8 LSB; =1 next 8Bit; ...)
                        case (addr-(load_addr*4)) is
                            when 0 =>
                                --get Bit 0 to 7
                                for i in 7 downto 0 LOOP
                                    Data1(i) := Data(i);
                                end LOOP;
                                
                            when 1 =>
                                --get Bit 8 to 15
                                for i in 15 downto 8 LOOP
                                    Data1(-8+i) := Data(i);     -- (-8+i) is used to still get 7 downto 0;
                                end LOOP;
                                
                            when 2 =>
                                --get Bit 16 to 23
                                for i in 23 downto 16 LOOP
                                    Data1(-16+i) := Data(i);    -- (-16+i) is used to still get 7 downto 0;
                                end LOOP;
                                
                            when 3 =>
                                --get Bit 24 to 31
                                for i in 31 downto 24 LOOP
                                    Data1(-24+i) := Data(i);    -- (-24+i) is used to still get 7 downto 0;
                                end LOOP;
                                
                            when others =>
                                --something went wrong
                                report "something is wrong with the adress calculation. addr: " & integer'image(addr) & "  load_addr: " & integer'image(load_addr) & "  difference: " & integer'image(addr-load_addr) severity error;
                        end case;
                        --got the correct 8 Bit
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
                    --   (line, File,       PC, OP-Code,       imm, rs1,rs2,rd) 
                        trace(l,    Outputfile, PC, string'("LH"), imm, rs, 0,  rd);
                        --Needs to get the correct part of the 32Bit Mem_cell (Differenz=0: load 0 to 15 LSB; =1 load 8 to 23Bit; ...)
                        case (addr-(load_addr*4)) is
                            when 0 =>
                                --get Bit 7 to 0
                                for i in 7 downto 0 LOOP
                                    Data1(i) := Data(i);
                                end LOOP;
                                --get 15 to 8
                                for i in 15 downto 8 LOOP
                                    Data2(-8+i) := Data(i);
                                end LOOP;
                                
                            when 1 =>
                                --get Bit 15 to 8
                                for i in 15 downto 8 LOOP
                                    Data1(i) := Data(i);
                                end LOOP;
                                --get Bit 23 to 16
                                for i in 23 downto 16 LOOP
                                    Data2(i) := Data(i);
                                end LOOP;
                            when 2 =>
                                --get Bit 23 to 16
                                for i in 23 downto 16 LOOP
                                    Data1(-16+i) := Data(i);
                                end LOOP;
                                --get 31 to 24
                                for i in 31 downto 24 LOOP
                                    Data2(-24+i) := Data(i);
                                end LOOP;
                            when 3 =>
                                --get Bit 31 to 24
                                for i in 31 downto 24 LOOP
                                    Data1(-24+i) := Data(i);
                                end LOOP;
                                --need to load next 32 Bit cell and get first 8 Bit
                                Data := Mem(load_addr + 1);
                                for i in 7 downto 0 LOOP
                                    Data2(i) := Data(i);
                                end LOOP;
                            when others =>
                                --something went wrong
                                report "something is wrong with the adress calculation. addr: " & integer'image(addr) & "  load_addr: " & integer'image(load_addr) & "  difference: " & integer'image(addr-load_addr) severity error;
                        end case;
                        --got the correct 16 Bit
                        --fill up to 32Bit with MSB of Data1
                        for i in 31 downto 16 LOOP
                            Data32Bit(i) := Data2(7);
                        end LOOP;
                        --fill in last 7 Bit
                        for i in 7 downto 0 LOOP
                            Data32Bit(i) := Data1(i);
                        end LOOP;
                        --save Data to rd
                        Reg(rd) := Data32Bit;
                    when 2 =>
                    --Load Word
                    --   (line, File,       PC, OP-Code,       imm, rs1,rs2,rd) 
                        trace(l,    Outputfile, PC, string'("LW"), imm, rs, 0,  rd);
                        --can just load the 32Bit cell. what if start adress is 103. then we need to load 103, 104, 105 and 106 (8Bit size)
                        --3 cases with each 4 loops
                        case (addr-(load_addr*4)) is
                        when 0 =>
                            --Just load Word
                            Data32Bit := Mem(load_addr);
                        
                        when 1 =>
                            --Load upper 24Bit from load_addr and lower 8Bit from load_addr+1
                            for i in 31 downto 8 LOOP
                                Data32Bit(i) := Data(i);
                            end LOOP;
                            Data := Mem(load_addr + 1);
                            for i in 7 downto 0 LOOP
                                Data32Bit(i) := Data(i);
                            end LOOP;
                        
                        when 2 =>
                            --Load upper 16Bit from load_addr and lower 16Bit from load_addr+1
                            for i in 31 downto 16 LOOP
                                Data32Bit(i) := Data(i);
                            end LOOP;
                            Data := Mem(load_addr + 1);
                            for i in 15 downto 0 LOOP
                                Data32Bit(i) := Data(i);
                            end LOOP;
                            
                        when 3 =>
                            --Load upper 8Bit from load_addr and lower 24Bit from load_addr+1
                            for i in 31 downto 24 LOOP
                                Data32Bit(i) := Data(i);
                            end LOOP;
                            Data := Mem(load_addr + 1);
                            for i in 23 downto 0 LOOP
                                Data32Bit(i) := Data(i);
                            end LOOP;
                            
                        when others =>
                            --something went wrong
                                report "something is wrong with the adress calculation. addr: " & integer'image(addr) & "  load_addr: " & integer'image(load_addr) & "  difference: " & integer'image(addr-load_addr) severity error;
                        end case;
                        
                        Reg(rd) := Data32Bit;
                        
                    when 3 => 
                    --Load byte unsigned
                        --   (line, File,       PC, OP-Code,       imm, rs1,rs2,rd) 
                        trace(l,    Outputfile, PC, string'("LBU"), imm, rs, 0,  rd);
                        --Copy upstairs, exchange fille up Data1(7) with '0'
                        --Needs to get the correct part of the 32Bit Mem_cell (Differenz=0: load first 8 LSB; =1 next 8Bit; ...)
                        case (addr-(load_addr*4)) is
                            when 0 =>
                                --get Bit 0 to 7
                                for i in 7 downto 0 LOOP
                                    Data1(i) := Data(i);
                                end LOOP;
                                
                            when 1 =>
                                --get Bit 8 to 15
                                for i in 15 downto 8 LOOP
                                    Data1(-8+i) := Data(i);     -- (-8+i) is used to still get 7 downto 0;
                                end LOOP;
                                
                            when 2 =>
                                --get Bit 16 to 23
                                for i in 23 downto 16 LOOP
                                    Data1(-16+i) := Data(i);    -- (-16+i) is used to still get 7 downto 0;
                                end LOOP;
                                
                            when 3 =>
                                --get Bit 24 to 31
                                for i in 31 downto 24 LOOP
                                    Data1(-24+i) := Data(i);    -- (-24+i) is used to still get 7 downto 0;
                                end LOOP;
                                
                            when others =>
                                --something went wrong
                                report "something is wrong with the adress calculation. addr: " & integer'image(addr) & "  load_addr: " & integer'image(load_addr) & "  difference: " & integer'image(addr-load_addr) severity error;
                        end case;
                        --got the correct 8 Bit
                        --fill up to 32Bit with '0'
                        for i in 31 downto 8 LOOP
                            Data32Bit(i) := '0';
                        end LOOP;
                        --fill in last 7 Bit
                        for i in 7 downto 0 LOOP
                            Data32Bit(i) := Data1(i);
                        end LOOP;
                        --save Data to rd
                        Reg(rd) := Data32Bit;
                        --end
                        
                    when 4 =>
                    --Load Word unsigned
                    --   (line, File,       PC, OP-Code,       imm, rs1,rs2,rd) 
                        trace(l,    Outputfile, PC, string'("LHU"), imm, rs, 0,  rd);
                        --Copy upstairs, exchange fille up Data1(7) with '0'
                         --Needs to get the correct part of the 32Bit Mem_cell (Differenz=0: load 0 to 15 LSB; =1 load 8 to 23Bit; ...)
                        case (addr-(load_addr*4)) is
                            when 0 =>
                                --get Bit 7 to 0
                                for i in 7 downto 0 LOOP
                                    Data1(i) := Data(i);
                                end LOOP;
                                --get 15 to 8
                                for i in 15 downto 8 LOOP
                                    Data2(-8+i) := Data(i);
                                end LOOP;
                                
                            when 1 =>
                                --get Bit 15 to 8
                                for i in 15 downto 8 LOOP
                                    Data1(i) := Data(i);
                                end LOOP;
                                --get Bit 23 to 16
                                for i in 23 downto 16 LOOP
                                    Data2(i) := Data(i);
                                end LOOP;
                            when 2 =>
                                --get Bit 23 to 16
                                for i in 23 downto 16 LOOP
                                    Data1(-16+i) := Data(i);
                                end LOOP;
                                --get 31 to 24
                                for i in 31 downto 24 LOOP
                                    Data2(-24+i) := Data(i);
                                end LOOP;
                            when 3 =>
                                --get Bit 31 to 24
                                for i in 31 downto 24 LOOP
                                    Data1(-24+i) := Data(i);
                                end LOOP;
                                --need to load next 32 Bit cell and get first 8 Bit
                                Data := Mem(load_addr + 1);
                                for i in 7 downto 0 LOOP
                                    Data2(i) := Data(i);
                                end LOOP;
                            when others =>
                                --something went wrong
                                report "something is wrong with the adress calculation. addr: " & integer'image(addr) & "  load_addr: " & integer'image(load_addr) & "  difference: " & integer'image(addr-load_addr) severity error;
                        end case;
                        --got the correct 16 Bit
                        --fill up to 32Bit with MSB of Data1
                        for i in 31 downto 16 LOOP
                            Data32Bit(i) := '0';
                        end LOOP;
                        --fill in last 7 Bit
                        for i in 7 downto 0 LOOP
                            Data32Bit(i) := Data1(i);
                        end LOOP;
                        --save Data to rd
                        Reg(rd) := Data32Bit;
                        
                        
                        
                    when others =>
                    --error in LOAD
                        report "something is wrong with the Load func3 case. func3: " & integer'image(func3);

                end case;
                
---------------------            
--MADE BY TIEMO SCHMITD            
---------------------
            when code_store=>
                --store decoding
                --get func3 from instr. for S-Type func3 is bit 14 to 12
                func3 := TO_INTEGER(unsigned(Inst(14 downto 12)));                --get other Parameters
                rs1 := TO_INTEGER(unsigned(Inst(19 downto 15)));    --Register for Memory Adress
                rs2 := TO_INTEGER(unsigned(Inst(24 downto 20)));    --Register for Data to store
                
                --Risc v Specification says Imm ist 12Bit in size. but it is split in one 7Bit and one 5Bit Part.
                Immp1 := Inst(31 downto 25);
                Immp2 := Inst(11 downto 7);
                -- now put them together and make it to a signed 32Bit vector and back to integer. Because we transform it into an integer we dont need sign extend
                Imm := to_integer(signed(bit_vector'(Immp1 & Immp2)));  --need to tell vivado that it should use the bitvector version of '&' 
                
                --now the different func3 options
                case func3 is 
                    when 0 =>
                        --store Byte 
                        --takes lowest 8 Bit of Rs2 and stores it at rs1+imm
                        Data32Bit := Reg(rs2);
                        --Spec pdf doesnt say anything about sign_extend or unsign_extend. But we want to save the Data so sign_extend
                        for i in 31 downto 8 LOOP
                            Data32Bit(i) := Data32Bit(7);
                        end LOOP;
                        Mem(rs1+Imm) := Data32Bit;
                        
                    when 1 =>
                        --store Halfword
                        --takes lowest 16 Bit of Rs2 and stores it at rs1+imm
                        Data32Bit := Reg(rs2);
                        --Spec pdf doesnt say anything about sign_extend or unsign_extend. But we want to save the Data so sign_extend
                        for i in 31 downto 16 LOOP
                            Data32Bit(i) := Data32Bit(15);
                        end LOOP;
                        Mem(rs1+Imm) := Data32Bit;
                      
                    when 2 =>
                        --store word
                        --takes lowest 8 Bit of Rs2 and stores it at rs1+imm
                        Data32Bit := Reg(rs2);
                        --Spec pdf doesnt say anything about sign_extend or unsign_extend. But we want to save the Data so sign_extend
                        for i in 31 downto 24 LOOP
                            Data32Bit(i) := Data32Bit(23);
                        end LOOP;
                        Mem(rs1+Imm) := Data32Bit;
                            
                    when others =>
                        --error in Store
                        report "something is wrong with the Store func3 case. func3: " & integer'image(func3);
                end case;
                
---------------------            
--MADE BY             
---------------------                                                    
            when code_arithmetic =>
                --Arithmetic OP (add, sub, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
                
---------------------
--MADE BY
---------------------                                
            when code_arithmeticImm_nop =>
                --Arithmetic OP (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI) and NOP (ADDI with x0 x0 0)

---------------------            
--MADE BY TIEMO SCHMITD            
---------------------             
            when code_jal =>
                --Jump Instruction with no condition
                --get rd
                rd := TO_INTEGER(unsigned(Inst(11 downto 7)));
                 
                --get imm by reorganzing Instr
                --Because Signextended Imm 31 downto 20 is MSB of Inst
                for i in 31 downto 20 LOOP
                imm32bit(i) := Inst(31);
                end LOOP;
                
                --immBit 19 downto 12 are at Inst 19 downto 12
                for i in 19 downto 12 LOOP
                    imm32bit(i) := Inst(i);
                end LOOP;
                
                --immBit 11 is at Inst 20
                imm32Bit(11) := Inst(20);
                
                --immBit 10 downto 1 are in Inst 30 downto 21
                for i in 30 downto 21 LOOP
                    imm32bit(-20 + i) := Inst(i);
                end LOOP;
                
                --LSB is 0
                imm32bit(0) := '0';
                immInteger := TO_INTEGER(signed(imm32bit));
                
                --Trace
                trace(l,    Outputfile, PC, string'("JAL"), immInteger, 0, 0,  rd);
                --now calculate the given adress to the 32Bit format we are using
                immInteger := immInteger/4;
                --the Specification PDF says it jumps in 2Byte Steps, but because we dont have shortInstruction we can jump in 4Byte(word) steps
                PC := (PC-1) + immInteger; --PC - 1, because after Loading Inst we directly increment it, which would be wrong adress by 1 here

---------------------            
--MADE BY TIEMO SCHMIDT            
---------------------              
            when code_jalr =>
                --Jump with return adress
                --get Parameters
                rd := TO_INTEGER(unsigned(Inst(11 downto 7)));
                --func3 can be ignored as there are no other instruction with same OP-Code
                rs1 := TO_INTEGER(unsigned(Inst(19 downto 15))); 
                imm := TO_INTEGER(signed(Inst(31 downto 20))); 
                
                --Trace
                trace(l,    Outputfile, PC, string'("JALR"), imm, rs1, 0,  rd);
                
                --Instruction after Jump Inst save to rd
                Reg(rd) := bit_vector(TO_UNSIGNED(PC, 32)); -- only Pc because it was incremented already
                --set PC to Target address
                PC := (rs1+Imm) / 4; --divided by 4, because Pc is addressing words and not halfword. Because we are not using ShortInstructions
            
---------------------            
--MADE BY Tiemo SCHMIDT            
---------------------  
            when code_Branch => 
                --compares the two registers and then adds imm ontop of current pc
                func3 := TO_INTEGER(unsigned(Inst(14 downto 12)));                  --get func3
                rs1 := TO_INTEGER(unsigned(Inst(19 downto 15)));                    --Register1
                rs2 := TO_INTEGER(unsigned(Inst(24 downto 20)));                    --Register2
                --Construct Imm
                for i in 31 downto 12 LOOP
                    imm32Bit(i) := Inst(31);
                end LOOP;
                imm32Bit(11) := Inst(7);
                imm32Bit(10 downto 5) := Inst(30 downto 25);
                imm32Bit(4 downto 2) := inst(11 downto 9);  --the way our Mem_access works we wont need the last 2 LSB from imm (1 and 0), so only 11 downto 9 and not 11 downto 8  
                imm32Bit(1 downto 0) := "00";               --Set last two to 0, because we are working only with 32Bit inst and not short inst
                imm := to_integer(signed(imm32Bit));
                
                case func3 is 
                    when 0 =>
                        --BEQ
                        trace(l,    Outputfile, PC, string'("BEQ"), imm, rs1, rs2,  0);
                        if Reg(rs1) = Reg(rs2) then
                            --Jump
                            PC := PC-1 + (imm/4); --PC-1 because we are inkrementing it at the beginning
                        else
                            --dont do a jump
                            --nothing
                        end if;
                    when 1 =>
                        --BNE
                        trace(l,    Outputfile, PC, string'("BNE"), imm, rs1, rs2,  0);
                        if Reg(rs1) /= Reg(rs2) then
                            --Jump
                            PC := PC-1 + (imm/4); --PC-1 because we are inkrementing it at the beginning
                        else
                            --dont do a jump
                            --nothing
                        end if;
                    when 4 =>
                        --BLT
                        trace(l,    Outputfile, PC, string'("BLT"), imm, rs1, rs2,  0);
                        if signed(Reg(rs1)) < signed(Reg(rs2)) then
                            --Jump
                            PC := PC-1 + (imm/4); --PC-1 because we are inkrementing it at the beginning
                        else
                            --dont do a jump
                            --nothing
                        end if;
                    when 5 =>
                        --BGE
                        trace(l,    Outputfile, PC, string'("BGE"), imm, rs1, rs2,  0);
                        if signed(Reg(rs1)) >= signed(Reg(rs2)) then
                            --Jump
                            PC := PC-1 + (imm/4); --PC-1 because we are inkrementing it at the beginning
                        else
                            --dont do a jump
                            --nothing
                        end if;
                    when 6 =>
                        --BLTU
                        trace(l,    Outputfile, PC, string'("BLTU"), imm, rs1, rs2,  0);
                        if unsigned(Reg(rs1)) < unsigned(Reg(rs2)) then
                            --Jump
                            PC := PC-1 + (imm/4); --PC-1 because we are inkrementing it at the beginning
                        else
                            --dont do a jump
                            --nothing
                        end if;
                    when 7 =>
                        --BGEU
                        trace(l,    Outputfile, PC, string'("BLT"), imm, rs1, rs2,  0);
                        if unsigned(Reg(rs1)) <= unsigned(Reg(rs2)) then
                            --Jump
                            PC := PC-1 + (imm/4); --PC-1 because we are inkrementing it at the beginning
                        else
                            --dont do a jump
                            --nothing
                        end if;
                    when others =>
                        --Error
                        report "something is wrong with the func3 Branch case. func3(as integr): " & integer'image(func3); --cant report Bit_vector transformed to integer
                    
                    end case;
                
---------------------            
--MADE BY HIAN ZING VOON        
---------------------  
            when code_lui =>  -- LUI is used with ADDI to load a 32-bit constant (RISCV pdf pg. 8)
                --LUI := Load upper immediate. It places imm in the top 20 bits, then fills lower 12 bits with 0
				imm32Bit (31 downto 12) := Inst(31 downto 12);				
				rd := TO_INTEGER(unsigned(Inst(11 downto 7)));
				
				-- Trace/Output
				trace(l, Outputfile, PC, string'("LUI"), to_Integer(signed(imm32Bit)), 0, 0,  rd);
	               
				-- Save to register
				Reg(rd) := imm32Bit;  --By default it's 32 zeros, so it is already 
				
---------------------            
--MADE BY Yu-Hung TSAI            
                        
--            when code_AUIPC =>
--            -- Build 32Bit address. For more context look at RiscV_spec.pdf P.19
--                imm := TO_INTEGER(unsigned(Inst(31 downto 12)));
--                rd  := TO_INTEGER(unsigned(Inst(11 downto 7)));
--                op  := TO_INTEGER(unsigned(Inst(6 downto 0)));

--                -- Form the 32-bit offset from the 20-bit immediate and fill the lowest 12 bits with zeros
--                pc_offset <= imm & "000000000000";
                
--                -- Calculate the new PC value by adding the offset to the current PC
--                new_pc <= bit_vector(unsigned(PC) + unsigned(pc_offset));
                
--                -- Store the result in the destination register
--                Reg(TO_INTEGER(unsigned(rd))) <= new_pc;

--            when others =>

--                -- Error in AUIPC
--                report "something is wrong with the AUIPC";
                

---------------------            
--MADE BY Tiemo SCHMIDT            
---------------------                                            
            when others =>
                --Error in OPCODE / or not implemented op-code
                report "something is wrong with the OP-Code case. Op-Code(as integr): " & integer'image(to_integer(unsigned(OP))); --cant report Bit_vector transformed to integer
        end case;        
        END process;
end Behavioral;
