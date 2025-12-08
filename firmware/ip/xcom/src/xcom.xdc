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
