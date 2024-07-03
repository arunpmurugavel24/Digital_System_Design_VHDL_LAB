----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.06.2024 14:08:45
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.numeric_bit.ALL;
use WORK.conversion_pack.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    port (
        f               : in bit_vector(4 downto 0);  -- 4:3 selects type of ALU (cmp/logic/add/shift); 2:0 is funct3
        a               : in bit_vector(31 downto 0);  
        b               : in bit_vector(31 downto 0);
        outToDMem       : out bit_vector(31 downto 0);
        ALU_condition   : out bit
    );
end ALU;

architecture Behavioral of ALU is
    signal ALU_condition_result : bit; -- debug
--    signal a2 : bit_vector(31 downto 0);
--    signal b2 : bit_vector(31 downto 0);
    
begin 
    ALU_condition <= ALU_condition_result;
    process (f, a, b)
        variable funct3         : bit_vector(2 downto 0);  -- 2:0 of f
        variable ALU_case       : bit_vector(1 downto 0);  -- 4:3 of f
--        variable f2             : bit_vector(4 downto 0) := "00010";  -- debug
--        variable a2             : bit_vector(31 downto 0) := "00000000000000000000000000000000";  -- debug
--        variable b2             : bit_vector (31 downto 0) := "10000000000000000000000000000000";  -- debug
        variable cmp_flag       : bit;  -- 0 or 1 
        variable tmp_result     : bit_vector(31 downto 0);
        variable compare_or     : bit;  -- checks another variable bit by bit, if any bit is 1, then 
    
        
    begin
      
        ALU_case := f(4 downto 3); -- 4:3 of f 
        funct3 := f(2 downto 0);  -- 2:0 of f
--        ALU_case := f2(4 downto 3);  -- debug
--        funct3 := f2(2 downto 0);  -- debug
        compare_or := '0';
        ALU_condition_result <= '0';
        
        case ALU_case is
        
            -- Cmp --
            -- Only Branch operations utilise variable 'ALU_condition' 
            when "00" =>
             
                -- SLT/SLTI --
                if funct3 = "010" then
                    if signed(a) < signed(b) then  -- this is synthesisable, and other similar if-cases
                        outToDMem <= x"00_00_00_01";
                    else
                        outToDMem <= x"00_00_00_00";
                    end if;
                    
                -- SLTU/SLTIU --
                elsif funct3 = "011" then
                    if unsigned(a) < unsigned(b) then
                        outToDMem <= x"00_00_00_01";
                    else
                        outToDMem <= x"00_00_00_00";
                    end if;
                    
                -- BEQ --
                elsif funct3 = "000" then
                    tmp_result := a XOR b;
--                    tmp_result := a2 XOR b2;  -- debug
                    
                    for i in tmp_result'range loop
                        compare_or := compare_or OR tmp_result(i);
                    end loop;
                        
                        if compare_or = '0' then 
                            ALU_condition_result <= '1';  -- BEQ (branch if equal)
                            outToDMem <= x"00_00_00_01";
--                            report("HEEEEEELO: compare_or: " & bit'IMAGE(compare_or) & "; ALU_condition: " & bitToString(ALU_condition_result));  -- debug
                        else
                            ALU_condition_result <= '0';  
                            outToDMem <= x"00_00_00_00";
--                            report("HEEEEEELO: compare_or: " & bit'IMAGE(compare_or) & "; ALU_condition: " & bitToString(ALU_condition_result));  -- debug
                        end if;
                        
                -- BNE --
                elsif funct3 = "001" then
                    tmp_result := a XOR b;
                    for i in tmp_result'range loop
                        compare_or := compare_or OR tmp_result(i);
                    end loop;
                        
                        if compare_or = '1' then
                            ALU_condition_result <= '1';
                            outToDMem <= x"00_00_00_01";
                        else 
                            ALU_condition_result <= '0';
                            outToDMem <= x"00_00_00_00";
                        end if;
                        
                -- BLT --
                elsif funct3 = "100" then
                    if signed(a) < signed (b) then
                        ALU_condition_result <= '1';
                        outToDMem <= x"00_00_00_01";
                    else
                        ALU_condition_result <= '0';
                        outToDMem <= x"00_00_00_00";
                    end if;
                    
                -- BGE -- 
                elsif funct3 = "101" then 
                    if signed(a) >= signed (b) then
                        ALU_condition_result <= '1';
                        outToDMem <= x"00_00_00_01";
                    else 
                        ALU_condition_result <= '0';
                        outToDMem <= x"00_00_00_00";
                    end if;
                    
                -- BLTU --
                elsif funct3 = "110" then
                    if unsigned(a) < unsigned (b) then
                        ALU_condition_result <= '1';
                        outToDMem <= x"00_00_00_01";
                    else 
                        ALU_condition_result <= '0';
                        outToDMem <= x"00_00_00_00";
                    end if;
                
                -- BGEU --
                elsif funct3 = "111" then
                    if signed(a) >= signed (b) then
                        ALU_condition_result <= '1';
                        outToDMem <= x"00_00_00_01";
                    else 
                        ALU_condition_result <= '0';
                        outToDMem <= x"00_00_00_00";
                    end if;
                end if;
            
            -- Logic -- 
            when "01" =>                
                
                -- XOR/XORI --
                if funct3 = "100" then
                    outToDMem <= a XOR b;
                    
                -- OR/ORI --
                elsif funct3 = "110" then
                    outToDMem <= a OR b;
                
                -- AND/ANDI --
                elsif funct3 = "111" then
                    outToDMem <= a AND b;
                    
                end if;
            
            -- Add --    
            when "10" => 
                report("helo3");
                
                case funct3 is 
                    -- ADD/ADDI/SUB --
                    when "000" =>
                    
                    -- others --
                    when others =>
                    
                end case;
                
            -- Shift --
            when "11" =>
                report("helo4");
                
                case funct3 is 
                    -- SLL/SLLI --
                    when "001" =>
                    
                    -- SRL/SRLI/SRA/SRAI --
                    when "101" =>
                    
                    -- others --
                    when others =>
                    
                end case;
            
            -- others --    
            when others =>
                report("NO!");
            
        end case;
    end process;
end Behavioral;
