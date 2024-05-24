----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/15/2024 04:24:26 PM
-- Design Name: Tiemo Schmidt, Hian Zing Voon, 
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
use IEEE.numeric_bit.all;       --for to_integer
use work.cpu_defs_pack.all;
use work.output_functions_pack.all;
use std.textio.all;



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
        file Outputfile : Text is out "trace";
        variable l : line;
        
        
        --Variable declaration
        --Register inside CPU
        variable Reg : reg_type;
        --Memory outside CPU
        variable Mem : mem_type;
   --!!!!!The Memory initialitation here (the function name)
        
        --Programm Counter Addresses are in integer format
        variable PC : Integer :=0;
        --Instruction is a 32Bit_vector, But we work it as Integer
        variable Inst : Integer RANGE 2**32-1 downto 0;             --!!!!!!!!!!NEEDS TO BE CHANGE TO BITVECTOR. VHDL CANT HANDLE 2**32 BIG INTEGER
        --Decoded Instruction Parameter
        variable op : opcode_type;--Maybe integer or Opcode. Skript says Instruction is integer --Biggest Nr. without bbb=111 is 11 110 11=124, smallest Nr is 00 000 11
        variable ErrorOP : String(7 downto 0);
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
        variable imm32Bit : bit_vector(31 downto 0);    --Immidiet need to be reorganized, easyer done as bit_vector
        variable immInteger : integer RANGE 2**20-1 downto 0;
          
        --For R-Type Instruction
        
        
        --Begin running the Programm  
        BEGIN
---------------------            
--MADE BY TIEMO SCHMITD            
---------------------
        --Create Output Header
        trace_Header(l, Outputfile);
        --get Instruction
        Inst := TO_INTEGER(unsigned(Mem(rs)));  --The memory is defined as bit_vector, but the skript says that we work the instructions as integer
        --PC count up
        PC := PC + 1;
        
        --decode Inst: get OP-CODE
        OP := bit_vector(TO_UNSIGNED(Inst mod 128, 7)); --gets the last 7Bit as integer
        
        case OP is
         
            when code_stop => wait; --Declared by us. Opcode is the only invalid OP-Code "111 1111"
---------------------            
--MADE BY TIEMO SCHMITD            
---------------------       
            when code_load =>
                --we have Instruction Typ-L
                --get Parameters
                imm := (Inst/2**20) mod 2**12; -- we want the 12 leftmost Bit from 32 Bit integer (31 to 20)
                rs := (Inst/2**15) mod 2**5;
                rd := (Inst/2**7) mod 2**5;
                
                --calculate source address
                addr := TO_INTEGER(unsigned(Reg(rs))) + imm; --depending on data_type of Reg, it needs change
                load_addr := addr/4;         --calculates adress of the 32Bit-adress. decimal point will be cut off(round down) 
                --Load Data from source address
                Data := Mem(load_addr);    --Loads whole 32Bit Mem_cell
                
                --now func3 needs to be looked at, func starts at bit 12, so we need to shift 11 times right
                func3 := (Inst/2**11) mod 2**3;
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
                func3 := (Inst/2**12) mod 2**3;
                --get other Parameters
                rs1 := (Inst/2**15) mod 2**5;   --Register for Memory Adress
                rs2 := (Inst/2**20) mod 2**5;   --Register for Data to store
                
                --Risc v Specification says Imm ist 12Bit in size. but it is split in one 7Bit and one 5Bit Part.
                Immp1 := bit_vector(to_unsigned((Inst/2**25) mod 7, 7));
                Immp2 := bit_vector(to_unsigned((Inst/2**7) mod 5, 5));
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
--MADE BY Hian Zing Voon            
---------------------                                                    
            when code_arithmetic =>
                --Arithmetic OP (add, sub, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
                

---------------------                                
            when code_arithmeticImm_nop =>
                --Arithmetic OP (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI) and NOP (ADDI with x0 x0 0)

---------------------            
--MADE BY TIEMO SCHMITD            
---------------------             
            when code_jal =>
                --Jump Instruction with no condition
                --get rd
                rd := (Inst /2**7) mod 2**5;
                
                --Convert Inst to Bit_vector wit 32Bit 
                instbit := bit_vector(TO_SIGNED(Inst, 32));
                 
                --get imm by reorganzing Instr
                --Because Signextended Imm 31 downto 20 is MSB of Inst
                for i in 31 downto 20 LOOP
                imm32bit(i) := InstBit(31);
                end LOOP;
                
                --immBit 10 downto 12 are at Inst 19 downto 12
                for i in 19 downto 12 LOOP
                    imm32bit(i) := InstBit(i);
                end LOOP;
                
                --immBit 11 is at Inst 20
                imm32Bit(11) := InstBit(20);
                
                --immBit 10 downto 1 are in Inst 30 downto 21
                for i in 30 downto 21 LOOP
                    imm32bit(-20 + i) := InstBit(i);
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
                rd := (Inst/2**7) mod 2**5;
                --func3 can be ignored as there are no other instruction with same OP-Code
                rs1 := (Inst/2**15) mod 2**5;
                imm := (Inst/2**20) mod 2**12;
                
                --Trace
                trace(l,    Outputfile, PC, string'("JALR"), imm, rs1, 0,  rd);
                
                --Instruction after Jump Inst save to rd
                Reg(rd) := bit_vector(TO_UNSIGNED(PC, 32)); -- only Pc because it was incremented already
                --set PC to Target address
                PC := (rs1+Imm) / 4; --divided by 4, because Pc is addressing words and not halfword. Because we are not using ShortInstructions
            
---------------------            
--MADE BY             
---------------------  
            when code_Branch => 
                --OR arithmetic
                
---------------------            
--MADE BY             
---------------------  
            when code_lui =>
                --Load upper Imm 20Bit fills lower 12Bit with 0
 
---------------------            
--MADE BY             
---------------------  
            when code_AUIPC =>
                --Build 32Bit address. For more context look at RiscV_spec.pdf P.19
            
---------------------            
--MADE BY             
---------------------                                            
            when others =>
                --Error in OPCODE / or not implemented op-code
                report "something is wrong with the OP-Code case. Op-Code(as integr): " & integer'image(to_integer(unsigned(OP))); --cant report Bit_vector transformed to integer
        end case;        
        END process;
end Behavioral;
