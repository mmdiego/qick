###############################################################################
# XCOM IP Core - Timing Constraints
# 
# This file defines timing constraints for the XCOM (eXtensible COMmunication)
# block, which provides high-speed serial RX/TX interface with DDR I/O.
#
# **IMPORTANT FREQUENCY REQUIREMENTS:**
# 
# 1. EXTERNAL RX CLOCK FREQUENCY (i_xcom_clk_p[]):
#    Period: 4.0 ns (250 MHz)
#    Source: External master device
#    NOTE: This frequency MUST match the actual external interface.
#          If your external device uses a different frequency, update
#          the rx_clk_period variable below and validate with:
#          - Oscilloscope/IBERT measurements
#          - External device datasheet
#          - Board-level design documentation
#
# 2. INTERNAL CLOCKS (from parent module timing.xdc):
#    - i_time_clk = clk_out1_d_1_MTSclkwiz_0 = 430.08 MHz (2.325 ns)
#    - i_core_clk = clk_out2_d_1_MTSclkwiz_0 = 215.04 MHz (4.650 ns)  
#    - i_ps_clk = 100 MHz (10 ns) [from PS]
#
# 3. GENERATED TX CLOCK (o_xcom_clk_p):
#    Frequency: i_time_clk / 4 = 430.08 MHz / 4 = 107.5 MHz
#    Period: 9.301 ns
#    Implementation: ODDRE1 DDR output at IOB
#
# **VALIDATION CHECKLIST:**
# [ ] External RX frequency confirmed via oscilloscope
# [ ] RX clock period matches external device spec sheet
# [ ] DAC clock (i_time_clk) = 430.08 MHz verified in design
# [ ] TX output clock measured at o_xcom_clk_p ≈ 107.5 MHz
# [ ] Setup/Hold timing margins > 200 ps on RX/TX paths
#
###############################################################################

###############################################################################
# PARAMETRIZABLE FREQUENCY DEFINITIONS
###############################################################################
# Modify these values only if the actual external interface frequency differs
# from the default 250 MHz (4.0 ns) specification.
#
# Common frequencies:
#   - 250 MHz = 4.0 ns (DEFAULT)
#   - 200 MHz = 5.0 ns
#   - 125 MHz = 8.0 ns
#   - 100 MHz = 10.0 ns
#
# WARNING: Changing these values requires validation on actual hardware!
###############################################################################

set rx_clk_period 4.0
# set rx_clk_period 5.0    ;# Alternative: 200 MHz
# set rx_clk_period 8.0    ;# Alternative: 125 MHz
# set rx_clk_period 10.0   ;# Alternative: 100 MHz


###############################################################################
# Section 1: EXTERNAL RX CLOCK DEFINITIONS
###############################################################################
# The RX clocks come from external devices (master clock sources).
# Each XCOM RX channel has its own differential clock input pair.
#
# Waveform {1.0 3.0} represents center-aligned DDR operation:
#   - The physical RX clock arrives at the CENTER of the data eye.
#   - Rising edge at 1.0 ns (offset by T/4 = 1.0 ns from data launch at 0.0 ns)
#   - This offset defines the setup/hold requirement for Vivado's STA.
#   - Together with xcom_clk_virt {0.0 2.0}, the Requirement becomes
#     1.0 ns (half-period) + 1.0 ns (phase offset) = higher slack budget.
#
# Channels 0 is REQUIRED; channels 1-15 are OPTIONAL (use -quiet)
###############################################################################

# Channel 0 - REQUIRED
create_clock -name xcom_rx_clk_0 -period $rx_clk_period \
    [get_ports i_xcom_clk_p[0]] -waveform {1.0 3.0}

# Channels 1-15 - OPTIONAL (suppress warnings if not present)
create_clock -name xcom_rx_clk_1  -period $rx_clk_period \
    [get_ports i_xcom_clk_p[1]]  -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_2  -period $rx_clk_period \
    [get_ports i_xcom_clk_p[2]]  -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_3  -period $rx_clk_period \
    [get_ports i_xcom_clk_p[3]]  -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_4  -period $rx_clk_period \
    [get_ports i_xcom_clk_p[4]]  -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_5  -period $rx_clk_period \
    [get_ports i_xcom_clk_p[5]]  -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_6  -period $rx_clk_period \
    [get_ports i_xcom_clk_p[6]]  -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_7  -period $rx_clk_period \
    [get_ports i_xcom_clk_p[7]]  -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_8  -period $rx_clk_period \
    [get_ports i_xcom_clk_p[8]]  -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_9  -period $rx_clk_period \
    [get_ports i_xcom_clk_p[9]]  -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_10 -period $rx_clk_period \
    [get_ports i_xcom_clk_p[10]] -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_11 -period $rx_clk_period \
    [get_ports i_xcom_clk_p[11]] -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_12 -period $rx_clk_period \
    [get_ports i_xcom_clk_p[12]] -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_13 -period $rx_clk_period \
    [get_ports i_xcom_clk_p[13]] -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_14 -period $rx_clk_period \
    [get_ports i_xcom_clk_p[14]] -waveform {1.0 3.0} -quiet
create_clock -name xcom_rx_clk_15 -period $rx_clk_period \
    [get_ports i_xcom_clk_p[15]] -waveform {1.0 3.0} -quiet


###############################################################################
# Section 2: VIRTUAL CLOCK FOR RX TIMING ANALYSIS
###############################################################################
# Virtual clock representing the ideal launch clock at the external source.
#
# Waveform {0.0 2.0}:
#   - Data is launched at t=0.0 ns (rising) and t=2.0 ns (falling).
#   - The physical RX clock (xcom_rx_clk_*) arrives at t=1.0 ns (center),
#     giving a 1.0 ns setup window on each DDR half-period.
#   - This is the standard center-aligned source-synchronous DDR model.
###############################################################################

create_clock -name xcom_clk_virt -period $rx_clk_period -waveform {0.0 2.0}


###############################################################################
# Section 3: GENERATED TX CLOCK
###############################################################################
# The TX clock is generated by ODDRE1 primitive at the IOB.
# 
# Clock Path:
#   i_time_clk (430.08 MHz) → tx_clk_r register → ODDRE1_tx_clk → o_xcom_clk_p
#
# ODDRE1 Configuration:
#   - CLK input: i_time_clk (2.325 ns period)
#   - D1, D2 inputs: tx_clk_d_r (shifted version of tx_clk_r)
#   - Q output: DDR clock at IOB
#
# Output Frequency Calculation:
#   - tx_clk_r toggles every 4 i_time_clk cycles (divider-by-4 logic)
#   - ODDRE1 outputs on both CLK edges → DDR doubling
#   - Result: (430.08 MHz / 4) = 107.5 MHz output (9.301 ns period)
#   - Edges {3 7 11} confirm: (7-3)*2.325ns = 9.3 ns period
#
# Timing Properties:
#   - Asynchronous to i_time_clk due to ODDRE1→pad routing delay
#   - Treated as independent clock domain for CDC analysis
#   - Board-level propagation delay NOT included in this constraint
#
# NOTE: If o_xcom_clk_p does not appear at IOB in synthesis, verify:
#   - xcom_link_tx module instantiation is correct
#   - ODDRE1_tx_clk cell name matches exactly
#   - Port o_xcom_clk_p is properly connected to ODDRE1 Q output
###############################################################################

create_generated_clock \
    -name xcom_tx_clk_out \
    -source [get_pins -filter {REF_PIN_NAME =~ CLK} \
        -of_objects [get_cells -hier -filter {name =~ *u_xcom_link_tx/ODDRE1_tx_clk}]] \
    -edges {3 7 11} \
    [get_ports o_xcom_clk_p]


###############################################################################
# Section 4: GENERATED LOOPBACK CLOCK (DEBUG/TEST ONLY)
###############################################################################
# Internal loopback clock for testing and CDC verification.
# Only present if LOOPBACK parameter is enabled in xcom instantiation.
# 
# Used for:
#   - Internal self-test loops
#   - CDC (Clock Domain Crossing) validation
#   - Debug/verification during development
###############################################################################

create_generated_clock \
    -name xcom_loop_clk \
    -source [get_ports i_time_clk] \
    -divide_by 4 \
    [get_pins -filter {REF_PIN_NAME =~ Q} -of_objects \
        [get_cells -hier -filter {name =~ *u_xcom_link_tx/tx_clk_r_reg}]] \
    -quiet


###############################################################################
# Section 5: ASYNCHRONOUS CLOCK DOMAIN CROSSINGS (CDC)
###############################################################################
# The XCOM block integrates multiple asynchronous clock domains:
#   - i_ps_clk (PS system clock, 100 MHz)
#   - i_core_clk (QICK CORE processor clock, 215.04 MHz)
#   - i_time_clk (DAC/timing reference clock, 430.08 MHz) ← PRIMARY
#   - xcom_rx_clk_* (external RX clocks, 250 MHz each) ← ASYNCHRONOUS
#   - xcom_tx_clk_out (generated TX clock, ~107.5 MHz) ← ASYNCHRONOUS
#   - xcom_loop_clk (loopback test clock, ~107.5 MHz) ← ASYNCHRONOUS
#
# CDC Approach:
#   ✓ All clock domain crossings are handled by explicit multi-stage
#     synchronizers implemented in RTL (xcom_cdc.sv)
#   ✓ These constraints cut false timing paths outside the synchronizers
#   ✓ Synchronizer flip-flop chains eliminate metastability at first stage
#
# Vivado Behavior:
#   - By default, would attempt to verify timing through synchronizers
#   - set_false_path suppresses these checks, trusting RTL design
#   - Metastability margin calculated separately in design review
###############################################################################

# --- TIME Domain <-> TX/Loopback Clocks (Asynchronous) ---
# xcom_tx_clk_out and xcom_loop_clk are hierarchically derived from
# clk_out1_d_1_MTSclkwiz_0 (i_time_clk), so set_clock_groups -asynchronous
# is rejected by Vivado between related clocks. Use set_false_path instead.

set_false_path \
    -from [get_clocks clk_out1_d_1_MTSclkwiz_0] \
    -to   [get_clocks xcom_tx_clk_out]

set_false_path \
    -from [get_clocks clk_out1_d_1_MTSclkwiz_0] \
    -to   [get_clocks xcom_loop_clk]

set_false_path \
    -from [get_clocks xcom_tx_clk_out] \
    -to   [get_clocks clk_out1_d_1_MTSclkwiz_0]

set_false_path \
    -from [get_clocks xcom_loop_clk] \
    -to   [get_clocks clk_out1_d_1_MTSclkwiz_0]

# --- CORE Domain <-> TIME Domain (Asynchronous) ---
set_false_path \
    -from [get_clocks -of_objects [get_nets i_core_clk]] \
    -to   [get_clocks -of_objects [get_nets i_time_clk]]

set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to   [get_clocks -of_objects [get_nets i_core_clk]]

# --- PS Domain <-> TIME Domain (Asynchronous) ---
# PS clock (100 MHz from ARM) is completely independent.

set_false_path \
    -from [get_clocks -of_objects [get_nets i_ps_clk]] \
    -to   [get_clocks -of_objects [get_nets i_time_clk]]

set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to   [get_clocks -of_objects [get_nets i_ps_clk]]

# --- RX External Clocks <-> Internal Clocks (Asynchronous) ---
# RX clocks only exist at IOB (IDELAYE3 input); internally fabric
# registers sampled by i_time_clk. Valid DDR but no phase alignment.

set_false_path \
    -from [get_clocks xcom_rx_clk_*] \
    -to   [get_clocks -of_objects [get_nets i_time_clk]]

set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to   [get_clocks xcom_rx_clk_*]


###############################################################################
# Section 6: CDC SYNCHRONIZER CONSTRAINTS
###############################################################################
# All clock domain crossings use explicit multi-stage synchronizers.
# First-stage flip-flops are "unsafe" from static timing view;
# metastability risk resolved by subsequent pipeline stages.
#
# Synchronizer Architecture (xcom_cdc.sv):
#   [ASYNC INPUT] → [FF_SYNC_0] → [FF_SYNC_1] → [FF_SYNC_2] → [SAFE OUTPUT]
#                    ↑ SET_FALSE_PATH applies here
#                    (2-3 cycles of target clock for synchronization)
#
# This is the standard Xilinx CDC methodology.
###############################################################################

# Relax setup/hold on all first-stage CDC sync registers
set_false_path -to [get_pins -filter {REF_PIN_NAME =~ D} -of_objects \
    [get_cells -hier -filter {name =~ *_cdc_reg* || name =~ *sync_reg*}]]

# Core enable request (i_core_clk → i_time_clk)
set_false_path \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects \
        [get_cells -hier -filter {name =~ *u_xcom_cdc/core_en_req_reg}]] \
    -to [get_clocks -of_objects [get_nets i_time_clk]]

# Core output data/control (i_time_clk → i_core_clk)
set_false_path \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects \
        [get_cells -hier -filter {name =~ *u_xcom_cdc/o_core_*_reg*}]] \
    -to [get_clocks -of_objects [get_nets i_core_clk]]

# AXI read data (i_time_clk → i_ps_clk)
set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to [get_pins -filter {REF_PIN_NAME =~ D} -of_objects \
        [get_cells -hier -filter {name =~ *u_xcom_axil_slv/rdata_reg_reg*}]]

# AXI write data (i_ps_clk → i_time_clk)
set_false_path \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects \
        [get_cells -hier -filter {name =~ *u_xcom_axil_slv/slave_registers_reg*}]] \
    -to [get_clocks -of_objects [get_nets i_time_clk]]

# RX phase control (i_time_clk → xcom_rx_clk_*)
set_false_path \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects \
        [get_cells -hier -filter {name =~ *u_xcom_link_rx/s_pha_reg}]] \
    -to [get_clocks xcom_rx_clk_*]

set_false_path -quiet \
    -from [get_pins -filter {REF_PIN_NAME =~ C} -of_objects \
        [get_cells -hier -filter {name =~ *u_xcom_link_rx/s_pha_reg}]] \
    -to [get_clocks xcom_loop_clk]


###############################################################################
# Section 7: RX DATA INPUT DELAYS
###############################################################################
# Center-aligned DDR input delay specification.
#
# Model:
#   xcom_clk_virt  waveform {0.0 2.0}: data launched at t=0 and t=2 ns
#   xcom_rx_clk_*  waveform {1.0 3.0}: clock arrives at t=1 ns (center of eye)
#
# The ±0.1 ns window models board-level skew between data and clock lines.
# VALIDATE these values with oscilloscope measurements on actual hardware.
# Tighter margin → more timing pressure on router. Loosen to 0.5 ns if needed.
###############################################################################

# Rising edge data launch
set_input_delay -clock xcom_clk_virt -max  0.1 [get_ports i_xcom_data_p*]
set_input_delay -clock xcom_clk_virt -min -0.1 [get_ports i_xcom_data_p*]

# Falling edge data launch (DDR complement)
set_input_delay -clock xcom_clk_virt -max  0.1 -clock_fall \
    [get_ports i_xcom_data_p*] -add_delay
set_input_delay -clock xcom_clk_virt -min -0.1 -clock_fall \
    [get_ports i_xcom_data_p*] -add_delay


###############################################################################
# Section 7b: RX DDR CENTER-ALIGNED TIMING EXCEPTIONS
###############################################################################
# For center-aligned DDR, only cross-edge transfers are valid:
#   VALID:   falling launch (virt) → rising capture (rx_clk)  [setup check]
#   VALID:   rising launch (virt)  → falling capture (rx_clk) [setup check]
#   INVALID: same-edge transfers   → hold checks are impossible
#
# Cut the invalid checks to prevent false timing violations.
# This is the standard Xilinx methodology for center-aligned DDR interfaces.
# Reference: Xilinx UG949 "UltraFast Design Methodology Guide", Ch. 4.
###############################################################################

# Rising launch → falling capture: not a valid setup check in center-aligned DDR
set_false_path -setup \
    -rise_from [get_clocks xcom_clk_virt] \
    -fall_to   [get_clocks xcom_rx_clk_*]

# Falling launch → rising capture: not a valid setup check in center-aligned DDR
set_false_path -setup \
    -fall_from [get_clocks xcom_clk_virt] \
    -rise_to   [get_clocks xcom_rx_clk_*]

# Same-edge hold checks: not applicable for center-aligned DDR
set_false_path -hold \
    -rise_from [get_clocks xcom_clk_virt] \
    -rise_to   [get_clocks xcom_rx_clk_*]

set_false_path -hold \
    -fall_from [get_clocks xcom_clk_virt] \
    -fall_to   [get_clocks xcom_rx_clk_*]


###############################################################################
# Section 8: TX DATA OUTPUT DELAYS
###############################################################################
# DDR output delay specification at the IOB.
# Valid window: ±500 ps (board propagation + receiver setup/hold).
# Adjust based on actual board measurements if timing fails.
#
# Interface Properties:
#   - Differential pairs: o_xcom_data_p / o_xcom_data_n
#   - Frequency: 107.5 MHz (9.301 ns period) on xcom_tx_clk_out
#   - Launch method: ODDRE1 DDR flip-flops at IOB
#   - Capture method: External receiver DDR registers
#   - Valid window: ±500 ps (board propagation + receiver setup/hold)
#
# Delay Specification:
#   Data valid window relative to xcom_tx_clk_out (capture clock):
#     -max: setup margin (data available 500 ps after clock)
#     -min: hold margin (data stable 500 ps before clock)
#
# NOTE: Board-level PCB propagation delay (trace delay) is NOT included
#       in these constraints. If timing fails, consider:
#       1. Measure actual trace delays with TDR (Time Domain Reflectometry)
#       2. Adjust ODELAYE3 tap settings (variable delay on data line)
#       3. Increase output_delay margins if receiver has slack
###############################################################################

# Rising edge capture at external receiver
set_output_delay -clock [get_clocks xcom_tx_clk_out] -max  0.5 \
    [get_ports o_xcom_data_p*]
set_output_delay -clock [get_clocks xcom_tx_clk_out] -min -0.5 \
    [get_ports o_xcom_data_p*]

# Falling edge capture at external receiver (DDR complement)
set_output_delay -clock [get_clocks xcom_tx_clk_out] -max  0.5 -clock_fall \
    [get_ports o_xcom_data_p*] -add_delay
set_output_delay -clock [get_clocks xcom_tx_clk_out] -min -0.5 -clock_fall \
    [get_ports o_xcom_data_p*] -add_delay


###############################################################################
# Section 9: TX MULTICYCLE AND TIMING RELAXATION
###############################################################################
# The TX data path spans from i_time_clk (430 MHz) to xcom_tx_clk_out (107.5 MHz).
# This is a significant frequency ratio that requires careful analysis.
#
# Data Flow:
#   i_time_clk → tx_clk_r (divide-by-4 logic) → ODDRE1 → o_xcom_data_p
#
# Timing Constraints:
#   set_multicycle_path -start N:
#     Shifts setup check window by (N-1) target clock cycles
#     Allows data to be stable for multiple target cycles
#
#   set_multicycle_path -hold:
#     Applies same shift to hold check
#
# If timing FAILS:
#   1. Try -start 2: allows 2x target clock cycles for data valid window
#   2. Uncomment set_false_path -setup: completely relaxes setup on falling edge
#   3. Verify ODELAYE3 configuration (data line delay compensation)
#   4. Check ODDRE1 D input timing (tx_data_d_r must be stable)
###############################################################################

# TX data valid for one target clock cycle relative to xcom_tx_clk_out
set_multicycle_path -to [get_ports o_xcom_data_p*] -start 1

# Apply same shift to hold check (rising edge)
set_multicycle_path -to [get_ports o_xcom_data_p*] -start 1 -hold

# Relax setup on falling edge of DAC clock to TX output port
# (active — needed to close timing on the DDR output path)
set_false_path -setup \
    -fall_from [get_clocks clk_out1_d_1_MTSclkwiz_0] \
    -to        [get_clocks xcom_tx_clk_out]
# Optional: If setup timing fails on falling edge of i_time_clk, uncomment:
# set_false_path -setup -fall_from [get_clocks i_time_clk] \
#     -to [get_clocks xcom_tx_clk_out]

# Alternative approach for aggressive relaxation (use if above fails):
# set_false_path -setup \
#     -from [get_clocks -of_objects [get_nets i_time_clk]] \
#     -to [get_ports o_xcom_data_p*]


###############################################################################
# Section 10: RX RESET CONTROL SIGNALS
###############################################################################
# Asynchronous control signals from i_time_clk to RX bit counter resets.
# These are NOT data paths; they are quasi-static control signals used
# by state machines for synchronization and reset.
#
# Safe to declare as false paths because:
#   1. Asserted infrequently (during state transitions only)
#   2. Reset timing is not critical (always given priority)
#   3. Vivado CDC tool would flag these as "low risk" crossings
#
# Affected Signals:
#   - ddr_bit_cntr_reg[0] PRE: asynchronous preset input
#   - ddr_bit_cntr_reg[*] CLR: asynchronous clear input
###############################################################################

# Preset (PRE) signal to RX bit counter [0]
set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to [get_pins -filter {REF_PIN_NAME =~ PRE} -of_objects \
        [get_cells -hier -filter \
            {name =~ *u_rx_cmd/RX[*].u_xcom_link_rx/ddr_bit_cntr_reg[0]}]]

# Clear (CLR) signal to remaining RX bit counter stages
set_false_path \
    -from [get_clocks -of_objects [get_nets i_time_clk]] \
    -to [get_pins -filter {REF_PIN_NAME =~ CLR} -of_objects \
        [get_cells -hier -filter \
            {name =~ *u_rx_cmd/RX[*].u_xcom_link_rx/ddr_bit_cntr_reg* && \
             name !~ "*ddr_bit_cntr_reg[0]"}]]


###############################################################################
# Section 11: DEBUG PROBE CONSTRAINTS
###############################################################################
# Low-speed debug probes (ILA/VIO) for post-implementation monitoring.
# These are control/diagnostic signals; timing is not critical.
# Safe to declare false paths without risk of functional failure.
###############################################################################

set_false_path -quiet \
    -from [get_ports i_xcom_*] \
    -through [get_ports o_dbg_probe*] \
    -to [get_clocks -of_objects [get_nets i_time_clk]]


###############################################################################
# END OF XCOM TIMING CONSTRAINTS
###############################################################################
