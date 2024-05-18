----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Tiemo Schmidt
-- 
-- Create Date: 05/15/2024 11:50:54 AM
-- Design Name: 
-- Module Name: Instruction_decoding - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Decodes Instuctions and calls the needed function
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

--!!!!!!!!!!!!!!!!
--Ok cant do it as function. You cant write into an Array that is given as a parameter
--!!!!!!!!!!!!!!!

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_defs_pack.ALL;
use work.mem_defs_pack.ALL;
--Needed packages:
--  memory
--  Typ declarations
--  etc.


Package Load_Commands is
    --Load command loads wanted adress from rs, adds offset to it, takes the Byte from this adress and fills it up to 32Bit and stores it at rd
    Function LB (Mem : mem_type; rs : integer; rd : integer; offset : integer)
    return boolean; --if true it worked, if false and error occured
END Load_Commands;


--package Body where it is defined what the function should do
Package Body Load_Commands is
    function LB (Mem : mem_type; rs : integer; rd : integer; offset : integer)
    return boolean is
    --Deklaration of Variables
    variable rs2 : data_type;   --the adress for the Memory. Data saved in Registers is data_type
    variable rs3 : addr_type;   --rs2 + offset
    variable Data8Bit :  bit_vector(7 downto 0); --should be size 8Bit.
    variable Fillvector : bit_vector(31 downto 8);
    variable Data32bit : bit_vector(31 downto 0);
    
    Begin
        --Load adress from rs
        rs2 := Mem(rs);
        --add offset
        rs3 := bit_vector(to_unsigned(to_integer(unsigned(rs2)) + offset))
        --Load data from address
        Data8Bit := ;--memorypack load
        
        --Fill up to 32Bit
        for i in 31 downto 8 LOOP
            Fillvector(i) := Data8Bit(7);
        end LOOP;
        Data32Bit := Fillvector & Data8Bit;
        
        --save in rd
        Mem(rd) := to_integer(signed(Data32Bit));       --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
       
    end LB;
End Load_Commands;