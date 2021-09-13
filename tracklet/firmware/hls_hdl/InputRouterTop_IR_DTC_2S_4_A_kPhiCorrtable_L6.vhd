-- ==============================================================
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2020.1 (64-bit)
-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity InputRouterTop_IR_DTC_2S_4_A_kPhiCorrtable_L6_rom is 
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


architecture rtl of InputRouterTop_IR_DTC_2S_4_A_kPhiCorrtable_L6_rom is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
signal addr1_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal mem : mem_array := (
    0 to 7=> "0000000000000000", 8 => "0000000010101101", 9 => "0000000001111100", 
    10 => "0000000001001010", 11 => "0000000000011000", 12 => "1111111111101000", 
    13 => "1111111110110110", 14 => "1111111110000100", 15 => "1111111101010011", 
    16 => "0000000101011011", 17 => "0000000011111000", 18 => "0000000010010101", 
    19 => "0000000000110001", 20 => "1111111111001111", 21 => "1111111101101011", 
    22 => "1111111100001000", 23 => "1111111010100101", 24 => "0000001000011100", 
    25 => "0000000110000010", 26 => "0000000011100111", 27 => "0000000001001101", 
    28 => "1111111110110011", 29 => "1111111100011001", 30 => "1111111001111110", 
    31 => "1111110111100100", 32 => "0000001011011110", 33 => "0000001000001100", 
    34 => "0000000100111010", 35 => "0000000001101000", 36 => "1111111110011000", 
    37 => "1111111011000110", 38 => "1111110111110100", 39 => "1111110100100010", 
    40 => "0000001101100101", 41 => "0000001001101100", 42 => "0000000101110100", 
    43 => "0000000001111100", 44 => "1111111110000100", 45 => "1111111010001100", 
    46 => "1111110110010100", 47 => "1111110010011011", 48 => "0000001111111111", 
    49 => "0000001011011011", 50 => "0000000110110110", 51 => "0000000010010010", 
    52 => "1111111101101110", 53 => "1111111001001010", 54 => "1111110100100101", 
    55 => "1111110000000001", 56 => "0000010001110011", 57 => "0000001100101110", 
    58 => "0000000111101000", 59 => "0000000010100010", 60 => "1111111101011110", 
    61 => "1111111000011000", 62 => "1111110011010010", 63 => "1111101110001101", 
    64 => "0100001111010110", 65 => "0011000001110100", 66 => "0001110100010010", 
    67 => "0000100110110000", 68 => "1111011001010000", 69 => "1110001011101110", 
    70 => "1100111110001100", 71 => "1011110000101010", 72 => "1111101110001101", 
    73 => "1111110011010010", 74 => "1111111000011000", 75 => "1111111101011110", 
    76 => "0000000010100010", 77 => "0000000111101000", 78 => "0000001100101110", 
    79 => "0000010001110011", 80 => "1111110000000001", 81 => "1111110100100101", 
    82 => "1111111001001010", 83 => "1111111101101110", 84 => "0000000010010010", 
    85 => "0000000110110110", 86 => "0000001011011011", 87 => "0000001111111111", 
    88 => "1111110010011011", 89 => "1111110110010100", 90 => "1111111010001100", 
    91 => "1111111110000100", 92 => "0000000001111100", 93 => "0000000101110100", 
    94 => "0000001001101100", 95 => "0000001101100101", 96 => "1111110100100010", 
    97 => "1111110111110100", 98 => "1111111011000110", 99 => "1111111110011000", 
    100 => "0000000001101000", 101 => "0000000100111010", 102 => "0000001000001100", 
    103 => "0000001011011110", 104 => "1111110111100100", 105 => "1111111001111110", 
    106 => "1111111100011001", 107 => "1111111110110011", 108 => "0000000001001101", 
    109 => "0000000011100111", 110 => "0000000110000010", 111 => "0000001000011100", 
    112 => "1111111010100101", 113 => "1111111100001000", 114 => "1111111101101011", 
    115 => "1111111111001111", 116 => "0000000000110001", 117 => "0000000010010101", 
    118 => "0000000011111000", 119 => "0000000101011011", 120 => "1111111101010011", 
    121 => "1111111110000100", 122 => "1111111110110110", 123 => "1111111111101000", 
    124 => "0000000000011000", 125 => "0000000001001010", 126 => "0000000001111100", 
    127 => "0000000010101101" );


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

entity InputRouterTop_IR_DTC_2S_4_A_kPhiCorrtable_L6 is
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

architecture arch of InputRouterTop_IR_DTC_2S_4_A_kPhiCorrtable_L6 is
    component InputRouterTop_IR_DTC_2S_4_A_kPhiCorrtable_L6_rom is
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
    InputRouterTop_IR_DTC_2S_4_A_kPhiCorrtable_L6_rom_U :  component InputRouterTop_IR_DTC_2S_4_A_kPhiCorrtable_L6_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0,
        addr1 => address1,
        ce1 => ce1,
        q1 => q1);

end architecture;


