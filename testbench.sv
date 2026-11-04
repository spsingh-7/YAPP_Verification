`include "uvm_macros.svh"
`include "yapp_pkg.sv"
`include "yapp_if.sv"
`include "channel_pkg.sv"
`include "channel_if.sv"
`include "hbus_pkg.sv"
`include "hbus_if.sv"
`include "router_module_pkg.sv"
`include "clock_and_reset_pkg.sv"
`include "clock_and_reset_if.sv"
`include "clkgen.sv"
`include "hw_top.sv"
`include "cdns_uvmreg_utils_pkg.sv"
`include "quicktest.sv"

module tb_top;
  
  import uvm_pkg::*;
  import clock_and_reset_pkg::*;
  import hbus_pkg::*;
  import channel_pkg::*;
  import yapp_pkg::*;
  import router_module_pkg::*;
  import cdns_uvmreg_utils_pkg::*;
  
  `include "router_mcsequencer.sv"
  `include "router_mcseqs_lib.sv"
  `include "router_tb.sv"
  `include "router_test_lib.sv"
  
  
  
  initial begin
    hbus_vif_config::set(null,"*.tb.henv.*", "vif", hw_top.hif);
    yapp_vif_config::set(null,"*.tb.env.agent.*","vif",hw_top.in0);
    channel_vif_config::set(null,"*.tb.ch0.*","vif",hw_top.ch0);
    channel_vif_config::set(null,"*.tb.ch1.*","vif",hw_top.ch1);
    channel_vif_config::set(null,"*.tb.ch2.*","vif",hw_top.ch2);
    clock_and_reset_vif_config::set(null,"*.tb.clk_rst_env*","vif", hw_top.clk_rst_if);
    run_test("base_test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule : tb_top