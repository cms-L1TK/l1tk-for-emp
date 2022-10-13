library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity tracklet_TE is
port (
  clk: in std_logic;
  te_din: in t_datas( numInputsTE  - 1 downto 0 );
  te_rin: in t_reads( numOutputsTE  - 1 downto 0 );
  te_rout: out t_reads( numInputsTE  - 1 downto 0 );
  te_dout: out t_datas( numOutputsTE  - 1 downto 0 )
);
end;

architecture rtl of tracklet_TE is

signal process_din: t_datas( numInputsTE  - 1 downto 0 ) := ( others => nulll );
signal process_rout: t_reads( numInputsTE  - 1 downto 0 ) := ( others => nulll );
signal process_dout: t_writes( numOutputsTE  - 1 downto 0 ) := ( others => nulll );
component TE_process
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsTE  - 1 downto 0 );
  process_rout: out t_reads( numInputsTE  - 1 downto 0 );
  process_dout: out t_writes( numOutputsTE  - 1 downto 0 )
);
end component;

signal memories_din: t_writes( numOutputsTE  - 1 downto 0 ) := ( others => nulll );
signal memories_rin: t_reads( numOutputsTE  - 1 downto 0 ) := ( others => nulll );
signal memories_dout: t_datas( numOutputsTE  - 1 downto 0 ) := ( others => nulll );
component TE_memories
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsTE  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsTE  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsTE  - 1 downto 0 )
);
end component;

begin

process_din <= te_din;
memories_din <= process_dout;
memories_rin <= te_rin;

te_rout <= process_rout;
te_dout <= memories_dout;

cP: TE_process port map ( clk, process_din, process_rout, process_dout );

cM: TE_memories port map ( clk, memories_din, memories_rin, memories_dout );

end;


library xil_defaultlib;
library ieee;
use ieee.std_logic_1164.all;
use work.hybrid_tools.all;
use work.hybrid_config.all;
use work.tracklet_config.all;
use work.tracklet_config_memory.all;
use work.tracklet_data_types.all;

entity TE_process is
port (
  clk: in std_logic;
  process_din: in t_datas( numInputsTE  - 1 downto 0 );
  process_rout: out t_reads( numInputsTE  - 1 downto 0 );
  process_dout: out t_writes( numOutputsTE  - 1 downto 0 )
);
end;

architecture rtl of TE_process is

constant lut_width: integer := 1;
constant lut_depth: integer := 256;
constant RAM_PERFORMANCE : string := "HIGH_PERFORMANCE";
constant widthAddr: natural := width( lut_depth );
component tf_lut
generic (
  lut_file: string;
  lut_width: integer;
  lut_depth: integer;
  RAM_PERFORMANCE : string
);
port (
  clk: in std_logic;
  ce: in std_logic;
  addr: in std_logic_vector( widthAddr - 1 downto 0 );
  dout: out std_logic_vector( lut_width-1 downto 0 )
);
end component;

begin

g: for k in 0 to numTE - 1 generate

constant offsetIn: natural := sum( 0 & numNodeInputsTE, 0, k );
constant offsetOut: natural := sum( 0 & numNodeOutputsTE, 0, k );
constant numInputs: natural := numNodeInputsTE( k );
constant numOutputs: natural := numNodeOutputsTE( k );
constant config_memories_out: t_config_memories( 0 to numOutputs - 1 ) := config_memories_out( sumMemOutVMR + offsetOut to sumMemOutVMR + offsetOut + numOutputs - 1 );
constant config_memories_in: t_config_memories( 0 to numInputs - 1 ) := config_memories_in( sumMemInVMR + offsetIn to sumMemInVMR + offsetIn + numInputs - 1 );

signal din: t_datas( numInputs  - 1 downto 0 ) := ( others => nulll );
signal rout: t_reads( numInputs  - 1 downto 0 ) := ( others => nulll );

signal lutRead: t_reads( 2 - 1 downto 0 ) := ( others => nulll );
type t_lutDatas is array ( natural range <> ) of std_logic_vector( 1 - 1 downto 0 );
signal lutData: t_lutDatas( 2 - 1 downto 0 ) := ( others => ( others => '0' ) );

signal reset, start, done, enable: std_logic := '0';
signal counter: std_logic_vector( widthNent - 1 downto 0 ) := ( others => '0' );
signal bxIn, bxOut: std_logic_vector ( widthBX - 1 downto 0 ) := ( others => '0' );
signal writes: t_writes( numOutputs - 1 downto 0 ) := ( others => nulll );

begin

din <= process_din( offsetIn + numInputs - 1 downto offsetIn );
process_rout( offsetIn + numInputs - 1 downto offsetIn ) <= rout;
process_dout( offsetOut + numOutputs - 1 downto offsetOut ) <= writes;

start <= process_din( offsetIn ).start;
bxIn <= process_din( offsetIn ).bx;

process ( clk ) is
begin
if rising_edge( clk ) then

  reset <= process_din( offsetIn ).reset;
  counter <= incr( counter );
  if enable = '1' and uint( counter ) = numFrames - 1 then
    enable <= '0';
  end if;
  if done = '1' then
    enable <= '1';
    counter <= ( others => '0' );
  end if;
  if reset = '1' then
    enable <= '0';
  end if;

end if;
end process;

gIn: for l in 0 to numInputs - 1 generate
rout( l ).start <= start;
end generate;

gOut: for l in 0 to numOutputs - 1 generate
writes( l ).reset <= reset;
writes( l ).start <= done or enable;
writes( l ).bx <= bxOut;
end generate;

gLUT: for l in 0 to 2 - 1 generate

constant lut_file: string := lut_files( 2 * k + l );

signal ce: std_logic := '0';
signal addr: std_logic_vector( widthAddr - 1 downto 0 ) := ( others => '0' );
signal dout: std_logic_vector( lut_width - 1 downto 0 ) := ( others => '0' );

begin

ce <= lutRead( l ).valid;
addr <= lutRead( l ).addr( addr'range );
lutData( l )( dout'range ) <= dout; 

lut: tf_lut generic map ( lut_file, lut_width, lut_depth, RAM_PERFORMANCE ) port map ( clk, ce, addr, dout );

end generate;

PS_PS: entity xil_defaultlib.TE_PS_PS port map (
  ap_clk => clk,
  ap_rst => reset,
  ap_start => start,
  ap_done => done,
  bx_V => bxIn,
  bx_o_V => bxOut,
  ap_idle => open,
  ap_ready => open,
  bx_o_V_ap_vld => open,
  bendinnertable_V_ce0 => lutRead( 0 ).valid,
  bendoutertable_V_ce0 => lutRead( 1 ).valid,
  bendinnertable_V_address0 => lutRead( 0 ).addr( 8 - 1 downto 0 ),
  bendoutertable_V_address0 => lutRead( 1 ).addr( 8 - 1 downto 0 ),
  bendinnertable_V_q0 => lutData( 0 ),
  bendoutertable_V_q0 => lutData( 1 ),
  instubinnerdata_dataarray_data_V_ce0 => rout( 0 ).valid,
  instubouterdata_dataarray_data_V_ce0 => rout( 1 ).valid,
  instubinnerdata_dataarray_data_V_address0 => rout( 0 ).addr( config_memories_in( 0 ).widthAddr - 1 downto 0 ),
  instubouterdata_dataarray_data_V_address0 => rout( 1 ).addr( config_memories_in( 1 ).widthAddr - 1 downto 0 ),
  instubinnerdata_dataarray_data_V_q0 => din( 0 ).data( config_memories_in( 0 ).widthData - 1 downto 0 ),
  instubouterdata_dataarray_data_V_q0 => din( 1 ).data( config_memories_in( 1 ).widthData - 1 downto 0 ),
  instubinnerdata_nentries_0_V => din( 0 ).nents( 0 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  instubinnerdata_nentries_1_V => din( 0 ).nents( 1 )( config_memories_in( 0 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_0_V_0 => din( 1 ).nents( 0 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_0_V_1 => din( 1 ).nents( 1 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_0_V_2 => din( 1 ).nents( 2 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_0_V_3 => din( 1 ).nents( 3 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_0_V_4 => din( 1 ).nents( 4 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_0_V_5 => din( 1 ).nents( 5 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_0_V_6 => din( 1 ).nents( 6 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_0_V_7 => din( 1 ).nents( 7 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_1_V_0 => din( 1 ).nents( 8 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_1_V_1 => din( 1 ).nents( 9 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_1_V_2 => din( 1 ).nents( 10 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_1_V_3 => din( 1 ).nents( 11 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_1_V_4 => din( 1 ).nents( 12 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_1_V_5 => din( 1 ).nents( 13 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_1_V_6 => din( 1 ).nents( 14 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  instubouterdata_nentries_1_V_7 => din( 1 ).nents( 15 )( config_memories_in( 1 ).widthNent - 1 downto 0 ),
  outstubpair_dataarray_data_V_ce0 => open,
  outstubpair_dataarray_data_V_we0 => writes( 0 ).valid,
  outstubpair_dataarray_data_V_address0 => writes( 0 ).addr( config_memories_out( 0 ).widthAddr - 1 downto 0 ),
  outstubpair_dataarray_data_V_d0 => writes( 0 ).data( config_memories_out( 0 ).widthData - 1 downto 0 )
);

end generate;

end;


library ieee;
use ieee.std_logic_1164.all;
use work.tracklet_config.all;
use work.tracklet_data_types.all;

entity TE_memories is
port (
  clk: in std_logic;
  memories_din: in t_writes( numOutputsTE  - 1 downto 0 );
  memories_rin: in t_reads( numOutputsTE  - 1 downto 0 );
  memories_dout: out t_datas( numOutputsTE  - 1 downto 0 )
);
end;

architecture rtl of TE_memories is

component tracklet_memory
generic (
  index: natural
);
port (
  clk: in std_logic;
  memory_din: in t_write;
  memory_read: in t_read;
  memory_dout: out t_data
);
end component;

begin


g: for k in 0 to numOutputsTE - 1 generate

signal memory_din: t_write := nulll;
signal memory_read: t_read := nulll;
signal memory_dout: t_data := nulll;

begin

memory_din <= memories_din( k );
memory_read <= memories_rin( k );
memories_dout( k ) <= memory_dout;

c: tracklet_memory generic map ( sumMemOutVMR + k ) port map ( clk, memory_din, memory_read, memory_dout );

end generate;

end;