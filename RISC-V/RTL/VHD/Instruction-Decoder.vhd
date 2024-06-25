----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.06.2024 17:34:11
-- Design Name: 
-- Module Name: Instruction-Decoder - Behavioral
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


entity Instruction_Decoder is
    Port (Inst : in bit_vector(31 downto 0);         --stable Instruction from reg
          rd_out, rs1_out, rs2_out : out bit_vector(31 downto 0);--Register Addresses
          rd_data, rs1_data, rs2_data : in bit_vector(31 downto 0);
          flags : in bit_vector(no idea);           --Flags for jump, and FSM- for what to enable
          f : out bit_vector(2 downto 0);           --what ADC should do
          a, b : out bit_vector(31 downto 0);        --Inputs for ADC
          clk, res : in bit
     );
end Instruction_Decoder;

architecture Behavioral of Instruction_Decoder is
    signal imm : bit_vector(6 downto 0);    --Inst-Bit 31 downto 25
    signal rs2 : bit_vector(4 downto 0);    --Inst-Bit 24 downto 20
    signal rs1 : bit_vector(4 downto 0);    --Inst-Bit 19 downto 15
    signal func3 : bit_vector (2 downto 0); --Inst-Bit 14 downto 12
    signal rd : bit_vector( 4 downto 0);    --Inst-Bit 11 downto 7
    signal opcode : bit_vector(6 downto 0); --Inst-Bit 6 downto 0
    
    begin
    --Decode outside of Process
    imm <= inst(31 downto 25);
    rs2 <= inst(24 downto 20);
    rs1 <= inst(19 downto 15);
    func3 <= inst(14 downto 12);
    rd <= inst(11 downto 7);
    opcode <= inst(6 downto 0);
    
    process(clk) --I think we have a clk
    begin
    if clk = '1' AND clk'event then
--isnt needed and slowes everything down i think        
--        --Reset everything for new Inst
--        a <= b"0000_0000_0000_0000_0000_0000_0000_0000";
--        b <= b"0000_0000_0000_0000_0000_0000_0000_0000";
--        f <= b"000";
--        --Reset addresses to Register 0
--        rs1_out <= b"0000_0000_0000_0000_0000_0000_0000_0000";
--        rs2_out <= b"0000_0000_0000_0000_0000_0000_0000_0000";
--        rd_out <= b"0000_0000_0000_0000_0000_0000_0000_0000";
        
        --Depending on Instruction Typ, different things need to be done
         case opcode is
            when b"0010011" =>
                --Instruction is I type. rs2 and Imm get put together. (Slli in it)
                rs1_out <= rs1;
                rs2_out <= b"0_0000";
                rd_out <=  rd;
                f <= func3;
                a <= rs1_data;
                b <= imm & rs2;
                --Maybe set some flags
                
            when b"0110011" =>
                --Instruction is R-Type add, etc. Need to look at func7 on how to handle rs2
                if imm = b"000_0000" then
                    --normal operation
                    rs1_out <= rs1;
                    rs2_out <= rs2;
                    rd_out <=  rd;
                    f <= func3;
                    a <= rs1_data;
                    b <= rs2_data;
                elsif imm = b"010_0000" then
                    --either its arithmetic Shift or sub
                    rs1_out <= rs1;
                    rs2_out <= rs2;
                    rd_out <=  rd;
                    f <= func3;
                    --now we need to look at func 3 to see if we sub or Arithmetic shift
                    case func3 is
                        when "000" =>
                            --sub, we need to invert rs2 and add 1
                            a <= rs1_data;
                            b <= bit_vector(unsigned(not(rs2_data)) + 1);
                        when "101"=>
                            --Arithmetic shift Right. not sure what i need to do.
                        when others => 
                            --Throw Error
                            report "Error R-Type decoding" severity error;
                     end case;
                end if;
            when b"0100011" =>
                --Instruction is S-Type. Store type
            when b"1100011" =>
                --Instruction is B-Type. Branch
            when b"0000011" =>
                --Instruction is I-Type Load
            when b"0110111" =>
                --LUI
            when b"0010111" =>
                --AUIPC
            when b"1101111" =>
                --Jal, some special flags are needed
            when b"1100111" =>
                --Jalr, some special Flags are needed
            when others =>
                --Error
                report "Error Instruction-Decoding at Op-code Case" severity error;
        end case;
    end if;
    end process;
end Behavioral;
