///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
//
// Fermi National Accelerator Laboratory
//
// Module: axil_slv.sv
// Project: QICK 
// Description: 
// AXI4-Lite Slave interface for the XCOM core.
// I/O ports corresponds to the AXI4 Interface definition.
//
// Change history: 05/14/25 - v0.1.0 Started by @lharnaldi
//                 12/03/25 - @lharnaldi 
//                            Fixed issues:
//                            1. awready_reg, wready_reg, arready_reg 
//                               now properly initialized
//                            2. Ready signals have defined values in 
//                               all FSM states
//                            3. Cleaner FSM structure with explicit 
//                               defaults
///////////////////////////////////////////////////////////////////////////////
module axil_slv#(
  parameter integer C_S_AXI_DATA_WIDTH = 32,
  parameter integer C_S_AXI_ADDR_WIDTH = 8,
  parameter integer NUM_REGS = 16
)(
  // Global signals
  input  logic                                S_AXI_ACLK,
  input  logic                                S_AXI_ARESETN,

  // Write address channel
  input  logic [C_S_AXI_ADDR_WIDTH-1:0]       S_AXI_AWADDR,
  //input  logic [2:0]                          S_AXI_AWPROT,
  input  logic                                S_AXI_AWVALID,
  output logic                                S_AXI_AWREADY,

  // Write data channel
  input  logic [C_S_AXI_DATA_WIDTH-1:0]       S_AXI_WDATA,
  input  logic [(C_S_AXI_DATA_WIDTH/8)-1:0]   S_AXI_WSTRB,
  input  logic                                S_AXI_WVALID,
  output logic                                S_AXI_WREADY,

  // Write response channel
  output logic [1:0]                          S_AXI_BRESP,
  output logic                                S_AXI_BVALID,
  input  logic                                S_AXI_BREADY,

  // Read address channel
  input  logic [C_S_AXI_ADDR_WIDTH-1:0]       S_AXI_ARADDR,
  //input  logic [2:0]                          S_AXI_ARPROT,
  input  logic                                S_AXI_ARVALID,
  output logic                                S_AXI_ARREADY,

  // Read data channel
  output logic [C_S_AXI_DATA_WIDTH-1:0]       S_AXI_RDATA,
  output logic [1:0]                          S_AXI_RRESP,
  output logic                                S_AXI_RVALID,
  input  logic                                S_AXI_RREADY,

  // User registers interface
  output logic [C_S_AXI_DATA_WIDTH-1:0]       o_slv_regs[0:NUM_REGS-1],
  input  logic [C_S_AXI_DATA_WIDTH-1:0]       i_slv_regs[0:NUM_REGS-1]
);

  // AXI4-Lite signals
  logic                                axi_awready;
  logic                                axi_wready;
  logic [1:0]                          axi_bresp;
  logic                                axi_bvalid;
  logic                                axi_arready;
  logic [C_S_AXI_DATA_WIDTH-1:0]       axi_rdata;
  logic [1:0]                          axi_rresp;
  logic                                axi_rvalid;

  // Internal signals
  logic [C_S_AXI_ADDR_WIDTH-1:0]       axi_awaddr;
  logic [C_S_AXI_ADDR_WIDTH-1:0]       axi_araddr;

  // Address decoding
  localparam integer ADDR_LSB = $clog2(C_S_AXI_DATA_WIDTH/8);
  localparam integer ADDR_MSB = ADDR_LSB + $clog2(NUM_REGS) - 1;

  logic slv_reg_wren;
  logic slv_reg_rden;
  integer byte_index;

  // I/O connections
  assign S_AXI_AWREADY = axi_awready;
  assign S_AXI_WREADY  = axi_wready;
  assign S_AXI_BRESP   = axi_bresp;
  assign S_AXI_BVALID  = axi_bvalid;
  assign S_AXI_ARREADY = axi_arready;
  assign S_AXI_RDATA   = axi_rdata;
  assign S_AXI_RRESP   = axi_rresp;
  assign S_AXI_RVALID  = axi_rvalid;

  // ============================================
  // Write Address Channel
  // ============================================
  always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
      axi_awready <= 1'b0;
      axi_awaddr  <= 0;
    end else begin
      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
        axi_awready <= 1'b1;
        axi_awaddr  <= S_AXI_AWADDR;
      end else begin
        axi_awready <= 1'b0;
      end
    end
  end

  // ============================================
  // Write Data Channel
  // ============================================
  always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
      axi_wready <= 1'b0;
    end else begin
      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID) begin
        axi_wready <= 1'b1;
      end else begin
        axi_wready <= 1'b0;
      end
    end
  end

  // Write enable generation
  assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

  // Register write logic with byte-enable support
  always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
      for (int i = 0; i < NUM_REGS; i++) begin
        o_slv_regs[i] <= 32'h0;
      end
    end else begin
      if (slv_reg_wren) begin
        for (byte_index = 0; byte_index < C_S_AXI_DATA_WIDTH/8; byte_index++) begin
          if (S_AXI_WSTRB[byte_index]) begin
            o_slv_regs[axi_awaddr[ADDR_MSB:ADDR_LSB]][(byte_index*8) +: 8] <= 
              S_AXI_WDATA[(byte_index*8) +: 8];
          end
        end
        //end else begin
        //    // Allow external updates to registers
        //    for (int i = 0; i < NUM_REGS; i++) begin
        //        o_slv_regs[i] <= i_slv_regs[i];
        //    end
      end
      // Values persist - no else clause overwriting them
    end
  end

  // ============================================
  // Write Response Channel
  // ============================================
  always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
      axi_bvalid <= 1'b0;
      axi_bresp  <= 2'b00;
    end else begin
      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
          axi_bvalid <= 1'b1;
          axi_bresp  <= 2'b00; // OKAY response
        end else begin
          if (S_AXI_BREADY && axi_bvalid) begin
            axi_bvalid <= 1'b0;
          end
        end
    end
  end

  // ============================================
  // Read Address Channel
  // ============================================
  always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
      axi_arready <= 1'b0;
      axi_araddr  <= 0;
    end else begin
      if (~axi_arready && S_AXI_ARVALID) begin
        axi_arready <= 1'b1;
        axi_araddr  <= S_AXI_ARADDR;
      end else begin
        axi_arready <= 1'b0;
      end
    end
  end

  // ============================================
  // Read Data Channel
  // ============================================
  always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
      axi_rvalid <= 1'b0;
      axi_rresp  <= 2'b0;
    end else begin
      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
        axi_rvalid <= 1'b1;
        axi_rresp  <= 2'b00; // OKAY response
      end else if (axi_rvalid && S_AXI_RREADY) begin
        axi_rvalid <= 1'b0;
      end
    end
  end

  // Read enable generation
  assign slv_reg_rden = axi_arready && S_AXI_ARVALID && ~axi_rvalid;

  // Register read logic
  always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
      axi_rdata <= 0;
    end else begin
      if (slv_reg_rden) begin
        axi_rdata <= o_slv_regs[axi_araddr[ADDR_MSB:ADDR_LSB]];
      end
    end
  end

endmodule
