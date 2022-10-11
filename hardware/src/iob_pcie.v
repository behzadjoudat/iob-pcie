`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_pcie_swreg_def.vh"

module iob_pcie
  # (
     parameter DATA_W = 32,
     parameter ADDR_W = `iob_pcie_swreg_ADDR_W
     )
   (

    // CPU interface
`include "iob_s_if.vh"

    // External interface
    `IOB_INPUT(PCIE_CLK, 1),
    `IOB_INPUT(PCIE_RST, 1),
    `IOB_INPUT(PCIE_CHNL_RX, 1),
    `IOB_OUTPUT(PCIE_CHNL_RX_CLK, 1),
    `IOB_OUTPUT(PCIE_CHNL_RX_ACK, 1),
    `IOB_INPUT(PCIE_CHNL_RX_LAST, 1),
    `IOB_INPUT(PCIE_CHNL_RX_LEN, 32),
    `IOB_INPUT(PCIE_CHNL_RX_OFF, 31),
    `IOB_INPUT(PCIE_CHNL_RX_DATA, 32),
    `IOB_INPUT(PCIE_CHNL_RX_DATA_VALID, 1),
    `IOB_OUTPUT(PCIE_CHNL_RX_DATA_REN, 1),
    `IOB_OUTPUT(PCIE_CHNL_TX_CLK, 1),
    `IOB_OUTPUT(PCIE_CHNL_TX, 1),
    `IOB_INPUT(PCIE_CHNL_TX_ACK, 1),
    `IOB_OUTPUT(PCIE_CHNL_TX_LAST, 1),
    `IOB_OUTPUT(PCIE_CHNL_TX_LEN, 32),
    `IOB_OUTPUT(PCIE_CHNL_TX_OFF, 31),
    `IOB_OUTPUT(PCIE_CHNL_TX_DATA, 32),
    `IOB_OUTPUT(PCIE_CHNL_TX_DATA_VALID, 1),
    `IOB_INPUT(PCIE_CHNL_TX_DATA_REN, 1),


`include "iob_gen_if.vh"
    );

`include "iob_pcie_swreg_gen.vh"


   `IOB_WIRE(PCIE_DATA_IN, 32)
   iob_reg #(.DATA_W(32))
   pcie_data_in (
		  .clk        (clk),
		  .arst       (rst),
		  .rst        (rst),
		  .en         (PCIE_DATA_IN_en),
		  .data_in    (PCIE_DATA_IN_wdata),
		  .data_out   (PCIE_DATA_IN)
		  );



iob_pcie_core iob_pcie_core0
  (
   .clk(clk),
   .rst(rst),
   .CLK(PCIE_CLK),
   .RST(PCIE_RST),
   .CHNL_RX_CLK(PCIE_CHNL_RX_CLK),
   .CHNL_RX(PCIE_CHNL_RX),
   .CHNL_RX_ACK(PCIE_CHNL_RX_ACK),
   .CHNL_RX_LAST(PCIE_CHNL_RX_LAST),
   .CHNL_RX_LEN(PCIE_CHNL_RX_LEN),
   .CHNL_RX_OFF(PCIE_CHNL_RX_OFF),
   .CHNL_RX_DATA(PCIE_CHNL_RX_DATA),
   .CHNL_RX_DATA_VALID(PCIE_CHNL_RX_DATA_VALID),
   .CHNL_RX_DATA_REN(PCIE_CHNL_RX_DATA_REN),
   .CHNL_TX_CLK(PCIE_CHNL_TX_CLK),
   .CHNL_TX(PCIE_CHNL_TX),
   .CHNL_TX_ACK(PCIE_CHNL_TX_ACK),
   .CHNL_TX_LAST(PCIE_CHNL_TX_LAST),
   .CHNL_TX_LEN(PCIE_CHNL_TX_LEN),
   .CHNL_TX_OFF(PCIE_CHNL_TX_OFF),
   .CHNL_TX_DATA(PCIE_CHNL_TX_DATA),
   .CHNL_TX_DATA_VALID(PCIE_CHNL_TX_DATA_VALID),
   .CHNL_TX_DATA_REN(PCIE_CHNL_TX_DATA_REN),
   .CORE_SETTER(PCIE_DATA_IN),
   .CORE_GETTER(PCIE_DATA_OUT_rdata)

 );

endmodule
    
