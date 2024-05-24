----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.05.2024 11:00:29
-- Design Name: 
-- Module Name: memory_content - Behavioral
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
use STD.TEXTIO.ALL;
use WORK.cpu_defs_pack.ALL;

package mem_defs_pack is  -- Declaration of function
    procedure filetomemory (
          variable f : in text;
          mem : inout mem_type);
end mem_defs_pack;
 
package body mem_defs_pack is -- Content of function
procedure filetomemory (
          variable f : in text;
          
          mem : inout mem_type) is 
          variable l : line;
          variable s : string(30 downto 1);  --The line in the text file MUST be longer than this defined string
          variable i : integer; -- bei Read integer, it only takes 1 number
          variable success : boolean;
          
    begin
        readline (f, l); 
        read(l, s, success);
        
        if success then 
            report ("---------------!!!!!!!!!-------------" & s);
        --report("Test");
        else
            report ("error");
        end if; 
        
        readline (f,l);
        read(l,i,success);
        
        if success then
            report ("scheissssssssssssse" & integer'image(i));
        else
            report ("error");
        end if;
        
        read(l,i,success);
        
        if success then
            report ("kackkkkkkkke" & integer'image(i));
        else
            report ("error");
        end if;
             
end filetomemory;
end mem_defs_pack;


