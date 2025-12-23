///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
//
// Fermi Forward Alliance LLC
//
// Module: toggle_synchronizer.sv
//
// NOTES: only works with 1 clk wide input pulses
//
///////////////////////////////////////////////////////////////////////////////
module toggle_synchronizer(
    input logic  i_rst_in_n,
    input logic  i_rst_out_n,
    input logic  i_clk_in ,
    input logic  i_clk_out,
    input logic  i_en     ,
    output logic o_en 
);

    logic toggle_ff;
    logic toggle_ff_sync_d1;
    logic toggle_ff_sync_d2;

    always_ff @ (posedge i_clk_in, negedge i_rst_in_n) begin
        if (~i_rst_in_n) begin
            toggle_ff <= 1'b0;
        end
        else begin
            if (i_en) begin
                toggle_ff <= ~toggle_ff;
            end
        end
    end

    synchronizer#(
       .NB(1)
    ) u_sync(
        .i_rstn     ( i_rst_out_n       ),
        .i_clk      ( i_clk_out         ),
        .i_async    ( toggle_ff         ),
        .o_sync     ( toggle_ff_sync_d1 )
    );

    always_ff @ (posedge i_clk_out, negedge i_rst_out_n) begin
        if (~i_rst_out_n) begin
            toggle_ff_sync_d2   <= 1'b0;
            o_en                <= 1'b0;
        end
        else begin
            toggle_ff_sync_d2   <= toggle_ff_sync_d1;
            o_en                <= toggle_ff_sync_d2 ^ toggle_ff_sync_d1;
        end
    end

    // SVA assertion to check for 1 clock wide pulses
    property one_cycle_pulse;
        @(posedge i_clk_in) disable iff (!i_rst_in_n)
            $rose(i_en) |=> !i_en;
    endproperty

    assert property (one_cycle_pulse)
        else $error("Input pulse is not exactly 1 clock wide. Synchronizer won't work correctly.");

endmodule
