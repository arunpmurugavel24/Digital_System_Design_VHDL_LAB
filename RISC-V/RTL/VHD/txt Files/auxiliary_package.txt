----------------------------------------------------------------------------------
-- University: Technical University of Munich
-- Student: Hian Zing Voon
-- 
-- Create Date: 28.06.2024 18:13:00
-- Design Name: auxiliary_pack
-- Module Name: auxiliary_pack - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Contains 1 function, bitToString to be used universally.
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
    
    -- Conversion of bit to string --
    function bitToString
        ( bit_in : bit ) return string;

end package conversion_pack;

package body conversion_pack is -- Content of function

    -- Body of conversion of bit_vector to string --
    function bitToString
        ( bit_in : bit) return string is 
        variable str : string(2 downto 1) := "  ";
    begin
        -- Loop through bit by bit in 'bitVector' and change chars in 'str' accordingly --
            if bit_in = '0' then
                str(1) := '0';
            elsif bit_in = '1' then
                str(1) := '1';
            else
                report("Error in bitVectorToString: " & str);  -- Report error in Tcl console, if any.
            end if;
        return str;  -- return is a must! Else Vivado will be running in a never ending loop.
    end function;
    
end package body conversion_pack;

