----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
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
        next_state_flag  : in bit;
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
            imm : in bit_vector(15 downto 0);    --Address for a jump Instruction
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
    
    component Data_Memory Port (
        clk        : in  BIT;
        mem_read   : in  BIT;
        mem_write  : in  BIT;
        funct3     : in  BIT_VECTOR(2 downto 0);
        address    : in  BIT_VECTOR(7 downto 0);
        write_data : in  BIT_VECTOR(7 downto 0);
        read_data  : out BIT_VECTOR(7 downto 0));
    end component;
    
    component Program_memory Port(
        clk        : in  BIT;
        mem_read   : in  BIT;
        addr       : in  BIT_VECTOR(31 downto 0);
        read_data  : out BIT_VECTOR(31 downto 0));
    end component;
    
    component inst_holder Port(
        enab, clk, res : in bit;
        Inst_input : in bit_vector(31 downto 0);
        Inst_output : out bit_vector(31 downto 0));
    end component;
    
    --SIGNALS
    --controller Outputs
    
    --Inst_decoder Outputs
    
    --pc_ctrl Outputs
    
    --Alu Outputs
    
    --Dmem outputs
    
    --Pmem outputs
    
    --RF outputs
    
    --int_holder Outputs
    
    --Mux Outputs
    
    
    
begin
    --Unit declaration
    ctrl:       controller Port Map();
    ID:         instruction_decoder Port Map();
    inst_hold:  inst_holder Port Map();
    ALU:        ALU Port Map();
    RegisterMux:Mux3to1 Port Map(); 
    pc_ctrl:    pc_ctrl Port Map();
    
    --Mem units
    RF:         registerfile Port Map();
    Dmem:       data_memory Port Map();
    Pmem:       program_memory Port Map();
    
    --no process needed as the TLE is only connection the signals(pathways)

end Behavioral;
