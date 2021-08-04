library ieee;
use ieee.std_logic_1164.all;


package hybrid_data_formats is


constant widthTrackletR    : natural := 7;
constant widthTrackletLayer: natural := 2;
constant widthTrackletBX   : natural := 3;

constant widthPSz    : natural := 12;
constant widthPSphi  : natural := 14;
constant widthPSbend : natural :=  3;
constant widthPSr    : natural := widthTrackletR;
constant widthPSlayer: natural := widthTrackletLayer;
constant widthPSbx   : natural := widthTrackletBX;

constant width2Sz    : natural :=  8;
constant width2Sphi  : natural := 17;
constant width2Sbend : natural :=  4;
constant width2Sr    : natural := widthTrackletR;
constant width2Slayer: natural := widthTrackletLayer;
constant width2Sbx   : natural := widthTrackletBX;

constant widthTrackletSeedType: natural :=  3;
constant widthTrackletInv2R   : natural := 14;
constant widthTrackletPhi0    : natural := 18;
constant widthTrackletZ0      : natural := 10;
constant widthTrackletCot     : natural := 14;

constant widthTrackletTrackId: natural :=  7;
constant widthTrackletStubId : natural := 10;
constant widthTrackletPhi    : natural := 12;
constant widthTrackletZ      : natural :=  9;

constant widthKFinv2R: natural := 16;
constant widthKFphiT : natural := 11;
constant widthKFzT   : natural := 13;
constant widthKFcot  : natural := 14;
constant widthKFphi  : natural := 10;
constant widthKFz    : natural := 12;

constant widthKFhits  : natural := 6;
constant widthKFsector: natural := 5;
constant widthKFr     : natural := 12;
constant widthKFdPhi  : natural := 9;
constant widthKFdZ    : natural := 10;


end;