-- ==============================================================
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity InputRouterTop_IR_DTC_PS_1_B_kPhiCorrtable_L1_rom is 
    generic(
             DWIDTH     : integer := 15; 
             AWIDTH     : integer := 6; 
             MEM_SIZE    : integer := 64
    ); 
    port (
          addr0      : in std_logic_vector(AWIDTH-1 downto 0); 
          ce0       : in std_logic; 
          q0         : out std_logic_vector(DWIDTH-1 downto 0);
          addr1      : in std_logic_vector(AWIDTH-1 downto 0); 
          ce1       : in std_logic; 
          q1         : out std_logic_vector(DWIDTH-1 downto 0);
          clk       : in std_logic
    ); 
end entity; 


architecture rtl of InputRouterTop_IR_DTC_PS_1_B_kPhiCorrtable_L1_rom is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
signal addr1_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal mem : mem_array := (
    0 to 7=> "000000000000000", 8 => "000000000111010", 9 => "000000000101001", 
    10 => "000000000011000", 11 => "000000000001000", 12 => "111111111111000", 
    13 => "111111111101000", 14 => "111111111010111", 15 => "111111111000110", 
    16 => "000000001010001", 17 => "000000000111010", 18 => "000000000100010", 
    19 => "000000000001011", 20 => "111111111110101", 21 => "111111111011110", 
    22 => "111111111000110", 23 => "111111110101111", 24 => "000000001011101", 
    25 => "000000001000010", 26 => "000000000100111", 27 => "000000000001101", 
    28 => "111111111110011", 29 => "111111111011001", 30 => "111111110111110", 
    31 => "111111110100011", 32 => "010100011101110", 33 => "001110100111100", 
    34 => "001000110001010", 35 => "000010111011000", 36 => "111101000101000", 
    37 => "110111001110110", 38 => "110001011000100", 39 => "101011100010010", 
    40 => "111111110001100", 41 => "111111110101101", 42 => "111111111001111", 
    43 => "111111111110000", 44 => "000000000010000", 45 => "000000000110001", 
    46 => "000000001010011", 47 => "000000001110100", 48 => "111111110011000", 
    49 => "111111110110110", 50 => "111111111010100", 51 => "111111111110010", 
    52 => "000000000001110", 53 => "000000000101100", 54 => "000000001001010", 
    55 => "000000001101000", 56 => "111111110100011", 57 => "111111110111110", 
    58 => "111111111011001", 59 => "111111111110011", 60 => "000000000001101", 
    61 => "000000000100111", 62 => "000000001000010", 63 => "000000001011101" );

attribute syn_rom_style : string;
attribute syn_rom_style of mem : signal is "select_rom";
attribute ROM_STYLE : string;
attribute ROM_STYLE of mem : signal is "distributed";

begin 


memory_access_guard_0: process (addr0) 
begin
      addr0_tmp <= addr0;
--synthesis translate_off
      if (CONV_INTEGER(addr0) > mem_size-1) then
           addr0_tmp <= (others => '0');
      else 
           addr0_tmp <= addr0;
      end if;
--synthesis translate_on
end process;

memory_access_guard_1: process (addr1) 
begin
      addr1_tmp <= addr1;
--synthesis translate_off
      if (CONV_INTEGER(addr1) > mem_size-1) then
           addr1_tmp <= (others => '0');
      else 
           addr1_tmp <= addr1;
      end if;
--synthesis translate_on
end process;

p_rom_access: process (clk)  
begin 
    if (clk'event and clk = '1') then
        if (ce0 = '1') then 
            q0 <= mem(CONV_INTEGER(addr0_tmp)); 
        end if;
        if (ce1 = '1') then 
            q1 <= mem(CONV_INTEGER(addr1_tmp)); 
        end if;
    end if;
end process;

end rtl;

Library IEEE;
use IEEE.std_logic_1164.all;

entity InputRouterTop_IR_DTC_PS_1_B_kPhiCorrtable_L1 is
    generic (
        DataWidth : INTEGER := 15;
        AddressRange : INTEGER := 64;
        AddressWidth : INTEGER := 6);
    port (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        address0 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce0 : IN STD_LOGIC;
        q0 : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
        address1 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce1 : IN STD_LOGIC;
        q1 : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0));
end entity;

architecture arch of InputRouterTop_IR_DTC_PS_1_B_kPhiCorrtable_L1 is
    component InputRouterTop_IR_DTC_PS_1_B_kPhiCorrtable_L1_rom is
        port (
            clk : IN STD_LOGIC;
            addr0 : IN STD_LOGIC_VECTOR;
            ce0 : IN STD_LOGIC;
            q0 : OUT STD_LOGIC_VECTOR;
            addr1 : IN STD_LOGIC_VECTOR;
            ce1 : IN STD_LOGIC;
            q1 : OUT STD_LOGIC_VECTOR);
    end component;



begin
    InputRouterTop_IR_DTC_PS_1_B_kPhiCorrtable_L1_rom_U :  component InputRouterTop_IR_DTC_PS_1_B_kPhiCorrtable_L1_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0,
        addr1 => address1,
        ce1 => ce1,
        q1 => q1);

end architecture;


