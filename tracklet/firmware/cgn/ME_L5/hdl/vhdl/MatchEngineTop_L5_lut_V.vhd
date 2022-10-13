-- ==============================================================
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2020.1 (64-bit)
-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity MatchEngineTop_L5_lut_V_rom is 
    generic(
             DWIDTH     : integer := 1; 
             AWIDTH     : integer := 9; 
             MEM_SIZE    : integer := 512
    ); 
    port (
          addr0      : in std_logic_vector(AWIDTH-1 downto 0); 
          ce0       : in std_logic; 
          q0         : out std_logic_vector(DWIDTH-1 downto 0);
          clk       : in std_logic
    ); 
end entity; 


architecture rtl of MatchEngineTop_L5_lut_V_rom is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal mem : mem_array := (
    0 to 7=> "0", 8 => "1", 9 to 23=> "0", 24 => "1", 25 to 39=> "0", 40 => "1", 41 to 55=> "0", 
    56 => "1", 57 to 71=> "0", 72 to 73=> "1", 74 to 87=> "0", 88 to 90=> "1", 91 to 103=> "0", 104 to 106=> "1", 
    107 to 119=> "0", 120 to 123=> "1", 124 to 135=> "0", 136 to 139=> "1", 140 to 151=> "0", 152 => "1", 153 to 154=> "0", 
    155 to 156=> "1", 157 to 167=> "0", 168 => "1", 169 to 170=> "0", 171 to 173=> "1", 174 to 183=> "0", 184 => "1", 
    185 to 187=> "0", 188 to 190=> "1", 191 to 199=> "0", 200 => "1", 201 to 203=> "0", 204 to 208=> "1", 209 to 215=> "0", 
    216 => "1", 217 to 220=> "0", 221 to 224=> "1", 225 to 231=> "0", 232 => "1", 233 to 237=> "0", 238 to 240=> "1", 
    241 to 247=> "0", 248 => "1", 249 to 253=> "0", 254 to 258=> "1", 259 to 263=> "0", 264 => "1", 265 to 271=> "0", 
    272 to 274=> "1", 275 to 279=> "0", 280 => "1", 281 to 287=> "0", 288 to 291=> "1", 292 to 295=> "0", 296 => "1", 
    297 to 304=> "0", 305 to 308=> "1", 309 to 311=> "0", 312 => "1", 313 to 321=> "0", 322 to 324=> "1", 325 to 327=> "0", 
    328 => "1", 329 to 338=> "0", 339 to 341=> "1", 342 to 343=> "0", 344 => "1", 345 to 355=> "0", 356 to 357=> "1", 
    358 to 359=> "0", 360 => "1", 361 to 372=> "0", 373 to 376=> "1", 377 to 388=> "0", 389 to 392=> "1", 393 to 405=> "0", 
    406 to 408=> "1", 409 to 421=> "0", 422 to 424=> "1", 425 to 438=> "0", 439 to 440=> "1", 441 to 455=> "0", 456 => "1", 
    457 to 471=> "0", 472 => "1", 473 to 487=> "0", 488 => "1", 489 to 503=> "0", 504 => "1", 505 to 511=> "0" );

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

entity MatchEngineTop_L5_lut_V is
    generic (
        DataWidth : INTEGER := 1;
        AddressRange : INTEGER := 512;
        AddressWidth : INTEGER := 9);
    port (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        address0 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce0 : IN STD_LOGIC;
        q0 : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0));
end entity;

architecture arch of MatchEngineTop_L5_lut_V is
    component MatchEngineTop_L5_lut_V_rom is
        port (
            clk : IN STD_LOGIC;
            addr0 : IN STD_LOGIC_VECTOR;
            ce0 : IN STD_LOGIC;
            q0 : OUT STD_LOGIC_VECTOR);
    end component;



begin
    MatchEngineTop_L5_lut_V_rom_U :  component MatchEngineTop_L5_lut_V_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0);

end architecture;


