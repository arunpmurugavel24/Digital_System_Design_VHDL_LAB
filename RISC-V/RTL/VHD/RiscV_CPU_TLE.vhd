----------------------------------------------------------------------------------
-- University: Technical University of Munich
-- Student: Tiemo Schmidt
-- 
-- Create Date: 04.07.2024 10:41:18
-- Design Name: 
-- Module Name: RiscV_CPU_TLE - Behavioral
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

entity RiscV_CPU_TLE is
    Port (clk, res : in bit);   --the only signals needed from the outside.
end RiscV_CPU_TLE;

architecture Behavioral of RiscV_CPU_TLE is
    --Component declaration
    --Logic
    component controller Port(
        clk              : in bit;
        reset            : in bit;
        -- FSM Inputs
        --next_state_flag  : in bit;
        jmp_flag         : in bit;
        store_flag       : in bit;
        load_flag        : in bit;
        -- FSM State Ouputs
        -- Memory Read/Write Enable
        mem_read_en     : out bit;
        mem_write_en    : out bit;        
        -- Register Write Enable
        reg_write_en    : out bit;        
        -- Instruction Holder Enable
        instr_holder_en    : out bit;        
        -- PC Controller Enable
        pc_ctrl_en    : out bit;        
        -- Instruction Decode Flags Reset
        instr_decode_flags_reset    : out bit;        
        -- PC Jump Flag
        pc_jmp_flag    : out bit);
    end component;
    
    component Instruction_decoder Port(
          Inst : in bit_vector(31 downto 0);            --stable Instruction from reg
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
          reg_mux : out bit_vector(1 downto 0));          --the control signal for the mux infront of rd_data (00 is Alu, 01 is Dmem, 10 is PC, 11 is open)
    end component;
    
    component pc_ctrl Port(
            enab_w, clk, res : in bit; --enables
            imm : in bit_vector(12 downto 0);    --Address for a jump Instruction
            PC : out bit_vector(15 downto 0);    --needs to be same size as Pmem
            Alu_condition : in bit;              --Chosses if Pc is incremented by 1 or imm
            jmp_condition : in bit;              --If Jump Instructions is used, we need to use the Alu address
            Alu_adress : in bit_vector(31 downto 0));
    end component;
    
    component Alu Port(
        f               : in bit_vector(4 downto 0);  -- 4:3 selects type of ALU (cmp/logic/add/shift); 2:0 is funct3
        a               : in bit_vector(31 downto 0);  
        b               : in bit_vector(31 downto 0);
        outToDMem       : out bit_vector(31 downto 0);
        ALU_condition   : out bit);
    end component;
    
    component Mux3to1 Port(
          In0, In1, In2 : in bit_vector(31 downto 0);
          output : out bit_vector(31 downto 0);
          sel : in bit_vector(1 downto 0));
    end component;
    
    --Memory
    component registerFile Port(
          clk : in bit;
          res : in bit;
          rd1_addr : in bit_vector(4 downto 0);
          rd2_addr : in bit_vector(4 downto 0);
          wr_addr : in bit_vector(4 downto 0);
          rd1_data : out bit_vector(31 downto 0);
          rd2_data : out bit_vector(31 downto 0);
          wr_data : in bit_vector(31 downto 0);
          wr_enab : in bit);
    end component;
    
    component DataMemory Port (
        clk        : in  BIT;
        mem_read   : in  BIT;
        mem_write  : in  BIT;
        funct3     : in  BIT_VECTOR(2 downto 0);
        address    : in  BIT_VECTOR(31 downto 0);
        write_data : in  BIT_VECTOR(31 downto 0);
        read_data  : out BIT_VECTOR(31 downto 0));
    end component;
    
    component Program_memory Port(
        clk        : in  BIT;
        mem_read   : in  BIT;
        addr       : in  BIT_VECTOR(15 downto 0);
        read_data  : out BIT_VECTOR(31 downto 0));
    end component;
    
    component inst_holder Port(
        enab, clk, res : in bit;
        Inst_input : in bit_vector(31 downto 0);
        Inst_output : out bit_vector(31 downto 0));
    end component;
    
    --SIGNALS
    --controller Outputs
    signal dmem_read_enab : bit;
    signal dmem_write_enab: bit;
    signal reg_write_enab: bit;
    signal inst_hold_enab : bit;
    signal pc_ctrl_enab : bit;
    signal pc_jmp_flag : bit;
    
    
    --Inst_decoder Outputs
    signal rd_adress, rs1_adress, rs2_adress : bit_vector(4 downto 0);
    signal a, b : bit_vector(31 downto 0);
    signal f : bit_vector(4 downto 0);
    signal pc_imm : bit_vector(12 downto 0);
    signal reg_mux_sel : bit_vector(1 downto 0);
    signal d3 : bit_vector(31 downto 0);
    signal jmp_flag, store_flag, load_flag : bit;
    signal mem_flag : bit_vector(2 downto 0);
    
    --pc_ctrl Outputs
    signal PC : bit_vector(15 downto 0);
    
    --Alu Outputs
    signal alu_output : bit_vector(31 downto 0);
    signal alu_condition : bit;
    
    --Dmem outputs
    signal dmem_output : bit_vector(31 downto 0);
    
    --Pmem outputs
    signal pmem_output : bit_vector(31 downto 0);
    
    --RF outputs
    signal rs1_data, rs2_data : bit_vector(31 downto 0);
    
    --int_holder Outputs
    signal Instruction : bit_vector(31 downto 0);
    
    --Mux Outputs
    signal mux_output : bit_vector(31 downto 0);
    signal PC_mux : bit_vector(31 downto 0);
    
    
begin
    --Bus size change
    pc_mux <= x"0000" & PC;
    --Unit declaration
    ctrl1:       controller Port Map(
        clk => clk,
        reset => res,
        --next_state_flag => open,
        jmp_flag => jmp_flag,
        store_flag => store_flag,
        load_flag => load_flag,
        mem_read_en => dmem_read_enab,
        mem_write_en => dmem_write_enab,
        reg_write_en => reg_write_enab,
        instr_holder_en => inst_hold_enab,
        pc_ctrl_en => pc_ctrl_enab,
        instr_decode_flags_reset => Open,
        pc_jmp_flag => pc_jmp_flag);
    
    ID1:         instruction_decoder Port Map(
          Inst => Instruction,
          rd_adress => rd_adress,
          rs1_adress => rs1_Adress,
          rs2_adress => rs2_adress,
          rd3 => d3,
          rs1_data => rs1_data,
          rs2_data => rs2_data,
          PC => PC,
          PC_imm => PC_imm,
          jmp_flag => jmp_flag,
          store_flag => store_flag,
          load_flag => load_flag,
          mem_flag => mem_flag,
          f => f,
          a => a,
          b => b,
          reg_mux => reg_mux_sel);
          

          
    ALU1:        ALU Port Map(
            f => f,
            a => a,
            b => b,
            outToDMem => Alu_output,
            ALU_condition => alu_condition);
    
    RegisterMux1:Mux3to1 Port Map(
            In0 => alu_output,
            In1 =>dmem_output,
            In2 => PC_mux, 
            output => mux_output,
            sel => reg_mux_sel); 
    
    pc_ctrl1:    pc_ctrl Port Map(
            enab_w => pc_ctrl_enab,
            clk => clk, 
            res => res,
            imm => pc_imm,
            PC => PC,
            Alu_condition => alu_condition, 
            jmp_condition => pc_jmp_flag, 
            Alu_adress => alu_output); 
    
    --Mem units
    RF:         registerfile Port Map(
          clk => clk,
          res => res,
          rd1_addr => rs1_adress,
          rd2_addr => rs2_adress,
          wr_addr => rd_adress, 
          rd1_data => rs1_data, 
          rd2_data => rs2_data, 
          wr_data => mux_output, 
          wr_enab => reg_write_enab); 
    
    Dmem1:       datamemory Port Map(
          clk => clk,
          mem_read => dmem_read_enab,
          mem_write => dmem_write_enab,
          funct3 => mem_flag,
          address => alu_output,
          write_data => d3,
          read_data => dmem_output);
    
    Pmem1:       program_memory Port Map(
          clk => clk,
          mem_read => '1',              --Maybe change always read
          addr => PC,
          read_data => pmem_output);
    
    inst_hold1:  inst_holder Port Map(
          enab => inst_hold_enab, 
          clk => clk, 
          res => res,
          Inst_input => pmem_output, 
          Inst_output => Instruction);
          
    --no process needed as the TLE is only connecting the signals(pathways)

end Behavioral;
