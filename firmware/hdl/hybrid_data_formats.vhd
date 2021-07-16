library ieee;
use ieee.std_logic_1164.all;


package hybrid_data_formats is


constant widthR    : natural := 7;
constant widthLayer: natural := 2;
constant widthBX   : natural := 3;

constant widthPSz    : natural := 12;
constant widthPSphi  : natural := 14;
constant widthPSbend : natural :=  3;
constant widthPSr    : natural := widthR;
constant widthPSlayer: natural := widthLayer;
constant widthPSbx   : natural := widthBX;

constant width2Sz    : natural :=  8;
constant width2Sphi  : natural := 17;
constant width2Sbend : natural :=  4;
constant width2Sr    : natural := widthR;
constant width2Slayer: natural := widthLayer;
constant width2Sbx   : natural := widthBX;

constant widthSeedType: natural :=  3;
constant widthInv2R   : natural := 14;
constant widthPhi0    : natural := 18;
constant widthZ0      : natural := 10;
constant widthCot     : natural := 14;

constant widthTrackId: natural :=  7;
constant widthStubId : natural := 10;
constant widthPhi    : natural := 12;
constant widthZ      : natural :=  9;


end;