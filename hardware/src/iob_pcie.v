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
    `IOB_INPUT(PCIE_CLK, 1),
    `IOB_INPUT(PCIE_RST, 1),
    `IOB_INPUT(PCIE_CHNL_RX, 1),
    `IOB_OUTPUT(PCIE_CHNL_RX_CLK, 1),
    `IOB_OUTPUT(PCIE_CHNL_RX_ACK, 1),
    `IOB_INPUT(PCIE_CHNL_RX_LAST, 1),
    `IOB_INPUT(PCIE_CHNL_RX_LEN, DATA_W),
    `IOB_INPUT(PCIE_CHNL_RX_OFF, DATA_W-1),
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
   
   
   `IOB_WIRE(PCIE_TX_DATA, DATA_W)
   iob_reg #(.DATA_W(32))
   pcie_tx_data (
		 .clk        (clk),
		 .arst       (rst),
		 .rst        (rst),
		 .en         (PCIE_TX_DATA_en),
		 .data_in    (PCIE_TX_DATA_wdata),
		 .data_out   (PCIE_TX_DATA)
		 );
   
   
   /*
   
   //reg [1:0] 		      rState,rState_nxt;
   assign PCIE_CHNL_RX_CLK = PCIE_CLK;
   assign PCIE_CHNL_RX_ACK = (rState == RX_DEFAULT);
   assign PCIE_CHNL_RX_DATA_REN = (rState == RX_DEFAULT);
   
   assign PCIE_CHNL_TX_CLK = PCIE_CLK;
   assign PCIE_CHNL_TX = (rState == TX_FULL);
   assign PCIE_CHNL_TX_LAST = 1'd1;
   assign PCIE_CHNL_TX_LEN = rLen; // in words
   assign PCIE_CHNL_TX_OFF = 0;
   assign PCIE_CHNL_TX_DATA = tData;
   assign PCIE_CHNL_TX_DATA_VALID = (rState == TX_FULL);

   assign PCIE_RX_DATA1_rdata = PCIE_CHNL_RX_LEN;

    localparam WAIT=0, RX_DEFAULT=1,TX_EN=2, TX_FULL=3;

   `IOB_VAR(rState_nxt, 2)   
   iob_reg
     #(
       .DATA_W(2),
       .RST_VAL(0)
       )
   pcie_trigger_reg
     (
      .clk  (PCIE_CLK),
      .arst (PCIE_RST),
      .rst  (1'b0),
      .en   (1'b1),
      .data_in (rState_nxt),
      .data_out (rState)
      );
   
   `IOB_VAR(rData_nxt, C_PCI_DATA_WIDTH)
   iob_reg
     #(
       .DATA_W(C_PCI_DATA_WIDTH),
       .RST_VAL(0)
       )
   pcie_rdata_reg
     (
      .clk  (PCIE_CLK),
      .arst (PCIE_RST),
      .rst  (1'b0),
      .en   (1'b1),
      .data_in (rData_nxt),
      .data_out (rData)
      );

   `IOB_VAR(tData_nxt, C_PCI_DATA_WIDTH)
   iob_reg
     #(
       .DATA_W(C_PCI_DATA_WIDTH),
       .RST_VAL(0)
       )
   pcie_tdata_reg
     (
      .clk  (PCIE_CLK),
      .arst (PCIE_RST),
      .rst  (1'b0),
      .en   (1'b1),
      .data_in (tData_nxt),
      .data_out (tData)
      );

   `IOB_VAR(rLen_nxt, DATA_W)
   iob_reg
     #(
       .DATA_W(DATA_W),
       .RST_VAL(0)
       )
   pcie_rlen_reg
     (
      .clk  (PCIE_CLK),
      .arst (PCIE_RST),
      .rst  (1'b0),
      .en   (1'b1),
      .data_in (rLen_nxt),
      .data_out (rLen)
      );

   `IOB_VAR(rCount_nxt, DATA_W)
   iob_reg
     #(
       .DATA_W(DATA_W),
       .RST_VAL(0)
       )
   pcie_rcount_reg
     (
      .clk  (PCIE_CLK),
      .arst (PCIE_RST),
      .rst  (1'b0),
      .en   (1'b1),
      .data_in (rCount_nxt),
      .data_out (rCount)
      );

   `IOB_WIRE(the_result, DATA_W)
   `IOB_VAR(the_result_nxt, DATA_W)
   iob_reg
     #(
       .DATA_W(DATA_W),
       .RST_VAL(0)
       )
   pcie_theresult_reg
     (
      .clk  (PCIE_CLK),
      .arst (PCIE_RST),
      .rst  (1'b0),
      .en   (1'b1),
      .data_in (the_result_nxt),
      .data_out (the_result)
      );
   
   `IOB_COMB begin
      if (PCIE_RST) begin
	 rLen_nxt =  0;
	 rCount_nxt =  0;
	 rData_nxt =  0;
      end
      case (rState)
	
	WAIT: begin // Wait for start of RX, save length
	   if (PCIE_CHNL_RX) begin
	      rLen_nxt =  PCIE_CHNL_RX_LEN;
	      rCount_nxt =  0;
	      rState_nxt =  RX_DEFAULT;
	      end
	end
	
	RX_DEFAULT: begin // Wait for last data in RX, save value
	   if (PCIE_CHNL_RX_DATA_VALID) begin
	      rData_nxt =  PCIE_CHNL_RX_DATA;
	      PCIE_RX_DATA_rdata = PCIE_CHNL_RX_DATA;
	      rCount_nxt =  rCount + (C_PCI_DATA_WIDTH/DATA_W);
	   end
	   if (rCount >= rLen)
	     rState_nxt =  TX_EN;
	end
	
	TX_EN: begin // Prepare for TX
	   rCount_nxt =  (C_PCI_DATA_WIDTH/DATA_W);
	   rState_nxt =  TX_FULL;
	   the_result_nxt = PCIE_TX_DATA;
	   rLen_nxt = PCIE_TX_DATA;
	end
	
	TX_FULL: begin // Start TX with save length and data value
	   if (PCIE_CHNL_TX_DATA_REN & PCIE_CHNL_TX_DATA_VALID) begin
	      tData_nxt =  {the_result - 1 , the_result } ;
	      the_result_nxt = the_result-2;
	      rCount_nxt =  rCount + (C_PCI_DATA_WIDTH/DATA_W);
	      if (rCount >= rLen)
		rState_nxt =  WAIT;
	   end
	end
      endcase // case (rState)
   end // UNMATCHED !!



      
  */    
endmodule // iob_pcie
