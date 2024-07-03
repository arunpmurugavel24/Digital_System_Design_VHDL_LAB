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
    signal ALU_condition_debug : bit; -- debug
begin 
    process(f, a, b)
        variable funct3         : bit_vector(2 downto 0);  -- 2:0 of f
        variable ALU_case       : bit_vector(1 downto 0);  -- 4:3 of f
        variable f2             : bit_vector(4 downto 0) := "00000";  -- debug
        variable a2             : bit_vector(31 downto 0) := "00000000000000000000000000000000";  -- debug
        variable b2             : bit_vector (31 downto 0) := "00000000000000000000000000000001";  -- debug
        variable cmp_flag       : bit;  -- 0 or 1 
        variable tmp_result     : bit_vector(31 downto 0);
        variable compare_or     : bit;  -- checks another variable bit by bit, if any bit is 1, then 
    begin
      
--        ALU_case := f(4 downto 3); -- 4:3 of f 
--        funct3 := f(2 downto 0);  -- 2:0 of f
        ALU_case := f2(4 downto 3);  -- debug
        funct3 := f2(2 downto 0);  -- debug
        compare_or := '0';
        
        case ALU_case is
        
            -- Cmp --
            when "00" =>
                report("helo");
            
                -- SLT/SLTI --
                if funct3 = "010" then
                    report("sup");
                    
                -- SLTU/SLTIU --
                elsif funct3 = "011" then
                    report("sup");
            
                -- BEQ/BNE --
                elsif funct3 = "000" or funct3 = "001" then
                    tmp_result := a XOR b;
--                    tmp_result := a2 XOR b2;  -- debug
                    
                    for i in tmp_result'range loop
                        compare_or := compare_or OR tmp_result(i);
                    end loop;
                        
                        if compare_or = '0' then 
                            ALU_condition <= '1';  -- BEQ (branch if equal)
--                            ALU_condition_debug <= '1';  -- debug
                        else
                            ALU_condition <= '0';  -- BNE (branch not equal)
--                            ALU_condition_debug <= '0';  -- debug
                        end if;
                        
--                        report("HEEEEEELO: compare_or: " & bit'IMAGE(compare_or) & "; ALU_condition: " & bit'IMAGE(ALU_condition_debug));  -- debug
                    
                -- BLT --
                elsif funct3 = "100" then
                    
                -- BGE -- 
                elsif funct3 = "101" then 
                
                -- BLTU --
                elsif funct3 = "110" then
                
                -- BGEU --
                elsif funct3 = "111" then
                
                -- others --
                end if;
                
            
            
            -- Logic -- 
            when "01" =>
                report("helo2");
                
                case funct3 is
                    -- XOR/XORI --
                    when "100" =>
                    
                    -- OR/ORI --
                    when "110" =>
                    
                    -- AND/ANDI --
                    when "111" =>
                    
                    -- others --
                    when others =>
                    
                end case;
            
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
