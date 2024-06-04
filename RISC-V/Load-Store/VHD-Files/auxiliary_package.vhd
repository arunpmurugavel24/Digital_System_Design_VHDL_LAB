----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Hian Zing Voon
-- 
-- Create Date: 04.06.2024 00:23:53
-- Design Name: 
-- Module Name: auxiliary_pack - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Contains 2 functions, stringToBitVector & bitVectorToString to be used universally
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


package conversion_pack is  -- Declaration of function
    
    -- Conversion of string to bit_vector --
    function stringToBitVector
        ( str : string ) return bit_vector;
    
    -- Conversion of bit_vector to string --
    function bitVectorToString
        ( bitVector : bit_vector ) return string;

end package conversion_pack;

package body conversion_pack is -- Content of function
    
    -- Body of conversion of string to bit_vector --
    function stringToBitVector
        ( str : string ) return bit_vector is 
        variable bitVector : bit_vector(str'range);
    begin
        -- Loop through char by char in 'str' and change bits in 'bitVector' accordingly --
        for i in str'range loop
            if str(i) = '0' then
                bitVector(i) := '0';
            elsif str(i) = '1' then
                bitVector(i) := '1';
            else
                report("Error in stringToBitVector: " & str);  -- Report error in Tcl console, if any.
                exit;
            end if;
        end loop;
        return bitVector;  -- return is a must! Else Vivado will be running in a never ending loop.
    end function;
    
    -- Body of conversion of bit_vector to string --
    function bitVectorToString
        ( bitVector : bit_vector) return string is 
        variable str : string(bitVector'range);
    begin
        -- Loop through bit by bit in 'bitVector' and change chars in 'str' accordingly --
        for i in bitVector'range loop
            if bitVector(i) = '0' then
                str(i) := '0';
            elsif bitVector(i) = '1' then
                str(i) := '1';
            else
                report("Error in bitVectorToString: " & str);  -- Report error in Tcl console, if any.
            end if;
        end loop;
        return str;  -- return is a must! Else Vivado will be running in a never ending loop.
    end function;
    
end package body conversion_pack;

