# Create clocks for XCOM RX lanes
set rx_clk_period 4.0
create_clock -name xcom_rx_clk_0  -period $rx_clk_period [get_ports i_xcom_clk_p[0]] -waveform {1.0 3.0}    ; # one interface must be always present
create_clock -name xcom_rx_clk_1  -period $rx_clk_period [get_ports i_xcom_clk_p[1]] -waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_2  -period $rx_clk_period [get_ports i_xcom_clk_p[2]] -waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_3  -period $rx_clk_period [get_ports i_xcom_clk_p[3]] -waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_4  -period $rx_clk_period [get_ports i_xcom_clk_p[4]] -waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_5  -period $rx_clk_period [get_ports i_xcom_clk_p[5]] -waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_6  -period $rx_clk_period [get_ports i_xcom_clk_p[6]] -waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_7  -period $rx_clk_period [get_ports i_xcom_clk_p[7]] -waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_8  -period $rx_clk_period [get_ports i_xcom_clk_p[8]] -waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_9  -period $rx_clk_period [get_ports i_xcom_clk_p[9]] -waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_10 -period $rx_clk_period [get_ports i_xcom_clk_p[10]]-waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_11 -period $rx_clk_period [get_ports i_xcom_clk_p[11]]-waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_12 -period $rx_clk_period [get_ports i_xcom_clk_p[12]]-waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_13 -period $rx_clk_period [get_ports i_xcom_clk_p[13]]-waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_14 -period $rx_clk_period [get_ports i_xcom_clk_p[14]]-waveform {1.0 3.0} -quiet 
create_clock -name xcom_rx_clk_15 -period $rx_clk_period [get_ports i_xcom_clk_p[15]]-waveform {1.0 3.0} -quiet 

# Virtual clock that drives the data of the External Source Device for XCOM RX lanes
create_clock -name xcom_clk_virt -period $rx_clk_period 


# Create generated clock for XCOM TX lane

# # Create generated clock for XCOM TX lane with normal register implementation
# create_generated_clock \
#     -name xcom_tx_clk_out \
#     -source [get_ports i_time_clk] \
#     -divide_by 4 \
#     [get_pins -filter {REF_PIN_NAME =~ Q} -of_objects [get_cells -hier -filter {name =~ *u_xcom_txrx/u_tx_cmd/u_xcom_link_tx/tx_clk_out_r_reg}]]

# create_generated_clock \
#     -name xcom_tx_clk_data \
#     -source [get_ports i_time_clk] \
#     -divide_by 4 \
#     [get_pins -filter {REF_PIN_NAME =~ Q} -of_objects [get_cells -hier -filter {name =~ *u_xcom_txrx/u_tx_cmd/u_xcom_link_tx/tx_data_clk_r_reg}]]


create_generated_clock \
    -name xcom_tx_clk_out \
    -source [get_pins -filter {REF_PIN_NAME =~ CLK} -of_objects [get_cells -hier -filter {name =~ *u_xcom_link_tx/ODDRE1_tx_clk}]] \
    -edges {3 7 11} \
    [get_ports o_xcom_clk_p]
    # -divide_by 4 \


# # Create generated clock for XCOM TX data clock
# create_generated_clock \
#     -name xcom_tx_clk_data \
#     -source [get_ports i_time_clk] \
#     -divide_by 4 \
#     [get_pins -filter {REF_PIN_NAME =~ Q} -of_objects [get_cells -hier -filter {name =~ *u_xcom_txrx/u_tx_cmd/u_xcom_link_tx/tx_data_clk_d_reg[1]}]]

# # Create generated clock for XCOM TX shifted clock
# create_generated_clock \
#     -name xcom_tx_clk_90 \
#     -source [get_ports i_time_clk] \
#     -edges {3 7 11} \
#     [get_pins -filter {REF_PIN_NAME =~ Q} -of_objects [get_cells -hier -filter {name =~ *u_xcom_txrx/u_tx_cmd/u_xcom_link_tx/tx_clk_d_reg[1]}]]
#     # -divide_by 4 \

# # Create generated clock for XCOM TX output clock
# create_generated_clock \
#     -name xcom_tx_clk_out \
#     -source [get_pins -filter {REF_PIN_NAME =~ Q} -of_objects [get_cells -hier -filter {name =~ *u_xcom_txrx/u_tx_cmd/u_xcom_link_tx/tx_clk_d_reg[1]}]] \
#     -divide_by 1 \
#     [get_ports o_xcom_clk_p]



# Create generated clock for XCOM Loopback
create_generated_clock \
    -name xcom_loop_clk \
    -source [get_ports i_time_clk] \
    -divide_by 4 \
    [get_pins -filter {REF_PIN_NAME =~ Q} -of_objects [get_cells -hier -filter {name =~ *u_xcom_txrx/u_tx_cmd/u_xcom_link_tx/tx_clk_r_reg}]] \
    -quiet


# False Path of Synchronizers
#set_false_path -to [get_pins -filter {REF_PIN_NAME =~ D} -of_objects [get_cells -hier -filter {name=~*data_int_reg_reg[0]*}]]
set_false_path -to [get_pins -filter {REF_PIN_NAME =~ D} -of_objects  [get_cells -hier -filter {name=~*_cdc_reg*}]]

set_false_path \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects [get_cells -hier -filter {name =~ *u_xcom_cdc/core_en_req_reg}]] \
    -to [get_clocks -of_objects [get_nets i_time_clk]]

set_false_path \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects [get_cells -hier -filter {name =~ *u_xcom_cdc/o_core_*_reg*}]] \
    -to [get_clocks -of_objects [get_nets i_time_clk]]

set_false_path \
    -from [get_clocks -of_objects [get_nets i_core_clk]] \
    -to [get_pins -filter {REF_PIN_NAME =~ D} -of_objects [get_cells -hier -filter {name =~ *u_xcom_axil_slv/rdata_reg_reg*}]] \

set_false_path \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects [get_cells -hier -filter {name =~ *u_xcom_link_rx/s_pha_reg}]] \
    -to [get_clocks -of_objects [get_nets i_xcom_clk_p*]]

# AXI Interface from/to PS clock
set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to [get_pins -filter {REF_PIN_NAME =~ D} -of_objects [get_cells -hier -filter {name =~ *u_xcom_axil_slv/rdata_reg_reg*}]] \

set_false_path \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects [get_cells -hier -filter {name =~ *u_xcom_axil_slv/slave_registers_reg*}]] \
    -to [get_clocks -of_objects [get_nets i_time_clk]]


## RX input delays
## Rising-edge lunch from Source Device (+/- 100ps skew)
set_input_delay -clock xcom_clk_virt -max  0.10 [get_ports i_xcom_data_p*]
set_input_delay -clock xcom_clk_virt -min -0.10 [get_ports i_xcom_data_p*]
## Falling-edge lunch from Source Device (+/- 100ps skew)
set_input_delay -clock xcom_clk_virt -max  0.10 -clock_fall [get_ports i_xcom_data_p*] -add_delay
set_input_delay -clock xcom_clk_virt -min -0.10 -clock_fall [get_ports i_xcom_data_p*] -add_delay

# ## RX Center-Aligned DDR transfers Timing Exceptions
# set_false_path -setup -fall_from [get_clocks xcom_clk_virt] -rise_to [get_clocks xcom_rx_clk_*]
# set_false_path -setup -rise_from [get_clocks xcom_clk_virt] -fall_to [get_clocks xcom_rx_clk_*]
# set_false_path -hold  -rise_from [get_clocks xcom_clk_virt] -rise_to [get_clocks xcom_rx_clk_*]
# set_false_path -hold  -fall_from [get_clocks xcom_clk_virt] -fall_to [get_clocks xcom_rx_clk_*]


## TX output delays
## Rising-edge capture at receiver
set_output_delay -clock [get_clocks xcom_tx_clk_out] -max  0.5 [get_ports o_xcom_data_p*]
set_output_delay -clock [get_clocks xcom_tx_clk_out] -min -0.5 [get_ports o_xcom_data_p*]
## Falling-edge capture at receiver
set_output_delay -clock [get_clocks xcom_tx_clk_out] -max  0.5 -clock_fall [get_ports o_xcom_data_p*] -add_delay
set_output_delay -clock [get_clocks xcom_tx_clk_out] -min -0.5 -clock_fall [get_ports o_xcom_data_p*] -add_delay

set_multicycle_path -to [get_ports o_xcom_data_p] -start 1
set_multicycle_path -to [get_ports o_xcom_data_p] -start 1 -hold
set_false_path -fall_from [get_clocks i_time_clk] -to [get_clocks xcom_tx_clk_out]


# RX DDR bit counter regs resets - false paths
set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to [get_pins -filter {REF_PIN_NAME =~ PRE} -of_objects [get_cells -hier -filter {name =~ *u_xcom_txrx/u_rx_cmd/RX[*].u_xcom_link_rx/ddr_bit_cntr_reg[0]}]]
set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to [get_pins -filter {REF_PIN_NAME =~ CLR} -of_objects [get_cells -hier -filter {name =~ *u_xcom_txrx/u_rx_cmd/RX[*].u_xcom_link_rx/ddr_bit_cntr_reg* && name !~ "*ddr_bit_cntr_reg[0]"}]]

# False-Path to CDC debug probes
set_false_path -quiet \
    -from [get_ports i_xcom_*] \
    -through [get_ports o_dbg_probe*] \
    -to [get_clocks -of_objects [get_nets i_time_clk]]
