

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.all;
use work.mem_12d;


entity TB is
--Empty Entity
end TB;



architecture Behavorial of TB is
    --Port for Memory Module 12dimensional Bit
    component mem_12d
    port(
    w_en : in boolean;
    addr : in bit_vector(11 downto 0);
    data_in : in bit_vector(11 downto 0);
    data_out : out bit_vector(11 downto 0)
    );
    end component;
    --Port for Memory Module 1dimensional integer
    component mem_int
    port(
    w_en : in boolean;
    addr : in integer range 4095 downto 0;
    data_in : in integer range 4095 downto 0;
    data_out : out integer range 4095 downto 0
    );
    end component;
    
    signal w_en: boolean := false;
    signal data_to_memory1, addr1, dataFromMem1 : BIT_VECTOR(11 downto 0);
    signal data_to_memory2, addr2,dataFromMem2 : integer range 4095 downto 0;

BEGIN
    --Bit MemoryModul
    UUT1: mem_12d port map(w_en => w_en, 
                addr => addr1, 
                data_in => data_to_memory1, 
                data_out => dataFromMem1);
    --Integer MemoryModul        
    UUT2: mem_int port map(w_en => w_en,
                addr => addr2,
                data_in => data_to_memory2,
                data_out => dataFromMem2);
    
  --Start Test
  PROCESS
  BEGIN
    --initializin Memory to 0
    
  
    for addr_v IN 0 TO 4095 LOOP
        addr1 <= BIT_VECTOR(TO_UNSIGNED(addr_v, 12));
        addr2 <= addr_v;
        data_to_memory1 <= BIT_VECTOR(TO_UNSIGNED(addr_v, 12));
        data_to_memory2 <= addr_v;
        w_en <=true; wait for 1 ns;  
        w_en <=false; wait for 1 ns;
        
        IF TO_INTEGER(UNSIGNED(dataFromMem1)) /= DataFromMem2 THEN
            report "Error at Address: " & INTEGER'image(addr_v);
        END IF;
    end loop; 
  END PROCESS;  
            
            
end Behavorial;


configuration Behavorial_TESTCONF of 
    TB -- Top Level Entity
is
for Behavorial -- Architecture of TLE

    for -- Instantiated Component
        UUT1: mem_12d -- Bound Entity
            use -- Bound ENtity
                entity WORK.mem_12d
                --Bound Arch
                ( Behavorial );
     end for;

    for -- Instantiated Component
        UUT2: mem_int  -- Bound Entity
            use -- Bound ENtity
                entity WORK.mem_12d
                --Bound Arch
                ( Behavorial );
     end for;
     
     
     
end for;
end Behavorial_TESTCONF;