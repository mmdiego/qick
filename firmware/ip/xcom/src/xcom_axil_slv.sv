///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
//
// Fermi National Accelerator Laboratory
//
// Module: xcom_axil_slv.sv
// Project: QICK 
// Description: 
// AXI4-Lite Slave interface for the XCOM core.
// I/O ports corresponds to the AXI4 Interface definition.
//
// Change history: 05/14/25 - v0.1.0 Started by @lharnaldi
//
///////////////////////////////////////////////////////////////////////////////
module xcom_axil_slv #(
    parameter integer C_S_AXI_ADDR_WIDTH = 6,                 // Address width.  Adjust as needed.
    parameter integer C_S_AXI_DATA_WIDTH = 32                 // Data width (32 or 64).
) (
    input  logic                            clk,              // System clock
    input  logic                            reset_n,          // Active-low reset
    // Write address channel signals
    input  logic [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_awaddr,     // Write address
    input  logic                            s_axi_awvalid,    // Write address valid
    output logic                            s_axi_awready,    // Write address ready
    // Write data channel signals
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   s_axi_wdata,      // Write data
    input  logic [C_S_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,      // Write strobes
    input  logic                            s_axi_wvalid,     // Write data valid
    output logic                            s_axi_wready,     // Write data ready
    // Write response channel signals
    output logic [1:0]                      s_axi_bresp,      // Write response
    output logic                            s_axi_bvalid,     // Write response valid
    input  logic                            s_axi_bready,     // Write response ready
    // Read address channel signals
    input  logic [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_araddr,     // Read address
    input  logic                            s_axi_arvalid,    // Read address valid
    output logic                            s_axi_arready,    // Read address ready
    // Read data channel signals
    output logic [C_S_AXI_DATA_WIDTH-1:0]   s_axi_rdata,      // Read data
    output logic [1:0]                      s_axi_rresp,      // Read response
    output logic                            s_axi_rvalid,     // Read data valid
    input  logic                            s_axi_rready,     // Read data ready
    // Registers.
    output logic [C_S_AXI_DATA_WIDTH-1:0]   o_xcom_ctrl,      //out std_logic_vector ( 5 downto 0) ;
    output logic [C_S_AXI_DATA_WIDTH-1:0]   o_xcom_cfg,       //out std_logic_vector ( 3 downto 0) ;
    output logic [C_S_AXI_DATA_WIDTH-1:0]   o_xcom_axi_data1, //out std_logic_vector (31 downto 0) ;
    output logic [C_S_AXI_DATA_WIDTH-1:0]   o_xcom_axi_data2, //out std_logic_vector (31 downto 0) ;
    output logic [C_S_AXI_DATA_WIDTH-1:0]   o_xcom_axi_addr,  //out std_logic_vector ( 3 downto 0) ;
    output logic [C_S_AXI_DATA_WIDTH-1:0]   o_xcom_tx_rx_ddr,
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   i_board_id,       //in  std_logic_vector ( 3 downto 0) ;
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   i_xcom_flag,      //in  std_logic ;
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   i_xcom_data1,     //in  std_logic_vector (31 downto 0) ;
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   i_xcom_data2,     //in  std_logic_vector (31 downto 0) ;
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   i_xcom_mem,       //in  std_logic_vector (31 downto 0) ;
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   i_xcom_rx_data,   //in  std_logic_vector (31 downto 0) ;
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   i_xcom_tx_data,   //in  std_logic_vector (31 downto 0) ;
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   i_xcom_status,    //in  std_logic_vector (28 downto 0) ;
    input  logic [C_S_AXI_DATA_WIDTH-1:0]   i_xcom_debug      //in  std_logic_vector (31 downto 0) );
);

    //-------------------------------------------------------------------------
    // Local parameters
    //-------------------------------------------------------------------------

    // Example: Define the memory map for this slave.  Start at address 0.
    localparam integer REG_OFFSET_0  = 0;       // Example register 0 offset
    localparam integer REG_OFFSET_1  = 4;       // Example register 1 offset
    localparam integer REG_OFFSET_2  = 8;
    localparam integer REG_OFFSET_3  = 12;
    localparam integer REG_OFFSET_4  = 16;
    localparam integer REG_OFFSET_5  = 20;
    localparam integer REG_OFFSET_6  = 24;
    localparam integer REG_OFFSET_7  = 28;
    localparam integer REG_OFFSET_8  = 32;
    localparam integer REG_OFFSET_9  = 36;
    localparam integer REG_OFFSET_10 = 40;
    localparam integer REG_OFFSET_11 = 44;
    localparam integer REG_OFFSET_12 = 48;
    localparam integer REG_OFFSET_13 = 52;
    localparam integer REG_OFFSET_14 = 56;
    localparam integer REG_OFFSET_15 = 60;

    //-------------------------------------------------------------------------
    // Local signals
    //-------------------------------------------------------------------------

    // Write address channel
    logic awready_reg;
    logic [C_S_AXI_ADDR_WIDTH-1:0] awaddr_reg;
    logic awaddr_valid_reg;  // Tracks if address has been received

    // Write data channel
    logic wready_reg;
    logic [C_S_AXI_DATA_WIDTH-1:0] wdata_reg;
    logic [C_S_AXI_DATA_WIDTH/8-1:0] wstrb_reg;
    logic wdata_valid_reg;   // Tracks if data has been received

    // Write response channel
    logic bvalid_reg;
    logic [1:0] bresp_reg;

    // Read address channel
    logic arready_reg;
    logic [C_S_AXI_ADDR_WIDTH-1:0] araddr_reg;

    // Read data channel
    logic rvalid_reg;
    logic [1:0] rresp_reg;
    logic [C_S_AXI_DATA_WIDTH-1:0] rdata_reg;

    // Internal register array to store data.  Example with 16 registers.
    logic [C_S_AXI_DATA_WIDTH-1:0] slave_registers [0:15];

    // FSM state for read operations
    typedef enum logic [1:0] {
        READ_IDLE,
        READ_ADDR_RCVD,
        READ_DATA_SENT
    } read_state_t;
    read_state_t read_state_reg, read_state_next;

    //-------------------------------------------------------------------------
    // I/O assignments
    //-------------------------------------------------------------------------

    // Drive the ready signals
    assign s_axi_awready = awready_reg;
    assign s_axi_wready  = wready_reg;
    assign s_axi_arready = arready_reg;

    // Drive the response and data signals
    assign s_axi_bresp   = bresp_reg;
    assign s_axi_bvalid  = bvalid_reg;
    assign s_axi_rdata   = rdata_reg;
    assign s_axi_rresp   = rresp_reg;
    assign s_axi_rvalid  = rvalid_reg;

    //-------------------------------------------------------------------------
    // Write channel logic (address and data handled independently)
    //-------------------------------------------------------------------------

    // Write address channel - capture address when valid and ready
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            awaddr_reg <= '0;
            awaddr_valid_reg <= 1'b0;
            awready_reg <= 1'b1;  // Start ready to accept address
        end else begin
            // Accept address when master is valid and we're ready
            if (s_axi_awvalid && awready_reg) begin
                awaddr_reg <= s_axi_awaddr;
                awaddr_valid_reg <= 1'b1;
                awready_reg <= 1'b0;  // Not ready for next address until response sent
            end
            // Clear address valid after response is sent
            else if (bvalid_reg && s_axi_bready) begin
                awaddr_valid_reg <= 1'b0;
                awready_reg <= 1'b1;  // Ready for next address
            end
        end
    end

    // Write data channel - capture data when valid and ready
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wdata_reg <= '0;
            wstrb_reg <= '0;
            wdata_valid_reg <= 1'b0;
            wready_reg <= 1'b1;  // Start ready to accept data
        end else begin
            // Accept data when master is valid and we're ready
            if (s_axi_wvalid && wready_reg) begin
                wdata_reg <= s_axi_wdata;
                wstrb_reg <= s_axi_wstrb;
                wdata_valid_reg <= 1'b1;
                wready_reg <= 1'b0;  // Not ready for next data until response sent
            end
            // Clear data valid after response is sent
            else if (bvalid_reg && s_axi_bready) begin
                wdata_valid_reg <= 1'b0;
                wready_reg <= 1'b1;  // Ready for next data
            end
        end
    end

    // Write response logic - send response when both address and data have been received
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            bvalid_reg <= 1'b0;
            bresp_reg  <= 2'b00;  // OKAY
        end else begin
            // Send response when both address and data are valid
            if (awaddr_valid_reg && wdata_valid_reg && !bvalid_reg) begin
                bvalid_reg <= 1'b1;
                bresp_reg  <= 2'b00;  // OKAY
            end
            // Clear response when master accepts it
            else if (bvalid_reg && s_axi_bready) begin
                bvalid_reg <= 1'b0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // Read channel logic
    //-------------------------------------------------------------------------

    // Read FSM state register
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            read_state_reg <= READ_IDLE;
        end else begin
            read_state_reg <= read_state_next;
        end
    end

    // Read FSM next-state logic
    always_comb begin
        read_state_next = read_state_reg; // Default: stay in the same state
        case (read_state_reg)
            READ_IDLE:
                if (s_axi_arvalid)
                    read_state_next = READ_ADDR_RCVD;
            READ_ADDR_RCVD:
                read_state_next = READ_DATA_SENT;
            READ_DATA_SENT:
                if(s_axi_rready)
                    read_state_next = READ_IDLE;
            default:
                read_state_next = READ_IDLE;
        endcase
    end

    // Read address capture
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            araddr_reg  <= '0;
        end else begin
            if (s_axi_arvalid && arready_reg) begin
                araddr_reg <= s_axi_araddr;
            end
        end
    end

    // Read data and response logic
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            arready_reg <= 1'b0;
            rvalid_reg <= 1'b0;
            rdata_reg  <= '0;
            rresp_reg  <= 2'b00; //OKAY
        end
        else begin
            case(read_state_reg)
               READ_ADDR_RCVD: begin
                    arready_reg <= 1'b0;
                    rvalid_reg  <= 1'b1;
                    rresp_reg   <= 2'b00;
                    case (araddr_reg[C_S_AXI_ADDR_WIDTH-1:0])
                        REG_OFFSET_0:  rdata_reg <= slave_registers[0];
                        REG_OFFSET_1:  rdata_reg <= slave_registers[1];
                        REG_OFFSET_2:  rdata_reg <= slave_registers[2];
                        REG_OFFSET_3:  rdata_reg <= slave_registers[3];
                        REG_OFFSET_4:  rdata_reg <= slave_registers[4];
                        REG_OFFSET_5:  rdata_reg <= slave_registers[5];
                        REG_OFFSET_6:  rdata_reg <= i_board_id;     //slave_registers[6];
                        REG_OFFSET_7:  rdata_reg <= i_xcom_flag;    //slave_registers[7];
                        REG_OFFSET_8:  rdata_reg <= i_xcom_data1;   //slave_registers[8];
                        REG_OFFSET_9:  rdata_reg <= i_xcom_data2;   //slave_registers[9];
                        REG_OFFSET_10: rdata_reg <= i_xcom_mem;     //slave_registers[10];
                        REG_OFFSET_11: rdata_reg <= '0;             //slave_registers[11];
                        REG_OFFSET_12: rdata_reg <= i_xcom_rx_data; //slave_registers[12];
                        REG_OFFSET_13: rdata_reg <= i_xcom_tx_data; //slave_registers[13];
                        REG_OFFSET_14: rdata_reg <= i_xcom_status;  //slave_registers[14];
                        REG_OFFSET_15: rdata_reg <= i_xcom_debug;   //slave_registers[15];
                        default:          rdata_reg <= '0; // Or some error value
                    endcase
                 end
                 READ_DATA_SENT: begin
                    if(s_axi_rready)
                        rvalid_reg <= 1'b0;
                  end
                  default: begin
                    rvalid_reg <= 1'b0;
                    arready_reg <= 1'b1;
                 end
            endcase
        end
    end

    //-------------------------------------------------------------------------
    // Register write logic
    //-------------------------------------------------------------------------

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            slave_registers[0]  <= '0;
            slave_registers[1]  <= '0;
            slave_registers[2]  <= '0;
            slave_registers[3]  <= '0;
            slave_registers[4]  <= '0;
            slave_registers[5]  <= '0;
            slave_registers[6]  <= '0;
            slave_registers[7]  <= '0;
            slave_registers[8]  <= '0;
            slave_registers[9]  <= '0;
            slave_registers[10] <= '0;
            slave_registers[11] <= '0;
            slave_registers[12] <= '0;
            slave_registers[13] <= '0;
            slave_registers[14] <= '0;
            slave_registers[15] <= '0;
        end else begin
           //reset
           if (slave_registers[0][0] != 1'b0) slave_registers[0][0]  <= 1'b0;
           
            // Write when both address and data are valid
            if (awaddr_valid_reg && wdata_valid_reg) begin
                case (awaddr_reg[C_S_AXI_ADDR_WIDTH-1:0])
                   REG_OFFSET_0: begin
                        if (wstrb_reg[0]) slave_registers[0][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[0][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[0][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[0][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_1: begin
                        if (wstrb_reg[0]) slave_registers[1][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[1][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[1][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[1][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_2: begin
                        if (wstrb_reg[0]) slave_registers[2][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[2][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[2][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[2][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_3: begin
                        if (wstrb_reg[0]) slave_registers[3][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[3][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[3][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[3][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_4: begin
                        if (wstrb_reg[0]) slave_registers[4][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[4][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[4][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[4][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_5: begin
                        if (wstrb_reg[0]) slave_registers[5][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[5][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[5][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[5][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_6: begin
                        if (wstrb_reg[0]) slave_registers[6][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[6][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[6][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[6][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_7: begin
                        if (wstrb_reg[0]) slave_registers[7][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[7][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[7][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[7][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_8: begin
                        if (wstrb_reg[0]) slave_registers[8][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[8][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[8][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[8][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_9: begin
                        if (wstrb_reg[0]) slave_registers[9][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[9][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[9][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[9][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_10: begin
                        if (wstrb_reg[0]) slave_registers[10][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[10][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[10][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[10][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_11: begin
                        if (wstrb_reg[0]) slave_registers[11][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[11][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[11][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[11][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_12: begin
                        if (wstrb_reg[0]) slave_registers[12][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[12][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[12][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[12][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_13: begin
                        if (wstrb_reg[0]) slave_registers[13][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[13][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[13][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[13][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_14: begin
                        if (wstrb_reg[0]) slave_registers[14][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[14][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[14][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[14][31:24] <= wdata_reg[31:24];
                     end
                     REG_OFFSET_15: begin
                        if (wstrb_reg[0]) slave_registers[15][7:0]   <= wdata_reg[7:0];
                        if (wstrb_reg[1]) slave_registers[15][15:8]  <= wdata_reg[15:8];
                        if (wstrb_reg[2]) slave_registers[15][23:16] <= wdata_reg[23:16];
                        if (wstrb_reg[3]) slave_registers[15][31:24] <= wdata_reg[31:24];
                     end
                    default: ; // Do nothing for invalid address, or return an error
                endcase
            end
        end
    end

    //-------------------------------------------------------------------------
    // Output Registers
    //-------------------------------------------------------------------------
       
    assign o_xcom_ctrl      = slave_registers[0];
    assign o_xcom_cfg       = slave_registers[1];
    assign o_xcom_axi_data1 = slave_registers[2];
    assign o_xcom_axi_data2 = slave_registers[3];
    assign o_xcom_axi_addr  = slave_registers[4];
    assign o_xcom_tx_rx_ddr = slave_registers[5];

endmodule