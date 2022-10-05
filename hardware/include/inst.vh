   //
   // /iob_pcie0/
   //

   iob_pcie iob_pcie0
     (
      .clk     (clk),
      .rst     (reset),

      // Register file interface
      .valid_ext   (PCIE_valid),
      .address_ext (PCIE_address),
      .wdata_ext   (PCIE_wdata),
      .wstrb_ext   (PCIE_wstrb),
      .rdata_ext   (PCIE_rdata),
      .ready_ext   (PCIE_ready),

      // CPU interface
      .valid       (slaves_req[`valid(`PCIE)]),
      .address     (slaves_req[`address(`PCIE,`iob_pcie_swreg_ADDR_W+2)-2]),
      .wdata       (slaves_req[`wdata(`PCIE)]),
      .wstrb       (slaves_req[`wstrb(`PCIE)]),
      .rdata       (slaves_resp[`rdata(`PCIE)]),
      .ready       (slaves_resp[`ready(`PCIE)])
      );
