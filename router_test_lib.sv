class base_test extends uvm_test;
  
  `uvm_component_utils(base_test)
  
  router_tb tb;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    uvm_config_db#(uvm_bitstream_t)::set(this, "*", "recording_detail", 1);
    super.build_phase(phase);
    /*uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase",
                                 "default_sequence",
                                yapp_5_packets::get_type());*/
    tb = router_tb::type_id::create("tb",this);
    `uvm_info(get_name(),"Executing Build Phase of Base Test",UVM_HIGH)
  endfunction : build_phase
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase
  
  virtual task run_phase(uvm_phase phase);
    uvm_objection obj = phase.get_objection();
    obj.set_drain_time(this, 200ns);
  endtask : run_phase
  
  virtual function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction : check_phase
  
endclass : base_test




class short_packet_test extends base_test;
  
  `uvm_component_utils(short_packet_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase",
                                 "default_sequence",
                                yapp_5_packets::get_type());
    super.build_phase(phase);
  endfunction : build_phase
  
endclass : short_packet_test




class set_config_test extends base_test;
  
  `uvm_component_utils(set_config_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    uvm_config_db#(uvm_bitstream_t)::set(this, "tb.env.agent", "is_active", UVM_PASSIVE);
    super.build_phase(phase);
  endfunction : build_phase
  
endclass : set_config_test



class incr_payload_test extends base_test;
  
  yapp_tx_sequencer 		tx_seqr;
  yapp_incr_payload_seq		inc_payload_seq;
  
  `uvm_component_utils(incr_payload_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
    /*uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "tb.env.agent.sequencer.run_phase",
                                            "default_sequence",
                                            yapp_incr_payload_seq::get_type());*/
    super.build_phase(phase);
    inc_payload_seq = yapp_incr_payload_seq::type_id::create("inc_payload_seq");
  endfunction : build_phase
  
  virtual function void connect_phase(uvm_phase phase);
    tx_seqr = tb.env.agent.sequencer;
  endfunction : connect_phase
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this, $sformatf("Executing Test: %s", this.get_type_name()));
    void'(inc_payload_seq.randomize());
    inc_payload_seq.start(tx_seqr);
    phase.drop_objection(this, $sformatf("Executing Test: %s", this.get_type_name()));
  endtask : run_phase
  
endclass : incr_payload_test




class exhaustive_seq_test extends base_test;
  
  //yapp_tx_sequencer		tx_seqr;
  //yapp_exhaustive_seq	exh_seq;
  
  `uvm_component_utils(exhaustive_seq_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "tb.env.agent.sequencer.run_phase",
                                            "default_sequence",
                                            yapp_exhaustive_seq::get_type());
    super.build_phase(phase);
  endfunction : build_phase
  
endclass : exhaustive_seq_test




class short_yapp_012_test extends base_test;
  
  `uvm_component_utils(short_yapp_012_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "tb.env.agent.sequencer.run_phase",
                                            "default_sequence",
                                            yapp_012_seq::get_type());
    super.build_phase(phase);
  endfunction : build_phase
endclass : short_yapp_012_test




class simple_test extends base_test;
  
  `uvm_component_utils(simple_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                           "tb.env.agent.sequencer.run_phase",
                                           "default_sequence",
                                            yapp_012_seq::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                           "tb.ch?.rx_agent.sequencer.run_phase",
                                           "default_sequence",
                                            channel_rx_resp_seq::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                           "tb.clk_rst_env.agent.sequencer.run_phase",
                                           "default_sequence",
                                            clk10_rst5_seq::get_type());
    super.build_phase(phase);   
  endfunction : build_phase
  
endclass : simple_test




class test_uvc_integration extends base_test;
  
  `uvm_component_utils(test_uvc_integration)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                           "tb.env.agent.sequencer.run_phase",
                                           "default_sequence",
                                            yapp_exhaustive_addr_seq::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                            "tb.henv.masters[0].sequencer.run_phase",
                                            "default_sequence",
                                            hbus_small_packet_seq::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                           "tb.ch?.rx_agent.sequencer.run_phase",
                                           "default_sequence",
                                            channel_rx_resp_seq::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                           "tb.clk_rst_env.agent.sequencer.run_phase",
                                           "default_sequence",
                                            clk10_rst5_seq::get_type());
    super.build_phase(phase);
  endfunction : build_phase
  
endclass : test_uvc_integration




class router_vseq_test extends base_test;
  
  `uvm_component_utils(router_vseq_test)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                           "tb.ch?.rx_agent.sequencer.run_phase",
                                           "default_sequence",
                                            channel_rx_resp_seq::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                           "tb.clk_rst_env.agent.sequencer.run_phase",
                                           "default_sequence",
                                            clk10_rst5_seq::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this,
                                           "tb.v_seqr.run_phase",
                                           "default_sequence",
                                            router_simple_mcseq::get_type());
    super.build_phase(phase);
  endfunction : build_phase
  
endclass : router_vseq_test