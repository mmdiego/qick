create_clock -period 5.000 -name i_core_clk -waveform {0.000 2.500} [get_ports i_core_clk]
create_clock -period 10.000 -name i_ps_clk -waveform {0.000 5.000} [get_ports i_ps_clk]
create_clock -period 2.000 -name i_time_clk -waveform {0.000 1.000} [get_ports i_time_clk]
