----------------------------------------------------------------------------------
-- Company: Technische Universität München
-- Engineer: Arun Prema Murugavel
-- Matrikel Nummer: 03787979
-- Email: arun.murugavel@tum.de
-- 
-- Create Date: 07/02/2024 01:46:51 PM
-- Design Name: Controller
-- Module Name: controller - Behavioral
-- Project Name: RISC V 32
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

entity controller is
    port (
        clk              : in bit;
        reset            : in bit;
        
        -- FSM Inputs
        next_state_flag  : in bit;
        jmp_flag         : in bit;
        store_flag       : in bit;
        load_flag        : in bit;
        mem_flag         : in bit_vector(2 downto 0);

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
        pc_jmp_flag    : out bit
    );
end controller;


architecture Behavioral of controller is

    -- Define Various State Types (Enumeration); 2^n Values
    type state_type is (FETCH, DECODE_EXECUTE, MEM, RD);
    signal state, next_state : state_type;

begin
    -- Dual Process
    -- State register
    process (clk, reset) -- Sequential
    begin
        if reset = '1' then
            state <= FETCH;
            instr_decode_flags_reset <= '1';
        elsif clk = '1' and clk'event then
            state <= next_state;
            instr_decode_flags_reset <= '0';
        end if;
    end process;

    -- Next State Logic and Output Logic
    process (state, next_state_flag, jmp_flag, store_flag, load_flag, mem_flag) -- Combinational
    begin
        case state is
            when FETCH =>
                -- State Outputs in the FETCH state
                mem_read_en <= '0';
                mem_write_en <= '0';
                reg_write_en <= '0';
                pc_ctrl_en <= '0';
                instr_holder_en <= '1';
                instr_decode_flags_reset <= '0';
                pc_jmp_flag <= '0';
                
                -- Next State
                next_state <= DECODE_EXECUTE;

            when DECODE_EXECUTE =>          
                -- General Outputs
                instr_holder_en <= '0';
                pc_ctrl_en <= '1';
                reg_write_en <= '1';
                
                -- Next State
                if load_flag = '1' or jmp_flag = '1' or store_flag = '1' then -- Load, Store or Jump Instruction
                    next_state <= MEM;
                else
                    next_state <= FETCH;
                    instr_decode_flags_reset <= '1';
                end if;

            when MEM =>
                -- General Output
                reg_write_en <= '0';
                pc_ctrl_en <= '0'; 
                              
                if jmp_flag = '1' then
                    -- Next State
                    next_state <= FETCH;
                    
                    -- State Outputs in the MEM State
                    instr_decode_flags_reset <= '1';
                    pc_jmp_flag <= '1';
                elsif store_flag = '1' then
                    -- Next State
                    next_state <= FETCH;
                    
                    -- State Outputs in the MEM State
                    mem_write_en <= '1';
                    instr_decode_flags_reset <= '1';
                else
                    -- Next State
                    next_state <= RD;
                    
                    -- State Outputs in the MEM State
                    mem_read_en <= '1';
                    instr_decode_flags_reset <= '1';                    
                end if;

            when RD =>
                -- Next State
                next_state <= FETCH;
                
                -- State Outputs in the RD State
                reg_write_en <= '1';

            when others =>
                next_state <= FETCH;
        end case;
    end process;

end Behavioral;