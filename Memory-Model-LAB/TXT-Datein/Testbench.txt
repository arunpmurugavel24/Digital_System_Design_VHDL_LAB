----------------------------------------------------------------------------------
-- Company: Technical University of Munich
-- Engineer: Tiemo Schmidt
-- Matrikle Nr.: 03758911
-- 
-- Create Date: 01.05.2024 21:58:10
-- Design Name: Testbench
-- Module Name: Testbench - Behavioral
-- Project Name: Memory Model LAB
-- Target Devices: 
-- Tool Versions: 
-- Description: It is a testbench meant for UUT1 (mem_12d) and UUT2 (mem_int).
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.numeric_bit.all; --for to_integer, to_unsigned,


ENTITY TB IS
--As this test bench ist not the TLE, it needs a Port, so it can be incorperated 
    PORT( 
        w_en : out boolean := false;                    --Signal to enable writing
        addr_1dim : out integer range 4095 downto 0;    --address Signal for the 1-dimensianal Integer Memorycell
        addr_12dim : out bit_vector(11 downto 0);       --address Signal for the 12-dimensional Bit Memorycell
        data_to_1dim : out integer range 4095 downto 0; --Data to Integer Memory 
        data_to_12dim : out bit_vector(11 downto 0);    --Data to Bit_vectore Memory
        data_from_1dim : in integer range 4095 downto 0;--Output from Integer Memory
        data_from_12dim : in bit_vector(11 downto 0)    --Output from Bit_vectore memory
    ); 
END TB;


--Architecture of the testbench
ARCHITECTURE  Behavorial OF TB IS


BEGIN
  --UUT Declaration takes place in TLE, I only need to send the right signal to the outputs

  PROCESS 
    BEGIN
    --addr_v is the current address
    FOR addr_v IN 0 TO 4095 LOOP
        --set addresses
        addr_1dim <= addr_v;
        addr_12dim <= bit_vector(TO_UNSIGNED(addr_v, 12));
        --set data that is written into the Memory-cell
        data_to_1dim <= addr_v;
        data_to_12dim <= bit_vector(TO_UNSIGNED(addr_v, 12));
        --set enable and wait 1ns, in the simulation everything before happens at the sime delta ( parrallel)
        w_en <= true; wait for 1ns;
        --set enable to false and wait 1ns for output to stabilize
        w_en <= false; wait for 1ns;
        
        --Checks if both outputs are the same
        IF data_from_1dim /= TO_INTEGER(UNSIGNED(data_from_12dim)) THEN
            --throw error if Outputs are different
            REPORT "Error at Address: " & INTEGER'image(addr_v);
        END IF;
    END LOOP; 
  END PROCESS;
END Behavorial;