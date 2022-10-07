//----------------------------------------------------------------------------
// Filename:			iob_pcie_core.v
// Version:				1.00.a
// Verilog Standard:	Verilog-2001

`timescale 1ns/1ns
module iob_pcie_core #(
                    parameter C_PCI_DATA_WIDTH = 9'd32
                    )
   (
    input 			  clk,
    input 			  rst,
    input [31:0] 		  CORE_SETTER,
    output wire [31:0] 		  CORE_GETTER,
    input 			  CLK,
    input 			  RST,
    output 			  CHNL_RX_CLK,
    input 			  CHNL_RX,
    output 			  CHNL_RX_ACK,
    input 			  CHNL_RX_LAST,
    input [31:0] 		  CHNL_RX_LEN,
    input [30:0] 		  CHNL_RX_OFF,
    input [C_PCI_DATA_WIDTH-1:0]  CHNL_RX_DATA,
    input 			  CHNL_RX_DATA_VALID,
    output 			  CHNL_RX_DATA_REN,
    output 			  CHNL_TX_CLK,
    output 			  CHNL_TX,
    input 			  CHNL_TX_ACK,
    output 			  CHNL_TX_LAST,
    output [31:0] 		  CHNL_TX_LEN,
    output [30:0] 		  CHNL_TX_OFF,
    output [C_PCI_DATA_WIDTH-1:0] CHNL_TX_DATA,
    output 			  CHNL_TX_DATA_VALID,
    input 			  CHNL_TX_DATA_REN
    );
   
reg [C_PCI_DATA_WIDTH-1:0] rData={C_PCI_DATA_WIDTH{1'b0}};
reg [31:0] 		      rLen=0;
reg [31:0] rCount=0;
reg [1:0] rState=0;

assign CHNL_RX_CLK = CLK;
assign CHNL_RX_ACK = (rState == 2'd1);
assign CHNL_RX_DATA_REN = (rState == 2'd1);

assign CHNL_TX_CLK = CLK;
assign CHNL_TX = (rState == 2'd3);
assign CHNL_TX_LAST = 1'd1;
assign CHNL_TX_LEN = rLen; // in words
assign CHNL_TX_OFF = 0;
assign CHNL_TX_DATA = rData;
assign CHNL_TX_DATA_VALID = (rState == 2'd3);

always @(posedge CLK or posedge RST) begin
	if (RST) begin
		rLen <= #1 0;
		rCount <= #1 0;
		rState <= #1 0;
		rData <= #1 0;
	end
	else begin
		case (rState)
		
		2'd0: begin // Wait for start of RX, save length
			if (CHNL_RX) begin
				rLen <= #1 CHNL_RX_LEN;
				rCount <= #1 0;
				rState <= #1 2'd1;
			end
		end
		
		2'd1: begin // Wait for last data in RX, save value
			if (CHNL_RX_DATA_VALID) begin
				rData <= #1 CHNL_RX_DATA;
				rCount <= #1 rCount + (C_PCI_DATA_WIDTH/32);
			end
			if (rCount >= rLen)
				rState <= #1 2'd2;
		end

		2'd2: begin // Prepare for TX
			rCount <= #1 (C_PCI_DATA_WIDTH/32);
			rState <= #1 2'd3;
		end

		2'd3: begin // Start TX with save length and data value
			if (CHNL_TX_DATA_REN & CHNL_TX_DATA_VALID) begin
				rData <= #1 {rCount + "10", rCount + "9", rCount + "8", rCount + "7", rCount + "6", rCount + "5", rCount + "4", rCount + "3", rCount + "2", rCount + "1"};
				rCount <= #1 rCount + (C_PCI_DATA_WIDTH/32);
				if (rCount >= rLen)
					rState <= #1 2'd0;
			end
		end
		
		endcase
	end
end

/*
wire [35:0] wControl0;
chipscope_icon_1 cs_icon(
	.CONTROL0(wControl0)
);

chipscope_ila_t8_512 a0(
	.CLK(CLK), 
	.CONTROL(wControl0), 
	.TRIG0({3'd0, (rCount >= 800), CHNL_RX, CHNL_RX_DATA_VALID, rState}),
	.DATA({442'd0,
			CHNL_TX_DATA_REN, // 1
			CHNL_TX_ACK, // 1
			CHNL_RX_DATA, // 64
			CHNL_RX_DATA_VALID, // 1
			CHNL_RX, // 1
			rState}) // 2
);
*/

endmodule
