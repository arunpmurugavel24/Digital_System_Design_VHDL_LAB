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
    Port (Inst : in bit_vector(31 downto 0);         --stable Instruction from reg
          rd_adress, rs1_adress, rs2_adress : out bit_vector(4 downto 0);--Register Addresses
          rs1_data, rs2_data : in bit_vector(31 downto 0);
          rd3 : out bit_vector(31 downto 0);
          PC : in bit_vector(MemSize downto 0);     --depending on used Mem PC size will go
          --flags : in bit_vector(no idea);           --Flags for jump, and FSM- for what to enable
          f : out bit_vector(4 downto 0);           --what ADC should do and which input of mux it uses. f(4 downto 3) is Mux, f(2 downto 0) is func3
          a, b : out bit_vector(31 downto 0);        --Inputs for ADC
          clk, res : in bit);
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
     
begin
    UUT : Instruction_decoder Port Map(Inst, open, rs1_adress, rs2_adress, rs1_data, rs2_data, rd3, PC, f, a, b,clk, res);
    Reg : RegisterFile PORT MAP(clk, res, rs1_adress, rs2_adress, rd_adress, rs1_data, rs2_data, rd_data, wr_enab);

    clk_pro: process
    begin
        clk <= not clk;
        wait for 25ns;
    end Process;
    
    stimuli : process
    begin
    --RES
        --wait for 50ns;
        --res <= '1';
        --wait for 100ns;
        --res <= '0';
        --wait for 50ns;
    --Seed Register
    wr_enab <= '1';
        for i in 31 downto 1 LOOP
            rd_data <= bit_vector(TO_UNSIGNED(i+2, 32));
            rd_adress <= bit_vector(TO_UNSIGNED(i, 5));
            wait for 50ns; 
        end lOOP;
    --TEST ADDI
        wait for 50ns;
        Inst <= b"1010_0001_0110_0000_1111_0011_1001_0011"; -- rs = R1, rd = R7, IMM = -1514
        wait for 50ns;
        wait;
    end process;
end Behavioral;
