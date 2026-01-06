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

# AXI Interface from/to PS clock
set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to [get_pins -filter {REF_PIN_NAME =~ D} -of_objects [get_cells -hier -filter {name =~ *u_xcom_axil_slv/rdata_reg_reg*}]] \

set_false_path \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects [get_cells -hier -filter {name =~ *u_xcom_axil_slv/slave_registers_reg*}]] \
    -to [get_clocks -of_objects [get_nets i_time_clk]]



create_clock -quiet -period 6.0 -name xcom_rx_clk_0 [get_ports i_xcom_clk_p[0]]
create_clock -quiet -period 6.0 -name xcom_rx_clk_1 [get_ports i_xcom_clk_p[1]]
create_clock -quiet -period 6.0 -name xcom_rx_clk_2 [get_ports i_xcom_clk_p[2]]
create_clock -quiet -period 6.0 -name xcom_rx_clk_3 [get_ports i_xcom_clk_p[3]]
create_clock -quiet -period 6.0 -name xcom_rx_clk_4 [get_ports i_xcom_clk_p[4]]

# # To be added later
# create_clock -quiet -period 6.0 -name xcom_rx_clk_5 [get_ports i_xcom_clk_p[5]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_6 [get_ports i_xcom_clk_p[6]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_7 [get_ports i_xcom_clk_p[7]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_8 [get_ports i_xcom_clk_p[8]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_9 [get_ports i_xcom_clk_p[9]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_10 [get_ports i_xcom_clk_p[10]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_11 [get_ports i_xcom_clk_p[11]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_12 [get_ports i_xcom_clk_p[12]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_13 [get_ports i_xcom_clk_p[13]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_14 [get_ports i_xcom_clk_p[14]]
# create_clock -quiet -period 6.0 -name xcom_rx_clk_15 [get_ports i_xcom_clk_p[15]]

create_clock -period 6.0 -name xcom_clk_virt 

set_input_delay -clock xcom_clk_virt -max  0.25 [get_ports i_xcom_data*]
set_input_delay -clock xcom_clk_virt -min -0.10 [get_ports i_xcom_data*]



create_generated_clock -name xcom_tx_clk -source [get_ports i_time_clk] -divide_by 4 [get_pins -filter {REF_PIN_NAME =~ Q} -of_objects [get_cells -hier -filter {name =~ *u_xcom_txrx/u_tx_cmd/u_xcom_link_tx/tx_clk_r_reg*}]]
 

set_output_delay -clock [get_clocks xcom_tx_clk] -max  0.0 [get_ports o_xcom_data*]
set_output_delay -clock [get_clocks xcom_tx_clk] -min -0.0 [get_ports o_xcom_data*]

# set_output_delay -clock [get_clocks xcom_tx_clk] -max  1.0 [get_ports o_xcom_data*]
# set_output_delay -clock [get_clocks xcom_tx_clk] -min -0.2 [get_ports o_xcom_data*]

# set_multicycle_path -start -to [get_ports o_xcom_data*] 2

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
