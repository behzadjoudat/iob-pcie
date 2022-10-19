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
   
   
   
   reg [C_PCI_DATA_WIDTH-1:0] rData={C_PCI_DATA_WIDTH{1'b0}};
   reg [C_PCI_DATA_WIDTH-1:0] tData={C_PCI_DATA_WIDTH{1'b0}};
   reg [DATA_W-1:0] 		      rLen=0;
   reg [DATA_W-1:0] 		      rCount=0;
   reg [1:0] 		      rState=0;
   
   assign PCIE_CHNL_RX_CLK = PCIE_CLK;
   assign PCIE_CHNL_RX_ACK = (rState == 2'd1);
   assign PCIE_CHNL_RX_DATA_REN = (rState == 2'd1);
   
   assign PCIE_CHNL_TX_CLK = PCIE_CLK;
   assign PCIE_CHNL_TX = (rState == 2'd3);
   assign PCIE_CHNL_TX_LAST = 1'd1;
   assign PCIE_CHNL_TX_LEN = rLen; // in words
   assign PCIE_CHNL_TX_OFF = 0;
   assign PCIE_CHNL_TX_DATA = tData;
   assign PCIE_CHNL_TX_DATA_VALID = (rState == 2'd3);
   
   always @(posedge PCIE_CLK or posedge PCIE_RST) begin
      if (PCIE_RST) begin
	 rLen <=  0;
	 rCount <=  0;
	 rState <=  0;
	 rData <=  0;
      end
      else begin
	 case (rState)
	   
	   2'd0: begin // Wait for start of RX, save length
	      if (PCIE_CHNL_RX) begin
				rLen <= #1 PCIE_CHNL_RX_LEN;
		 rCount <=  0;
		 rState <=  2'd1;
	      end
	   end
	   
	   2'd1: begin // Wait for last data in RX, save value
	      if (PCIE_CHNL_RX_DATA_VALID) begin
		 rData <=  PCIE_CHNL_RX_DATA;
		 PCIE_RX_DATA_rdata <= rData;
		 rCount <=  rCount + (C_PCI_DATA_WIDTH/DATA_W);
	      end
	      if (rCount >= rLen)
		rState <=  2'd2;
	   end
	   
	   2'd2: begin // Prepare for TX
	      rCount <=  (C_PCI_DATA_WIDTH/DATA_W);
	      rState <=  2'd3;
	   end
	   
	   2'd3: begin // Start TX with save length and data value
	      if (PCIE_CHNL_TX_DATA_REN & PCIE_CHNL_TX_DATA_VALID) begin
		 tData <=  {rCount + 10, rCount + 9, rCount + 8, rCount + 7, rCount + 6, rCount + 5, rCount + 4, rCount + 3, rCount + 2, rCount + 1};
		 rCount <=  rCount + (C_PCI_DATA_WIDTH/32);
		 if (rCount >= rLen)
		   rState <=  2'd0;
	      end
		end
	   
	 endcase
      end
   end
      
endmodule
    
