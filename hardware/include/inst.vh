   //
   // /iob_pcie0/
   //

   iob_pcie iob_pcie0
     (
      .clk     (clk),
      .rst     (rst),
      .PLD_CLK_i(PLD_CLK_IF),
      .PLD_RST_i(PLD_RST_IF),
      .PCIE_CHNL_RX_i(PCIE_CHNL_RX_IF),
      .PCIE_CHNL_RX_CLK_o(PCIE_CHNL_RX_CLK_IF),
      .PCIE_CHNL_RX_ACK_o(PCIE_CHNL_RX_ACK_IF),
      .PCIE_CHNL_RX_LAST_i(PCIE_CHNL_RX_LAST_IF),
      .PCIE_CHNL_RX_LEN_i(PCIE_CHNL_RX_LEN_IF),
      .PCIE_CHNL_RX_OFF_i(PCIE_CHNL_RX_OFF_IF),
      .PCIE_CHNL_RX_DATA_i(PCIE_CHNL_RX_DATA_IF),
      .PCIE_CHNL_RX_DATA_VALID_i(PCIE_CHNL_RX_DATA_VALID_IF),
      .PCIE_CHNL_RX_DATA_REN_o(PCIE_CHNL_RX_DATA_REN_IF),
      .PCIE_CHNL_TX_CLK_o(PCIE_CHNL_TX_CLK_IF),
      .PCIE_CHNL_TX_o(PCIE_CHNL_TX_IF),
      .PCIE_CHNL_TX_ACK_i(PCIE_CHNL_TX_ACK_IF),
      .PCIE_CHNL_TX_LAST_o(PCIE_CHNL_TX_LAST_IF),
      .PCIE_CHNL_TX_LEN_o(PCIE_CHNL_TX_LEN_IF),
      .PCIE_CHNL_TX_OFF_o(PCIE_CHNL_TX_OFF_IF),
      .PCIE_CHNL_TX_DATA_o(PCIE_CHNL_TX_DATA_IF),
      .PCIE_CHNL_TX_DATA_VALID_o(PCIE_CHNL_TX_DATA_VALID_IF),
      .PCIE_CHNL_TX_DATA_REN_i(PCIE_CHNL_TX_DATA_REN_IF),

     // CPU interface
      .valid       (slaves_req[`valid(`PCIE)]),
      .address     (slaves_req[`address(`PCIE,`iob_pcie_swreg_ADDR_W+2)-2]),
      .wdata       (slaves_req[`wdata(`PCIE)]),
      .wstrb       (slaves_req[`wstrb(`PCIE)]),
      .rdata       (slaves_resp[`rdata(`PCIE)]),
      .ready       (slaves_resp[`ready(`PCIE)])
      );
