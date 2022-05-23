library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

PACKAGE kfout_data_formats IS

CONSTANT widthExtraMVA           : NATURAL :=  6;  
CONSTANT widthTQMVA              : NATURAL :=  3;  
CONSTANT widthHitPattern         : NATURAL :=  7;  
CONSTANT widthBendChi2           : NATURAL :=  3;  
CONSTANT widthChi2RPhi           : NATURAL :=  4;  
CONSTANT widthChi2RZ             : NATURAL :=  4;  
CONSTANT widthD0                 : NATURAL :=  13;  
CONSTANT widthZ0                 : NATURAL :=  12;  
CONSTANT widthTanL               : NATURAL :=  16;  
CONSTANT widthPhi0               : NATURAL :=  12;  
CONSTANT widthInvR               : NATURAL :=  15;  

CONSTANT numpartialTTTrack       : NATURAL :=  3;
CONSTANT widthpartialTTTrack     : NATURAL :=  32;
CONSTANT widthTTTrack            : NATURAL :=  numpartialTTTrack*widthpartialTTTrack;


END kfout_data_formats;