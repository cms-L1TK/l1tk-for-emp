-- emp device declaration
--
-- Defines constants for the whole device
--
-- Alessandro Thea, April 2018
library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.emp_framework_decl.all;

-------------------------------------------------------------------------------
package emp_device_decl is

  constant BOARD_DESIGN_ID : std_logic_vector(7 downto 0) := X"FF";

  constant N_REGION        : integer := 28;

  constant N_REFCLK        : integer := 2;
  constant CROSS_REGION    : integer := 3;

  constant IO_REGION_SPEC : io_region_spec_array_t(0 to N_REGION - 1) := (
    others  => kIONoGTRegion
  );


end emp_device_decl;
-------------------------------------------------------------------------------
