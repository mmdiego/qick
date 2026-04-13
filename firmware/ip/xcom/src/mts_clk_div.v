module mts_clk_div (
   input  wire         mmcm1_pl_clk,
   input  wire         mmcm1_rstn,
   input  wire         mmcm1_sysref,
   output wire         mmcm1_pl_clk_div,
   output wire         mmcm1_sysref_dly_r
);


   reg  mmcm1_sysref_iob;
   reg  mmcm1_sysref_d1;
   reg  mmcm1_sysref_d2;
   reg  mmcm1_sysref_en;
   reg  mmcm1_sysref_redge_en;
   wire mmcm1_sysref_redge;

// (* IOB = "TRUE" *)   reg  mmcm1_sysref_iob;

   // always @(posedge mmcm1_pl_clk) begin
   //    mmcm1_sysref_iob <= mmcm1_sysref; 
   // end

   always @(posedge mmcm1_pl_clk or negedge mmcm1_rstn) begin
      if (~mmcm1_rstn) begin
         mmcm1_sysref_iob <= 1'b0;
         mmcm1_sysref_en <= 1'b0;
         mmcm1_sysref_d1 <= 1'b0;
         mmcm1_sysref_d2 <= 1'b0;
         mmcm1_sysref_redge_en <= 1'b0;
      end else begin
         mmcm1_sysref_iob <= mmcm1_sysref;
         mmcm1_sysref_d1 <= mmcm1_sysref_iob;
         mmcm1_sysref_d2 <= mmcm1_sysref_d1;
         if (mmcm1_sysref_redge) begin
            mmcm1_sysref_redge_en <= 1'b1;
         end
         if (mmcm1_sysref_redge_en & mmcm1_sysref_redge) begin
            mmcm1_sysref_en <= 1'b1;
         end
      end
   end
   assign mmcm1_sysref_redge = mmcm1_sysref_d1 & ~mmcm1_sysref_d2;

   assign mmcm1_sysref_dly_r = mmcm1_sysref_d2;

   // BUFGCE_DIV: General Clock Buffer with Divide Function
   //             Virtex UltraScale+
   // Xilinx HDL Language Template, version 2023.1

   BUFGCE_DIV #(
      .BUFGCE_DIVIDE(2),              // 1-8
      // Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
      .IS_CE_INVERTED(1'b0),          // Optional inversion for CE
      .IS_CLR_INVERTED(1'b0),         // Optional inversion for CLR
      .IS_I_INVERTED(1'b0),           // Optional inversion for I
      .SIM_DEVICE("ULTRASCALE_PLUS")  // ULTRASCALE, ULTRASCALE_PLUS
   )
   BUFGCE_DIV_mmcm1 (
      .O(mmcm1_pl_clk_div),   // 1-bit output: Buffer
      .CE(mmcm1_sysref_en),   // 1-bit input: Buffer enable
      .CLR(~mmcm1_rstn),      // 1-bit input: Asynchronous clear
      .I(mmcm1_pl_clk)        // 1-bit input: Buffer
   );

endmodule
