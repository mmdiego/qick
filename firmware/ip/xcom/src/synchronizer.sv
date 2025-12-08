///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
//
// Fermi Forward Alliance LLC
//
// Module: sync_n.sv
// Project: QICK
// Description: 2 FF, NB-bits data synchronizer. 
//              It serves as clock domain crossing (CDC) logic. 
//
// Change history: 04/29/25 - Created by @lharnaldi
//                 12/08/25 - Updated to match the common project synchronizer
//
///////////////////////////////////////////////////////////////////////////////
// module synchronizer #(
//    //number of bits in data
//    parameter NB = 1
// )(
//     input logic           i_clk ,
//     input logic           i_rstn,
//     input logic  [NB-1:0] i_async,
//     output logic [NB-1:0] o_sync
// );

//     logic [NB-1:0] meta_r, meta_n;
//     logic [NB-1:0] sync_r, sync_n;

//     //two D FFs
//     always_ff @ (posedge i_clk) begin
//      if(!i_rstn) begin
//        meta_r <= '0;
//        sync_r <= '0;
//      end else begin
//        meta_r <= meta_n;
//        sync_r <= sync_n;
//      end
//     end

//     //next-state logic
//     assign meta_n = i_async;
//     assign sync_n = meta_r;
    
//     //output logic
//     assign o_sync = sync_r;

// endmodule

module synchronizer # (
  parameter NB  = 32
)(
  input  wire [NB-1:0] i_async,
  input  wire          i_clk,
  input  wire          i_rstn,
  output wire [NB-1:0] o_sync
);

  // FAST REGISTER GRAY TRANSFORM OF INPUT
  (* ASYNC_REG = "TRUE" *) reg [NB-1:0] data_cdc, data_r;

  always_ff @(posedge i_clk)
    if (!i_rstn) begin
      data_cdc  <= 0;
      data_r    <= 0;
    end else begin 
      data_cdc  <= i_async;
      data_r    <= data_cdc;
    end

  assign o_sync = data_r;

endmodule