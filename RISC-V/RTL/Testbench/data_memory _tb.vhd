----------------------------------------------------------------------------------
-- University: Technical University of Munich
-- Student: Yu-Hung Tsai
-- 
-- Create Date: 03.07.2024 12:34:51
-- Design Name: 
-- Module Name: Data_Memory Testbench
-- Project Name:
-- Description:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.ALL;

entity DataMemory_tb is
end DataMemory_tb;

architecture Behavioral of DataMemory_tb is
    -- Component declaration for the DataMemory
    component DataMemory
        Port (
            clk        : in  BIT;
            mem_read   : in  BIT;
            mem_write  : in  BIT;
            funct3     : in  BIT_VECTOR(2 downto 0);
            address    : in  BIT_VECTOR(7 downto 0);
            write_data : in  BIT_VECTOR(31 downto 0);
            read_data  : out BIT_VECTOR(31 downto 0)
        );
    end component;

    -- Signals to connect to the DataMemory
    signal clk        : BIT := '0';
    signal mem_read   : BIT := '0';
    signal mem_write  : BIT := '0';
    signal funct3     : BIT_VECTOR(2 downto 0) := (others => '0');
    signal address    : BIT_VECTOR(7 downto 0) := (others => '0');
    signal write_data : BIT_VECTOR(31 downto 0) := (others => '0');
    signal read_data  : BIT_VECTOR(31 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: DataMemory
        Port map (
            clk => clk,
            mem_read => mem_read,
            mem_write => mem_write,
            funct3 => funct3,
            address => address,
            write_data => write_data,
            read_data => read_data
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- Stimulus process
    stim_proc: process
    begin        
        -- Store Byte
        mem_write <= '1';
        funct3 <= "000";
        address <= "00000001";
        write_data <= x"000000AB"; -- Store 0xAB at address 1
        wait for 10 ns;

        -- Store Half-word
        funct3 <= "001";
        address <= "00000010";
        write_data <= x"0000CDEF"; -- Store 0xEF at address 2, 0xCD at address 3
        wait for 10 ns;

        -- Store Word
        funct3 <= "010";
        address <= "00000100";
        write_data <= x"12345678"; -- Store 0x78 at address 4, 0x56 at address 5, 0x34 at address 6, 0x12 at address 7
        wait for 10 ns;

        -- Read Byte
        mem_write <= '0';
        mem_read <= '1';
        funct3 <= "000";
        address <= "00000001"; -- Read from address 1
        wait for 10 ns;
        
        -- Check the result
        assert read_data = x"000000AB"
        report "Test failed for LB" severity error;

        -- Read Half-word
        funct3 <= "001";
        address <= "00000010"; -- Read from address 2
        wait for 10 ns;
        
        -- Check the result
        assert read_data = x"0000EFCD"
        report "Test failed for LH" severity error;

        -- Read Word
        funct3 <= "010";
        address <= "00000100"; -- Read from address 4
        wait for 10 ns;
        
        -- Check the result
        assert read_data = x"12345678"
        report "Test failed for LW" severity error;

        -- End simulation
        wait;
    end process;

end Behavioral;
