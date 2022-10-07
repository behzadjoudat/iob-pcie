   //
   // /iob_pcie0/
   //

   iob_pcie iob_pcie0
     (
      .clk     (clk),
      .rst     (rst),
      .PCIE_CLK(PCIE_CLK_IF),
      .PCIE_RST(PCIE_RST_IF),
      .PCIE_CHNL_RX(PCIE_CHNL_RX_IF),
      .PCIE_CHNL_RX_CLK(PCIE_CHNL_RX_CLK_IF),
      .PCIE_CHNL_RX_ACK(PCIE_CHNL_RX_ACK_IF),
      .PCIE_CHNL_RX_LAST(PCIE_CHNL_RX_LAST_IF),
      .PCIE_CHNL_RX_LEN(PCIE_CHNL_RX_LEN_IF),
      .PCIE_CHNL_RX_OFF(PCIE_CHNL_RX_OFF_IF),
      .PCIE_CHNL_RX_DATA(PCIE_CHNL_RX_DATA_IF),
      .PCIE_CHNL_RX_DATA_VALID(PCIE_CHNL_RX_DATA_VALID_IF),
      .PCIE_CHNL_RX_DATA_REN(PCIE_CHNL_RX_DATA_REN_IF),
      .PCIE_CHNL_TX_CLK(PCIE_CHNL_TX_CLK_IF),
      .PCIE_CHNL_TX(PCIE_CHNL_TX_IF),
      .PCIE_CHNL_TX_ACK(PCIE_CHNL_TX_ACK_IF),
      .PCIE_CHNL_TX_LAST(PCIE_CHNL_TX_LAST_IF),
      .PCIE_CHNL_TX_LEN(PCIE_CHNL_TX_LEN_IF),
      .PCIE_CHNL_TX_OFF(PCIE_CHNL_TX_OFF_IF),
      .PCIE_CHNL_TX_DATA(PCIE_CHNL_TX_DATA_IF),
      .PCIE_CHNL_TX_DATA_VALID(PCIE_CHNL_TX_DATA_VALID_IF),
      .PCIE_CHNL_TX_DATA_REN(PCIE_CHNL_TX_DATA_REN_IF),

     // CPU interface
      .valid       (slaves_req[`valid(`PCIE)]),
      .address     (slaves_req[`address(`PCIE,`iob_pcie_swreg_ADDR_W+2)-2]),
      .wdata       (slaves_req[`wdata(`PCIE)]),
      .wstrb       (slaves_req[`wstrb(`PCIE)]),
      .rdata       (slaves_resp[`rdata(`PCIE)]),
      .ready       (slaves_resp[`ready(`PCIE)])
      );
