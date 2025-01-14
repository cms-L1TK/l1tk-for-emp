library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.hybrid_config.all;
use work.hybrid_tools.all;


package hybrid_data_formats is


-- TFP

constant widthTFPinv2R: natural := tfpWidthInv2R;
constant widthTFPphi0 : natural := tfpWidthPhi0;
constant widthTFPcot  : natural := tfpWidthCot;
constant widthTFPz0   : natural := tfpWidthZ0;

constant baseTFPinv2R: real := tfpRangeInv2R * 2.0 ** ( -widthTFPinv2R );
constant baseTFPPhi0 : real := tfpRangePhi0  * 2.0 ** ( -widthTFPphi0  );
constant baseTFPCot  : real := tfpRangeCot   * 2.0 ** ( -widthTFPcot   );
constant baseTFPZ0   : real := tfpRangeZ0    * 2.0 ** ( -widthTFPz0    );

-- TM

constant rangeTMinv2R: real := 2.0 * invPtToDphi / minPt          * real( htNumBinsInv2R + 2 )                    / real( htNumBinsInv2R );
constant rangeTMphiT : real := 2.0 * MATH_PI / real( numRegions ) * real( htNumBinsPhiT * ( gpNumBinsPhiT + 2 ) ) / real( htNumBinsPhiT * gpNumBinsPhiT );
constant rangeTMzT   : real := 2.0 * sinh( maxEta ) * chosenRofZ  * real( gpNumBinsZT + 2 )                       / real( gpNumBinsZT );

constant baseTMinv2R: real := rangeTMinv2R / real( htNumBinsInv2R + 2 );
constant baseTMphiT : real := rangeTMphiT  / real( htNumBinsPhiT * ( gpNumBinsPhiT + 2 ) );
constant baseTMzT   : real := rangeTMzT    / real( gpNumBinsZT + 2 );

constant rangeTMcot: real := ( rangeTMzT + 2.0 * beamWindowZ ) / chosenRofZ;
constant baseTMcot : real := ( baseTMzT  + 2.0 * beamWindowZ ) / chosenRofZ;

constant rangeDTCr  : real := 2.0 * maxRphi;
constant rangeDTCphi: real := 2.0 * MATH_PI / real( numRegions ) + maxRPhi * rangeTMinv2R;
constant rangeDTCz  : real := 2.0 * halfLength;

constant rangeTMr  : real := 2.0 * maxRphi;
constant rangeTMphi: real := baseTMphiT + maxRPhi * baseTMinv2R;
constant rangeTMz  : real := baseTMzT   + maxRZ   * baseTMcot;

constant baseTMR  : real := baseTMphiT / baseTMinv2R * 2.0 ** ( ilog2( rangeDTCr   / baseTMphiT * baseTMinv2R ) - dtcwidthR   );
constant baseTMPhi: real := baseTMphiT               * 2.0 ** ( ilog2( rangeDTCphi / baseTMphiT               ) - dtcWidthPhi );
constant baseTMZ  : real := baseTMzT                 * 2.0 ** ( ilog2( rangeDTCz   / baseTMzT                 ) - dtcWidthz   );

constant rangeTMdPhi: real := 0.5 * pitchRowPS / radiusInner + 0.25 * ( pitchCol2S + scattering ) * rangeTMinv2R;
constant rangeTMdZ  : real := 0.5 * pitchCol2S * sinh( maxEta );

constant widthTMstubId: natural := widthTBStubId;
constant widthTMr     : natural := ilog2( rangeTMr     / baseTMr     );
constant widthTMphi   : natural := ilog2( rangeTMphi   / baseTMPhi   );
constant widthTMz     : natural := ilog2( rangeTMz     / baseTMZ     );
constant widthTMdPhi  : natural := ilog2( rangeTMdPhi  / baseTMPhi   );
constant widthTMdZ    : natural := ilog2( rangeTMdZ    / baseTMZ     );
constant widthTMInv2R : natural := ilog2( rangeTMinv2R / baseTMinv2R );
constant widthTMphiT  : natural := ilog2( rangeTMphiT  / baseTMphiT  );
constant widthTMzT    : natural := ilog2( rangeTMzT    / baseTMzT    );

-- DR

constant widthDRr     : natural := widthTMr;
constant widthDRdPhi  : natural := widthTMdPhi;
constant widthDRdZ    : natural := widthTMdZ;
constant widthDRphi   : natural := widthTMphi;
constant widthDRz     : natural := widthTMz;
constant widthDRinv2R : natural := widthTMinv2R;
constant widthDRphiT  : natural := widthTMphiT;
constant widthDRzT    : natural := widthTMzT;

-- KF

constant widthKFr   : natural := widthTMr;
constant widthKFphi : natural := widthTMphi;
constant widthKFz   : natural := widthTMz;
constant widthKFdPhi: natural := widthTMdPhi;
constant widthKFdZ  : natural := widthTMdZ;

constant baseShiftKFinv2R: integer := -ilog2( baseTMinv2R        / baseTFPinv2R );
constant baseShiftKFphiT : integer := -ilog2( baseTMphiT         / baseTFPphi0  );
constant baseShiftKFcot  : integer := -ilog2( baseTMzT / baseTMR / baseTFPcot   );
constant baseShiftKFzT   : integer := -ilog2( baseTMzT           / baseTFPz0    );

constant baseKFinv2R: real := baseTMinv2R        * 2.0 ** baseShiftKFinv2R;
constant baseKFphiT : real := baseTMphiT         * 2.0 ** baseShiftKFphiT;
constant baseKFcot  : real := baseTMzT / baseTMR * 2.0 ** baseShiftKFcot;
constant baseKFzT   : real := baseTMzT           * 2.0 ** baseShiftKFzT;

constant widthKFinv2R: natural := width( rangeTMinv2R / baseKFinv2R );
constant widthKFphiT : natural := width( rangeTMphiT  / baseKFphiT  );
constant widthKFcot  : natural := width( rangeTMcot   / baseKFcot   );
constant widthKFzT   : natural := width( rangeTMzT    / baseKFzT    );


end;
