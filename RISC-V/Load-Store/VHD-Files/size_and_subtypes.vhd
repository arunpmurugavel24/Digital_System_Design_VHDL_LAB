----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Yu-Hung Tsai
-- 
-- Create Date: 10.05.2024 12:22:34
-- Design Name:
-- Module Name: size_and_subtypes 
-- Project Name: Risc V functional CPU 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package cpu_defs_pack is

    -- PC, Addr Wire of Bus, Memory Depth --
    constant AddrSize       : integer := 16;
    constant BytesperWord   : integer := 2;
    --constant MemoryAddrSize : bit_vector(AddrSize - BytesperWord);

    -- Data Wire of Bus, Memory Width --
    constant BusDataSize    : integer := 16;

    -- (maximum) Size of Interuction --
    constant InstrSize      : integer := 31;

    -- Sizes of Register --
    constant RegDataSize    : integer := 32;
    constant RegAddrSize    : integer := 5; 

    -- Type of Opcode --
    subtype opcode_type is bit_vector(6 downto 0);

    -- Definition of Types --
	subtype AddrType is bit_vector
		(AddrSize-1 downto 0);
        
	subtype InstrType is bit_vector
		(InstrSize-1 downto 0);
        
	subtype BusDataType is bit_vector
		(BusDataSize-1 downto 0);
        
	subtype RegDataType is bit_vector
		(RegDataSize-1 downto 0);
        
	type Reg_Type is array 
    	(integer range 2**RegAddrSize-1 downto 0) of RegDataType;
		
	type Mem_Type is array
    	--(integer range 2**MemAddrSize-1 downto 0) of BusDataType;
        (65535 downto 0) of bit_vector(31 downto 0);
    
    -- Definition of Opcode --

    -- Stop Instruction --
    constant code_stop : opcode_type := "1111111";

    -- Load and Store PC Instructions --
    constant code_load : opcode_type := "0000011";
    constant code_store : opcode_type := "0100011";

    -- Logic and Arithmetic Instruction --
    -- SLLI, SRLI, SRAI, XORI, ORI, ANDI --
    constant code_arithmeticImm_nop: opcode_type := "0010011"; 

    -- SLL, SRL, SRA, ADD, SUB, SLT, SLTU, XOR, OR, AND --
    constant code_arithmetic: opcode_type := "0110011";

    -- Jump Instruction -- 
    constant code_jal : opcode_type := "1101111";
    constant code_jalr: opcode_type := "1100111";    
    
    -- LUI and AUIPC Instruction -- 
    constant code_lui  : opcode_type := "0110111";
    constant code_AUIPC: opcode_type := "0010111"; 

    -- Branch Instruction --
    -- BEQ, BNE, BLT, BGE, BLUT, BGEU --
    constant code_Branch  : opcode_type := "1100011";


end cpu_defs_pack;
