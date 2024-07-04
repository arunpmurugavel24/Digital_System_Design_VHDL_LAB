----------------------------------------------------------------------------------
-- University: Technical University of Munich
-- Student: Hian Zing Voon, Yu-Hung Tsai
-- 
-- Create Date: 28.06.2024 14:08:45
-- Design Name: ALU
-- Module Name: ALU - Behavioral
-- Project Name: ALU
-- Description: Arithmetic logic unit (ALU) takes input to execute arithmetic and logical operations like ADD, SUB and BLT.
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

---------------------            
--MADE BY HIAN ZING VOON            
---------------------
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
    signal ALU_condition_result : bit;  -- temporarily holds the value of ALU_condition
    
begin 
    ALU_condition <= ALU_condition_result;  -- takes the value of ALU_condition_result and sets it as output whenever it changes
    process (f, a, b)
        variable funct3         : bit_vector(2 downto 0);  -- 2:0 of f
        variable ALU_case       : bit_vector(1 downto 0);  -- 4:3 of f
--        variable f2             : bit_vector(4 downto 0) := "00010";  -- debug
--        variable a2             : bit_vector(31 downto 0) := "00000000000000000000000000000000";  -- debug
--        variable b2             : bit_vector (31 downto 0) := "10000000000000000000000000000000";  -- debug
        variable tmp_result_1   : bit_vector(31 downto 0);  -- temporary result for BEQ, BNE and barrel shifter
        variable tmp_result_2   : bit_vector(31 downto 0);  -- temporary result for barrel shifter
        variable tmp_result_3   : bit_vector(31 downto 0);  -- temporary result for barrel shifter
        variable tmp_result_4   : bit_vector(31 downto 0);  -- temporary result for barrel shifter
        variable tmp_a          : bit_vector(31 downto 0);  -- temporary result for barrel shifter
        variable tmp_MSB        : bit;  -- temporary single bit result for barrel shifter, the most significant bit (MSB)
        variable compare_or     : bit;  -- checks another variable bit by bit, if any bit is 1, then 
        variable a_and_b        : bit_vector(31 downto 0);  -- for add/addi/sub operations
        variable a_xor_b        : bit_vector(31 downto 0);  -- for add/addi/sub operations
        variable abc            : bit_vector(31 downto 0);   -- for add/addi/sub operations
        variable c              : bit_vector(32 downto 0);  -- for add/addi/sub operations
        variable shift_amt      : bit_vector(4 downto 0);  -- shift amount
        
    begin
    
        ALU_case := f(4 downto 3); -- 4:3 of f 
        funct3 := f(2 downto 0);  -- 2:0 of f
--        ALU_case := f2(4 downto 3);  -- debug
--        funct3 := f2(2 downto 0);  -- debug
        compare_or := '0';
        ALU_condition_result <= '0';
        
        case ALU_case is

---------------------            
--MADE BY HIAN ZING VOON            
---------------------    
            -- Cmp --
            -- Only Branch operations utilise variable 'ALU_condition' 
            when "00" =>
                case funct3 is
                    
                    -- SLT/SLTI --
                    when "010" =>
                        if signed(a) < signed(b) then  -- this is synthesisable, and other similar if-cases
                            outToDMem <= x"00_00_00_01";
                        else
                            outToDMem <= x"00_00_00_00";
                        end if;
                        
                    -- SLTU/SLTIU --
                    when "011" =>
                        if unsigned(a) < unsigned(b) then
                            outToDMem <= x"00_00_00_01";
                        else
                            outToDMem <= x"00_00_00_00";
                        end if;
                        
                    -- BEQ --
                    when "000" =>
                        tmp_result_1 := a XOR b;
    --                    tmp_result := a2 XOR b2;  -- debug
                        
                        for i in tmp_result_1'range loop
                            compare_or := compare_or OR tmp_result_1(i);
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
                    when "001" =>
                        tmp_result_1 := a XOR b;
                        for i in tmp_result_1'range loop
                            compare_or := compare_or OR tmp_result_1(i);
                        end loop;
                            
                            if compare_or = '1' then
                                ALU_condition_result <= '1';
                                outToDMem <= x"00_00_00_01";
                            else 
                                ALU_condition_result <= '0';
                                outToDMem <= x"00_00_00_00";
                            end if;
                            
                    -- BLT --
                    when "100" =>
                        if signed(a) < signed (b) then
                            ALU_condition_result <= '1';
                            outToDMem <= x"00_00_00_01";
                        else
                            ALU_condition_result <= '0';
                            outToDMem <= x"00_00_00_00";
                        end if;
                        
                    -- BGE -- 
                    when "101" =>
                        if signed(a) >= signed (b) then
                            ALU_condition_result <= '1';
                            outToDMem <= x"00_00_00_01";
                        else 
                            ALU_condition_result <= '0';
                            outToDMem <= x"00_00_00_00";
                        end if;
                        
                    -- BLTU --
                    when "110" =>
                        if unsigned(a) < unsigned (b) then
                            ALU_condition_result <= '1';
                            outToDMem <= x"00_00_00_01";
                        else 
                            ALU_condition_result <= '0';
                            outToDMem <= x"00_00_00_00";
                        end if;
                    
                    -- BGEU --
                    when "111" =>
                        if unsigned(a) >= unsigned (b) then
                            ALU_condition_result <= '1';
                            outToDMem <= x"00_00_00_01";
                        else 
                            ALU_condition_result <= '0';
                            outToDMem <= x"00_00_00_00";
                        end if;
                    
                    -- others --
                    when others =>
                        report("Error at Cmp!");
                end case;
                
---------------------            
--MADE BY HIAN ZING VOON            
---------------------                
            -- Logic -- 
            when "01" =>                
                case funct3 is
                
                    -- XOR/XORI --
                    when "100" =>
                        outToDMem <= a XOR b;
                        
                    -- OR/ORI --
                    when "110" =>
                        outToDMem <= a OR b;
                    
                    -- AND/ANDI --
                    when "111" =>
                        outToDMem <= a AND b;
                    
                    -- others --
                    when others =>
                        report("Error at Logic!");
                    
                end case;
                
---------------------            
--MADE BY Yu-Hung Tsai           
---------------------      
            -- Add --    
            when "10" =>
                case funct3 is 
                    
                    -- ADD/ADDI/SUB --
                    when "000" =>
                    
                        for i in 0 to 31 loop
                            a_and_b(i) := a(i) and b(i);
                            a_xor_b(i) := a(i) xor b(i);
                            abc(i) := c(i) and a_xor_b(i);
                            outToDMem(i) <= c(i) xor a_xor_b(i);
                            c(i+1) := a_and_b(i) or abc(i);
                        end loop;

                    -- others --
                    when others =>
                        report("Error at Add!");
                        
                end case;

---------------------            
--MADE BY HIAN ZING VOON            
--------------------- 
            -- Shift -- (with the idea of a barrel shifter)
            when "11" =>
                tmp_result_1    := x"00_00_00_00";
                tmp_result_2    := x"00_00_00_00";
                tmp_result_3    := x"00_00_00_00";
                tmp_result_4    := x"00_00_00_00";
                shift_amt       := "00000";  -- default value
                shift_amt       := b(4 downto 0);
                case funct3 is 
                    
                    -- SLL/SLLI --
                    when "001" =>
                        
                        -- Stage 1: Shift by 1 bit --
                        if shift_amt(0) = '1' then
                            tmp_result_1 := a(30 downto 0) & '0';
                        else 
                            tmp_result_1 := a;
                        end if;
                        
                        -- Stage 2: Shift by 2 bits --
                        if shift_amt(1) = '1' then
                            tmp_result_2 := a(29 downto 0) & "00";
                        else
                            tmp_result_2 := tmp_result_1;
                        end if;
                        
                        -- Stage 3: Shift by 4 bits --
                        if shift_amt(2) = '1' then
                            tmp_result_3 := a(27 downto 0) & "0000";
                        else
                            tmp_result_3 := tmp_result_2;
                        end if;
                        
                        -- Stage 4: Shift by 16 bits --
                        if shift_amt(3) = '1' then
                            tmp_result_4 := a(15 downto 0) & b"0000_0000_0000_0000";
                        else
                            tmp_result_4 := tmp_result_3;
                        end if;
                        
                        -- Stage 5: Shift by 32 bits --
                        if shift_amt(4) = '1' then
                            tmp_result_4 := x"00_00_00_00";
                        end if;
                        
                        outToDMem <= tmp_result_4;
                        
                    -- SRL/SRLI --
                    when "101" =>
                        tmp_a := x"00_00_00_00";
                        
                        -- Initial inverting of bits --
                        for i in 0 to 31 loop
                            tmp_a(i) := a(31-i);
                        end loop;
                                                    
                        -- Stage 1: Shift by 1 bit --
                        if shift_amt(0) = '1' then
                            tmp_result_1 := tmp_a(30 downto 0) & '0';
                        else 
                            tmp_result_1 := tmp_a;
                        end if;
                        
                        -- Stage 2: Shift by 2 bits --
                        if shift_amt(1) = '1' then
                            tmp_result_2 := tmp_a(29 downto 0) & "00";
                        else
                            tmp_result_2 := tmp_result_1;
                        end if;
                        
                        -- Stage 3: Shift by 4 bits --
                        if shift_amt(2) = '1' then
                            tmp_result_3 := tmp_a(27 downto 0) & "0000";
                        else
                            tmp_result_3 := tmp_result_2;
                        end if;
                        
                        -- Stage 4: Shift by 16 bits --
                        if shift_amt(3) = '1' then
                            tmp_result_4 := tmp_a(15 downto 0) & b"0000_0000_0000_0000";
                        else
                            tmp_result_4 := tmp_result_3;
                        end if;
                        
                        -- Stage 5: Shift by 32 bits --
                        if shift_amt(4) = '1' then
                            tmp_result_4 := x"00_00_00_00";
                        end if;
                        
                        -- Final inverting of bits --
                        for i in 0 to 31 loop
                            tmp_a(i) := tmp_result_4(31-i);
                        end loop;
                        
                        outToDMem <= tmp_a; 
                        
                    -- SRA/SRAI --
                    when "111" =>
                        tmp_a := x"00_00_00_00";
                        tmp_MSB := a(31);
                        
                        -- Initial inverting of bits --
                        for i in 0 to 31 loop
                            tmp_a(i) := a(31-i);
                        end loop;
                                                    
                        -- Stage 1: Shift by 1 bit --
                        if shift_amt(0) = '1' then
                            if tmp_MSB = '1' then
                                tmp_result_1 := tmp_a(30 downto 0) & '1';
                            else 
                                tmp_result_1 := tmp_a(30 downto 0) & '0';
                            end if;
                        else 
                            tmp_result_1 := tmp_a;
                        end if;
                        
                        -- Stage 2: Shift by 2 bits --
                        if shift_amt(1) = '1' then
                            if tmp_MSB = '1' then
                                tmp_result_2 := tmp_a(29 downto 0) & "11";
                            else 
                                tmp_result_2 := tmp_a(29 downto 0) & "00";
                            end if;
                        else
                            tmp_result_2 := tmp_result_1;
                        end if;
                        
                        -- Stage 3: Shift by 4 bits --
                        if shift_amt(2) = '1' then
                            if tmp_MSB = '1' then
                                tmp_result_3 := tmp_a(27 downto 0) & "1111";
                            else 
                                tmp_result_3 := tmp_a(27 downto 0) & "0000";
                            end if;
                        else
                            tmp_result_3 := tmp_result_2;
                        end if;
                        
                        -- Stage 4: Shift by 16 bits --
                        if shift_amt(3) = '1' then
                            if tmp_MSB = '1' then
                                tmp_result_4 := tmp_a(15 downto 0) & b"1111_1111_1111_1111";
                            else 
                                tmp_result_4 := tmp_a(15 downto 0) & b"0000_0000_0000_0000";
                            end if;
                        else
                            tmp_result_4 := tmp_result_3;
                        end if;
                        
                        -- Stage 5: Shift by 32 bits --
                        if shift_amt(4) = '1' then
                            if tmp_MSB = '1' then
                                tmp_result_4 := x"ff_ff_ff_ff";
                            else 
                                tmp_result_4 := x"00_00_00_00";
                            end if;
                        end if;
                        
                        -- Final inverting of bits --
                        for i in 0 to 31 loop
                            tmp_a(i) := tmp_result_4(31-i);
                        end loop;
                        
                        outToDMem <= tmp_a;
                    
                    -- others --
                    when others =>
                        report("Error at Shift!");
                        
                end case;
            
            -- others --    
            when others =>
                report("Invalid funct3!");
                
        end case;
    end process;
end Behavioral;
