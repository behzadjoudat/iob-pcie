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
    `IOB_INPUT(PLD_CLK_i,1),
    `IOB_INPUT(PLD_RST_i,1),
    `IOB_INPUT(PCIE_CHNL_RX_i, 1),// goes high to signal incoming data. will remain high until all incoming data is written
    `IOB_INPUT(PCIE_CHNL_RX_LAST_i, 1), //high indicates this is the last recive transaction in a sequence
    `IOB_INPUT(PCIE_CHNL_RX_LEN_i, DATA_W),//length of receive transaction in 4 byte words
    `IOB_INPUT(PCIE_CHNL_RX_OFF_i, DATA_W-1),//offset in 4 byte words indicating where to start storing received data if applicable in design
    `IOB_INPUT(PCIE_CHNL_RX_DATA_i, 64),//receive data
    `IOB_INPUT(PCIE_CHNL_RX_DATA_VALID_i, 1),// high if the data on chnl_rx_data is valid
    `IOB_OUTPUT(PCIE_CHNL_RX_DATA_REN_o, 1),//when high and chnl_rx_data_valid is high, consumes the data currently available on chnl_rx_data
    `IOB_OUTPUT(PCIE_CHNL_RX_ACK_o, 1),//must be pulsed for at least 1 cycle to acknowledge the incoming data transaction

    `IOB_OUTPUT(PCIE_CHNL_TX_o, 1),// set high to signal a transaction. keep high until all out going data is written to the fifo
    `IOB_OUTPUT(PCIE_CHNL_TX_LAST_o, 1),// high indicates this is the last send transaction in the sequence.
    `IOB_OUTPUT(PCIE_CHNL_TX_LEN_o, DATA_W),// length of send transaction in 4 byte words
    `IOB_OUTPUT(PCIE_CHNL_TX_OFF_o, DATA_W-1),//offset in 4 byte words indicating where to start storing sent data in the pc threads receive buffer
    `IOB_OUTPUT(PCIE_CHNL_TX_DATA_o, 64),//send data
    `IOB_OUTPUT(PCIE_CHNL_TX_DATA_VALID_o, 1),//set high when data on chnl_tx_data is valid , update when chnl_tx_data is consumed.
    `IOB_INPUT(PCIE_CHNL_TX_DATA_REN_i, 1),// when high and chnl_tx_valid is high, consumes the data currently available on chnl_tx_data
    `IOB_INPUT(PCIE_CHNL_TX_ACK_i, 1),// will be pulsed high for at least 1 cycle to acknowledge the data transaction

`include "iob_gen_if.vh"
    );


`include "iob_pcie_swreg_gen.vh"

   //outputs

   assign PCIE_CHNL_TX_o = TX_DATA_VALID;


      
   assign PCIE_CHNL_TX_LAST_o = 1'd1;
   assign PCIE_CHNL_TX_LEN_o = TX_LEN; //length in 64-bit words
   assign PCIE_CHNL_TX_OFF_o = 31'd0;
   assign RX_LEN_VALID_rdata = PCIE_CHNL_RX_i;


   assign PCIE_CHNL_RX_ACK_o = RX_LEN_ACK;
   assign PCIE_CHNL_RX_DATA_REN_o = RX_LEN_ACK & ~rx_full;
   
   assign RX_LEN_rdata = PCIE_CHNL_RX_LEN_i;
   
   assign RX_DATA_VALID_rdata = PCIE_CHNL_RX_DATA_VALID_i & PCIE_CHNL_TX_DATA_REN_i ;
   

   assign TX_REN_VALID_rdata= PCIE_CHNL_TX_DATA_REN_i;

   
     
   

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
       .DATA_W(1)
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
       .DATA_W(1)
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

   
   wire rx_wr = PCIE_CHNL_RX_i & PCIE_CHNL_RX_DATA_VALID_i & ~rx_full;
   
   
   wire rx_ren = PCIE_CHNL_RX_i & PCIE_CHNL_RX_DATA_VALID_i & ~|wstrb & ~rx_empty;
   //ready = rx_en_reg;
   
   iob_fifo_async
     #(
       .R_DATA_W(DATA_W),
       .W_DATA_W(C_PCI_DATA_WIDTH),
       .ADDR_W(5)
       )
   rxfifo
     (
      .rst     (PLD_RST_i),

      // write port
      .w_clk   (PLD_CLK_i),
      .w_empty (),
      .w_full  (rx_full),
      .w_data  (PCIE_CHNL_RX_DATA_i),
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


  
   wire  tx_ren = PCIE_CHNL_TX_DATA_REN_i & ~tx_empty & PCIE_CHNL_TX_DATA_VALID_o;
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
      .r_clk   (PLD_CLK_i),
      .r_full  (),
      .r_empty (tx_empty),
      .r_data  (PCIE_CHNL_TX_DATA_o),
      .r_en    (tx_ren),
      .r_level ()
      );
   

endmodule // iob_pcie
