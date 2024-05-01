----------------------------------------------------------------------------------
-- Company: Technical University of Munich
-- Engineer: Yu-Hung Tsai
-- 
-- Create Date: 04/26/2024 01:47:55 PM
-- Design Name: mem_int
-- Module Name: mem_int - Behavioral
-- Project Name: Memory Model LAB
-- Target Devices: 
-- Tool Versions: 
-- Description: It is a memory model with integer index (UUT2).
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_int is
    port (
        w_en    : in  boolean;
        addr    : in  integer range 4095 downto 0;
        data_in : in  integer range 4095 downto 0;
        data_out: out integer range 4095 downto 0
    );
end mem_int;

architecture Behavioral of mem_int is

begin
    process( w_en, addr, data_in)
        type mem_type is array
            (integer range 4095 downto 0) of
                integer range 4095 downto 0;
        variable Mem: mem_type;
    begin
        if w_en then
            Mem(addr) := data_in;
        end if;
        data_out <= Mem(addr);
    end process;

end Behavioral;
