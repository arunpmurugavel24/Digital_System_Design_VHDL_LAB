---------------------------------------------------------------------------------
-- University: Technical University of Munich
-- Student: Tiemo Schmidt 
-- 
-- Create Date: 25.06.2024 17:34:11
-- Module Name: Instruction-Decoder - Behavioral
-- Project Name: RiscV Structural Model
--
-- Description: Testbench for originally only Instruction Decoder, but was extended to also Test Alu 
--      to see if the Instruction with the same alu operation work correctly. 
--
----------------------------------------------------------------------------------
--TO TEST
--LUI   DONE
--AUIPC DONE
--JAL   DONE
--JALR  DONE
--BEQ   DONE
--BNE   DONE
--BLT   DONE
--BGE   DONE
--BLTU  DONE
--BGEU  DONE
--LB    DONE
--LH    DONE
--LW    DONE
--LBU   DONE
--LHU   DONE
--SB    DONE
--SH    DONE
--SW    DONE
--ADDI  DONE
--SLTI  DONE
--SLTIU DONE
--XORI  DONE
--ORI   DONE
--ANDI  DONE
--SLLI  DONE
--SRLI  DONE
--SRAI  DONE
--ADD   DONE
--SUB   DONE
--SLL   DONE
--SLT   DONE
--SLTU  DONE
--XOR   DONE
--SRL   DONE
--SRA   DONE
--OR    DONE
--AND   DONE
--
--Wave-Config Colour Coding
--Green: General Signals: clk, res, wr-enab, Inst, Inst-Parts
--Yellow: Register Signals
--Red: Current Operation being done
--Blue: Alu Inputs
--Ergebnis: are the values the Alu should calculate
--Pink: extra ID-Outputs for Dmem or pc_crtl, or Mux for Load, Store, Branch
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
          jmp_flag : out bit;                           --tells the controller that the mux for jmps need to be set
          store_flag : out bit;                         --tells controller for mem store access
          load_flag : out bit;                          --tells controller for mem load access
          mem_flag : out bit_vector(2 downto 0);        --Tells the memory what it works with (byte000, halfword 001, word 010,byte unsigend 100, Halfword unsigned 101) Keeps with func3 conventions 
          f : out bit_vector(4 downto 0);               --what ADC should do and which input of mux it uses. f(4 downto 3) is Mux, f(2 downto 0) is func3
          a, b : out bit_vector(31 downto 0);           --Inputs for ADC
          reg_mux : out bit_vector(1 downto 0));
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
     
     component Alu Port(
        f               : in bit_vector(4 downto 0);  -- 4:3 selects type of ALU (cmp/logic/add/shift); 2:0 is funct3
        a               : in bit_vector(31 downto 0);  
        b               : in bit_vector(31 downto 0);
        outToDMem       : out bit_vector(31 downto 0);
        ALU_condition   : out bit);
    end component;
     
     --ALU HERE
     
     --Signals
     signal Inst, rd_data, rs1_data, rs2_data, rd3 :  bit_vector(31 downto 0);         --stable Instruction from reg
     signal rd_adress, rs1_adress, rs2_adress :  bit_vector(4 downto 0);--Register Addresses
     signal PC :  bit_vector(MemSize downto 0);     --depending on used Mem PC size will go
     signal f :  bit_vector(4 downto 0);           --what ADC should do and which input of mux it uses. f(4 downto 3) is Mux, f(2 downto 0) is func3
     signal a, b :  bit_vector(31 downto 0);        --Inputs for ADC
     signal clk, res, wr_enab :  bit;
     signal PC_imm : bit_vector(12 downto 0);         --the Branch imm is +-4KB(2^13), LSB is 0
    --FLAGS
     signal jmp_flag : bit;                           --tells the controller that the mux for jmps need to be set
     signal store_flag : bit;                         --tells controller for mem store access
     signal load_flag : bit;                          --tells controller for mem load access
     signal mem_flag : bit_vector(2 downto 0);        --Tells the memory what it works with (byte000, halfword 001, word 010,byte unsigend 100, Halfword unsigned 101) Keeps with func3 conventions 
     signal reg_mux : bit_vector (1 downto 0);
     --Visual crutches for the waveform
     signal operation : string(6 downto 1);
     signal Ergebnis : integer;
     
     --for constructin Instructions
    signal imm : bit_vector(6 downto 0);    --Inst-Bit 31 downto 25
    signal rs2 : bit_vector(4 downto 0);    --Inst-Bit 24 downto 20
    signal rs1 : bit_vector(4 downto 0);    --Inst-Bit 19 downto 15
    signal func3 : bit_vector (2 downto 0); --Inst-Bit 14 downto 12
    signal rd : bit_vector( 4 downto 0);    --Inst-Bit 11 downto 7
    signal opcode : bit_vector(6 downto 0); --Inst-Bit 6 downto 0
    
    --SIGNALES FOR ALU HERE 
    --f, a, b are named like this and ALREADY EXIST. Others you need to create
    signal alu_output : bit_vector(31 downto 0);
    signal alu_condition : bit;
    
begin
    UUT1 : Instruction_decoder Port Map(Inst, Open, rs1_adress, rs2_adress, rd3, rs1_data, rs2_data, PC, PC_imm, jmp_flag, store_flag, load_flag, mem_flag, f, a, b, reg_mux);
    Reg : RegisterFile PORT MAP(clk, res, rs1_adress, rs2_adress, rd_adress, rs1_data, rs2_data, rd_data, wr_enab);
    --ALU HERE
    ALU1:        ALU Port Map(
            f => f,
            a => a,
            b => b,
            outToDMem => Alu_output,
            ALU_condition => alu_condition);    
    --always true
    inst <= imm & rs2 & rs1 & func3 & rd & opcode;
    
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
        for i in 31 downto 5 LOOP
            rd_data <= bit_vector(TO_UNSIGNED(i+2, 32));
            rd_adress <= bit_vector(TO_UNSIGNED(i, 5));
            wait for 5.0ns; 
        end lOOP;
        --R4 is -1
        rd_data <= bit_vector(TO_SIGNED(-1, 32));
        rd_adress <= bit_vector(TO_UNSIGNED(4, 5));
        wait for 5ns;
        --R3 is -5
        rd_data <= bit_vector(TO_SIGNED(-5, 32));
        rd_adress <= bit_vector(TO_UNSIGNED(3, 5));
        wait for 5ns;
        --R2 is 2**31
        rd_data <= b"0111_1111_1111_1111_1111_1111_1111_1111";
        rd_adress <= bit_vector(TO_UNSIGNED(2, 5));
        wait for 5.0ns; 
        --R1 is 1
        rd_data <= bit_vector(TO_UNSIGNED(1, 32));
        rd_adress <= bit_vector(TO_UNSIGNED(1, 5));
        wait for 5.0ns;
        wr_enab <= '0'; 
------------------
    wait for 20ns; --visial
    --TEST IMM 
    --ADDI
        operation <= "ADDI  ";
        opcode <= b"001_0011";
        func3 <= b"000";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        --Test Edgecases (-1(imm)+1(rs1) in binary, 2*32(rs1) + 1(imm)
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));
        rs2 <= b"1_1111";
        imm <= b"111_1111";
        Ergebnis <= 0;
        --inst<= imm & rs2 & rs1 & func3 & rd & opcode;
        wait for 5ns;
        
        --Test integer overflow
        rs1 <= bit_vector(TO_UNSIGNED(2, 5));   --R2 has +2**31
        --Creates imm -1
        rs2 <= b"0_0001";
        imm <= b"000_0000";
        Ergebnis <= TO_INTEGER(signed(bit_vector'(x"8000_0000")));
        --inst<= imm & rs2 & rs1 & func3 & rd & opcode;
        wait for 5ns; --Visual representation of next Inst test
 -----------------     
        --Xori
        operation <= "XORI  ";
        opcode <= b"001_0011";
        func3 <= b"100";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        --
        rs1 <= bit_vector(TO_UNSIGNED(2, 5));   --R2 has +2**31        imm <=  b"1111";     
        rs2 <=  b"1_1111";            --rs2 only needs to take lower 5 bits with mod
        imm <= b"011_1111";           
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R2, IMM = 4.095 should return msb(31) and lowest 11-0Bit as 0;
        Ergebnis <= 2147481600;
        wait for 5ns;

------------------------        
        --Ori
        operation <= "ORI   ";
        opcode <= b"001_0011";
        func3 <= b"110";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has +1        imm <=  b"0111_1111_1110";     
        rs2 <=  b"1_1110";                      --rs2 only needs to take lower 5 bits with mod
        imm <= b"011_1111";           
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1, IMM = 4.094 should return lowest 11-0Bit as 1;
        Ergebnis <= TO_INTEGER(signed(bit_vector'(x"0000_07ff")));
        wait for 5ns;
        
------------------------        
        --ANDI
        operation <= "ANDI  ";
        opcode <= b"001_0011";
        func3 <= b"111";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(31, 5));  --R31 has 33 (0010_0001) 
        rs2 <=  b"1_1110";                      --rs2 only needs to take lower 5 bits with mod
        imm <= b"111_1111";           
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R31, IMM = -1 should return only 6Bit as 1;
        Ergebnis <= TO_INTEGER(signed(bit_vector'(x"0000_0020")));
        wait for 5ns;
        
------------------------                
        --SLTI     
        --compare 1 and -1: Test negativ Nr
        operation <= "SLTI  ";
        opcode <= b"001_0011";
        func3 <= b"010";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <=  b"1_1111";                      --rs2 only needs to take lower 5 bits
        imm <= b"111_1111";           
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1(value: 1), IMM = -1 should return lowest LSB s 0;
        Ergebnis <= 0;
        wait for 5ns;
        
        --compare 1 and 1: Test Equal
        operation <= "SLTI  ";
        opcode <= b"001_0011";
        func3 <= b"010";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <=  b"0_0001";                      --rs2 only needs to take lower 5 bits
        imm <= b"000_0000";           
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1(value: 1), IMM = 1 should return lowest LSB s 0;
        Ergebnis <= 0;
        wait for 5ns;
        
        --compare 1 and 3
        operation <= "SLTI  ";
        opcode <= b"001_0011";
        func3 <= b"010";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <=  b"0_0011";                      --rs2 only needs to take lower 5 bits
        imm <= b"000_0000";           
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1(value: 1), IMM = 3 should return lowest LSB as 1;
        Ergebnis <= 1;
        wait for 5ns;
        
------------------------                
        --SLTIU
        --compare 1 and 4095
        operation <= "SLTIU ";
        opcode <= b"001_0011";
        func3 <= b"011";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <=  b"1_1111";                      
        imm <= b"111_1111";                     -- Because unsigned it should create 4095       
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1, IMM = 4.094 should return lowest LSB as 1;
        Ergebnis <= 1;
        wait for 5ns;
        
        --compare 1 and 1: Test Equal
        operation <= "SLTIU ";
        opcode <= b"001_0011";
        func3 <= b"010";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <=  b"0_0001";                      --rs2 only needs to take lower 5 bits
        imm <= b"000_0000";           
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1(value: 1), IMM = 1 should return lowest LSB s 0;
        Ergebnis <= 0;
        wait for 5ns;
        
        --compare 1 and 3
        operation <= "SLTIU ";
        opcode <= b"001_0011";
        func3 <= b"010";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <=  b"0_0011";                      --rs2 only needs to take lower 5 bits
        imm <= b"000_0000";           
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R1(value: 1), IMM = 3 should return lowest LSB as 1;
        Ergebnis <= 1;
        wait for 5ns;        

--!!!---------------------
        --Test LOAD
        operation <="LB    ";
        opcode <= b"000_0011";
        func3 <= "000";
        rs1 <= bit_vector(TO_UNSIGNED(5, 5));
        rd  <= bit_vector(TO_UNSIGNED(30, 5));   -- Loades Data, from adress in rs1, to rd
        rs2 <= b"1_1111";
        imm <= b"000_0000";
        wait for 5ns;
        
        operation <="LH    ";
        opcode <= b"000_0011";
        func3 <= "001";
        rs1 <= bit_vector(TO_UNSIGNED(5, 5));
        rd  <= bit_vector(TO_UNSIGNED(30, 5));   -- Loades Data, from adress in rs1, to rd
        rs2 <= b"1_1111";
        imm <= b"000_0000";
        wait for 5ns;
        
        operation <="LW    ";
        opcode <= b"000_0011";
        func3 <= "010";
        rs1 <= bit_vector(TO_UNSIGNED(5, 5));
        rd  <= bit_vector(TO_UNSIGNED(30, 5));   -- Loades Data, from adress in rs1, to rd
        rs2 <= b"1_1111";
        imm <= b"000_0000";
        wait for 5ns;
        
        operation <="LBU   ";
        opcode <= b"000_0011";
        func3 <= "100";
        rs1 <= bit_vector(TO_UNSIGNED(5, 5));
        rd  <= bit_vector(TO_UNSIGNED(30, 5));   -- Loades Data, from adress in rs1, to rd
        rs2 <= b"1_1111";
        imm <= b"000_0000";
        wait for 5ns;
        
        operation <="LHU   ";
        opcode <= b"000_0011";
        func3 <= "101";
        rs1 <= bit_vector(TO_UNSIGNED(5, 5));
        rd  <= bit_vector(TO_UNSIGNED(30, 5));   -- Loades Data, from adress in rs1, to rd
        rs2 <= b"1_1111";
        imm <= b"000_0000";
        wait for 5ns;
--!!!---------------------
        --Test STORE
        operation <="SB    ";
        opcode <= b"010_0011";
        func3 <= "000";
        rs1 <= bit_vector(TO_UNSIGNED(5, 5));
        rs2  <= bit_vector(TO_UNSIGNED(2, 5));   -- saves Data from rs2 to the adress in rs1
        rd <= b"1_1111";
        imm <= b"000_0000";
        wait for 5ns;
        
        operation <="SH    ";
        opcode <= b"010_0011";
        func3 <= "001";
        rs1 <= bit_vector(TO_UNSIGNED(5, 5));
        rs2  <= bit_vector(TO_UNSIGNED(2, 5));   -- saves Data from rs2 to the adress in rs1
        rd <= b"1_1111";
        imm <= b"000_0000";
        wait for 5ns;
        
        operation <="SW    ";
        opcode <= b"010_0011";
        func3 <= "010";
        rs1 <= bit_vector(TO_UNSIGNED(5, 5));
        rs2  <= bit_vector(TO_UNSIGNED(2, 5));   -- saves Data from rs2 to the adress in rs1
        rd <= b"1_1111";
        imm <= b"000_0000";
        wait for 5ns;
--!!!---------------------
        --Test R-type
        --ADD
        operation <= "ADD   ";
        opcode <= b"011_0011";
        func3 <= b"000";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        --Test Edgecases 2*32(rs2) + 1(RS1)
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));
        rs2 <= bit_vector(TO_UNSIGNED(2, 5));
        imm <= b"000_0000";
        Ergebnis <= TO_INTEGER(signed(bit_vector'(x"8000_0000")));
        --inst<= imm & rs2 & rs1 & func3 & rd & opcode;
        wait for 5ns;
        
        --Test normal calc: Rs1(1) + Rs31(33) = 34
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R2 has +2**31
        --Creates imm -1
        rs2 <= bit_vector(TO_UNSIGNED(31, 5));
        imm <= b"000_0000";
        Ergebnis <= 34;
        --inst<= imm & rs2 & rs1 & func3 & rd & opcode;
        wait for 5ns; --Visual representation of next Inst test
 ------------------
        --sub
        
        operation <= "SUB   ";
        opcode <= b"011_0011";
        func3 <= b"000";
        imm <= b"010_0000"; --sets sub
        
        --Case normal calc 33-1=32
        rs1 <= bit_vector(TO_UNSIGNED(31, 5));
        rs2 <= bit_vector(TO_UNSIGNED(1, 5));
        Ergebnis <= 32;
        wait for 5ns;
        
        --Case sub negativ nr. calc 1-(-5)=6;
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));
        rs2 <= bit_vector(TO_UNSIGNED(3, 5));
        Ergebnis <= 6;
        wait for 5ns;
        
-------------------             
        --Xor
        operation <= "XOR   ";
        opcode <= b"011_0011";
        func3 <= b"100";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        imm <= b"000_0000";
        rs1 <= bit_vector(TO_UNSIGNED(2, 5));   --R2 has +2**31        imm <=  b"1111";     
        rs2 <=  bit_vector(TO_UNSIGNED(1, 5));  --rs2 only needs to take lower 5 bits with mod
        --Inst <= imm & rs2 & rs1 & func3 & rd & opcode; -- rs = R2, IMM = 4.095 should return and Bit 31 and 0 as 0;
        Ergebnis <= 2147483646;
        wait for 5ns;

------------------------        
        --Or
        operation <= "OR    ";
        opcode <= b"011_0011";
        func3 <= b"100";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        imm <= b"000_0000";
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1;     
        rs2 <=  bit_vector(TO_UNSIGNED(30, 5)); --R30 has 32 
        -- 1 OR 32 = 33;
        Ergebnis <= 33;
        wait for 5ns;
        
------------------------        
        --AND
        operation <= "AND   ";
        opcode <= b"011_0011";
        func3 <= b"111";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        imm <= b"000_0000";
        rs1 <= bit_vector(TO_UNSIGNED(31, 5));  --R31 has 33 (0010_0001) 
        rs2 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        --31 OR 1 = 1;
        Ergebnis <= 1;
        wait for 5ns;
        
------------------------                
        --SLT     
        --compare 1 and -5: Test negativ Nr
        operation <= "SLT   ";
        opcode <= b"011_0011";
        func3 <= b"010";
        imm <= b"000_0000";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <= bit_vector(TO_UNSIGNED(3, 5));   --rs2 only needs to take lower 5 bits
        -- rs1 = R1(value: 1), rs =R3 (value: -5) should return lowest LSB s 0;
        Ergebnis <= 0;
        wait for 5ns;
        
        --compare 1 and 1: Test Equal
        operation <= "SLT   ";
        opcode <= b"011_0011";
        func3 <= b"010";
        imm <= b"000_0000";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        -- rs = R1(value: 1), rs =R1 (value: 1) should return lowest LSB s 0;
        Ergebnis <= 0;
        wait for 5ns;
        
        --compare 1 and 3
        operation <= "SLT   ";
        opcode <= b"011_0011";
        func3 <= b"010";
        imm <= b"000_0000";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <=  bit_vector(TO_UNSIGNED(30, 5)); --R30 has 32
        -- rs = R1(value: 1), rs =R30 (value: 32) should return lowest LSB s 1;
        Ergebnis <= 1;
        wait for 5ns;
        
------------------------                
        --SLTU
        --compare 1 and -5(which is unsigned 4.294.967.291, because the register is 32Bit long and not extended) 
        operation <= "SLTU  ";
        opcode <= b"011_0011";
        func3 <= b"011";
        imm <= b"000_0000";
        rd <= b"0_0000";        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <= bit_vector(TO_UNSIGNED(3, 5));   --R2 has -5(which is unsigned 4.294.967.291)               
        --should give out 1
        Ergebnis <= 1;
        wait for 5ns;
        
        --compare 1 and 1: Test Equal
        operation <= "SLTU  ";
        opcode <= b"011_0011";
        func3 <= b"010";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <= bit_vector(TO_UNSIGNED(1, 5));   --R2 has 1
        -- should return 0
        Ergebnis <= 0;
        wait for 5ns;
        
        --compare 1 and 6
        operation <= "SLTU  ";
        opcode <= b"011_0011";
        func3 <= b"010";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --R1 has 1
        rs2 <=  bit_vector(TO_UNSIGNED(5, 5));  --R2 has 7
        Ergebnis <= 1;
        wait for 5ns;
        
-----------------------
        --Test Branch
        --All instruction should test for Output = 1 and 0
        --general
        opcode <= b"110_0011";
        rd <= b"0_0000"; 
        --imm offset. PC_imm should show -241
        imm(6) <= '1';
        rd(0) <=  '1';
        imm(5 downto 0) <= b"11_0000";
        rd(4 downto 1) <= b"1111";
        --BEQ (equal)
        Operation <= "BEQ   ";
        func3 <= b"000";
            --equal
            rs1 <= bit_vector(to_unsigned(1, 5));   --Value 1
            rs2 <= bit_vector(to_unsigned(1, 5));   --Value 1
            Ergebnis <= 1;
            wait for 5ns;
            --not equal
            rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --value 1
            rs2 <= bit_vector(TO_UNSIGNED(5, 5));   --Value 7
            Ergebnis <= 0;
            wait for 5ns;
            
        --BNE (not Equal)
        Operation <= "BNQ   ";
        func3 <= b"001";
            --equal
            rs1 <= bit_vector(to_unsigned(1, 5));   --Value 1
            rs2 <= bit_vector(to_unsigned(1, 5));   --Value 1
            Ergebnis <= 0;
            wait for 5ns;
            --not equal
            rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --Value 1
            rs2 <= bit_vector(TO_UNSIGNED(5, 5));   --Value 7
            Ergebnis <= 1;
            wait for 5ns;
            
        --BLT (less than)
        Operation <= "BLT   ";
        func3 <= b"100";
            --less than
            rs1 <= bit_vector(TO_UNSIGNED(1, 5));   --Value 1
            rs2 <= bit_vector(TO_UNSIGNED(5, 5));   --Value 7
            Ergebnis <= 1;
            wait for 5ns;
            --Equal
            rs1 <= bit_vector(to_unsigned(1, 5));   --Value 1
            rs2 <= bit_vector(to_unsigned(1, 5));   --Value 1
            Ergebnis <= 0;
            wait for 5ns;
            --more
            rs1 <= bit_vector(TO_UNSIGNED(5, 5));   --Value 7
            rs2 <= bit_vector(TO_UNSIGNED(1, 5));   --Value 1
            Ergebnis <= 0;
            wait for 5ns;
            
        --BGE (geater than)
        Operation <= "BGE   ";
        func3 <= b"101";
            --greater
            rs1 <= bit_vector(to_unsigned(5, 5));   --Value 7
            rs2 <= bit_vector(to_unsigned(1, 5));   --Value 1
            Ergebnis <= 1;
            wait for 5ns;    
            --equal
            rs1 <= bit_vector(to_unsigned(1, 5));   --Value 1
            rs2 <= bit_vector(to_unsigned(1, 5));   --Value
            Ergebnis <= 1;
            wait for 5ns;
            --less
            rs1 <= bit_vector(to_unsigned(1, 5));   --Value 1
            rs2 <= bit_vector(to_unsigned(5, 5));   --Value 7
            Ergebnis <= 0;
            wait for 5ns;
            
        --BLTU(less than unsigned)
        Operation <= "BLTU  ";
        func3 <= b"110";
            --greater
            rs1 <= bit_vector(to_unsigned(3, 5));   --Value -5(unsigend: 4.294.967.291)
            rs2 <= bit_vector(to_unsigned(5, 5));   --Value 7
            Ergebnis <= 0;
            wait for 5ns;    
            --equal
            rs1 <= bit_vector(to_unsigned(3, 5));   --Value -5(unsigend: 4.294.967.291)
            rs2 <= bit_vector(to_unsigned(3, 5));   --Value -5(unsigend: 4.294.967.291)
            Ergebnis <= 0;
            wait for 5ns;
            --less
            rs1 <= bit_vector(to_unsigned(5, 5));   --Value 7
            rs2 <= bit_vector(to_unsigned(3, 5));   --Value -5(unsigend: 4.294.967.291)
            Ergebnis <= 1;
            wait for 5ns;
            
        --BGEU (greater than unsigned)
        Operation <= "BGEU  ";
        func3 <= b"111";
            --greater
            rs1 <= bit_vector(to_unsigned(3, 5));   --Value -5(unsigend: 4.294.967.291)
            rs2 <= bit_vector(to_unsigned(5, 5));   --Value 7
            Ergebnis <= 1;
            wait for 5ns;    
            --equal
            rs1 <= bit_vector(to_unsigned(3, 5));   --Value -5(unsigend: 4.294.967.291)
            rs2 <= bit_vector(to_unsigned(3, 5));   --Value -5(unsigend: 4.294.967.291)
            Ergebnis <= 1;
            wait for 5ns;
            --less
            rs1 <= bit_vector(to_unsigned(5, 5));   --Value 7
            rs2 <= bit_vector(to_unsigned(3, 5));   --Value -5(unsigend: 4.294.967.291)
            Ergebnis <= 0;
            wait for 5ns;        
        
-----------------------
        --Test LUI and AUIPC
        --LUI
        operation <= "LUI   ";
        opcode <= b"011_0111";
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        func3 <= b"011";
        rs1 <= b"0_0101";           --R1 has 1
        rs2 <=  b"0_0110";          --R2 has 6
        imm <= b"010_1010";
        Ergebnis <= 1415753728;         --is the 20bits from imm & rs2 & rs1 & func3, in 31 downto 12;
        wait for 5ns;
        
        --AUIPC --like Lui, but adds PC on Top
        operation <= "AUIPC ";
        opcode <= b"001_0111";
        PC <= bit_vector(TO_UNSIGNED(30, 16));  --Set current PC
        rd <= b"0_0000";                        --R0, because we dont have an alu in this tb
        func3 <= b"011";
        rs1 <= b"0_0101";           --R1 has 1
        rs2 <=  b"0_0110";          --R2 has 6
        imm <= b"010_1010";
        Ergebnis <= 1415753728+ 30;         --is the 20bits from imm & rs2 & rs1 & func3, in 31 downto 12;
        wait for 5ns;
-----------------------
        --Test JAL AND JALR       
        --JAL
        --Case negativ jump
        operation <= "JAL   ";
        opcode <= b"110_1111";
        rd <= b"0_0000";
        PC <=  bit_vector(TO_UNSIGNED(52, 16));
        --imm -20
        rs2 <= b"0_1101";
        imm <= b"111_1111";
        func3 <= b"111";
        rs1 <= b"1_1111";
        Ergebnis <= 32;
        wait for 5ns;
        --11111111101111111011
        --111111111011111110110
        --Case positiv jump
        operation <= "JAL   ";
        opcode <= b"110_1111";
        rd <= b"0_0000";
        PC <=  bit_vector(TO_UNSIGNED(30, 16));
        --imm 20
        rs2 <= b"0_1010";
        imm <= b"000_0000";
        func3 <= b"000";
        rs1 <= b"0_0000";
        Ergebnis <= 40;
        wait for 5ns;
----------
        --JALR          
        --TO Test: rs1 with LSB = 1 should come out as 0, positiv and negativ;
        --rs1 LSB = 1
        operation <= "JALR  ";
        opcode <= b"110_0111";
        rd <= b"0_0000";
        rs1 <= bit_vector(TO_UNSIGNED(31, 5));
        func3 <= b"000";
        --imm 20
        rs2 <= b"0_1010";
        imm <= b"000_0000";
        --Adding 33+10 = 43, BUT LSB = 0, so 52
        Ergebnis <= 42;
        wait for 5ns;
        
        --rs1 LSB = 1 AND imm LSB = 1;
        operation <= "JALR  ";
        opcode <= b"110_0111";
        rd <= b"0_0000";
        rs1 <= bit_vector(TO_UNSIGNED(31, 5));
        func3 <= b"000";
        --imm 21
        rs2 <= b"0_1011";
        imm <= b"000_0000";
        --Adding 33+11 = 44, BUT LSB = 0, so 54
        Ergebnis <= 44;
        wait for 5ns;

        --positiv
        operation <= "JALR  ";
        opcode <= b"110_0111";
        rd <= b"0_0000";
        rs1 <= bit_vector(TO_UNSIGNED(5, 5));
        func3 <= b"000";
        --imm 20
        rs2 <= b"0_1010";
        imm <= b"000_0000";
        --Adding 7+10 = 17
        Ergebnis <= 16;
        wait for 5ns;
        
        --negativ
        operation <= "JALR  ";
        opcode <= b"110_0111";
        rd <= b"0_0000";
        rs1 <= bit_vector(TO_UNSIGNED(30, 5));
        func3 <= b"000";
        --imm -20
        rs2 <= b"0_1100";
        imm <= b"111_1111";
        --Adding 32-20 = 12
        Ergebnis <= 12;
        wait for 5ns;
        
-----------------
        --Shift Instruction 
        --Imm
        --gerneral
        opcode <= b"001_0011";
        rd <= b"0_0000";
        imm <= b"000_0000";
    
        --SLLI
        Operation <= "SLLI  ";
        func3 <= "001"; 
            --corner cases. Sift 0Times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= b"0_0000";
            Ergebnis <= -1;
            wait for 5ns;
            
            --corner case shift b"1_1111"times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= b"1_1111"; --shift 31times 
            Ergebnis <= -2147483648; -- -1 shifted 31(11111) times is -2**31-1
            wait for 5ns;
            
            --Normal case
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= b"0_0111"; --shift 7times 
            Ergebnis <= -128; --
            wait for 5ns;
        --SRLI
        Operation <= "SRLI  ";
        func3 <= "101";
            --corner cases. Sift 0Times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= b"0_0000";
            Ergebnis <= -1;
            wait for 5ns;
            
            --corner case shift b"1_1111"times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= b"1_1111"; --shift 31times 
            Ergebnis <= 1; --Or 0, not sure right now
            wait for 5ns;
            
            --Normal case
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= b"0_0111"; --shift 7times 
            Ergebnis <= 33554431; --
            wait for 5ns;         
        --SRAI
        Operation <= "SRAI  ";
            func3 <= "101"; 
            imm <= b"010_0000";
            
            --corner cases. Sift 0Times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= b"0_0000";
            Ergebnis <= -1;
            wait for 5ns;
            
            --corner case shift b"1_1111"times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= b"1_1111"; --shift 31times 
            Ergebnis <= -1; -- -1 shifted right arithmetic stays -1
            wait for 5ns;
            
            --"Normal" case
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= b"0_0111";   --shift 7times 
            Ergebnis <= -1;     -- (-1) shifted 7 times is still -1, because -1 is smallest step
            wait for 5ns;
            
            --Normal case
            rs1 <= bit_vector(TO_UNSIGNED(2, 5));   --value 2**31
            rs2 <= b"0_0111";   --shift 7times 
            Ergebnis <= 16777215;     -- 2**31 shifted 7 times is 16.777.215
            wait for 5ns; 
            
-----------------
        --Shift Instruction 
        --R-Type
        --gerneral
        opcode <= b"011_0011";
        rd <= b"0_0000";
        imm <= b"000_0000";
        --SLL
        Operation <= "SLL   ";
        func3 <= "001"; 
            --corner cases. Sift 0Times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= bit_vector(TO_UNSIGNED(0, 5));   --Value 0
            Ergebnis <= -1;
            wait for 5ns;
            
            --corner case shift b"1_1111"times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= bit_vector(TO_UNSIGNED(2, 5));   --Value 2**31, lowest 5 bits so 1_1111
            Ergebnis <= -2147483648; --Or 0, not sure right now
            wait for 5ns;
            
            --Normal case
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
             rs2 <= bit_vector(TO_UNSIGNED(5, 5));   --Value 7 shift 7times 
            Ergebnis <= -128; --
            wait for 5ns;
        --SRL
        Operation <= "SRL   ";
        func3 <= "101";
            --corner cases. Sift 0Times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= bit_vector(TO_UNSIGNED(0, 5));   --Value 0
            Ergebnis <= -1;
            wait for 5ns;
            
            --corner case shift b"1_1111"times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= bit_vector(TO_UNSIGNED(2, 5));   --Value 2**31, lowest 5 bits so 1_1111
            Ergebnis <= 1; --1
            wait for 5ns;
            
            --Normal case
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= bit_vector(TO_UNSIGNED(5, 5)); --shift 7times 
            Ergebnis <= 33554431; --
            wait for 5ns;         
        --SRA
        Operation <= "SRA   ";
            func3 <= "101"; 
            imm <= b"010_0000";
            
            --corner cases. Sift 0Times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= bit_vector(TO_UNSIGNED(0, 5));   --Value 0
            Ergebnis <= -1;
            wait for 5ns;
            
            --corner case shift b"1_1111"times
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= bit_vector(TO_UNSIGNED(2, 5));   --Value 2**31, lowest 5 bits: so 1_1111
            Ergebnis <= -1; --Or 0, not sure right now
            wait for 5ns;
            
            --"Normal" case
            rs1 <= bit_vector(TO_UNSIGNED(4, 5));
            rs2 <= bit_vector(TO_UNSIGNED(5, 5));   --Value 7 shift 7times 
            Ergebnis <= -1;     -- (-1) shifted 7 times is still -1, because -1 is smallest step
            wait for 5ns;
            
            --Normal case
            rs1 <= bit_vector(TO_UNSIGNED(2, 5));   --value 2**31
            rs2 <= bit_vector(TO_UNSIGNED(5, 5));   --Value 7 shift 7times 
            Ergebnis <= 16777215;     -- 2**31 shifted 7 times is 16.777.215
            wait for 5ns; 
            
    --END
        wait;
    end process;
end Behavioral;
