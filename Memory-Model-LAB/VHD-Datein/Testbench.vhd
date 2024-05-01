----------------------------------------------------------------------------------
-- Company: Technical University of Munich
-- Engineer: Tiemo Schmidt
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

library IEEE;
use IEEE.numeric_bit.all;


entity TB is
    port( 
        w_en : out boolean := false;
        addr_1dim : out integer range 4095 downto 0;
        addr_12dim : out bit_vector(11 downto 0);
        data_to_1dim : out integer range 4095 downto 0;
        data_to_12dim : out bit_vector(11 downto 0);
        data_from_1dim : in integer range 4095 downto 0;
        data_from_12dim : in bit_vector(11 downto 0)
    ); 
end TB;

--Architecture of the testbench
architecture Behavorial of TB is


BEGIN
  --UUT Declaration takes place in TLE, I only need to send the right signal to the outputs

  PROCESS 
    BEGIN
    --addr_v is the current address
    for addr_v IN 0 TO 4095 LOOP
        --set addresses
        addr_1dim <= addr_v;
        addr_12dim <= bit_vector(TO_UNSIGNED(addr_v, 12));
        --set data that is written into the Memory-cell
        data_to_1dim <= addr_v;
        data_to_12dim <= bit_vector(to_unsigned(addr_v, 12));
        --set enable
        w_en <= true; wait for 1ns;
        w_en <= false; wait for 1ns;
        
        if data_from_1dim /= TO_INTEGER(UNSIGNED(data_from_12dim)) THEN
            --throw error
            report "Error at Address: " & INTEGER'image(addr_v);
        end if;
    end loop; 
  END PROCESS;  
            
            
end Behavorial;