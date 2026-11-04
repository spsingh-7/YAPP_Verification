`include "uvm_macros.svh"
import uvm_pkg::*;
import cdns_uvmreg_utils_pkg::*;

class qt_test extends uvm_test;
  `uvm_component_utils(qt_test)
  yapp_router_regs_t model;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    model = yapp_router_regs_t::type_id::create("model", this);
    model.build();
    model.lock_model();
  endfunction
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("QT_TEST", "Starting Register Reset Test", UVM_LOW)
    model.reset();
    model.print();
    model.router_yapp_regs.print();
    `uvm_info("QT_TEST", "Register Reset Test Complete", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
