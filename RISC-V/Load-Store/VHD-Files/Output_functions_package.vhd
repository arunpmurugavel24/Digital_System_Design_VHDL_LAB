----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.05.2024 14:27:22
-- Design Name: Tiemo Schmidt
-- Module Name: Output_functions_package - Behavioral
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
use std.textio.all;

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
                    write(l, OP_code, left, 4); --we are calling trace in the different switch cases, so opcode doesnt need to be flexible
                    write(l, string'(" | "));
                    write(l, integer'image(Imm), left, 4);
                    write(l, string'(" | "));                    
                    write(l, integer'image(r1),left, 3);
                    write(l, string'(" | "));
                    write(l, integer'image(r2),left, 3);
                    write(l, string'(" | "));
                    write(l, integer'image(rd), left, 3);                                        
                end trace;
                
procedure trace_header(
                l : inout line;
                f : inout text) is 
                begin
                    write(l, string'("PC"), left, 3);
                    write(l, string'(" | "));
                    write(l, string'("OP"), left, 4); --we are calling trace in the different switch cases, so opcode doesnt need to be flexible
                    write(l, string'(" | "));
                    write(l, string'("IMM"), left, 4);
                    write(l, string'(" | "));                    
                    write(l, string'("rs1"),left, 3);
                    write(l, string'(" | "));
                    write(l, string'("rs2"),left, 3);
                    write(l, string'(" | "));
                    write(l, string'("rd"), left, 3);
                    writeline(f, l);
                    --divider
                    write(l, string'("--------------------"));
                    writeline(f, l); 
                end trace_header;
end package body;