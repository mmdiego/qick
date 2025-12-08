///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
//
// Fermi Fordward Alliance LLC
//
// Module: toggle_synchronizer.sv
// Project: UTILS
//
///////////////////////////////////////////////////////////////////////////////
module toggle_synchronizer(
    input logic  i_rstn   ,
    input logic  i_clk_in ,
    input logic  i_clk_out,
    input logic  i_en     ,
    output logic o_en 
);

    logic toggle_ff;
    logic toggle_ff_sync_d1;
    logic toggle_ff_sync_d2;

    always_ff @ (posedge i_clk_in, negedge i_rstn) begin
        if (~i_rstn) begin
            toggle_ff <= 1'b0;
        end
        if (i_en) begin
            toggle_ff <= ~toggle_ff;
        end
    end

    synchronizer#(
       .NB(1)
    ) u_sync(
        .i_rstn     ( i_rstn            ),
        .i_clk      ( i_clk_out         ),
        .i_async    ( toggle_ff         ),
        .o_sync     ( toggle_ff_sync_d1 )
    );

    always_ff @ (posedge i_clk_out, negedge i_rstn) begin
        if (~i_rstn) begin
            toggle_ff_sync_d2   <= 1'b0;
            o_en                <= 1'b0;
        end
        else begin
            toggle_ff_sync_d2   <= toggle_ff_sync_d1;
            o_en                <= toggle_ff_sync_d2 ^ toggle_ff_sync_d1;
        end
    end

endmodule
