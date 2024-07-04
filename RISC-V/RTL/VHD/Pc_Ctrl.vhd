----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Tiemo Schmidt
-- 
-- Create Date: 04.07.2024 10:52:56
-- Module Name: pc_Ctrl - Behavioral
-- Project Name: RiscV Structural Model
--
-- Description: PC_ctrl. is responsible for Incrementing the PC with either 4 or the imm 
--      send by the Instruction decoder. It can also save the Adress calculated in the ALU
--      as the new PC.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_bit.ALL;
use work.cpu_defs_pack.all;


entity Pc_Ctrl is
    Port (enab_w, clk, res : in bit; --enables
            imm : in bit_vector(12 downto 0);    --Address for a jump Instruction
            PC : out bit_vector(15 downto 0);    --Needs to be looked at if Adress room is big enough
            Alu_condition : in bit;              --Chosses if Pc is incremented by 1 or imm
            jmp_condition : in bit;              --If Jump Instructions is used, we need to use the Alu address
            Alu_adress : in bit_vector(31 downto 0) 
            );
end Pc_Ctrl;

architecture Behavioral of Pc_Ctrl is
    signal count : unsigned(15 downto 0);   --the Intern PC, unsigned, because there are no negativ adresses
begin
    --Always true
    PC <= bit_vector(count);
    process(clk, res)
    begin
        if res = '1' then
            --Res counter
            count <= x"0000";
        --When no jmp Instruction    
        --if we are in EX then pc should increment, enab_w = 1;
        else
            if clk = '1' AND Clk'event then
                if enab_w = '1' AND jmp_condition = '0' then
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
                elsif enab_w = '1' AND jmp_Condition = '1' then 
                    --set count to new Address
                    count <= unsigned(bit_vector'(Alu_adress(15 downto 1) & b"0")); --sets LSB to 0
                else
                    report"ERROR";
                end if;
            end if;
        end if;
    end process;
end Behavioral;
