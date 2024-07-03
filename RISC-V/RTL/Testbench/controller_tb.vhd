----------------------------------------------------------------------------------
-- Company: Technische Universität München
-- Engineer: Arun Prema Murugavel
-- Matrikel Nummer: 03787979
-- Email: arun.murugavel@tum.de
-- 
-- Create Date: 07/03/2024 02:06:07 PM
-- Design Name: controller_tb.vhd
-- Module Name: controller_tb - Behavioral
-- Project Name: RISC V 32 RTL
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_controller is
end tb_controller;

architecture Behavioral of tb_controller is
    -- Component Declaration for the Unit Under Test (UUT)
    component controller
        port (
            clk                    : in bit;
            reset                  : in bit;
            
            -- FSM Inputs
            next_state_flag        : in bit;
            jmp_flag               : in bit;
            store_flag             : in bit;
            load_flag              : in bit;

            -- FSM State Outputs
            mem_read_en            : out bit;
            mem_write_en           : out bit;
            reg_write_en           : out bit;
            instr_holder_en        : out bit;
            pc_ctrl_en             : out bit;
            instr_decode_flags_reset : out bit;
            pc_jmp_flag            : out bit
        );
    end component;

    -- Signals to connect to the UUT
    signal clk                : bit := '0';
    signal reset              : bit := '0';
    
    -- FSM Input Signals
    signal next_state_flag    : bit := '0';
    signal jmp_flag           : bit := '0';
    signal store_flag         : bit := '0';
    signal load_flag          : bit := '0';

    -- FSM Output Signals
    signal mem_read_en        : bit;
    signal mem_write_en       : bit;
    signal reg_write_en       : bit;
    signal instr_holder_en    : bit;
    signal pc_ctrl_en         : bit;
    signal instr_decode_flags_reset : bit;
    signal pc_jmp_flag        : bit;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: controller
        port map (
            clk                    => clk,
            reset                  => reset,
            next_state_flag        => next_state_flag,
            jmp_flag               => jmp_flag,
            store_flag             => store_flag,
            load_flag              => load_flag,
            mem_read_en            => mem_read_en,
            mem_write_en           => mem_write_en,
            reg_write_en           => reg_write_en,
            instr_holder_en        => instr_holder_en,
            pc_ctrl_en             => pc_ctrl_en,
            instr_decode_flags_reset => instr_decode_flags_reset,
            pc_jmp_flag            => pc_jmp_flag
        );

    -- Clock process definitions
    clk_pro: process
    begin
        clk <= not clk;
        wait for 2.5ns;
    end Process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        wait for 5.0ns;
        reset <= '1';
        wait for 10.0ns;
        
        reset <= '0';
        wait for 5.0ns;

        -- Simulate different input scenarios
        -- Case 1: FETCH to DECODE_EXECUTE
        next_state_flag <= '0';
        jmp_flag <= '0';
        store_flag <= '0';
        load_flag <= '0';
        wait for 10.0ns;

        -- Case 2: DECODE_EXECUTE to MEM (Load Instruction)
        load_flag <= '1';
        wait for 10.0ns;

        -- Case 3: MEM to RD
        load_flag <= '0';
        wait for 10.0ns;

        -- Case 4: RD to FETCH
        wait for 10.0ns;

        -- Case 5: DECODE_EXECUTE to MEM (Store Instruction)
        store_flag <= '1';
        wait for 10.0ns;
        
        -- Case 6: MEM to FETCH (Store Complete)
        store_flag <= '0';
        wait for 10.0ns;
        
        -- Case 7: DECODE_EXECUTE to MEM (Jump Instruction)
        jmp_flag <= '1';
        wait for 10.0ns;
        
        -- Case 8: MEM to FETCH (Jump Complete)
        jmp_flag <= '0';
        wait for 10.0ns;

        -- Finish simulation
        wait;
    end process;
end Behavioral;
