library ieee;
use ieee.std_logic_1164.all;

use work.tfp_config.all;
use work.tfp_data_types.all;

use ieee.math_real.all;
use work.tfp_tools.all;
use work.tfp_data_formats.all;
use work.kf_data_formats.all;


entity kf_top is
port (
    clk: in std_logic;
    kf_din: in t_channelsSF( numNodesKF - 1 downto 0 );
    kf_dout: out t_channelsKF( numNodesDR - 1 downto 0 )
);
end;


architecture rtl of kf_top is


component kf_node
port (
    clk: in std_logic;
    node_din: in t_channelSF;
    node_dout: out t_channelKF
);
end component;


begin


g: for k in 0 to numNodesKF - 1 generate

signal node_din: t_channelSF := nulll;
signal node_dout: t_channelKF := nulll;

begin

node_din <= kf_din( k );
kf_dout( k ) <= node_dout;

c: kf_node port map ( clk, node_din, node_dout );

end generate;


end;