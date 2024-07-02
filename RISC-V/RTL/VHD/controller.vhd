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
        
        -- FSM States
        
        -- FSM State Ouputs
        state_output     : out std_logic_vector(2 downto 0)  -- Optional output to monitor state
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
        elsif clk = '1' and clk'event then
            state <= next_state;
        end if;
    end process;

    -- Next State Logic and Output Logic
    process (state, next_state_flag, jmp_flag, store_flag, load_flag, mem_flag) -- Combinational
    begin
        -- Default Assignments to Output
        
        -- 
        case state is
            when FETCH =>
                -- State Outputs in the FETCH state
                
                -- Next State
                next_state <= DECODE_EXECUTE;

            when DECODE_EXECUTE =>
                -- State Outputs in the DECODE state
                
                -- Next State
                if next_state_flag = '1' then
                    next_state <= MEM;
                elsif load_flag = '1' or store_flag = '1' then
                    next_state <= FETCH;
                end if;

            when MEM =>
                if jmp_flag = '1' then
                    -- Next State
                    next_state <= FETCH;
                    
                    -- State Outputs in the MEM State
                    
                    
                else
                    -- Next State
                    next_state <= RD;
                    
                    -- State Outputs in the MEM state
                    
                    
                end if;

            when RD =>
                if load_flag = '1' then
                    -- Next State
                    next_state <= FETCH;
                    
                    -- State Outputs in RD State
                    
                    
                else
                    -- Next State
                    next_state <= FETCH;
                    
                    -- State Outputs in the RD State
                    
                    
                end if;

            when others =>
                next_state <= FETCH;
        end case;
    end process;

end Behavioral;