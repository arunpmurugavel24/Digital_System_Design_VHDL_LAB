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
use work.conversion_pack.all;


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
        file inputFile : text open read_mode is "C:\Users\Tiemo Schmidt\Documents\VHDL-Ecker\Digital_System_Design_VHDL_LAB\RISC-V\Load-Store\VHD-Files\Inputfile-Testbench.txt";
        file Outputfile : Text open write_mode is "C:\Users\Tiemo Schmidt\Downloads\project_1\trace.txt";
        variable l : line;
        
        
        --Variable declaration
        variable stop_detected : boolean := true; 
        --Register inside CPU
        variable Reg : Reg_Type := (others => "00000000000000000000000000000000");
        --Memory outside CPU
        variable Mem : Mem_Type := (
        100 => "00000000000000000000000001111111",
        others => "00000000000000000000000000000000");
   
        
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
        variable func7 : integer RANGE 128 downto 0;
        variable rd : Integer Range 31 downto 0;
        variable shamt : integer Range 31 downto 0; -- Shift Amount Bits
        variable addr: integer Range 2**16-1 downto 0; --the adress given in the Instruction (8Bit-Steps)
        variable load_addr : integer RANGE 2**16-1 downto 0; --the calculated adress for the 32Bit Memory cell
        variable difference : integer RANGE 0 to 3;          --Difference between the given software-address and the Hardware-addres*4
        variable DataIntTmp : integer RANGE 2**16-1 downto 0; -- Temporary Integer Variable
        variable rs2_low : bit_vector(4 downto 0);
        variable Data : bit_vector(31 downto 0); --the whole bit_vector from Memory
        variable Data1 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data2 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data3 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data4 : Bit_vector(7 downto 0); --one Address is only 8Bit big
        variable Data32Tmp : Bit_Vector(31 downto 0); -- Temporary 32 Bit Variable
        variable Data32Tmp2 : Bit_Vector(31 downto 0); --Temporary 32 Bit Variable
               
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
        variable new_pc   : integer;
        
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
    
    --Loop so that tracer_header doesnt get called each time the next instruction is fetched    
    while stop_detected LOOP
        Reg(0) := "00000000000000000000000000000000"; --Our way of Hardwireing register x0 as '0'
        Inst := Mem(PC);  --The memory is defined as bit_vector, but the skript says that we work the instructions as integer
        --PC count up
        PC := PC + 1;
        
        --decode Inst: get OP-CODE
        OP := Inst(6 downto 0); --gets the last 7Bit as integer

        case OP is
         
            when code_stop => 
                --we implemented it as a way to stop the simulation and start the Mem_dump
                --opcode is the only illegal Opcode "111 1111"
                stop_detected := false;
                trace(l, Outputfile, PC, "stop", 0, 0, 0, 0);

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
--MADE BY TIEMO SCHMITD      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! MUSS ADRESSING nochmal ändern      
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
                        trace(l,    Outputfile, PC, string'("SB"), imm, rs1, rs2,  0);
                        --takes lowest 8 Bit of Rs2 and stores it at rs1+imm
                        Data32Bit := Reg(rs2);
                        --get the lower 8
                        Data1 := Data32Bit(7 downto 0);
                        --calculate Hardware address save it to only the given bit
                        addr := to_integer(signed(Reg(rs1)))+imm;
                        load_addr := addr/4;
                        difference := addr - (load_addr*4);
                        
                        --Save the 8Bit to the correct place in Mem at load_addr
                        Mem(load_addr)(8*(difference+1)-1 downto 8*(difference+1)-8) := Data1;

                    when 1 =>
                        --store Halfword
                        trace(l,    Outputfile, PC, string'("SH"), imm, rs1, rs2,  0);
                        --takes lowest 16 Bit of Rs2 and stores it at rs1+imm
                        Data32Bit := Reg(rs2);
                        Data1 := Data32Bit(15 downto 8);
                        Data2 := Data32Bit(7 downto 0);
                        --calculate Hardware address save it to only the given bit
                        addr := to_integer(signed(Reg(rs1)))+imm;
                        load_addr := addr/4;
                        difference := addr - (load_addr*4);
                        case difference is 
                        when 0 =>
                            
                            Mem(load_addr)(15 downto 8) := Data1;
                            Mem(load_addr)(7 downto 0) := Data2;
                        when 1 =>
                            Mem(load_addr)(23 downto 16) := Data1;
                            Mem(load_addr)(15 downto 8) := Data2;
                        when 2 =>
                            Mem(load_addr)(31 downto 24) := Data1;
                            Mem(load_addr)(23 downto 16) := Data2;
                        when 3 =>
                            Mem(load_addr+1)(7 downto 0) := Data1;
                            Mem(load_addr)(31 downto 24) := Data2;
                        when others =>
                        end case;
                        
                      
                    when 2 =>
                        --store word
                        trace(l,    Outputfile, PC, string'("SW"), imm, rs1, rs2,  0);
                        --takes lowest 32 Bit of Rs2 and stores it at rs1+imm
                        Data32Bit := Reg(rs2);
                        addr := to_integer(signed(Reg(rs1)))+imm;
                        load_addr := addr/4;
                        difference := addr - (load_addr*4);
                        --if difference is 0 then just save to Mem, otherwise it needs to be split
                        case difference is
                            when 0 => 
                                Mem(load_addr) := Data32Bit;
                                
                            when 1 =>
                                --save the lowest 24Bit to the the 24 MSB of the Mem(load_addr) and the highest 8Bit of rs2 to the lowest 8 Bit of Mem(load_addr+1)
                                Mem(load_Addr)(31 downto 8) := Data32Bit(23 downto 0);
                                Mem(load_Addr+1)(7 downto 0) := Data32Bit(31 downto 24);
                            when 2 =>
                                --save the lowest 16Bit to the the 16 MSB of the Mem(load_addr) and the highest 16Bit of rs2 to the lowest 16 Bit of Mem(load_addr+1)
                                Mem(load_Addr)(31 downto 16) := Data32Bit(15 downto 0);
                                Mem(load_Addr+1)(15 downto 0) := Data32Bit(31 downto 16);
                            when 3=>
                                --save the lowest 8Bit to the the 8 MSB of the Mem(load_addr) and the highest 24Bit of rs2 to the lowest 24 Bit of Mem(load_addr+1)
                                Mem(load_Addr)(31 downto 24) := Data32Bit(7 downto 0);
                                Mem(load_Addr+1)(23 downto 0) := Data32Bit(31 downto 8);
                            when others=>
                                report"Error: Store-Instruction Address Calculation. Difference took on a Value that shouldnt be possible" severity error;
                            end case;
                                           
                        
                            
                    when others =>
                        --error in Store
                        report "something is wrong with the Store func3 case. func3: " & integer'image(func3);
                end case;
                
---------------------            
--MADE BY ARUN PREMA MURUGAVEL     
---------------------                                                    
            when code_arithmetic =>
                --Arithmetic OP (add, sub, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
                --Arithmetic Decoding
                --R Format
                func3 := TO_INTEGER(unsigned(Inst(14 downto 12)));  --get other Parameter
                rs1 := TO_INTEGER(unsigned(Inst(19 downto 15)));    --Source Register 1
                rs2 := TO_INTEGER(unsigned(Inst(24 downto 20)));    --Source Register 2
                rd := TO_INTEGER(unsigned(Inst(11 downto 7)));      --Destination Register
                func7 := TO_INTEGER(unsigned(Inst(31 downto 25)));
                --func3+func7 combined with Opcode, specify what operation to perform
                case func3 is
                    when 0 => 
                        case func7 is
                            when 0 => --ADD
                                trace(l, Outputfile, PC, string'("ADD"), imm, rs1, rs2,  rd);
                                Reg(rd) := bit_vector(to_signed((TO_INTEGER(signed(Reg(rs1))) + TO_INTEGER(signed(Reg(rs2)))), 32));
                            when 32 => --SUB
                                trace(l, Outputfile, PC, string'("SUB"), imm, rs1, rs2,  rd);
                                Reg(rd) := bit_vector(to_signed((TO_INTEGER(signed(Reg(rs1))) - TO_INTEGER(signed(Reg(rs2)))), 32));
                            when others =>
                                report("Error at ADD/SUB func7");
                        end case;
                    when 1 => --SLL
                        trace(l, Outputfile, PC, string'("SLL"), imm, rs1, rs2,  rd);
                        Data32Bit := "00000000000000000000000000000000"; --Final Bits Will be saved here
                        Data32Tmp := Reg(rs1);
                        Data32Tmp2 := Reg(rs2);
                        for i in 4 downto 0 Loop
                            rs2_low(i) := Data32Tmp2(i);
                        end Loop;
                        DataIntTmp := TO_INTEGER(unsigned(rs2_low));
                        for i in 0 to (31 - DataIntTmp) Loop
                            Data32Bit(i + DataIntTmp) := Data32Tmp(i);
                        end Loop;
                        Reg(rd) := Data32Bit;
                    when 2 => -- SLT
                        trace(l, Outputfile, PC, string'("SLT"), imm, rs1, rs2,  rd);
                        if (to_integer(signed(Reg(rs1))) < to_integer(signed(Reg(rs2)))) then
                            Data32Bit(0) := '1';
                        end if;
                        if (to_integer(signed(Reg(rs1))) >= to_integer(signed(Reg(rs2)))) then
                            Data32Bit(0) := '0';
                        end if;
                        Reg(rd) := Data32Bit;
                    when 3 => -- SLTU
                        trace(l, Outputfile, PC, string'("SLTU"), imm, rs1, rs2,  rd);
                        if (to_integer(unsigned(Reg(rs1))) < to_integer(unsigned(Reg(rs2)))) then
                            Data32Bit(0) := '1';
                        end if;
                        if (to_integer(unsigned(Reg(rs1))) >= to_integer(signed(Reg(rs2)))) then
                            Data32Bit(0) := '0';
                        end if;
                        Reg(rd) := Data32Bit;
                    when 4 => --XOR
                        trace(l, Outputfile, PC, string'("XOR"), imm, rs1, rs2,  rd);
                        Reg(rd) := Reg(rs1) xor Reg(rs2);
                    when 5 =>
                        case func7 is
                            when 32 => --SRA
                                trace(l, Outputfile, PC, string'("SRA"), imm, rs1, rs2,  rd);
                                Data32Bit := "00000000000000000000000000000000"; --Final Bits Will be saved here
                                Data32Tmp := Reg(rs1);
                                Data32Tmp2 := Reg(rs2);
                                for i in 4 downto 0 Loop
                                    rs2_low(i) := Data32Tmp2(i);
                                end Loop;
                                DataIntTmp := TO_INTEGER(unsigned(rs2_low));
                                for i in 31 downto DataIntTmp Loop
                                    Data32Bit(i - DataIntTmp) := Data32Tmp(i);
                                end Loop;
                                for j in 31 downto (31 - DataIntTmp) Loop
                                    Data32Bit(j) := Data32Bit(31-DataIntTmp);
                                end Loop;
                                Reg(rd) := Data32Bit;
                            when 0 => --SRL
                                trace(l, Outputfile, PC, string'("SRL"), imm, rs1, rs2,  rd);
                                Data32Bit := "00000000000000000000000000000000"; --Final Bits Will be saved here
                                Data32Tmp := Reg(rs1);
                                Data32Tmp2 := Reg(rs2);
                                for i in 4 downto 0 Loop
                                    rs2_low(i) := Data32Tmp2(i);
                                end Loop;
                                DataIntTmp := TO_INTEGER(unsigned(rs2_low));
                                for i in 31 downto DataIntTmp Loop
                                    Data32Bit(i - DataIntTmp) := Data32Tmp(i);
                                end Loop;
                                Reg(rd) := Data32Bit;
                            when others =>
                                report("Error at SRA/SRL func7");
                        end case;
                        when 6 => --OR
                            trace(l, Outputfile, PC, string'("OR"), imm, rs1, rs2,  rd);
                            Reg(rd) := Reg(rs1) or Reg(rs2);
                        when 7 => --AND
                            trace(l, Outputfile, PC, string'("AND"), imm, rs1, rs2,  rd);
                            Reg(rd) := Reg(rs1) and Reg(rs2);    
                        when others =>
                            report "something is wrong with the Arithmetic Funcitons";
                end case;
---------------------
--MADE BY ARUN PREMA MURUGAVEL
---------------------                                
            when code_arithmeticImm_nop =>
                --Arithmetic OP (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI) and NOP (ADDI with x0 x0 0)
                --Arithmetic Decoding
                --I Format
                func3 := TO_INTEGER(unsigned(Inst(14 downto 12)));  --get other Parameter
                rs1 := TO_INTEGER(unsigned(Inst(19 downto 15)));    --Source Register 1
                rd := TO_INTEGER(unsigned(Inst(11 downto 7)));      --Destination Register
                imm := TO_INTEGER(signed(Inst(31 downto 20)));      -- Immediate Amount
                shamt := TO_INTEGER(unsigned(Inst(24 downto 20)));  -- Shift Amount
                func7 := TO_INTEGER(unsigned(Inst(31 downto 25)));  -- func7
                case func3 is
                        when 0 =>
                            if (imm /= 0) then --ADDI
                                trace(l, Outputfile, PC, string'("ADDI"), imm, rs1, 0,  rd);
                                Reg(rd) := bit_vector(to_signed((TO_INTEGER(signed(Reg(rs1))) + imm), 32));
                            else --NOP
                                trace(l, Outputfile, PC, string'("NOP"), imm, rs1, 0,  rd);
                                Reg(rd) := bit_vector(to_signed((TO_INTEGER(signed(Reg(rs1))) + 0), 32));
                            end if;
                    when 1 => --SLLI
                        trace(l, Outputfile, PC, string'("SLLI"), imm, rs1, rs2,  rd);
                        Data32Bit := "00000000000000000000000000000000"; --Final Bits Will be saved here
                        Data32Tmp := Reg(rs1);
                        for i in 0 to (31 - shamt) Loop
                            Data32Bit(i + shamt) := Data32Tmp(i);
                        end Loop;
                        Reg(rd) := Data32Bit;
                    when 2 => --SLTI
                        trace(l, Outputfile, PC, string'("SLTI"), imm, rs1, rs2,  rd);
                        if (to_integer(signed(Reg(rs1))) < to_integer(to_signed(imm, 32))) then
                            Data32Bit(0) := '1';
                        end if;
                        if (to_integer(signed(Reg(rs1))) >= to_integer(to_signed(imm, 32))) then
                            Data32Bit(0) := '0';
                        end if;
                        Reg(rd) := Data32Bit;
                    when 3 => --SLTUI
                        trace(l, Outputfile, PC, string'("SLTUI"), imm, rs1, rs2,  rd);
                        if to_integer(unsigned(Reg(rs1))) < to_integer(to_unsigned(imm, 32)) then
                            Data32Bit(0) := '1';
                        end if;
                        if (to_integer(unsigned(Reg(rs1))) >= to_integer(to_unsigned(imm, 32))) then
                            Data32Bit(0) := '0';
                        end if;
                        Reg(rd) := Data32Bit;
                    when 4 => --XORI
                        trace(l, Outputfile, PC, string'("XORI"), imm, rs1, rs2,  rd);
                        Reg(rd) := Reg(rs1) xor bit_vector(to_signed(imm, 32));
                    when 5 =>
                        case func7 is
                            when 0 => --SRAi
                                trace(l, Outputfile, PC, string'("SRA"), imm, rs1, rs2,  rd);
                                Data32Bit := "00000000000000000000000000000000"; --Final Bits Will be saved here
                                Data32Tmp := Reg(rs1);
                                for i in 31 downto shamt Loop
                                    Data32Bit(i - shamt) := Data32Tmp(i);
                                end Loop;
                                for j in 31 downto (31 - shamt) Loop
                                    Data32Bit(j) := Data32Bit(31-shamt);
                                end Loop;
                                Reg(rd) := Data32Bit;
                            when 32 => --SRLi
                                trace(l, Outputfile, PC, string'("SRL"), imm, rs1, rs2,  rd);
                                Data32Bit := "00000000000000000000000000000000"; --Final Bits Will be saved here
                                Data32Tmp := Reg(rs1);
                                for i in 31 downto shamt Loop
                                    Data32Bit(i - shamt) := Data32Tmp(i);
                                end Loop;
                                Reg(rd) := Data32Bit;
                            when others =>
                                report("Error at SRAI/SRLI func7");
                        end case;
                    when 6 => --ORI
                        trace(l, Outputfile, PC, string'("ORI"), imm, rs1, rs2,  rd);
                        Reg(rd) := Reg(rs1) or bit_vector(to_signed(imm, 32));
                    when 7 => --ANDI
                        trace(l, Outputfile, PC, string'("ANDI"), imm, rs1, rs2,  rd);
                        Reg(rd) := Reg(rs1) and bit_vector(to_signed(imm, 32));
                    when others =>
                        report "something is wrong with the Arithmetic Immediate Functions";
                end case;
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
--------------------- 				                              
            when code_AUIPC =>
            -- Build 32Bit address. For more context look at RiscV_spec.pdf P.19
                imm := TO_INTEGER(unsigned(Inst(31 downto 12)));
                rd  := TO_INTEGER(unsigned(Inst(11 downto 7)));
                op  := Inst(6 downto 0);
                
                -- Form the 32-bit offset from the 20-bit immediate and fill the lowest 12 bits with zeros
                imm32Bit (31 downto 12) := Inst(31 downto 12);				
                

                -- Calculate the new PC value by adding the offset to the current PC
                new_pc :=  PC + TO_INTEGER(signed(imm32Bit));
                
                trace(l,    Outputfile, PC, string'("AUIPC"), imm, 0, 0,  rd);
                -- Store the result in the destination register
                Reg(rd) := bit_vector(TO_SIGNED(new_pc, 32));
                

---------------------            
--MADE BY Tiemo SCHMIDT            
---------------------                                            
            when others =>
                --Error in OPCODE / or not implemented op-code
                report "something is wrong with the OP-Code case. Op-Code(as integr): " & integer'image(to_integer(unsigned(OP))) & "   PC: " & integer'image(PC); --cant report Bit_vector transformed to integer
        end case;
    end LOOP;
        --stop_detected got set to false, stop programm and dump memory
        mem_dump(l, Outputfile, mem);
        wait;
                 
        END process;
end Behavioral;
