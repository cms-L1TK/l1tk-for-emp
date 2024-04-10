create_clock -period [expr {round(1.0e6 / 360.0) / 1.0e3}] [get_ports clk_p]
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clk_p]