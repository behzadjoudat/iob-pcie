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
    `IOB_INPUT(PLD_CLK,1),
    `IOB_INPUT(PLD_RST,1),
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
   assign PCIE_CHNL_RX_CLK = PLD_CLK;
   assign PCIE_CHNL_TX_CLK = PLD_CLK;

   assign PCIE_CHNL_TX = TX_DATA_VALID;


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
   assign RX_LEN_VALID_rdata = PCIE_CHNL_RX;


   assign PCIE_CHNL_RX_ACK = RX_LEN_ACK;
   assign PCIE_CHNL_RX_DATA_REN = RX_LEN_ACK & ~rx_full;
   
   assign RX_LEN_rdata = PCIE_CHNL_RX_LEN;
   
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

   
   wire rx_wr = PCIE_CHNL_RX & PCIE_CHNL_RX_DATA_VALID & ~rx_full;
   
   
   wire rx_ren = PCIE_CHNL_RX & PCIE_CHNL_RX_DATA_VALID & ~|wstrb & ~rx_empty;
   //ready = rx_en_reg;
   
   iob_fifo_async
     #(
       .R_DATA_W(DATA_W),
       .W_DATA_W(C_PCI_DATA_WIDTH),
       .ADDR_W(5)
       )
   rxfifo
     (
      .rst     (PLD_RST),

      // write port
      .w_clk   (PLD_CLK),
      .w_empty (),
      .w_full  (rx_full),
      .w_data  (PCIE_CHNL_RX_DATA),
      .w_en    (rx_wr),
      .w_level (),

      // read port
      .r_clk   (clk),
      .r_empty (rx_empty),
      .r_full  (),
      .r_data  (RX_DATAH_rdata),
      .r_en    (rx_ren),
      .r_level ()
      );


  
   wire  tx_ren = PCIE_CHNL_TX_DATA_REN & ~tx_empty & PCIE_CHNL_TX_DATA_VALID;
   wire  tx_wr = ~tx_full & |wstrb ; //MAYBE I NEED TO ADD ANOTHER SIGNAL TO THIS LINE 
 
//   PCIE_CHNL_TX_DATA_VALID = tx_ren_reg;

   iob_fifo_async
     #(
       .R_DATA_W(C_PCI_DATA_WIDTH),
       .W_DATA_W(DATA_W),
       .ADDR_W(5)
       )
   txfifo
     (
      .rst     (rst),
      
      // write port
      .w_clk   (clk),
      .w_empty (),
      .w_full  (tx_full),
      .w_data  (TX_DATAH),
      .w_en    (tx_wr),
      .w_level (),
      
      // read port
      .r_clk   (PLD_CLK),
      .r_full  (),
      .r_empty (tx_empty),
      .r_data  (PCIE_CHNL_TX_DATA),
      .r_en    (tx_ren),
      .r_level ()
      );
   

endmodule // iob_pcie
