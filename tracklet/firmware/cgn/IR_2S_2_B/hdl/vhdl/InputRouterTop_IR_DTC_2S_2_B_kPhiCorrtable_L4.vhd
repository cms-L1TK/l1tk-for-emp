-- ==============================================================
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2020.1 (64-bit)
-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity InputRouterTop_IR_DTC_2S_2_B_kPhiCorrtable_L4_rom is 
    generic(
             DWIDTH     : integer := 16; 
             AWIDTH     : integer := 7; 
             MEM_SIZE    : integer := 128
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


architecture rtl of InputRouterTop_IR_DTC_2S_2_B_kPhiCorrtable_L4_rom is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
signal addr1_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal mem : mem_array := (
    0 to 7=> "0000000000000000", 8 => "0000000011010101", 9 => "0000000010011000", 
    10 => "0000000001011011", 11 => "0000000000011110", 12 => "1111111111100010", 
    13 => "1111111110100101", 14 => "1111111101101000", 15 => "1111111100101011", 
    16 => "0000000101101101", 17 => "0000000100000100", 18 => "0000000010011100", 
    19 => "0000000000110100", 20 => "1111111111001100", 21 => "1111111101100100", 
    22 => "1111111011111100", 23 => "1111111010010011", 24 => "0000001000100011", 
    25 => "0000000110000111", 26 => "0000000011101010", 27 => "0000000001001110", 
    28 => "1111111110110010", 29 => "1111111100010110", 30 => "1111111001111001", 
    31 => "1111110111011101", 32 => "0000001001111111", 33 => "0000000111001000", 
    34 => "0000000100010001", 35 => "0000000001011011", 36 => "1111111110100101", 
    37 => "1111111011101111", 38 => "1111111000111000", 39 => "1111110110000001", 
    40 => "0000001100010111", 41 => "0000001000110101", 42 => "0000000101010011", 
    43 => "0000000001110001", 44 => "1111111110001111", 45 => "1111111010101101", 
    46 => "1111110111001011", 47 => "1111110011101001", 48 => "0000001111001101", 
    49 => "0000001010110111", 50 => "0000000110100001", 51 => "0000000010001011", 
    52 => "1111111101110101", 53 => "1111111001011111", 54 => "1111110101001001", 
    55 => "1111110000110011", 56 => "0000010000101001", 57 => "0000001011111000", 
    58 => "0000000111001000", 59 => "0000000010011000", 60 => "1111111101101000", 
    61 => "1111111000111000", 62 => "1111110100001000", 63 => "1111101111010111", 
    64 => "0110101011011011", 65 => "0100110001010011", 66 => "0010110111001011", 
    67 => "0000111101000011", 68 => "1111000010111101", 69 => "1101001000110101", 
    70 => "1011001110101101", 71 => "1001010100100101", 72 => "1111101111010111", 
    73 => "1111110100001000", 74 => "1111111000111000", 75 => "1111111101101000", 
    76 => "0000000010011000", 77 => "0000000111001000", 78 => "0000001011111000", 
    79 => "0000010000101001", 80 => "1111110000110011", 81 => "1111110101001001", 
    82 => "1111111001011111", 83 => "1111111101110101", 84 => "0000000010001011", 
    85 => "0000000110100001", 86 => "0000001010110111", 87 => "0000001111001101", 
    88 => "1111110011101001", 89 => "1111110111001011", 90 => "1111111010101101", 
    91 => "1111111110001111", 92 => "0000000001110001", 93 => "0000000101010011", 
    94 => "0000001000110101", 95 => "0000001100010111", 96 => "1111110110000001", 
    97 => "1111111000111000", 98 => "1111111011101111", 99 => "1111111110100101", 
    100 => "0000000001011011", 101 => "0000000100010001", 102 => "0000000111001000", 
    103 => "0000001001111111", 104 => "1111110111011101", 105 => "1111111001111001", 
    106 => "1111111100010110", 107 => "1111111110110010", 108 => "0000000001001110", 
    109 => "0000000011101010", 110 => "0000000110000111", 111 => "0000001000100011", 
    112 => "1111111010010011", 113 => "1111111011111100", 114 => "1111111101100100", 
    115 => "1111111111001100", 116 => "0000000000110100", 117 => "0000000010011100", 
    118 => "0000000100000100", 119 => "0000000101101101", 120 => "1111111100101011", 
    121 => "1111111101101000", 122 => "1111111110100101", 123 => "1111111111100010", 
    124 => "0000000000011110", 125 => "0000000001011011", 126 => "0000000010011000", 
    127 => "0000000011010101" );


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

entity InputRouterTop_IR_DTC_2S_2_B_kPhiCorrtable_L4 is
    generic (
        DataWidth : INTEGER := 16;
        AddressRange : INTEGER := 128;
        AddressWidth : INTEGER := 7);
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

architecture arch of InputRouterTop_IR_DTC_2S_2_B_kPhiCorrtable_L4 is
    component InputRouterTop_IR_DTC_2S_2_B_kPhiCorrtable_L4_rom is
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
    InputRouterTop_IR_DTC_2S_2_B_kPhiCorrtable_L4_rom_U :  component InputRouterTop_IR_DTC_2S_2_B_kPhiCorrtable_L4_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0,
        addr1 => address1,
        ce1 => ce1,
        q1 => q1);

end architecture;


