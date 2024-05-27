----------------------------------------------------------------------------------
-- Company: Technische Universität München
-- Engineer: Arun Prema Murugavel
-- 
-- Create Date: 05/27/2024 02:47:50 PM
-- Design Name: cpu_defs_pack
-- Module Name: cpu_defs_pack - Behavioral
-- Project Name: RISC-V-32
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

package cpu_defs_pack is 
    constant bus_width : natural := 32;
    constant data_width : natural := bus_width;
    constant addr_width : natural := 16;
    
    constant reg_addr_width : natural := 5;
    
    subtype data_type is
        natural range 0 to 2**(data_width - 1);
    
    subtype reg_addr_type is
        natural range 0 to 2**(reg_addr_width - 1);
        
    type reg_type is array(reg_addr_type) of data_type;
    
end cpu_defs_pack;