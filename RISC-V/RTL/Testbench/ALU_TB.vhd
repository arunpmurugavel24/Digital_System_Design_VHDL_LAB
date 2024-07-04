----------------------------------------------------------------------------------
-- University: Technical University of Munich
-- Student: Hian Zing Voon
-- 
-- Create Date: 03.07.2024 15:07:33
-- Design Name: ALU_TB
-- Module Name: ALU_TB - Behavioral
-- Project Name: ALU Test bench
-- Description: A test bench meant to check every single instruction set (if needed) of the arithmetic logic unit (ALU).
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU_TB is
--  Port is empty, as there are no inputs into TLE and no outputs from TLE
end ALU_TB;

architecture Behavioral of ALU_TB is
    signal f                : bit_vector(4 downto 0);
    signal f_str            : string(5 downto 1);
    signal a                : bit_vector(31 downto 0);
    signal b                : bit_vector(31 downto 0);
    signal outToDMem        : bit_vector(31 downto 0);
    signal ALU_condition    : bit;
    signal clk              : bit;
    
    component ALU
        port(
            f               : in bit_vector(4 downto 0);
            a               : in bit_vector(31 downto 0);
            b               : in bit_vector(31 downto 0);
            outToDMem       : out bit_vector(31 downto 0);
            ALU_condition   : out bit
            );
    end component;
begin
    
    -- Instanstiate the ALU --
    UUT1: ALU
        port map(
            f               => f,
            a               => a,
            b               => b,
            outToDMem       => outToDMem,
            ALU_condition   => ALU_condition
            );
    
    clk_pro: process
    begin
        clk <= not clk;
        wait for 2.5ns;
    end Process;        
    
    -- Test process --
    process
    begin   
        -- Initalise inputs --
        f       <= "00000";
        f_str   <= "Init ";
        a       <= x"00_00_00_00";  -- x: hexadecimal
        b       <= b"0000_0000_0000_0000_0000_0000_0000_0001";  -- b: binary
        wait for 5 ns;
        
        -- Test case: SLT/SLTI --
        a <= x"00_00_00_01";
        b <= x"00_00_00_10";
        f <= "00010";
        f_str <= "SLT. ";
        wait for 5 ns;
        
        -- Test case: SLTU/SLTIU --
        a <= x"00_00_01_00";
        b <= x"00_00_00_10";
        f <= "00010";
        f_str <= "SLTU.";
        wait for 5 ns;
        
        -- Test case: BEQ --
        a <= x"00_00_00_01";
        b <= x"00_00_00_01";
        f <= "00000";
        f_str <= "BEQ  ";
        wait for 5 ns;
        
        -- Test case: BNE --
        a <= x"00_00_00_01";
        b <= x"00_00_00_00";
        f <= "00001";
        f_str <= "BNE  ";
        wait for 5 ns;
        
        -- Test case: BLT --
        a <= x"00_00_00_01";
        b <= x"00_00_00_00";
        f <= "00100";
        f_str <= "BLT  ";
        wait for 5 ns;
        
        -- Test case: BGE --
        a <= x"00_00_00_01";
        b <= x"00_00_00_00";
        f <= "00101";
        f_str <= "BGE  ";
        wait for 5 ns;
        
        -- Test case: BLTU --
        a <= x"00_00_00_10";
        b <= x"00_00_00_00";
        f <= "00110";
        f_str <= "BLTU ";
        wait for 5 ns;
        
        -- Test case: BGEU --
        a <= x"00_00_00_10";
        b <= x"00_00_00_00";
        f <= "00111";
        f_str <= "BGEU ";
        wait for 5 ns;
        
        -- Test case: XOR/XORI --
        a <= x"00_00_00_10";
        b <= x"00_00_00_00";
        f <= "01100";
        f_str <= "XOR. ";
        wait for 5 ns;
        
        -- Test case: OR/ORI --
        a <= x"00_00_11_10";
        b <= x"01_00_00_00";
        f <= "01110";
        f_str <= "OR.  ";
        wait for 5 ns;
        
        -- Test case: AND/ANDI --
        a <= x"00_00_11_10";
        b <= x"00_00_00_00";
        f <= "01111";
        f_str <= "AND. ";
        wait for 5 ns;
        
        -- Test case: ADD/ADDI/SUB --
        a <= x"7f_ff_ff_ff";  -- 2147483647
        b <= x"00_00_00_1f";  -- 31
        f <= "10000";
        f_str <= "ADD. ";  -- Calculation of a+b = -2147483618 (no overflow)
        wait for 5 ns;
        
        -- Test case: SUB --
        a <= x"80_00_00_00";  -- -2147483648
        b <= x"ff_ff_ff_ff";  -- -1
        f <= "10000";
        f_str <= "SUB  ";  -- Calculation of a+b = 2147483647 (no overflow, 2's complement)
        wait for 5 ns;
        
        -- Test case: SLL/SLLI --
        a <= b"0000_0000_0000_0000_0000_0000_0000_0001"; 
        b <= b"0000_0000_0000_0000_0000_0000_0000_0010";  
        f <= "11001";
        f_str <= "SLL. "; 
        wait for 5 ns;
        
        -- Test case: SRL-SRLI --
        a <= b"0000_0000_0000_0000_0000_0000_0000_0010"; 
        b <= b"0000_0000_0000_0000_0000_0000_0000_0001";  
        f <= "11101";
        f_str <= "SRL. "; 
        wait for 5 ns;
        
        -- Test case: SRA/SRAI --
        a <= b"1000_0000_0000_0000_0000_0000_0000_0010"; 
        b <= b"0000_0000_0000_0000_0000_0000_0000_0100";  
        f <= "11111";
        f_str <= "SRA. "; 
        wait for 5 ns;
        
        
    end process;
end Behavioral;
