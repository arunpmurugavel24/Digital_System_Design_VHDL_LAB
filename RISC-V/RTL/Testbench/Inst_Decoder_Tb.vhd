----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.06.2024 00:33:31
-- Design Name: 
-- Module Name: Inst_Decoder_Tb - Behavioral
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
use work.cpu_defs_pack.all;
use IEEE.numeric_bit.all; 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Inst_Decoder_Tb is
--  Port ( );
end Inst_Decoder_Tb;

architecture Behavioral of Inst_Decoder_Tb is
    component Instruction_decoder
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
          res : in bit);
     end component;
     
     component RegisterFile
            Port (clk : in bit;
          res : in bit;
          rd1_addr : in bit_vector(4 downto 0);
          rd2_addr : in bit_vector(4 downto 0);
          wr_addr : in bit_vector(4 downto 0);
          rd1_data : out bit_vector(31 downto 0);
          rd2_data : out bit_vector(31 downto 0);
          wr_data : in bit_vector(31 downto 0);
          wr_enab : in bit);
     end component;
     
     --Signals
     signal Inst, rd_data, rs1_data, rs2_data, rd3 :  bit_vector(31 downto 0);         --stable Instruction from reg
     signal rd_adress, rs1_adress, rs2_adress :  bit_vector(4 downto 0);--Register Addresses
     signal PC :  bit_vector(MemSize downto 0);     --depending on used Mem PC size will go
     signal f :  bit_vector(4 downto 0);           --what ADC should do and which input of mux it uses. f(4 downto 3) is Mux, f(2 downto 0) is func3
     signal a, b :  bit_vector(31 downto 0);        --Inputs for ADC
     signal clk, res, wr_enab :  bit;
     signal PC_imm : bit_vector(12 downto 0);         --the Branch imm is +-4KB(2^13), LSB is 0
          --flags : in bit_vector(no idea);             --Flags for jump, and FSM- for what to enable
     signal next_state_flag : bit;
     signal jmp_flag : bit;                           --tells the controller that the mux for jmps need to be set
     signal store_flag : bit;                         --tells controller for mem store access
     signal load_flag : bit;                          --tells controller for mem load access
     signal mem_flag : bit_vector(2 downto 0);        --Tells the memory what it works with (byte000, halfword 001, word 010,byte unsigend 100, Halfword unsigned 101) Keeps with func3 conventions 
     signal imm_int : integer;
     
     --for constructin Instructions
    signal imm : bit_vector(6 downto 0);    --Inst-Bit 31 downto 25
    signal rs2 : bit_vector(4 downto 0);    --Inst-Bit 24 downto 20
    signal rs1 : bit_vector(4 downto 0);    --Inst-Bit 19 downto 15
    signal func3 : bit_vector (2 downto 0); --Inst-Bit 14 downto 12
    signal rd : bit_vector( 4 downto 0);    --Inst-Bit 11 downto 7
    signal opcode : bit_vector(6 downto 0); --Inst-Bit 6 downto 0
begin
    UUT : Instruction_decoder Port Map(Inst, Open, rs1_adress, rs2_adress, rd3, rs1_data, rs2_data, PC, PC_imm, next_state_flag, jmp_flag, store_flag, load_flag, mem_flag, f, a, b, res);
    Reg : RegisterFile PORT MAP(clk, res, rs1_adress, rs2_adress, rd_adress, rs1_data, rs2_data, rd_data, wr_enab);

    clk_pro: process
    begin
        clk <= not clk;
        wait for 2.5ns;
    end Process;
    
    stimuli : process
    begin
    --RES
        wait for 5.0ns;
        res <= '1';
        wait for 10.0ns;
        res <= '0';
        wait for 5.0ns;
    --Seed Register
    wr_enab <= '1';
        for i in 31 downto 1 LOOP
            rd_data <= bit_vector(TO_UNSIGNED(i+2, 32));
            rd_adress <= bit_vector(TO_UNSIGNED(i, 5));
            wait for 5.0ns; 
        end lOOP;
        
------------------
    --TEST IMM 
    --ADDI
        wait for 5.0ns;
        opcode <= b"001_0011";
        func3 <= b"000";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        --Loop to test different addi
        for i in 15 downto 1 LOOP
            --gets Register data
            rs1 <= bit_vector(to_unsigned(i, 5));
            --imm is imm & rs2
            --im shift imm by 5 bits and get lower 7 Bit
            imm_int <= (342+(11*i));-- * ((-1)**i);
            wait for 0ns;
            report integer'image(i) & "imm: " & integer'image(imm_int);
            if (i mod 2) = 0 then       --negates the nr every straight i
                imm_int <= to_integer((not TO_SIGNED(imm_int, 12)) + 1);
            end if;
            report integer'image(i) & "imm_inv: " & integer'image(imm_int);
            wait for 0ns; --one delta cycle
            imm <=  bit_vector(TO_unSIGNED( ((imm_int/(2**5)) mod 2**7),7));     --imm switches between + and -. Nr is shifted 5 to the right and then lower 7 bit are taken with mod
            rs2 <=  bit_vector(TO_unSIGNED( (imm_int mod (2**5)),5));            --rs2 only needs to take lower 5 bits with mod
            Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1, rd = R7, IMM = -1514
            wait for 5.0ns;
        end LOOP;
        
        --Xori
                opcode <= b"001_0011";
        func3 <= b"100";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        --Loop to test different addi
        for i in 31 downto 1 LOOP
            --gets Register data
            rs1 <= bit_vector(to_unsigned(i, 5));
            --imm is imm & rs2
            --im shift imm by 5 bits and get lower 7 Bit
            imm <=  bit_vector(TO_SIGNED( ((((342+(11*i))*((-1)**i))/(2**5)) mod (2**7)),7));     --imm switches between + and -. Nr is shifted 5 to the right and then lower 7 bit are taken with mod
            rs2 <=  bit_vector(TO_SIGNED( (((342+(11*i))*((-1)**i)) mod (2**5)),5));            --rs2 only needs to take lower 5 bits with mod
            Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1, rd = R7, IMM = -1514
            wait for 50ns;
        end LOOP;
        
        --Ori
                opcode <= b"001_0011";
        func3 <= b"110";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        --Loop to test different addi
        for i in 31 downto 1 LOOP
            --gets Register data
            rs1 <= bit_vector(to_unsigned(i, 5));
            --imm is imm & rs2
            --im shift imm by 5 bits and get lower 7 Bit
           imm <=  bit_vector(TO_SIGNED( ((((342+(11*i))*(-1)**i)/(2**5)) mod 2**7),7));     --imm switches between + and -. Nr is shifted 5 to the right and then lower 7 bit are taken with mod
            rs2 <=  bit_vector(TO_SIGNED( (((342+(11*i))*(-1)**i) mod (2**5)),5));            --rs2 only needs to take lower 5 bits with mod
            Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1, rd = R7, IMM = -1514
            wait for 5.0ns;
        end LOOP;
        
        
        --ANDI
                opcode <= b"001_0011";
        func3 <= b"111";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        --Loop to test different addi
        for i in 31 downto 1 LOOP
            --gets Register data
            rs1 <= bit_vector(to_unsigned(i, 5));
            --imm is imm & rs2
            --im shift imm by 5 bits and get lower 7 Bit
            imm <=  bit_vector(TO_SIGNED( ((((342+(11*i))*(-1)**i)/(2**5)) mod 2**7),7));     --imm switches between + and -. Nr is shifted 5 to the right and then lower 7 bit are taken with mod
            rs2 <=  bit_vector(TO_SIGNED( (((342+(11*i))*(-1)**i) mod (2**5)),5));            --rs2 only needs to take lower 5 bits with mod
            Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1, rd = R7, IMM = -1514
            wait for 5.0ns;
        end LOOP;
        
        --SLTI
                opcode <= b"001_0011";
        func3 <= b"010";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        --Loop to test different addi
        for i in 31 downto 1 LOOP
            --gets Register data
            rs1 <= bit_vector(to_unsigned(i, 5));
            --imm is imm & rs2
            --im shift imm by 5 bits and get lower 7 Bit
            imm <=  bit_vector(TO_SIGNED( ((((342+(11*i))*(-1)**i)/(2**5)) mod 2**7),7));     --imm switches between + and -. Nr is shifted 5 to the right and then lower 7 bit are taken with mod
            rs2 <=  bit_vector(TO_SIGNED( (((342+(11*i))*(-1)**i) mod (2**5)),5));            --rs2 only needs to take lower 5 bits with mod
            Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1, rd = R7, IMM = -1514
            wait for 5.0ns;
        end LOOP;
        
        --SLTIU
        opcode <= b"001_0011";
        func3 <= b"011";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        --Loop to test different addi
        for i in 31 downto 1 LOOP
            --gets Register data
            rs1 <= bit_vector(to_unsigned(i, 5));
            --imm is imm & rs2
            --im shift imm by 5 bits and get lower 7 Bit
            imm <=  bit_vector(TO_SIGNED( ((((342+(11*i))*(-1)**i)/(2**5)) mod 2**7),7));     --imm switches between + and -. Nr is shifted 5 to the right and then lower 7 bit are taken with mod
            rs2 <=  bit_vector(TO_SIGNED( (((342+(11*i))*(-1)**i) mod (2**5)),5));            --rs2 only needs to take lower 5 bits with mod
            Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1, rd = R7, IMM = -1514
            wait for 5.0ns;
        end LOOP;
-----------------------
        --Test LOAD
        
-----------------------
        --Test STORE
        
-----------------------
        --Test R-type
        
-----------------------
        --Test Branch
        
-----------------------
        --Test LUI and AUIPC
     
-----------------------
        --Test JAL AND JALR                 
        wait;
    end process;
end Behavioral;
