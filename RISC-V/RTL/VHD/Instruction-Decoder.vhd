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
use work.cpu_defs_pack.all;


entity Instruction_Decoder is
    Port (Inst : in bit_vector(31 downto 0);            --stable Instruction from reg
          rd_adress, rs1_adress, rs2_adress : out bit_vector(4 downto 0);--Register Addresses
          rd3 : out bit_vector(31 downto 0);            --Data that is sent to Dmem
          rs1_data, rs2_data : in bit_vector(31 downto 0);
          PC : in bit_vector(15 downto 0);              --depending on used Mem PC size will go
          PC_imm : out bit_vector(12 downto 0);         --the Branch imm is +-4KB(2^13), LSB is 0
          --flags : in bit_vector(no idea);             --Flags for jump, and FSM- for what to enable
          next_state_flag : in bit;
          jmp_flag : out bit;                           --tells the controller that the mux for jmps need to be set
          store_flag : out bit;                         --tells controller for mem store access
          load_flag : out bit;                          --tells controller for mem load access
          mem_flag : out bit_vector(2 downto 0);        --Tells the memory what it works with (byte000, halfword 001, word 010,byte unsigend 100, Halfword unsigned 101) Keeps with func3 conventions 
          f : out bit_vector(4 downto 0);               --what ADC should do and which input of mux it uses. f(4 downto 3) is Mux, f(2 downto 0) is func3
          a, b : out bit_vector(31 downto 0);           --Inputs for ADC
          res : in bit
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
    
    process(Inst, res, PC, rs1_data, rs2_data, imm, rs2, rs1, func3, rd, opcode, next_state_flag) --Needs all Inputs, otherwise it wont work  sad smiley(T_T)
    begin
    --if clk = '1' AND clk'event then                                       --NOT CLK AS THERE IS NO GREY IN INSTRUCTION DECODER

        -- RESET FLAGS
        if res = '1' then --sets Flags back after half a clockzykle
            --all Flags to 0
            jmp_flag <= '0';
            mem_flag <= b"000";
            load_flag <= '0';
            store_flag <= '0';
            --all adress pointers to 
            rd_adress <= b"0_0000";
            rs1_adress <= b"0_0000";
            rs2_adress <= b"0_0000";

        end if;
        
                
        --Depending on Instruction Typ, different things need to be done
         case opcode is
            when b"0010011" =>
                --Instruction is I type. rs2 and Imm get put together. (Slli in it)
                --get Register inputs
                rs1_adress <= rs1;
                rs2_adress <= b"00_000";
                rd_adress <=  rd;
                a <= rs1_data;
                --Imm ist imm & rs2 and then sign extended
                for i in 31 downto 12 LOOP
                    b(i) <= imm(6);
                end LOOP;
                b(11 downto 0) <= imm & rs2;
                    
                --set f function 
                case func3 is
                    when "000" =>
                        --addi
                        f <= "01" & func3;
                    when "001"=>
                        --slli
                        f<= "11" & func3;
                    when "010"=>
                        --slti
                        f <= "00" & func3;
                    when "011"=>
                        --sltiu
                        f <= "00" & func3;
                    when "100"=>
                        --xori
                        f <= "10" & func3;
                    when "101"=>
                        --srli is 101. srai is "111
                        if imm = b"000_0000" then
                            f <= "11" & func3;
                        else 
                            f <= "11" & "111"; --decided to make sra 111
                        end if;
                    when "110"=>
                        --ori
                        f <= "10" & "111";    
                    when "111"=>
                        --andi
                        f <= "10" & "111";
                    end case;
---------------------                
            when b"0110011" =>
                --Instruction is R-Type add, etc. Need to look at func7 on how to handle rs2
                --get Register inputs
                rs1_adress <= rs1;
                rs2_adress <= rs2;
                rd_adress <=  rd;
                a <= rs1_data;
                b <= rs2_data;
                    
                --set f function and b if needed
                case func3 is
                    when "000" =>
                        --add, sub
                        f <= "01" & func3;
                        --sub wanted, need to invert b and add 1
                        if imm = b"010_0000" then
                            b <= bit_vector(unsigned(not(rs2_data)) + 1);
                        end if;
                    when "001"=>
                        --shift left
                        f <= "11" & func3;
                    when "010"=>
                        --slt (set lower than)
                        f <= "00" & func3;
                    when "011"=>
                        --sltu
                        f <= "00" & func3;
                    when "100"=>
                        --xor
                        --adnere Imm länge. drüber schauen, extenden, absenden
                        f <= "10" & func3;
                    when "101"=>
                        --srl, sra is "111
                        if imm = b"000_0000" then
                            f <= "11" & func3;
                        else 
                            f <= "11" & "111"; --decided to make sra 111
                        end if;
                    when "110"=>
                        --or
                        --adnere Imm länge. drüber schauen, extenden, absenden
                        f <= "10" & "111";    
                    when "111"=>
                        --and
                        --adnere Imm länge. drüber schauen, extenden, absenden
                        f <= "10" & "111";
                    end case;
---------------------
            when b"0100011" =>
                --Instruction is S-Type. Store type
                --i only calculate adress (rs1+imm) send the data from rs2 to tmp and tell Dmem if word, halfword or byte
                report"In Store Handeling";
                rs1_adress <= rs1;
                rs2_adress <= rs2;
                rd_adress <=  rd;
                a <= rs1_data;
                rd3 <= rs2_data;        --the data Pipeline to Mem
                --signextended imm
                for i in 31 downto 12 LOOP
                    b(i) <= imm(6);
                end LOOP;
                b(11 downto 0) <= imm & rd;
                f <= "01000";           --add, calculates the adress
                mem_flag <= func3;
                store_flag <= '1';       -- tells controller that mem-state is needed with wr-Mem
                --next state should be EX and then Mem;
---------------------
            when b"1100011" =>
                --Instruction is B-Type. Branch
                --we need to compare and then jump the immediatly
                f <= "00" & func3;
                --get data from Reg
                rs1_adress <= rs1;
                rs2_adress <= rs2;
                
                --Send data to Alu to be comp
                a <= rs1_data;
                b <= rs2_data;
                
                -- splice Imm to fit PC_imm
                PC_imm(12) <= imm(6);
                PC_imm(11) <= rd(0);
                PC_imm(10 downto 5) <= imm(5 downto 0);
                PC_imm(4 downto 1) <= rd(4 downto 1);
                --surprisingly no flag. just normal increment, Mux input gets set by ALU
               
---------------------                
            when b"0000011" =>
                --Instruction is I-Type Load
                --i only calculate adress (rs1+imm), tell Dmem if word, halfword or byte and save data
                rs1_adress <= rs1;
                rd_adress <=  rd;
                a <= rs1_data;
                --signextended imm
                for i in 31 downto 12 LOOP
                    b(i) <= imm(6);
                end LOOP;
                b(11 downto 0) <= imm & rs2;
                f <= "01000";           --add, calculates the adress
                mem_flag <= func3;
                load_flag <= '1';       -- tells controller that mem-state is needed with rd-Mem
                --next state should be EX and then Mem;
---------------------                
            when b"0110111" =>
                --LUI
                --takes imm and places it in MSB
                a(31 downto 12) <= Imm & rs2 & rs1 & func3;
                a(11 downto 0) <= x"000";
                rs2_adress <= b"0_0000";  --Register 0
                b <= rs2_data;
                f <= "01000"; --add
                rd_Adress <= rd;
                --next state save the Alu result to rd

---------------------             
            when b"0010111" =>
                --AUIPC
                --get PC, add imm, save to rd
                a(31 downto 12) <= Imm & rs2 & rs1 & func3;
                a(11 downto 0) <= x"000";
                rs2_adress <= b"0_0000";  --Register 0
                b(15 downto 0) <= PC;
                b(31 downto 16) <= x"0000";
                f <= "01000"; --add
                rd_Adress <= rd;
                --next state save the Alu result to rd
---------------------                
            when b"1101111" =>
                --Jal, some special flags are needed
                --bigger imm then jalr, need to tell controller that jmp is happening
                --PC + imm
                a(31 downto 16) <= x"0000";
                a(15 downto 0) <= PC;
                --confusing imm splitting
                for i in 31 downto 20 LOOP
                    b(i) <= imm(6);     --sign extended
                end LOOP;
                b(19 downto 12) <= rs1 & func3;
                b(11) <= rs2(0);
                b(10 downto 1) <= imm(5 downto 0) & rs2(4 downto 1);
                f <= "01000";           --add
                rd_adress <= rd;        --set adress for PC-saving
                jmp_flag <= '1';        --controller needs to set mux for saving the next PC 
---------------------               
            when b"1100111" =>
                --Jalr, some special Flags are needed
                --set A to rs1 and B to imm(add). wait for EX-State. get new PC, and save to rd(Reg)
                f <= "01" & func3; --has same func3 as add
                rs1_adress <= rs1;
                rd_adress <= rd;
                a <= rs1_data;
                for i in 31 downto 12 LOOP
                    b(i) <= imm(6);
                end LOOP;
                b(11 downto 0) <= imm & rs2;
                --set Flag for controller to set Mux for Reg
                jmp_Flag <= '1';
---------------------                
            when others =>
                --Error
                report "Error Instruction-Decoding at Op-code Case" severity error;
        end case;
    --end if;
    end process;
end Behavioral;
