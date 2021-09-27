use work.tracklet_config.all;
use work.tracklet_data_types.all;



package tracklet_config_memory is


constant NUM_MEM_BINS            : natural := work.tracklet_config.NUM_MEM_BINS;
constant NUM_ENTRIES_PER_MEM_BINS: natural := work.tracklet_config.NUM_ENTRIES_PER_MEM_BINS;
constant INIT_FILE               : string  := "";
constant INIT_HEX                : boolean := true;
constant RAM_PERFORMANCE         : string  := "HIGH_PERFORMANCE";

constant config_memory_IL36    : t_config_memory := ( tf_mem,      8, 7, 36, 2 );
constant config_memory_AS36    : t_config_memory := ( tf_mem,     10, 7, 36, 8 );
constant config_memory_VMSME16 : t_config_memory := ( tf_mem_bin, 10, 5, 16, 8 );
constant config_memory_VMSME17 : t_config_memory := ( tf_mem_bin, 10, 5, 17, 8 );
constant config_memory_VMSTE22 : t_config_memory := ( tf_mem,      8, 7, 22, 2 );
constant config_memory_VMSTE16 : t_config_memory := ( tf_mem_bin,  8, 5, 16, 2 );
constant config_memory_SP14    : t_config_memory := ( tf_mem,      8, 7, 14, 2 );
constant config_memory_TPROJ60 : t_config_memory := ( tf_mem,      8, 7, 60, 2 );
constant config_memory_TPROJ58 : t_config_memory := ( tf_mem,      8, 7, 58, 2 );
constant config_memory_TPAR70  : t_config_memory := ( tf_mem,     10, 7, 70, 8 );
constant config_memory_VMPROJ24: t_config_memory := ( tf_mem,      8, 7, 24, 2 );
constant config_memory_AP60    : t_config_memory := ( tf_mem,     10, 7, 60, 8 );
constant config_memory_AP58    : t_config_memory := ( tf_mem,     10, 7, 58, 8 );
constant config_memory_CM14    : t_config_memory := ( tf_mem,      8, 7, 14, 2 );
constant config_memory_FM52    : t_config_memory := ( tf_mem,      8, 7, 52, 2 );

constant config_memories_VMR: t_config_memories( 0 to numVMR - 1 ) := ( 
  0      => config_memory_VMSTE22,
  1      => config_memory_VMSTE16,
  2      => config_memory_VMSME16,
  others => config_memory_VMSME17
);

constant config_memories_TC: t_config_memories( 0 to numOutputsTC - 1 ) := (
  0      => config_memory_TPROJ60,
  1 to 3 => config_memory_TPROJ58,
  4      => config_memory_TPAR70
);

constant config_memories_PR: t_config_memories( 0 to numPR - 1 ) := (
  0 => config_memory_AP60,
  others => config_memory_AP58
);

function init_config_memories_out return t_config_memories;
constant config_memories_out: t_config_memories( 0 to numMemories - 1 );

function init_config_memories_in return t_config_memories;
constant config_memories_in: t_config_memories( 0 to numMemories - 1 );


end;



package body tracklet_config_memory is


function init_config_memories_out return t_config_memories is
  variable config_memories: t_config_memories( 0 to numMemories - 1 );
  variable n: natural := 0;
begin
  -- IR
  config_memories( 0 to sumMemOutIR - 1 ) := ( others => config_memory_IL36 );
  -- VMR
  for k in 0 to numVMR - 1 loop
    config_memories( sumMemOutIR + n ) := config_memory_AS36;
    config_memories( sumMemOutIR + n + 1 to sumMemOutIR + n + numNodeOutputsVMR( k ) - 1 ) := ( others => config_memories_VMR( k ) );
    n := n + numNodeOutputsVMR( k );
  end loop;
  -- TE
  config_memories( sumMemOutVMR to sumMemOutTE  - 1 ) := ( others => config_memory_SP14 );
  -- TC
  for k in 0 to numOutputsTC - 1 loop
    config_memories( sumMemOutTE + k ) := config_memories_TC( k );
  end loop;
  -- PR
  n := 0;
  for k in 0 to numPR - 1 loop
    config_memories( sumMemOutTC + n to sumMemOutTC + n + numNodeOutputsPR( k ) - 2 ) := ( others => config_memory_VMPROJ24 );
    config_memories( sumMemOutTC + n + numNodeOutputsPR( k ) - 1 ) := config_memories_PR( k );
    n := n + numNodeOutputsPR( k );
  end loop;
  -- ME
  config_memories( sumMemOutPR  to sumMemOutME  - 1 ) := ( others => config_memory_CM14 );
  -- MC
  config_memories( sumMemOutME  to sumMemOutMC  - 1 ) := ( others => config_memory_FM52 );
  return config_memories;
end function;

constant config_memories_out: t_config_memories( 0 to numMemories - 1 ) := init_config_memories_out;

function init_config_memories_in return t_config_memories is
  variable dout: t_config_memories( 0 to numMemories - 1 );
begin
  for k in dout'range loop
    dout( k ) := config_memories_out( mapping( k ) );
  end loop;
  return dout;
end function;

constant config_memories_in: t_config_memories( 0 to numMemories - 1 ) := init_config_memories_in;

end;