
--Made by YuHung, Memory with Integer indices
library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

entity RAM4096x12_1dim is
    port (
        w_en    : in  boolean;
        addr    : in  integer range 4095 downto 0;
        data_in : in  integer range 4095 downto 0;
        data_out: out integer range 4095 downto 0
    );
end RAM4096x12_1dim;

architecture Behavioral of RAM4096x12_1dim is

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



----Made by Hian Zing Voon, Memory with bit_vectore indicies
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

--entity mem_12d is
----  Port
--    port (
--        w_en    : in boolean; 
--        addr    : in bit_vector( 11 downto 0 );
--        data_in : in bit_vector( 11 downto 0 ); 
--        data_out: out bit_vector( 11 downto 0 )
--        );
--end mem_12d;

--architecture Behavioral12d of mem_12d is

--begin
--    process( w_en, addr, data_in)
--        type mem_type is array
--            (bit,bit,bit,bit,bit,bit,bit,bit,bit,bit,bit,bit) of
--                bit_vector( 11 downto 0 );
--        variable Mem: mem_type;
--    begin 
--        -- conditional write
--        if w_en then
--            Mem(addr(11),addr(10),addr(9),addr(8),
--                addr(7),addr(6),addr(5),addr(4),
--                addr(3),addr(2),addr(1),addr(0))
--                := data_in;
--        end if;
--        -- continuous read
--        data_out<=Mem(addr(11),addr(10),addr(9),
--                      addr(8),addr(7),addr(6),
--                      addr(5),addr(4),addr(3),
--                      addr(2),addr(1),addr(0));
        
--        end process;

--end Behavioral12d;


----------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
