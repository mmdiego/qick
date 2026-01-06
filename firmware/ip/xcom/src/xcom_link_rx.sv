///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
//
// Fermi National Accelerator Laboratory
//
// Module: xcom_link_rx.sv
// Project: QICK 
// Description: Receiver interface for the XCOM block
//
//Inputs:
// - i_clk       clock signal
// - i_rstn      active low reset signal
// - i_id        this input configures the ID of the board in the network. It
//               can be configured manually or automatically. 
// - i_ack       it is a one clock duration signal indicating an
//               acknowledgement from the tproc/pynq side. This means the
//               tproc/pynq side can receive and process the data arriving in
//               the XCOM link  
// - i_xcom_data serial data received. This is the general data input of the
//               XCOM block
// - i_xcom_clk  serial clock for reception. This is the general clock input of
//               the XCOM block
//Outputs:
// - o_req       signal indicating valid data arrived. This signal is to
//               indicate to the tproc/pynq side there are new valid data to
//               process.
// - o_cmd       command to be executed by the tproc/pynq
// - o_data      data received, to be processed by the tproc/pynq
// - o_dbg_state debug port for monitoring the state of the internal FSM
//
// Change history: 09/20/24 - v1 Started by @mdifederico
//                 05/01/25 - Refactored by @lharnaldi
//                          - the sync_n core was removed to sync all signals
//                            in one place (external).
//
///////////////////////////////////////////////////////////////////////////////

module xcom_link_rx (
    input  logic            i_clk          ,
    input  logic            i_rstn         ,
    input  logic  [4-1:0]   i_id           ,
    // Command Processing    
    input  logic            i_ack          ,
    output logic            o_req          ,
    output logic  [4-1:0]   o_cmd          ,
    output logic [32-1:0]   o_data         ,
    // Xwire COM
    input  logic            i_xcom_data    ,
    input  logic            i_xcom_clk     ,
    // XCOM RX DEBUG
    output logic  [5-1:0]   o_dbg_state      
);


logic          s_no_data, s_timeout, s_data_last ;
logic          s_broadcast, s_local_id;

logic [ 8-1:0] s_header_shreg ;
logic [ 8-1:0] s_header         ;
logic [32-1:0] s_data_shreg ;  
logic          s_new_data;
logic          s_new_bit;

logic          s_rx_idle, s_rx_header, s_rx_req ;

typedef enum logic [3-1:0]{ IDLE   = 3'b000, 
                            HEADER = 3'b001, 
                            DATA   = 3'b010, 
                            REQ    = 3'b011, 
                            ACK    = 3'b100
} state_t;
state_t state_r, state_n;

logic [6-1:0] s_rx_pack_size;

// Timeout counter, up to 32 clock cycles. This gives roughly 64 ns with
// a t_clk = 500 MHz
logic [5-1:0] timeout_cntr_r, timeout_cntr_n; 
// logic [6-1:0] bit_cntr_r, bit_cntr_n        ; // Receive up to 40 bits
logic [1:0] data_cntr_r, data_cntr_n       ; // Receive up to 4 data words

// DDR - RX Serial to Paralel
///////////////////////////////////////////////////////////////////////////////

logic [3:0] ddr_data0_reg_pos, ddr_data0_reg_neg;
logic [3:0] ddr_data1_reg_pos, ddr_data1_reg_neg;
logic ddr_last_toggle;
always_ff @ (posedge i_xcom_clk) begin
   if (~ddr_last_toggle) begin
      ddr_data0_reg_pos <= {ddr_data0_reg_pos[2:0], i_xcom_data};
   end else begin
      ddr_data1_reg_pos <= {ddr_data1_reg_pos[2:0], i_xcom_data};
   end
end
always_ff @ (negedge i_xcom_clk) begin
   if (~ddr_last_toggle) begin
      ddr_data0_reg_neg <= {ddr_data0_reg_neg[2:0], i_xcom_data};
   end else begin
      ddr_data1_reg_neg <= {ddr_data1_reg_neg[2:0], i_xcom_data};
   end
end


// DDR Bit Counter
///////////////////////////////////////////////////////////////////////////////
logic [3:0] ddr_bit_cntr;
logic ddr_bit_cntr_rstn;
assign ddr_bit_cntr_rstn = i_rstn & ~s_timeout;
always_ff @ (negedge i_xcom_clk, negedge ddr_bit_cntr_rstn) begin
   if (!ddr_bit_cntr_rstn) begin
      ddr_bit_cntr  <= 'd1;
   end else begin
      ddr_bit_cntr  <= {ddr_bit_cntr[2:0], ddr_bit_cntr[3]};
   end
end

logic ddr_first_bits;
assign ddr_first_bits = ddr_bit_cntr[0];
logic ddr_last_bits;
assign ddr_last_bits  = ddr_bit_cntr[3];


// // IDDR: Input Double Data Rate Input Register with Set, Reset
// //       and Clock Enable.
// //       7 Series
// // Xilinx HDL Language Template, version 2025.1

// IDDR #(
//    .DDR_CLK_EDGE  ("OPPOSITE_EDGE"),   // "OPPOSITE_EDGE", "SAME_EDGE"
//                                        //    or "SAME_EDGE_PIPELINED"
//    .INIT_Q1       (1'b0),              // Initial value of Q1: 1'b0 or 1'b1
//    .INIT_Q2       (1'b0),              // Initial value of Q2: 1'b0 or 1'b1
//    .SRTYPE        ("SYNC")             // Set/Reset type: "SYNC" or "ASYNC"
// ) IDDR_inst (
//    .R             (1'b0),              // 1-bit reset
//    .S             (1'b0),              // 1-bit set
//    .CE            (1'b1),              // 1-bit clock enable input
//    .C             (i_xcom_clk),        // 1-bit clock input
//    .D             (i_xcom_data),       // 1-bit DDR data input
//    .Q1            (ddr_data_reg_h),   // 1-bit output for positive edge of clock
//    .Q2            (ddr_data_reg_l)    // 1-bit output for negative edge of clock
// );


always_ff @ (negedge i_xcom_clk, negedge i_rstn) begin
   if (!i_rstn) begin
      ddr_last_toggle  <= 1'b0;
   end else begin
      if (ddr_last_bits) begin
         ddr_last_toggle  <= ~ddr_last_toggle;
      end
   end
end


logic ddr_last_sync;
logic ddr_last_sync_d;
synchronizer #(
   .NB         (1)
) 
u_ddr_last_sync (
  .i_clk      ( i_clk            ),
  .i_rstn     ( i_rstn           ),
  .i_async    ( ddr_last_toggle  ),
  .o_sync     ( ddr_last_sync    )
);

always_ff @ (posedge i_clk, negedge i_rstn) begin
   if (!i_rstn) begin
      ddr_last_sync_d  <= 1'b0;
   end else begin
      ddr_last_sync_d  <= ddr_last_sync;
   end
end

logic ddr_last_sync_edge;
assign ddr_last_sync_edge = ddr_last_sync ^ ddr_last_sync_d;


// DDR Data CDC
///////////////////////////////////////////////////////////////////////////////
logic [ 7:0] ddr_data_cdc ;
logic       ddr_data_dv  ;

always_ff @ (posedge i_clk) begin
   if (!i_rstn) begin
      ddr_data_cdc   <= '0;
      ddr_data_dv    <= 1'b0;
   end else begin
      ddr_data_dv      <= ddr_last_sync_edge;
      if (ddr_last_sync_edge) begin
         if (~ddr_last_toggle) begin
            ddr_data_cdc   <= {ddr_data1_reg_pos[3], ddr_data1_reg_neg[3],
                                 ddr_data1_reg_pos[2], ddr_data1_reg_neg[2],
                                 ddr_data1_reg_pos[1], ddr_data1_reg_neg[1],
                                 ddr_data1_reg_pos[0], ddr_data1_reg_neg[0]};
         end else begin
            ddr_data_cdc   <= {ddr_data0_reg_pos[3], ddr_data0_reg_neg[3],
                                 ddr_data0_reg_pos[2], ddr_data0_reg_neg[2],
                                 ddr_data0_reg_pos[1], ddr_data0_reg_neg[1],
                                 ddr_data0_reg_pos[0], ddr_data0_reg_neg[0]};
         end
      end
   end
end

assign s_new_data = ddr_data_dv;

always_ff @ (posedge i_clk) begin
   if (!i_rstn) begin
      s_data_shreg    <= '0; 
      s_header_shreg  <= '0; 
   end else begin 
      if (s_new_data) begin
         if ( s_rx_header ) begin
            s_header_shreg <= ddr_data_cdc;
            s_data_shreg   <= '0;
         end else               
            s_data_shreg   <= {s_data_shreg[31-8:0], ddr_data_cdc};
      end
   end
end
assign s_header = s_new_data & s_rx_header ? ddr_data_cdc : s_header_shreg;

// New Bit Monitor
///////////////////////////////////////////////////////////////////////////////

logic          s_xcom_clk_dly;
logic          s_xcom_clk_sync;

synchronizer #(
   .NB(1)
) sync_xcom_clk(
  .i_clk      ( i_clk           ),
  .i_rstn     ( i_rstn          ),
  .i_async    ( i_xcom_clk      ),
  .o_sync     ( s_xcom_clk_sync )
);

always_ff @ (posedge i_clk) begin
   if (!i_rstn) begin
      s_xcom_clk_dly  <= 1'b0;
   end else begin 
      s_xcom_clk_dly  <= s_xcom_clk_sync;
   end
end

assign s_new_bit   = s_xcom_clk_dly ^ s_xcom_clk_sync;

///// DDR RX STATE
///////////////////////////////////////////////////////////////////////////////

always_ff @ (posedge i_clk) begin
   if   ( !i_rstn ) state_r  <= IDLE;
   else             state_r  <= state_n;
end

always_comb begin
   state_n     = state_r;
   s_rx_idle   = 1'b0;
   s_rx_header = 1'b0;
   s_rx_req    = 1'b0;
   case (state_r)
      IDLE:  begin
         s_rx_idle = 1'b1;
         if ( s_new_bit ) begin //detects first bit transition
            state_n     = HEADER; 
         end
      end
      HEADER:  begin
         s_rx_header = 1'b1;
         if ( s_timeout  ) state_n = IDLE; // TimeOut
         if ( s_new_data ) begin
            if      ( s_no_data  ) state_n = REQ  ; // Package has No Data
            else                   state_n = DATA ; // Package has Data   
         end
      end
      DATA:  begin 
         if ( s_timeout   ) state_n = IDLE; // TimeOut
         if ( s_data_last ) state_n = REQ;  // Last Data Received
      end
      REQ:  begin
         if ( s_timeout  ) state_n = IDLE; // TimeOut
         if ( s_broadcast | s_local_id ) begin
            s_rx_req = 1'b1;
            if (i_ack ) state_n = ACK;
         end else
            state_n = IDLE;
      end
      ACK:  begin
         if ( s_timeout  ) state_n = IDLE; // TimeOut
         if (!i_ack) state_n = IDLE;
      end
      default: state_n = state_r;
   endcase
end


// RX Length Decoding
///////////////////////////////////////////////////////////////////////////////
always_comb begin
   case ( s_header [6:5] )
      2'b00  : s_rx_pack_size = 6'd8  ; //8-bit header + no data
      2'b01  : s_rx_pack_size = 6'd16 ; //8-bit header + 8-bit data 
      2'b10  : s_rx_pack_size = 6'd24 ; //8-bit header + 16-bit data
      2'b11  : s_rx_pack_size = 6'd40 ; //8-bit header + 32-bit data
      default: s_rx_pack_size = 6'd8  ; //8-bit header + no data
   endcase
end


///////////////////////////////////////////////////////////////////////////////
// RX Measurement
always_ff @ (posedge i_clk) begin
   if (!i_rstn) begin
      data_cntr_r    <= 2'd0;
      timeout_cntr_r <= '0;
   end else begin
      data_cntr_r    <= data_cntr_n;
      timeout_cntr_r <= timeout_cntr_n;
   end
end

//next-state logic
assign data_cntr_n    = (s_new_data) ? (s_rx_header) ? 2'd0 : data_cntr_r + 1'b1 : data_cntr_r; 
assign timeout_cntr_n = (s_new_bit)  ? '0                   : (s_rx_idle) ? '0   : timeout_cntr_r + 1'b1; 

assign s_data_last   = s_new_data & (data_cntr_r == ((s_rx_pack_size-8)/8 - 1) ) ; // Last Data Received
assign s_no_data     = (s_header[6:5] == 2'b00) ; // cmd with no data
assign s_broadcast   = (s_header[3:0] == 4'd0); //broadcast
assign s_local_id    = (s_header[3:0] == i_id) ;
assign s_timeout     = &timeout_cntr_r ; // New Data was not received in time

///////////////////////////////////////////////////////////////////////////////
// OUTPUTS
///////////////////////////////////////////////////////////////////////////////
assign o_dbg_state  = {2'b00,state_r};
assign o_req        = s_rx_req;
assign o_cmd        = s_header[7:4];
assign o_data       = s_data_shreg;
   
endmodule
