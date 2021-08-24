-- ==============================================================
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2020.1 (64-bit)
-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity MatchEngineTop_L3_table1_rom is 
    generic(
             DWIDTH     : integer := 1; 
             AWIDTH     : integer := 8; 
             MEM_SIZE    : integer := 256
    ); 
    port (
          addr0      : in std_logic_vector(AWIDTH-1 downto 0); 
          ce0       : in std_logic; 
          q0         : out std_logic_vector(DWIDTH-1 downto 0);
          clk       : in std_logic
    ); 
end entity; 


architecture rtl of MatchEngineTop_L3_table1_rom is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal mem : mem_array := (
    0 to 3=> "0", 4 => "1", 5 to 11=> "0", 12 => "1", 13 to 19=> "0", 20 => "1", 21 to 27=> "0", 
    28 to 29=> "1", 30 to 35=> "0", 36 to 37=> "1", 38 to 43=> "0", 44 to 46=> "1", 47 to 51=> "0", 52 to 55=> "1", 
    56 to 59=> "0", 60 to 63=> "1", 64 to 67=> "0", 68 to 71=> "1", 72 to 75=> "0", 76 to 80=> "1", 81 to 83=> "0", 
    84 to 88=> "1", 89 to 91=> "0", 92 => "1", 93 => "0", 94 to 96=> "1", 97 to 99=> "0", 100 => "1", 
    101 => "0", 102 to 104=> "1", 105 to 107=> "0", 108 => "1", 109 to 110=> "0", 111 to 113=> "1", 114 to 115=> "0", 
    116 => "1", 117 to 118=> "0", 119 to 121=> "1", 122 to 123=> "0", 124 => "1", 125 to 126=> "0", 127 to 129=> "1", 
    130 to 131=> "0", 132 => "1", 133 to 134=> "0", 135 to 137=> "1", 138 to 139=> "0", 140 => "1", 141 to 142=> "0", 
    143 to 145=> "1", 146 to 147=> "0", 148 => "1", 149 to 151=> "0", 152 to 154=> "1", 155 => "0", 156 => "1", 
    157 to 159=> "0", 160 to 162=> "1", 163 => "0", 164 => "1", 165 to 167=> "0", 168 to 172=> "1", 173 to 176=> "0", 
    177 to 180=> "1", 181 to 184=> "0", 185 to 188=> "1", 189 to 192=> "0", 193 to 196=> "1", 197 to 200=> "0", 201 to 204=> "1", 
    205 to 209=> "0", 210 to 212=> "1", 213 to 218=> "0", 219 to 220=> "1", 221 to 226=> "0", 227 to 228=> "1", 229 to 235=> "0", 
    236 => "1", 237 to 243=> "0", 244 => "1", 245 to 251=> "0", 252 => "1", 253 to 255=> "0" );

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

p_rom_access: process (clk)  
begin 
    if (clk'event and clk = '1') then
        if (ce0 = '1') then 
            q0 <= mem(CONV_INTEGER(addr0_tmp)); 
        end if;
    end if;
end process;

end rtl;

Library IEEE;
use IEEE.std_logic_1164.all;

entity MatchEngineTop_L3_table1 is
    generic (
        DataWidth : INTEGER := 1;
        AddressRange : INTEGER := 256;
        AddressWidth : INTEGER := 8);
    port (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        address0 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce0 : IN STD_LOGIC;
        q0 : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0));
end entity;

architecture arch of MatchEngineTop_L3_table1 is
    component MatchEngineTop_L3_table1_rom is
        port (
            clk : IN STD_LOGIC;
            addr0 : IN STD_LOGIC_VECTOR;
            ce0 : IN STD_LOGIC;
            q0 : OUT STD_LOGIC_VECTOR);
    end component;



begin
    MatchEngineTop_L3_table1_rom_U :  component MatchEngineTop_L3_table1_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0);

end architecture;


