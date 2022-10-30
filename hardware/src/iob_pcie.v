`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_pcie_swreg_def.vh"

module iob_pcie
  # (
     parameter DATA_W = 32,
     parameter ADDR_W = `iob_pcie_swreg_ADDR_W,
     parameter C_PCI_DATA_WIDTH = 64
     )
   (

    // CPU interface
`include "iob_s_if.vh"

    // External interface
    `IOB_INPUT(PCIE_CHNL_RX, 1),
    `IOB_OUTPUT(PCIE_CHNL_RX_CLK, 1),
    `IOB_OUTPUT(PCIE_CHNL_RX_ACK, 1),
    `IOB_INPUT(PCIE_CHNL_RX_LAST, 1), //not currently being used
    `IOB_INPUT(PCIE_CHNL_RX_LEN, DATA_W),
    `IOB_INPUT(PCIE_CHNL_RX_OFF, DATA_W-1),//not currently being used
    `IOB_INPUT(PCIE_CHNL_RX_DATA, 64),
    `IOB_INPUT(PCIE_CHNL_RX_DATA_VALID, 1),
    `IOB_OUTPUT(PCIE_CHNL_RX_DATA_REN, 1),
    `IOB_OUTPUT(PCIE_CHNL_TX_CLK, 1),
    `IOB_OUTPUT(PCIE_CHNL_TX, 1),
    `IOB_INPUT(PCIE_CHNL_TX_ACK, 1),
    `IOB_OUTPUT(PCIE_CHNL_TX_LAST, 1),
    `IOB_OUTPUT(PCIE_CHNL_TX_LEN, DATA_W),
    `IOB_OUTPUT(PCIE_CHNL_TX_OFF, DATA_W-1),
    `IOB_OUTPUT(PCIE_CHNL_TX_DATA, 64),
    `IOB_OUTPUT(PCIE_CHNL_TX_DATA_VALID, 1),
    `IOB_INPUT(PCIE_CHNL_TX_DATA_REN, 1),


`include "iob_gen_if.vh"
    );


`include "iob_pcie_swreg_gen.vh"

   //outputs
   assign PCIE_CHNL_RX_CLK = clk;
   assign PCIE_CHNL_TX_CLK = clk;

   assign PCIE_CHNL_TX = TX_DATA_VALID;

   //`IOB_POSEDGE_DETECT(clk,rst,TX_DATA_VALID,TX_DATA_VALID_REG,PCIE_CHNL_TX_DATA_VALID_int)
   //assign PCIE_CHNL_TX_DATA_VALID = PCIE_CHNL_TX_DATA_VALID_int;
   //assign PCIE_CHNL_TX_DATA_VALID = TX_DATA_VALID;


   iob_edge_detect edge_detect_0
     (
      .clk(clk),
      .rst(rst),
      .bit_in(TX_DATA_VALID),
      .detected(PCIE_CHNL_TX_DATA_VALID)
      );
      
   assign PCIE_CHNL_TX_LAST = 1'd1;
   assign PCIE_CHNL_TX_LEN = TX_LEN; //length in 64-bit words
   assign PCIE_CHNL_TX_OFF = 31'd0;
   assign PCIE_CHNL_TX_DATA = {TX_DATAH, TX_DATAL};
   assign RX_LEN_VALID_rdata = PCIE_CHNL_RX;


   assign PCIE_CHNL_RX_ACK = RX_LEN_ACK;
   assign PCIE_CHNL_RX_DATA_REN = RX_LEN_ACK;
   
   assign RX_LEN_rdata = PCIE_CHNL_RX_LEN;

   assign RX_DATAH = PCIE_CHNL_RX_DATA;
   assign RX_DATAL = PCIE_CHNL_RX_DATA;
   
   assign RX_DATA_VALID_rdata = PCIE_CHNL_RX_DATA_VALID & PCIE_CHNL_TX_DATA_REN ;
   

   assign TX_REN_VALID_rdata= PCIE_CHNL_TX_DATA_REN;

   
     
   

   //
   //SW ACCESSIBLE REGiSTERS
   //
   
   `IOB_WIRE(TX_DATAH, DATA_W)
   iob_reg 
     #(
       .DATA_W(32)
       )
   tx_datah 
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (TX_DATAH_en),
      .data_in    (TX_DATAH_wdata),
      .data_out   (TX_DATAH)
      );

   `IOB_WIRE(TX_DATAL, DATA_W)
   iob_reg 
     #(
       .DATA_W(32)
       )
   tx_datal 
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (TX_DATAL_en),
      .data_in    (TX_DATAL_wdata),
      .data_out   (TX_DATAL)
      );
  
 `IOB_WIRE(TX_LEN, DATA_W)
   iob_reg 
     #(
       .DATA_W(32)
       )
   tx_len 
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (TX_LEN_en),
      .data_in    (TX_LEN_wdata),
      .data_out   (TX_LEN)
      );
   
   `IOB_WIRE(TX_DATA_VALID, 1)
   iob_reg 
     #(
       .DATA_W(1)
       )
   tx_data_valid
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (TX_DATA_VALID_en),
      .data_in    (TX_DATA_VALID_wdata),
      .data_out   (TX_DATA_VALID)
      );
   
   `IOB_WIRE(TX_CHNL, 1)
   iob_reg 
     #(
       .DATA_W(32)
       )
   tx_chnl 
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (TX_CHNL_en),
      .data_in    (TX_CHNL_wdata),
      .data_out   (TX_CHNL)
      );
   
   `IOB_WIRE(RX_LEN_ACK, 1)
   iob_reg 
     #(
       .DATA_W(32)
       )
   rx_len_ack
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (RX_LEN_ACK_en),
      .data_in    (RX_LEN_ACK_wdata),
      .data_out   (RX_LEN_ACK)
      );














endmodule // iob_pcie
