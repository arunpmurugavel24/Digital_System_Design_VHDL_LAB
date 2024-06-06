----------------------------------------------------------------------------------
-- University: Technical University of Munich
-- Student: Tiemo SCHMIDT
-- 
-- Create Date: 24.05.2024 14:27:22
-- Design Name:
-- Module Name: Output_functions_package - Behavioral
-- Project Name: Risc V functional CPU 
-- Description:  the Procedurs for writing into the Outputfile
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use work.cpu_defs_pack.all;
use IEEE.numeric_bit.all;       --for to_integer

package output_functions_pack is
procedure trace(
                l : inout line;
                f : inout text;
                PC : in integer;  
                Op_code : in String; 
                Imm : in integer:=0;
                r1 : in integer := 0;
                r2 : in integer := 0;
                rd : in integer := 0);
                
procedure trace_header(
                l : inout line;
                f : inout text);
                
procedure mem_dump(
                l : inout line;
                f : inout text;
                mem : in mem_type);
                
end package;




package body output_functions_pack is
procedure trace( l : inout line;
                f : inout text;
                PC : in integer;
                Op_code : in String; 
                Imm : in integer:=0;
                r1 : in integer := 0;
                r2 : in integer := 0;
                rd : in integer := 0) is
                begin
                    write(l, integer'image(PC), left, 3);
                    write(l, string'(" | "));
                    write(l, OP_code, left, 5); --we are calling trace in the different switch cases, so opcode doesnt need to be flexible
                    write(l, string'(" | "));
                    write(l, integer'image(Imm), left, 8);
                    write(l, string'(" | "));                    
                    write(l, integer'image(r1),left, 3);
                    write(l, string'(" | "));
                    write(l, integer'image(r2),left, 3);
                    write(l, string'(" | "));
                    write(l, integer'image(rd), left, 3);    
                    writeline(f, l);                                    
                end trace;
                
procedure trace_header(
                l : inout line;
                f : inout text) is 
                begin
                    write(l, string'("PC"), left, 4);
                    write(l, string'("|"));
                    write(l, string'("OP"), left, 7); --we are calling trace in the different switch cases, so opcode doesnt need to be flexible
                    write(l, string'("|"));
                    write(l, string'("IMM"), left, 10);
                    write(l, string'("|"));                    
                    write(l, string'("rs1"),left, 5);
                    write(l, string'("|"));
                    write(l, string'("rs2"),left, 5);
                    write(l, string'("|"));
                    write(l, string'("rd"), left, 3);
                    writeline(f, l);
                    --divider
                    write(l, string'("---------------------------"),left, 3);
                    writeline(f, l); 
                end trace_header;
                
procedure mem_dump(
                l : inout line;
                f : inout text;
                mem : in mem_type) is 
                begin
                    --load last 1000 lines (64535 to 65535) of mem and write them into the Outputfile (f
                    --Spacing to Trace
                    write(l, string'(" "));
                    writeline(f,l);
                    write(l, string'(" "));
                    writeline(f,l);
                    write(l, string'(" "));
                    writeline(f,l);
                    write(l, string'("--------Memory DUMP--------"));
                    writeline(f,l);
                    --Memory Dump Header
                    write(l, string'("address"), left, 7);
                    write(l, string'("|"));
                    write(l, string'("mem-Content"), left, 11);  --2^31 has 10numbers, so with a "-" we need 11;
                    writeline(f, l);
                    write(l, String'("---------------------------"));
                    writeline(f, l);
                    --write every address into Outputfile
                    for i in 64535 to 65535 LOOP
                        write(l, integer'image(i), left, 7);
                        write(l, string'("|"));
                        write(l, integer'image(to_integer(signed(mem(i)))), left, 11);
                        writeline(f, l);
                    end LOOP;
  
                end mem_dump;
                
end package body;