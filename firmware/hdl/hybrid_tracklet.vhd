library ieee;
use ieee.std_logic_1164.all;

use work.hybrid_config.all;
use work.hybrid_data_formats.all;
use work.hybrid_data_types.all;
use work.memUtil_pkg.all;


entity hybrid_tracklet is
port (
    clk: in std_logic;
    tracklet_din: in t_stubsDTC;
    tracklet_dout: out t_candTracklet
);
end;


architecture rtl of hybrid_tracklet is

signal reset: std_logic := '1';
signal IR_start: std_logic := '0';
signal IR_bx_in: std_logic_vector(2 downto 0) := ( others => '0' );
signal FT_bx_out: std_logic_vector(2 downto 0) := ( others => '0' );
signal FT_bx_out_vld: std_logic := '0';
signal FT_done: std_logic := '0';
signal DL_39_link_AV_dout: t_arr_DL_39_DATA := ( others => ( others => '0' ) );
signal DL_39_link_empty_neg: t_arr_DL_39_1b := ( others => '0' );
signal DL_39_link_read: t_arr_DL_39_1b := ( others => '0' );
signal BW_46_stream_AV_din: t_arr_BW_46_DATA := ( others => ( others => '0' ) );
signal BW_46_stream_A_full_neg: t_arr_BW_46_1b := ( others => '1' );
signal BW_46_stream_A_write: t_arr_BW_46_1b := ( others => '0' );
signal TW_84_stream_AV_din: t_arr_TW_84_DATA := ( others => ( others => '0' ) );
signal TW_84_stream_A_full_neg: t_arr_TW_84_1b := ( others => '1' );
signal TW_84_stream_A_write: t_arr_TW_84_1b := ( others => '0' );
component SectorProcessor
port(
  clk: in std_logic;
  reset: in std_logic;
  IR_start: in std_logic;
  IR_bx_in: in std_logic_vector(2 downto 0);
  FT_bx_out: out std_logic_vector(2 downto 0);
  FT_bx_out_vld: out std_logic;
  FT_done: out std_logic;
  DL_39_link_AV_dout: in t_arr_DL_39_DATA;
  DL_39_link_empty_neg: in t_arr_DL_39_1b;
  DL_39_link_read: out t_arr_DL_39_1b;
  BW_46_stream_AV_din: out t_arr_BW_46_DATA;
  BW_46_stream_A_full_neg: in t_arr_BW_46_1b;
  BW_46_stream_A_write: out t_arr_BW_46_1b;
  TW_84_stream_AV_din: out t_arr_TW_84_DATA;
  TW_84_stream_A_full_neg: in t_arr_TW_84_1b;
  TW_84_stream_A_write: out t_arr_TW_84_1b
);
end component;

function conv( dtc: t_stubsDTC ) return t_arr_DL_39_DATA is
  variable ps: t_stubDTCPS;
  variable ss: t_stubDTC2S;
  variable a: t_arr_DL_39_DATA := ( others => ( others => '0' ) );
begin
  for k in 0 to numDTCPS - 1 loop
    ps := dtc.ps( k );
    a( enum_DL_39'val( k ) ) := ps.r & ps.z & ps.phi & ps.bend & ps.layer & ps.valid;
  end loop;
  for k in 0 to numDTC2S - 1 loop
    ss := dtc.ss( k );
    a( enum_DL_39'val( k + numDTCPS ) ) := ss.r & ss.z & ss.phi & ss.bend & ss.layer & ss.valid;
  end loop;
  return a;
end function;

function conv( dtc: t_stubsDTC ) return t_arr_DL_39_1b is
  variable a: t_arr_DL_39_1b := ( others => '0' );
begin
  for k in 0 to numDTCPS - 1 loop
    a( enum_DL_39'val( k ) ) := dtc.ps( k ).valid;
  end loop;
  for k in 0 to numDTC2S - 1 loop
    a( enum_DL_39'val( k + numDTCPS ) ) := dtc.ss( k ).valid;
  end loop;
  return a;
end function;

function conv( bw: t_arr_BW_46_DATA; tw: t_arr_TW_84_DATA ) return t_candTracklet is
  variable c: t_candTracklet := nulll;
  variable s: t_stubTracklet := nulll;
  variable b: std_logic_vector( 46 - 1 downto 0 );
  variable t: std_logic_vector( 84 - 1 downto 0 );
begin
  for k in 0 to numStubsTracklet - 1 loop
    b := bw( enum_BW_46'val( k ) );
    s.valid   := b( 1 + widthTrackId + widthStubId + widthR + widthPhi + widthZ - 1 );
    s.trackId := b(     widthTrackId + widthStubId + widthR + widthPhi + widthZ - 1 downto widthStubId + widthR + widthPhi + widthZ );
    s.stubId  := b(                    widthStubId + widthR + widthPhi + widthZ - 1 downto               widthR + widthPhi + widthZ );
    s.r       := b(                                  widthR + widthPhi + widthZ - 1 downto                        widthPhi + widthZ );
    s.phi     := b(                                           widthPhi + widthZ - 1 downto                                   widthZ );
    s.z       := b(                                                      widthZ - 1 downto                                        0 );
    c.stubs( k ) := s;
  end loop;
  t := tw( enum_TW_84'val( 0 ) );
  c.track.valid    := t( 1 + widthSeedType + widthInv2R + widthPhi0 + widthZ0 + widthCot - 1 );
  c.track.seedtype := t(     widthSeedType + widthInv2R + widthPhi0 + widthZ0 + widthCot - 1 downto widthInv2R + widthPhi0 + widthZ0 + widthCot );
  c.track.inv2R    := t(                     widthInv2R + widthPhi0 + widthZ0 + widthCot - 1 downto              widthPhi0 + widthZ0 + widthCot );
  c.track.phi0     := t(                                  widthPhi0 + widthZ0 + widthCot - 1 downto                          widthZ0 + widthCot );
  c.track.z0       := t(                                              widthZ0 + widthCot - 1 downto                                    widthCot );
  c.track.cot      := t(                                                        widthCot - 1 downto                                           0 );
  return c;
end function;


begin


reset <= '0' after 12.5 ns;
IR_start <= '1' after 25 ns;
IR_bx_in <= tracklet_din.ps( 0 ).bx;
DL_39_link_AV_dout <= conv( tracklet_din );
DL_39_link_empty_neg <= conv( tracklet_din );
tracklet_dout <= conv( BW_46_stream_AV_din, TW_84_stream_AV_din );

c: SectorProcessor port map (
  clk, reset, IR_start, IR_bx_in, FT_bx_out, FT_bx_out_vld, FT_done, DL_39_link_AV_dout,
  DL_39_link_empty_neg, DL_39_link_read, BW_46_stream_AV_din, BW_46_stream_A_full_neg, BW_46_stream_A_write,
  TW_84_stream_AV_din, TW_84_stream_A_full_neg, TW_84_stream_A_write
);


end;