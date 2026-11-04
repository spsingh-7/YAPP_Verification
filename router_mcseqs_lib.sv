class router_simple_mcseq extends uvm_sequence;
  
  `uvm_object_utils(router_simple_mcseq)
  `uvm_declare_p_sequencer(router_mcsequencer)
  
  hbus_small_packet_seq		sml_pkt_seq;
  hbus_read_max_pkt_seq		max_pkt_seq;
  yapp_012_seq				y012_addr;
  hbus_set_get_regs_seq		reg_rd_seq;
  six_yapp_seq				y6_pkt;
  
  function new(string name = "router_simple_mcseq");
    super.new(name);
  endfunction : new
  
  virtual task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing %s", get_type_name()), UVM_LOW)
    `uvm_do_on(sml_pkt_seq, p_sequencer.hbus_seqr)
    `uvm_do_on(max_pkt_seq, p_sequencer.hbus_seqr)
    `uvm_info(get_type_name(), $sformatf("router MAXPKTSIZE register read: %0h", max_pkt_seq.max_pkt_reg),UVM_LOW)
    repeat(2)
      `uvm_do_on(y012_addr,	p_sequencer.yapp_seqr)
    `uvm_do_on(reg_rd_seq,	p_sequencer.hbus_seqr)
    `uvm_info(get_type_name(), $sformatf("router MAXPKTSIZE register read: %0h", reg_rd_seq.read_max_seq.max_pkt_reg),UVM_LOW)
    `uvm_do_on(y6_pkt,		p_sequencer.yapp_seqr)
  endtask : body
  
  virtual task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body
  
endclass : router_simple_mcseq