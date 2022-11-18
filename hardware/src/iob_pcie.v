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

   assign PCIE_CHNL_TX_o = _TXCHNL;  

   assign PCIE_CHNL_TX_LAST_o = 1'd1;

   assign PCIE_CHNL_TX_LEN_o = _TXCHNL_LEN; //length in 64-bit words

   assign PCIE_CHNL_TX_OFF_o = 0;

   assign _RXCHNL_rdata = PCIE_CHNL_RX_i;

   wire ack;
   
   assign PCIE_CHNL_RX_ACK_o = ack ;
   
   wire ack_next = PCIE_CHNL_RX_DATA_VALID_i & !rx_full;

   iob_reg 
     #(
       .DATA_W(1)
       )
   ack_reg 
     (
      .clk        (PLD_CLK_i),
      .arst       (PLD_CLK_i),
      .rst        (1'd0),
      .en         (1'b1),
      .data_in    (ack_next),
      .data_out   (ack)
      );


   
   assign PCIE_CHNL_RX_DATA_REN_o = _RXCHNL_DATA_REN; //& ~rx_full;



   assign _RXCHNL_LEN_rdata = PCIE_CHNL_RX_LEN_i;
   assign _RXCHNL_DATA_VALID_rdata = PCIE_CHNL_RX_DATA_VALID_i ;
   assign _TXCHNL_DATA_REN_rdata= PCIE_CHNL_TX_DATA_REN_i;


   

//test loopback
/*
   assign _RXCHNL_DATA_rdata = PCIE_CHNL_RX_DATA_i;
   assign PCIE_CHNL_TX_DATA_o = _TXCHNL_DATA;
   assign _RXCHNL_DATA_rdata = PCIE_CHNL_RX_DATA_i;
*/
   
   `IOB_WIRE(tx_empty,1)
   `IOB_WIRE(tx_full,1)
   `IOB_WIRE(rx_empty,1)
   `IOB_WIRE(rx_full,1)
   

   //
   //SW ACCESSIBLE REGiSTERS
   //
   

 `IOB_WIRE(_TXCHNL_LEN, DATA_W)
   iob_reg 
     #(
       .DATA_W(32)
       )
   txchnl_len 
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (_TXCHNL_LEN_en),
      .data_in    (_TXCHNL_LEN_wdata),
      .data_out   (_TXCHNL_LEN)
      );


   
   `IOB_WIRE(_RXCHNL_DATA_REN, 1)
   iob_reg 
     #(
       .DATA_W(1)
       )
   rxchnl_data_ren
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (_RXCHNL_DATA_REN_en),
      .data_in    (_RXCHNL_DATA_REN_wdata[0]),
      .data_out   (_RXCHNL_DATA_REN)
      );
      
   `IOB_WIRE(_TXCHNL_DATA_VALID, 1)
   iob_reg 
     #(
       .DATA_W(1)
       )
   txchnl_data_valid
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (_TXCHNL_DATA_VALID_en),
      .data_in    (_TXCHNL_DATA_VALID_wdata[0]),
      .data_out   (_TXCHNL_DATA_VALID)
      );
   
   `IOB_WIRE(_TXCHNL, 1)
   iob_reg 
     #(
       .DATA_W(1)
       )
   txchnl 
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (_TXCHNL_en),
      .data_in    (_TXCHNL_wdata[0]),
      .data_out   (_TXCHNL)
      );
   
   `IOB_WIRE(_RXCHNL_ACK, 1)
   iob_reg 
     #(
       .DATA_W(1)
       )
   rxchnl_ack
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'd0),
      .en         (_RXCHNL_ACK_en),
      .data_in    (_RXCHNL_ACK_wdata[0]),
      .data_out   (_RXCHNL_ACK)
      );

   
   wire rx_wr = PCIE_CHNL_RX_i & PCIE_CHNL_RX_DATA_VALID_i ;
   
   
   wire rx_ren = valid && !rx_empty && !wstrb;

   
   iob_fifo_async
     #(
       .R_DATA_W(DATA_W),
       .W_DATA_W(C_PCI_DATA_WIDTH),
       .ADDR_W(5)
       )
   rxfifo
     (
      .rst     (rst),
      
      // write port riffa side
      .w_clk   (PLD_CLK_i),
      .w_empty (),
      .w_full  (rx_full),
      .w_data  (PCIE_CHNL_RX_DATA_i),
      .w_en    (rx_wr),
      .w_level (),
      
      // read port cpu side
      .r_clk   (clk),
      .r_full  (),
      .r_empty (rx_empty),
      .r_data  (_RXCHNL_DATA_rdata),
      .r_en    (rx_ren),
      .r_level ()
      );

   
  

   wire tx_wr = valid & ~tx_full & |wstrb ; 
 

   wire tx_ren = ~tx_empty && PCIE_CHNL_TX_DATA_REN_i ;
 
   iob_reg 
     #(
       .DATA_W(1)
       )
   read_riffa
     (
      .clk        (PLD_CLK_i),
      .arst       (PLD_RST_i),
      .rst        (1'd0),
      .en         (1'd1),
      .data_in    (tx_ren),
      .data_out   (PCIE_CHNL_TX_DATA_VALID_o)
      );

	
   iob_fifo_async
     #(
       .R_DATA_W(C_PCI_DATA_WIDTH),
       .W_DATA_W(DATA_W),
       .ADDR_W(5)
       )
   txfifo
     (
      .rst     (rst),
      
      // write port cpu side
      .w_clk   (clk),
      .w_empty (),
      .w_full  (tx_full),
      .w_data  (wdata),
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
