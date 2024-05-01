----------------------------------------------------------------------------------
-- Company: Technical University of Munich
-- Engineer: Arun Prema Murugavel
-- 
-- Create Date: 04/26/2024 01:47:55 PM
-- Design Name: mem_12d
-- Module Name: mem_12d - Behavioral
-- Project Name: Memory Model LAB
-- Target Devices: 
-- Tool Versions: 
-- Description: It is a memory model with 12-dimensional index (UUT1).
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

entity mem_12d is
    generic(
	address_bits: integer := 12);
    port (
        w_en    : in  boolean;
        addr    : in  bit_vector((address_bits-1) downto 0);
        data_in : in  bit_vector((address_bits-1) downto 0);
        data_out: out bit_vector((address_bits-1) downto 0)
    );
end mem_12d;

architecture Behavioral of mem_12d is

begin
    process( w_en, addr, data_in)
        type mem_type is array
            (bit,bit,bit,bit,bit,bit,bit,bit,bit,bit,bit,bit) of
                bit_vector( 11 downto 0 );
        variable Mem: mem_type;
    begin
        -- conditional write
        if w_en then
            Mem(addr(11),addr(10),addr(9),addr(8),
                addr(7),addr(6),addr(5),addr(4),
                addr(3),addr(2),addr(1),addr(0))
                := data_in;
        end if;
        -- continuous read
        data_out<=Mem(addr(11),addr(10),addr(9),
                      addr(8),addr(7),addr(6),
                      addr(5),addr(4),addr(3),
                      addr(2),addr(1),addr(0));
        
        end process;

end Behavioral;
