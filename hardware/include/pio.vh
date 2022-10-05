   // PCIE
   output                           PCIE_valid,
   output [`iob_pcie_swreg_ADDR_W-1:0]   PCIE_address,
   output [`DATA_W-1:0]   PCIE_wdata,
   output [`DATA_W/8-1:0] PCIE_wstrb,
   input [`DATA_W-1:0]  PCIE_rdata,
   input                          PCIE_ready,
