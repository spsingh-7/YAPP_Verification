class router_mcsequencer extends uvm_sequencer;
  
  `uvm_component_utils(router_mcsequencer)
  
  //Do not create these handles
  //They will be assigned using hierarchical path names in the TB
  yapp_tx_sequencer			yapp_seqr;
  hbus_master_sequencer		hbus_seqr;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase
  
endclass : router_mcsequencer