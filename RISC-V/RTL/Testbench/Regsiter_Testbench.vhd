----------------------------------------------------------------------------------
-- University: Technical University of Munich
-- Student: Tiemo Schmidt
-- 
-- Create Date: 28.06.2024 14:28:39
-- Design Name: 
-- Module Name: Regsiter_Testbench - Behavioral
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
use IEEE.NUMERIC_bit.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Regsiter_Testbench is
--  Port ( );
end Regsiter_Testbench;

architecture Behavioral of Regsiter_Testbench is
    component RegisterFile
        Port(clk : in bit;
          res : in bit;
          rd1_addr : in bit_vector(4 downto 0);
          rd2_addr : in bit_vector(4 downto 0);
          wr_addr : in bit_vector(4 downto 0);
          rd1_data : out bit_vector(31 downto 0);
          rd2_data : out bit_vector(31 downto 0);
          wr_data : in bit_vector(31 downto 0);
          wr_enab : in bit);
          end component;
          
          Signal clk : bit;
          Signal res :  bit;
          Signal rd1_addr :  bit_vector(4 downto 0);
          Signal rd2_addr :  bit_vector(4 downto 0);
          Signal wr_addr :  bit_vector(4 downto 0);
          Signal rd1_data :  bit_vector(31 downto 0);
          Signal rd2_data :  bit_vector(31 downto 0);
          Signal  wr_data :  bit_vector(31 downto 0);
          Signal  wr_enab :  bit;
          
begin
    UUT : RegisterFile Port Map (clk, res, rd1_addr, rd2_addr, wr_addr, rd1_data, rd2_data, wr_data, wr_enab);
    
    clk_pro: process
    begin
    clk <= not clk;
    wait for 25ns;
    end process;
    
    --fill Register with 1 to 31

    Test : process 
    
    begin
        --fill Register with 1 to 31
        wait for 50ns;
        wr_enab <= '1';
        for i in 31 downto 1 LOOP
            wr_data <= bit_vector(TO_UNSIGNED(i+2, 32));
            wr_addr <= bit_vector(TO_UNSIGNED(i, 5));
            wait for 50ns; 
        end lOOP;
        wr_enab <= '0';
        wait for 50ns;
        --now get data
        --try asynchron get
        wait for 12ns;
        rd1_addr <= bit_vector(TO_UNSIGNED(4, 5));
        rd2_addr <= bit_vector(TO_UNSIGNED(5, 5));
        wait for 38ns;
        --look if all data was saved correct
        for i in 31 downto 0 LOOP
            rd1_addr <= bit_vector(TO_UNSIGNED(i, 5));
            rd2_addr <= bit_vector(TO_UNSIGNED(i, 5));
            wait for 50ns; 
        end lOOP;
        
        --Test Reset
        res <= '1';
        wait for 50ns;
        res <= '1';
        --look through all Registers if they are reset
        wait for 50ns;
                for i in 31 downto 0 LOOP
            rd1_addr <= bit_vector(TO_UNSIGNED(i, 5));
            rd2_addr <= bit_vector(TO_UNSIGNED(i, 5));
            wait for 50ns; 
        end lOOP;
        wait;
    end process;
end Behavioral;
