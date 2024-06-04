----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Hian Zing Voon
-- 
-- Create Date: 24.05.2024 11:00:29
-- Design Name: 
-- Module Name: memory_content - Behavioral
-- Project Name: Risc V functional CPU 
-- Description: the functions for Loading the assembler txt file, transforming it into a 
--              32Bit bit_vector and then saving it to the Memory.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.all; -- For to_integer
use STD.TEXTIO.ALL;
use WORK.cpu_defs_pack.ALL;
use WORK.mnemonics_pack.ALL;
use WORK.conversion_pack.ALL;

package mem_defs_pack is  -- Declaration of procedure
procedure filetomemory (
    variable inputFile : in text;
    Mem : inout Mem_Type );
end mem_defs_pack;
 
package body mem_defs_pack is -- Content of procedure
procedure filetomemory (

---------------------            
--MADE BY HIAN ZING VOON            
---------------------
    variable inputFile : in text;
    Mem : inout Mem_Type ) is 
    variable row : line;
    variable PC : integer :=0;
    variable stop_detected : boolean := true; 
    variable mnemonicsOpcodeIn : string(5 downto 1);  -- The line in the text file MUST be longer than this defined string
    variable int1 : integer; -- rs1/rd depending on the case
    variable int2 : integer;  -- rs2/imm depending on the case
    variable int3 : integer;  -- rd/imm depending on the case
    variable funct3 : bit_vector(2 downto 0) := "000";
    variable funct7 : bit_vector(6 downto 0) := "0000000";
    variable success : boolean;
    variable outputToMem32Bit : bit_vector(31 downto 0) := "00000000000000000000000000000000";  -- bit_vector is defined to use downto
    variable check : string(31 downto 0);
    variable outputToMem32Bit_string : string(31 downto 0);
    variable opcode_string : string(7 downto 1);
    variable opcode : bit_vector(7 downto 1);
    variable mem_check : string(31 downto 0);  -- used for debugging
    variable immStore : bit_vector(11 downto 0);
    variable immBranch : bit_vector(12 downto 0);
          
    begin
    
        -- Read is a 2-step-process; first extract the entire line via "readline", then read part by part via "read"
--        while not endfile(inputFile) loop  -- loop through the entire .txt file
        while stop_detected loop
            funct3 := "000";
            funct7 := "0000000";
            outputToMem32Bit := "00000000000000000000000000000000";
            readline (inputFile, row);
            success := TRUE;
            
            -- Read Opcode -- 
            read(row, mnemonicsOpcodeIn, success);
            
            -- Check for mnemonics -- 
--            report("mnemonicsOpcodeIn: " & mnemonicsOpcodeIn);  -- debugging
            mnemonics_opcode(mnemonicsOpcodeIn, opcode_string);  -- usage of procedure from mnemonics_package.vhd
            opcode := stringToBitVector(opcode_string);  -- usage of procedure from auxiliary_package.vhd
            
            -- Start of switch case -- 
            case opcode is 

---------------------            
--MADE BY HIAN ZING VOON            
---------------------            
                -- R-type -- 
                when code_arithmetic =>
                read(row, int1, success);  
                if success then
                    read(row, int2, success);
                    if success then
                        read(row, int3, success);
                        if success then
                            
                            -- Declaration of funct3 & funct7 -- (if not defined, means default value of zeros will be used)
                            if mnemonicsOpcodeIn = "SLL  " then
                                funct3 := "001";
                            elsif mnemonicsOpcodeIn = "XOR  " then
                                funct3 := "100";
                            elsif mnemonicsOpcodeIn = "SRL  " then
                                funct3 := "101";
                            elsif mnemonicsOpcodeIn = "SRA  " then
                                funct3 := "101";
                                funct7 := "0100000";
                            elsif mnemonicsOpcodeIn = "OR   " then
                                funct3 := "110";
                            elsif mnemonicsOpcodeIn = "AND  " then
                                funct3 := "111";
                            elsif mnemonicsOpcodeIn = "SUB  " then
                                funct7 := "0100000";
                            elsif mnemonicsOpcodeIn = "SLT  " then
                                funct3 := "010";
                            elsif mnemonicsOpcodeIn = "SLTU " then
                                funct3 := "011";
                            end if;
                                
                            -- Writing values into outputToMem32Bit to store it in 'Mem' --
                            outputToMem32Bit(31 downto 25) := funct7;  -- funct7
                            outputToMem32Bit(24 downto 20) := bit_vector(to_unsigned(int2, 5));  -- rs2
                            outputToMem32Bit(19 downto 15) := bit_vector(to_unsigned(int1, 5));  -- rs1
                            outputToMem32Bit(14 downto 12) := funct3;  -- funct3
                            outputToMem32Bit(11 downto 7) := bit_vector(to_unsigned(int3, 5));  -- rd
                            outputToMem32Bit(6 downto 0) := opcode;  -- opcode
                            
                            -- Save outputToMem32Bit in 'Mem' --
                            Mem(PC) := outputToMem32Bit;
                            
--                            mem_check := bitVectorToString(outputToMem32Bit);  -- debugging
--                            report("Check mem" & "(" & integer'image(PC) & "): "  & mem_check);  -- debugging
                        
                        end if;
                    end if;
                end if;

---------------------            
--MADE BY HIAN ZING VOON            
---------------------               
                -- I-type(1) -- 
                when code_arithmeticImm_nop =>
                read(row, int1, success);  
                if success then
                    read(row, int2, success);
                    if success then
                        read(row, int3, success);
                        if success then
                            
                            -- Declaration of funct3 & funct7 -- (if not defined, means default value of zeros will be used)
                            if mnemonicsOpcodeIn = "SLTI " then
                                funct3 := "010";
                            elsif mnemonicsOpcodeIn = "SLTIU" then
                                funct3 := "011";
                            elsif mnemonicsOpcodeIn = "XORI " then
                                funct3 := "100";
                            elsif mnemonicsOpcodeIn = "ORI  " then
                                funct3 := "110";
                            elsif mnemonicsOpcodeIn = "ANDI " then
                                funct3 := "111";
                            elsif mnemonicsOpcodeIn = "SLLI " then
                                funct3 := "001";
                            elsif mnemonicsOpcodeIn = "SRLI " then
                                funct3 := "101";
                            elsif mnemonicsOpcodeIn = "SRAI " then
                                funct3 := "101";
                                funct7 := "0100000";
                            end if;
                            
                            -- Writing values into outputToMem32Bit to store it in 'Mem' --
                            -- 2 different cases --
                            -- Case 1: with shamt (RISCV Spec pg. 130)--
                            report ("mnemonicsOpcodeIn: " & mnemonicsOpcodeIn);  -- debugging
                            if mnemonicsOpcodeIn = "SLLI " or mnemonicsOpcodeIn = "SRLI " or mnemonicsOpcodeIn = "SRAI " then
                                outputToMem32Bit(31 downto 25) := funct7;  -- funct7
                                outputToMem32Bit(24 downto 20) := bit_vector(to_unsigned(int2, 5));  -- shamt
                                outputToMem32Bit(19 downto 15) := bit_vector(to_unsigned(int1, 5));  -- rs1
                                outputToMem32Bit(14 downto 12) := funct3;  -- funct3
                                outputToMem32Bit(11 downto 7) := bit_vector(to_unsigned(int3, 5));  -- rd
                                outputToMem32Bit(6 downto 0) := opcode;  -- opcode
                            
                                -- Save outputToMem32Bit in 'Mem' --
                                Mem(PC) := outputToMem32Bit;
                            
--                                mem_check := bitVectorToString(outputToMem32Bit);  -- debugging
--                                report("Check mem" & "(" & integer'image(PC) & "): "  & mem_check);  -- debugging
                            
                            -- Case 2: without shamt --
                            else 
                                outputToMem32Bit(31 downto 20) := bit_vector(to_signed(int2, 12));  -- imm
                                outputToMem32Bit(19 downto 15) := bit_vector(to_unsigned(int1, 5));  -- rs1
                                outputToMem32Bit(14 downto 12) := funct3;  -- funct3
                                outputToMem32Bit(11 downto 7) := bit_vector(to_unsigned(int3, 5));  -- rd
                                outputToMem32Bit(6 downto 0) := opcode;  -- opcode
                            
                                -- Save outputToMem32Bit in 'Mem' --
                                Mem(PC) := outputToMem32Bit;
                            
--                                mem_check := bitVectorToString(outputToMem32Bit);  -- debugging
--                                report("Check mem" & "(" & integer'image(PC) & "): "  & mem_check);  -- debugging
                            end if;
                            
                        end if;            
                    end if;
                end if;

---------------------            
--MADE BY HIAN ZING VOON            
---------------------            
                -- I-type(2) -- 
                when code_load =>
                read(row, int1, success);  
                if success then
                    read(row, int2, success);
                    if success then
                        read(row, int3, success);
                       
                        -- Declaration of funct3 & funct7 -- (if not defined, means default value of zeros will be used)
                        if mnemonicsOpcodeIn = "LH   " then
                            funct3 := "001";
                        elsif mnemonicsOpcodeIn = "LW   " then
                            funct3 := "010";
                        elsif mnemonicsOpcodeIn = "LBU  " then
                            funct3 := "100";
                        elsif mnemonicsOpcodeIn = "LHU  " then
                            funct3 := "101";
                        end if;
                            
                        -- Writing values into outputToMem32Bit to store it in 'Mem' --
                        outputToMem32Bit(31 downto 20) := bit_vector(to_signed(int3, 12));  -- imm
                        outputToMem32Bit(19 downto 15) := bit_vector(to_unsigned(int1, 5));  -- rs1
                        outputToMem32Bit(14 downto 12) := funct3;  -- funct3
                        outputToMem32Bit(11 downto 7) := bit_vector(to_unsigned(int2, 5));  -- rd
                        outputToMem32Bit(6 downto 0) := opcode;  -- opcode
                        
                        -- Save outputToMem32Bit in 'Mem' --
                        Mem(PC) := outputToMem32Bit;
                        
--                        mem_check := bitVectorToString(outputToMem32Bit);  -- debugging
--                        report("Check mem" & "(" & integer'image(PC) & "): "  & mem_check);  -- debugging
                        
                    end if;
                end if;

---------------------            
--MADE BY HIAN ZING VOON            
---------------------
                -- S-type -- 
                when code_store =>
                read(row, int1, success);  
                if success then
                    read(row, int2, success);
                    if success then
                        read(row, int3, success);
                        if success then
                            
                            -- Declaration of funct3 & funct7 -- (if not defined, means default value of zeros will be used)
                            if mnemonicsOpcodeIn = "SH   " then
                                funct3 := "001";
                            elsif mnemonicsOpcodeIn = "SW   " then
                                funct3 := "010";
                            end if;
                            
                            -- Predefine 'immStore', as slicing can't be done on conversion directly --
                            immStore := bit_vector(to_signed(int3, 12));
                            
                            -- Writing values into outputToMem32Bit to store it in 'Mem' --
                            outputToMem32Bit(31 downto 25) := immStore(11 downto 5);  -- imm
                            outputToMem32Bit(24 downto 20) := bit_vector(to_unsigned(int2, 5));  -- rs2
                            outputToMem32Bit(19 downto 15) := bit_vector(to_unsigned(int1, 5));  -- rs1
                            outputToMem32Bit(14 downto 12) := funct3;  -- funct3
                            outputToMem32Bit(11 downto 7) := immStore(4 downto 0);  -- imm
                            outputToMem32Bit(6 downto 0) := opcode;  -- opcode
                            
                            -- Save outputToMem32Bit in 'Mem' --
                            Mem(PC) := outputToMem32Bit;
                            
--                            mem_check := bitVectorToString(outputToMem32Bit);  -- debugging
--                            report("Check mem" & "(" & integer'image(PC) & "): "  & mem_check);  -- debugging
                        
                        end if;
                    end if;
                end if;     

---------------------            
--MADE BY HIAN ZING VOON            
---------------------                
                -- B-type -- 
                when code_Branch =>
                read(row, int1, success);  
                if success then
                    read(row, int2, success);
                    if success then
                        read(row, int3, success);
                        if success then
                                               
                            -- Declaration of funct3 & funct7 -- (if not defined, means default value of zeros will be used)
                            if mnemonicsOpcodeIn = "BNE  " then
                                funct3 := "001";
                            elsif mnemonicsOpcodeIn = "BLT  " then
                                funct3 := "100";
                            elsif mnemonicsOpcodeIn = "BGE  " then
                                funct3 := "101";
                            elsif mnemonicsOpcodeIn = "BLTU " then
                                funct3 := "110";
                            elsif mnemonicsOpcodeIn = "BGEU " then
                                funct3 := "111";
                            end if;

                            -- Predefine 'immStore', as slicing can't be done on conversion directly --
                            immBranch := bit_vector(to_signed(int3, 13));
                               
                            -- Writing values into outputToMem32Bit to store it in 'Mem' --
                            outputToMem32Bit(31) := immBranch(12);  -- imm
                            outputToMem32Bit(30 downto 25) := immBranch(10 downto 5);  -- imm
                            outputToMem32Bit(24 downto 20) := bit_vector(to_unsigned(int2, 5));  -- rs2
                            outputToMem32Bit(19 downto 15) := bit_vector(to_unsigned(int1, 5));  -- rs1
                            outputToMem32Bit(14 downto 12) := funct3;  -- funct3
                            outputToMem32Bit(11 downto 8) := immBranch(4 downto 1);  -- imm
                            outputToMem32Bit(7) := immBranch(11);  -- imm
                            outputToMem32Bit(6 downto 0) := opcode;  -- opcode
                            
                            -- Save outputToMem32Bit in 'Mem' --
                            Mem(PC) := outputToMem32Bit;
                            
--                            mem_check := bitVectorToString(outputToMem32Bit);  -- debugging
--                            report("Check mem" & "(" & integer'image(PC) & "): "  & mem_check);  -- debugging
                        
                        end if;    
                    end if;
                end if;             

---------------------            
--MADE BY Yu-Hung TSAI
---------------------
                -- U-type(1) --
                when code_lui =>        
                read(row, int1, success);                         
                if success then
                    read(row, int2, success);
                    if success then
                        -- Writing values into outputToMem32Bit to store it in 'Mem' --
                        outputToMem32Bit(31 downto 12) := bit_vector(to_signed(int2, 20));  -- imm
                        outputToMem32Bit(11 downto 7) := bit_vector(to_unsigned(int1, 5));  -- rd
                        outputToMem32Bit(6 downto 0) := opcode;  -- opcode
                            
                        -- Save outputToMem32Bit in 'Mem' --
                        Mem(PC) := outputToMem32Bit;
                            
--                            mem_check := bitVectorToString(outputToMem32Bit);  -- debugging
--                            report("Check mem" & "(" & integer'image(PC) & "): "  & mem_check);  -- debugging
                        
                    end if;    
                end if;

                    
---------------------            
--MADE BY Yu-Hung TSAI 
---------------------
                -- U-type(2) -- 
                when code_AUIPC =>      
                read(row, int1, success);                         
                if success then
                    read(row, int2, success);
                    if success then
                        -- Writing values into outputToMem32Bit to store it in 'Mem' --
                        outputToMem32Bit(31 downto 12) := bit_vector(to_signed(int2, 20));  -- imm
                        outputToMem32Bit(11 downto 7) := bit_vector(to_unsigned(int1, 5));  -- rd
                        outputToMem32Bit(6 downto 0) := opcode;  -- opcode
                            
                        -- Save outputToMem32Bit in 'Mem' --
                        Mem(PC) := outputToMem32Bit;
                            
--                            mem_check := bitVectorToString(outputToMem32Bit);  -- debugging
--                            report("Check mem" & "(" & integer'image(PC) & "): "  & mem_check);  -- debugging
                        
                    end if;    
                end if;
                                   
---------------------            
--MADE BY Yu-Hung TSAI            
---------------------         
                -- I-type(3) --
                when code_jalr =>
                read(row, int1, success);  
                if success then
                    read(row, int2, success);
                    if success then
                        read(row, int3, success);
                        if success then                        
                            -- Declaration of funct3 & funct7 -- (if not defined, means default value of zeros will be used)
                            if mnemonicsOpcodeIn = "JALR " then
                                funct3 := "000";
                            end if;
                                
                            -- Writing values into outputToMem32Bit to store it in 'Mem' --
                            outputToMem32Bit(31 downto 20) := bit_vector(to_signed(int3, 12));  -- imm
                            outputToMem32Bit(19 downto 15) := bit_vector(to_unsigned(int1, 5));  -- rs1
                            outputToMem32Bit(14 downto 12) := funct3;  -- funct3
                            outputToMem32Bit(11 downto 7) := bit_vector(to_unsigned(int2, 5));  -- rd
                            outputToMem32Bit(6 downto 0) := opcode;  -- opcode
                        
                        -- Save outputToMem32Bit in 'Mem' --
                        Mem(PC) := outputToMem32Bit;
                        end if;    
                    end if;
                end if;  

---------------------            
--MADE BY Yu-Hung TSAI            
---------------------               
                -- J-type modified -- 
                when code_jal =>
                read(row, int1, success);  
                if success then
                    read(row, int2, success);
                    if success then
                         -- Writing values into outputToMem32Bit to store it in 'Mem' --
                         outputToMem32Bit(31 downto 12) := bit_vector(to_signed(int2, 20));  -- imm                        
                         outputToMem32Bit(11 downto 7)  := bit_vector(to_unsigned(int1, 5));  -- rd
                         outputToMem32Bit(6 downto 0)   := opcode;  -- opcode
                        
                        -- Save outputToMem32Bit in 'Mem' --
                        Mem(PC) := outputToMem32Bit;
                            
                    end if;
                end if;
                
                -- To stop the program --           
                when code_stop =>
                    outputToMem32Bit(6 downto 0) := opcode;
                    
                    -- Save outputToMem32Bit in 'Mem' --
                    Mem(PC) := outputToMem32Bit;
                    
                    stop_detected := false;
                
                when others =>
                    report("Something went wrong while trying to decode the input file. Please refer back to memory_content.vhd");
                
            -- End of switch case --
            end case;
            
         
         PC := PC + 1;   
         end loop;
             
end filetomemory;
end mem_defs_pack;

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
