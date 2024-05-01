----------------------------------------------------------------------------------
-- Company: Technical University of Munich
-- Engineer: Hian Zing Voon
-- 
-- Create Date: 01.05.2024 21:58:10
-- Design Name: TLE (Top Level Entity)
-- Module Name: TLE - Behavioral
-- Project Name: Memory Model LAB
-- Target Devices: 
-- Tool Versions: 
-- Description: It is a top level entity that instantiates and connects the testbench, and two other Unit Under Test (UUT).
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;


entity TLE is  -- Top Level Entity (TLE)
-- Port is empty, as there are no inputs into TLE and no outputs from TLE
end TLE;


architecture TLE_Behavioral of TLE is -- architecture of TLE

-- Component uses Entities which are declared either in TB, UUT1 or UUT2
component mem_12d is
port(
    w_en    : in boolean;
    addr    : in bit_vector( 11 downto 0 );
    data_in : in bit_vector( 11 downto 0 );
    data_out: out bit_vector( 11 downto 0 )
); 
end component;

component mem_int
port(
     w_en    : in  boolean;
     addr    : in  integer range 4095 downto 0;
     data_in : in  integer range 4095 downto 0;
     data_out: out integer range 4095 downto 0
); 
end component;

component TB
port( 
        w_en : out boolean;
        addr_1dim : out integer range 4095 downto 0;
        addr_12dim : out bit_vector(11 downto 0);
        data_to_1dim : out integer range 4095 downto 0;
        data_to_12dim : out bit_vector(11 downto 0);
        data_from_1dim : in integer range 4095 downto 0;
        data_from_12dim : in bit_vector(11 downto 0)
);
end component;

-- Signals are internal inputs & outputs within the TLE
signal w_en: boolean := false;
signal dataToMem1, addr_12dim, dataFromMem1 : bit_vector(11 downto 0);
signal dataToMem2, addr_1dim, dataFromMem2 : integer range 4095 downto 0;

begin -- Body of architecture 

UUT1: mem_12d -- Instantiated Component
port map(
    w_en => w_en,
    addr => addr_12dim,
    data_in => datatoMem1,
    data_out => dataFromMem1
);

UUT2: mem_int -- Instantiated Component
port map(
    w_en => w_en,
    addr => addr_1dim,
    data_in => datatoMem2,
    data_out => dataFromMem2
);

TB_inst: TB -- Instantiated Component
port map(
    w_en => w_en,
    addr_12dim => addr_12dim,
    addr_1dim => addr_1dim,
    data_to_12dim => dataToMem1,
    data_to_1dim => dataToMem2,
    data_from_1dim => dataFromMem2,
    data_from_12dim => dataFromMem1
);

end TLE_Behavioral;


configuration TLE_CONF of TLE is -- Configuration of Entity: Top Level Entity 

for TLE_Behavioral -- Architecture of TLE
   
    for TB_inst: TB -- Instantiated Component
        use entity work.TB(Behavorial);
    end for;
    
    for UUT1: mem_12d -- Instantiated Component
        use entity work.mem_12d(Behavioral);
    end for;
        
    for UUT2: mem_int -- Instantiated Component
        use entity work.mem_int(Behavioral);
    end for;  
  
end for;

end TLE_CONF;
