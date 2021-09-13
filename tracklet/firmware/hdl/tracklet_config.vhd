library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.hybrid_data_formats.all;


package tracklet_config is

constant numIR           : natural := 17;
constant numNodeInputsIR : naturals( 0 to numIR - 1 ) := ( others => 1 );
constant numNodeOutputsIR: naturals( 0 to numIR - 1 ) := ( 9 => 2, others => 1 );
constant numInputsIR     : natural := sum( numNodeInputsIR  & 0 );
constant numOutputsIR    : natural := sum( numNodeOutputsIR & 0 );

constant numVMR           : natural := 6;
constant numNodeInputsVMR : naturals( 0 to numVMR - 1 ) := ( 3, 2, 4, 2, 3, 4 );
constant numNodeOutputsVMR: naturals( 0 to numVMR - 1 ) := ( 10, 10, 9, 9, 9, 9 );
constant numInputsVMR     : natural := sum( numNodeInputsVMR  & 0 );
constant numOutputsVMR    : natural := sum( numNodeOutputsVMR & 0 );
constant mappingVMR       : naturals( 0 to numInputsVMR - 1 ) := ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 10, 12, 13, 14, 15, 16, 17 );

constant numTE           : natural := 9;
constant numNodeInputsTE : naturals( 0 to numTE - 1 ) := ( others => 2 );
constant numNodeOutputsTE: naturals( 0 to numTE - 1 ) := ( others => 1 );
constant numInputsTE     : natural := sum( numNodeInputsTE  & 0 );
constant numOutputsTE    : natural := sum( numNodeOutputsTE & 0 );
constant mappingTE       : naturals( 0 to numInputsTE - 1 ) := ( 19, 32, 20, 35, 21, 29, 22, 30, 23, 33, 24, 36, 25, 31, 26, 34, 27, 37 );

constant numTC           : natural := 1;
constant numNodeInputsTC : naturals( 0 to numTC - 1 ) := ( others => 11 );
constant numNodeOutputsTC: naturals( 0 to numTC - 1 ) := ( others =>  5 );
constant numInputsTC     : natural := sum( numNodeInputsTC  & 0 );
constant numOutputsTC    : natural := sum( numNodeOutputsTC & 0 );
constant mappingTC       : naturals( 0 to numInputsTC - 1 ) := ( 18, 28, 74, 75, 76, 77, 78, 79, 80, 81, 82 );

constant numPR           : natural := 4;
constant numNodeInputsPR : naturals( 0 to numPR - 1 ) := ( others => 1 );
constant numNodeOutputsPR: naturals( 0 to numPR - 1 ) := ( others => 9 );
constant numInputsPR     : natural := sum( numNodeInputsPR & 0 );
constant numOutputsPR    : natural := sum( numNodeOutputsPR & 0);
constant mappingPR       : naturals( 0 to numInputsPR - 1 ) := nota( numInputsPR, 83 );

constant numME           : natural := 32;
constant numNodeInputsME : naturals( 0 to numME - 1 ) := ( others => 2 );
constant numNodeOutputsME: naturals( 0 to numME - 1 ) := ( others => 1 );
constant numInputsME     : natural := sum( numNodeInputsME  & 0 );
constant numOutputsME    : natural := sum( numNodeOutputsME & 0 );
constant mappingME       : naturals( 0 to numInputsME - 1 ) := ( 39, 88, 40, 89, 41, 90, 42, 91, 43, 92, 44, 93, 45, 94, 46, 95, 48, 97, 49, 98, 50, 99, 51, 100, 52, 101, 53, 102, 54, 103, 55, 104, 57, 106, 58, 107, 59, 108, 60, 109, 61, 110, 62, 111, 63, 112, 64, 113, 66, 115, 67, 116, 68, 117, 69, 118, 70, 119, 71, 120, 72, 121, 73, 122 );

constant numMC           : natural := 4;
constant numNodeInputsMC : naturals( 0 to numMC - 1 ) := ( others => 10 );
constant numNodeOutputsMC: naturals( 0 to numMC - 1 ) := ( others =>  1 );
constant numInputsMC     : natural := sum( numNodeInputsMC  & 0  );
constant numOutputsMC    : natural := sum( numNodeOutputsMC & 0 );
constant mappingMC       : naturals( 0 to numInputsMC - 1 ) := ( 124, 125, 126, 127, 128, 129, 130, 131,  38,  96, 132, 133, 134, 135, 136, 137, 138, 139,  47, 105, 140, 141, 142, 143, 144, 145, 146, 147,  56, 114, 148, 149, 150, 151, 152, 153, 154, 155,  65, 123 );

constant numFT           : natural := 1;
constant numNodeInputsFT : naturals( 0 to numFT - 1 ) := ( others => 5 );
constant numNodeOutputsFT: naturals( 0 to numFT - 1 ) := ( others => 5 );
constant numInputsFT     : natural := sum( numNodeInputsFT  & 0 );
constant numOutputsFT    : natural := sum( numNodeOutputsFT & 0 );
constant mappingFT       : naturals( 0 to numInputsFT - 1 ) := ( 87, 156, 157, 158, 159 );

constant sumMemOutIR : natural :=                numOutputsIR;
constant sumMemOutVMR: natural := sumMemOutIR  + numOutputsVMR;
constant sumMemOutTE : natural := sumMemOutVMR + numOutputsTE;
constant sumMemOutTC : natural := sumMemOutTE  + numOutputsTC;
constant sumMemOutPR : natural := sumMemOutTC  + numOutputsPR;
constant sumMemOutME : natural := sumMemOutPR  + numOutputsME;
constant sumMemOutMC : natural := sumMemOutME  + numOutputsMC;

constant numMemories: natural := sumMemOutMC;

constant sumMemInVMR: natural :=               numInputsVMR;
constant sumMemInTE : natural := sumMemInVMR + numInputsTE;
constant sumMemInTC : natural := sumMemInTE  + numInputsTC;
constant sumMemInPR : natural := sumMemInTC  + numInputsPR;
constant sumMemInME : natural := sumMemInPR  + numInputsME;
constant sumMemInMC : natural := sumMemInME  + numInputsMC;
constant sumMemInFT : natural := sumMemInMC  + numInputsFT;

constant mapping: naturals( 0 to numMemories - 1 ) := mappingVMR & mappingTE & mappingTC & mappingPR & mappingME & mappingMC & mappingFT;
function init_reverseMapping return naturals;
constant reverseMapping: naturals( 0 to numMemories - 1 );

constant widthLink  : natural := 20;
constant widthPhiBin: natural := 32;
type t_links   is array ( natural range <> ) of std_logic_vector( widthLink   - 1 downto 0 );
type t_phiBins is array ( natural range <> ) of std_logic_vector( widthPhiBin - 1 downto 0 );

constant links: t_links( 0 to numOutputsIR - 1 ) := (
  0  to  2 => x"20003",
  3  to  4 => x"20005",
  5  to  8 => x"20007",
  9  to 11 => x"30009",
  12 to 13 => x"3000b",
  others   => x"3000d"
);

constant phiBins: t_phiBins( 0 to numOutputsIR - 1 ) := (
  0 to 2 => x"00000008",
  9      => x"00000202",
  others => x"00000002"
);

type t_lut_files is array ( natural range <> ) of string( 1 to 54 );
constant lut_files: t_lut_files( 0 to 2 * numTE - 1 ) := (
  "../emData/LUTs/TE_L1PHID14_L2PHIB15_stubptinnercut.tab",
  "../emData/LUTs/TE_L1PHID14_L2PHIB15_stubptoutercut.tab",
  "../emData/LUTs/TE_L1PHID14_L2PHIB16_stubptinnercut.tab",
  "../emData/LUTs/TE_L1PHID14_L2PHIB16_stubptoutercut.tab",
  "../emData/LUTs/TE_L1PHID15_L2PHIB13_stubptinnercut.tab",
  "../emData/LUTs/TE_L1PHID15_L2PHIB13_stubptoutercut.tab",
  "../emData/LUTs/TE_L1PHID15_L2PHIB14_stubptinnercut.tab",
  "../emData/LUTs/TE_L1PHID15_L2PHIB14_stubptoutercut.tab",
  "../emData/LUTs/TE_L1PHID15_L2PHIB15_stubptinnercut.tab",
  "../emData/LUTs/TE_L1PHID15_L2PHIB15_stubptoutercut.tab",
  "../emData/LUTs/TE_L1PHID15_L2PHIB16_stubptinnercut.tab",
  "../emData/LUTs/TE_L1PHID15_L2PHIB16_stubptoutercut.tab",
  "../emData/LUTs/TE_L1PHID16_L2PHIB14_stubptinnercut.tab",
  "../emData/LUTs/TE_L1PHID16_L2PHIB14_stubptoutercut.tab",
  "../emData/LUTs/TE_L1PHID16_L2PHIB15_stubptinnercut.tab",
  "../emData/LUTs/TE_L1PHID16_L2PHIB15_stubptoutercut.tab",
  "../emData/LUTs/TE_L1PHID16_L2PHIB16_stubptinnercut.tab",
  "../emData/LUTs/TE_L1PHID16_L2PHIB16_stubptoutercut.tab"
);

constant numPages : natural := 8;
constant widthBX  : natural := width( numPages );
constant widthAddr: natural := widthBX + widthFrames;
constant widthNent: natural := widthFrames;
constant widthData: natural := 84;

constant NUM_MEM_BINS            : natural := 8;
constant NUM_ENTRIES_PER_MEM_BINS: natural := 2 ** widthNent / NUM_MEM_BINS;

constant numNent: natural := numPages * NUM_ENTRIES_PER_MEM_BINS;

subtype r_dataDTC   is natural range 39 - 1 downto 0;
subtype r_trackWord is natural range 84 - 1 downto 0;
subtype r_stubWord  is natural range 46 - 1 downto 0;

end;


package body tracklet_config is


function init_reverseMapping return naturals is
  variable res: naturals( mapping'range );
begin
  for k in mapping'range loop
    res( mapping( k ) ) := k;
  end loop;
  return res;
end function;

constant reverseMapping: naturals( 0 to numMemories - 1 ) := init_reverseMapping;


end;