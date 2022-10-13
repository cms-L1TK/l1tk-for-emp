-- ==============================================================
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2020.1 (64-bit)
-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity InputRouterTop_IR_DTC_2S_3_A_kPhiCorrtable_L2_rom is 
    generic(
             DWIDTH     : integer := 14; 
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


architecture rtl of InputRouterTop_IR_DTC_2S_3_A_kPhiCorrtable_L2_rom is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
signal addr1_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal mem : mem_array := (
    0 to 7=> "00000000000000", 8 => "00000000110110", 9 => "00000000100111", 
    10 => "00000000010111", 11 => "00000000000111", 12 => "11111111111001", 
    13 => "11111111101001", 14 => "11111111011001", 15 => "11111111001010", 
    16 => "00000001001110", 17 => "00000000110111", 18 => "00000000100001", 
    19 => "00000000001011", 20 => "11111111110101", 21 => "11111111011111", 
    22 => "11111111001001", 23 => "11111110110010", 24 => "00000001110101", 
    25 => "00000001010011", 26 => "00000000110010", 27 => "00000000010000", 
    28 => "11111111110000", 29 => "11111111001110", 30 => "11111110101101", 
    31 => "11111110001011", 32 => "01101101110011", 33 => "01001110011011", 
    34 => "00101111000011", 35 => "00001111101011", 36 => "11110000010101", 
    37 => "11010000111101", 38 => "10110001100101", 39 => "10010010001101", 
    40 => "11111110001011", 41 => "11111110101101", 42 => "11111111001110", 
    43 => "11111111110000", 44 => "00000000010000", 45 => "00000000110010", 
    46 => "00000001010011", 47 => "00000001110101", 48 => "11111110110010", 
    49 => "11111111001001", 50 => "11111111011111", 51 => "11111111110101", 
    52 => "00000000001011", 53 => "00000000100001", 54 => "00000000110111", 
    55 => "00000001001110", 56 => "11111111001010", 57 => "11111111011001", 
    58 => "11111111101001", 59 => "11111111111001", 60 => "00000000000111", 
    61 => "00000000010111", 62 => "00000000100111", 63 => "00000000110110" );

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

entity InputRouterTop_IR_DTC_2S_3_A_kPhiCorrtable_L2 is
    generic (
        DataWidth : INTEGER := 14;
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

architecture arch of InputRouterTop_IR_DTC_2S_3_A_kPhiCorrtable_L2 is
    component InputRouterTop_IR_DTC_2S_3_A_kPhiCorrtable_L2_rom is
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
    InputRouterTop_IR_DTC_2S_3_A_kPhiCorrtable_L2_rom_U :  component InputRouterTop_IR_DTC_2S_3_A_kPhiCorrtable_L2_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0,
        addr1 => address1,
        ce1 => ce1,
        q1 => q1);

end architecture;


