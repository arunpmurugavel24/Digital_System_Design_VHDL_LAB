----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2024 19:41:54
-- Design Name: 
-- Module Name: Pc_Ctrl - Behavioral
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
use IEEE.NUMERIC_bit.ALL;


entity Pc_Ctrl is
    Port (enab_w, clk, res : in bit; --enables
            imm : in bit_vector(15 downto 0); --Address for a jump Instruction
            PC : out bit_vector(15 downto 0);    --Needs to be looked at if Adress room is big enough
            Alu_condition : in bit;              --Chosses if Pc is incremented by 1 or imm
            jmp_condition : in bit;               --If Jump Instructions is used, we need to use the Alu address
            Alu_adress : in bit_vector(31 downto 0) 
            );
end Pc_Ctrl;

architecture Behavioral of Pc_Ctrl is
    signal count : unsigned(15 downto 0);   --the Intern PC, unsigned, because ther are no negativ adresses
begin
    --Always true
    PC <= bit_vector(count);
    process(clk, res)
    begin
        if res = '1' then
            --Res counter
            count <= x"0000";
        --When no jmp Instruction    
        --elsif enab_w then         --Uncomment if not every clk cycle it should increment
        elsif clk = '1' AND clk'event AND jmp_condition = '0' then
            --Increment count by 4 8Bit-Addressesor imm
            case Alu_condition is
            when '0' =>
                --increment normaly
                count <= count + 4;
            when '1' =>
                --increment by imm
                count <= count + TO_INTEGER(signed(imm)); --needs to be signed, because imm could be negativ  
            end case;
        
        --jmp Instruction case
        elsif clk = '1' AND clk'event AND jmp_Condition = '1' then 
            --set count to new Address
            count <= unsigned((Alu_adress(15 downto 1) & b"0")); --sets LSB to 0
        end if;
    end process;
end Behavioral;
