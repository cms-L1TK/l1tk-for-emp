library ieee;
use ieee.std_logic_1164.ALL;

use work.emp_framework_decl.all;
use work.emp_device_types.all;


package emp_project_decl is


constant PAYLOAD_REV: std_logic_vector(31 downto 0) := X"12345678";

constant LB_ADDR_WIDTH  : integer := 10;

constant CLOCK_AUX_DIV     : clock_divisor_array_t := (18, 9, 4);
constant CLOCK_COMMON_RATIO: integer               := 36;
constant CLOCK_RATIO       : integer               :=  6;

constant PAYLOAD_LATENCY: integer := 21 + 2;

-- mgt -> chk -> buf -> fmt -> (algo) -> (fmt) -> buf -> chk -> mgt -> clk -> altclk
constant REGION_CONF : region_conf_array_t := (
     0 => ( no_mgt, buf,    no_fmt, buf,    no_mgt ),
     1 => ( no_mgt, buf,    no_fmt, buf,    no_mgt ),
     2 => ( no_mgt, buf,    no_fmt, buf,    no_mgt ),
     3 => ( no_mgt, buf,    no_fmt, buf,    no_mgt ),
     4 => ( no_mgt, buf,    no_fmt, buf,    no_mgt ),
     5 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
     6 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
     7 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
     8 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
    ---- Cross-chip
     9 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
    10 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
    11 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
    12 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
    13 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
    14 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
    15 => ( no_mgt, no_buf, no_fmt, buf,    no_mgt ),
    16 => ( no_mgt, no_buf, no_fmt, no_buf, no_mgt ),
    17 => ( no_mgt, no_buf, no_fmt, no_buf, no_mgt ),
    others => kDummyRegion
);


end;
