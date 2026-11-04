class router_module_env extends uvm_env;
  
  `uvm_component_utils(router_module_env)
  
  router_scoreboard		scoreboard;
  router_reference		reference;
  
  //Reference Model Connectors
  uvm_analysis_export#(yapp_packet) 		yapp_exp;
  uvm_analysis_export#(hbus_transaction) 	hbus_exp;
  
  //Scoreboard Connectors
  uvm_analysis_export#(channel_packet) 		ch0_exp;
  uvm_analysis_export#(channel_packet) 		ch1_exp;
  uvm_analysis_export#(channel_packet) 		ch2_exp;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
    yapp_exp 	= new("yapp_exp", 	this);
    hbus_exp	= new("hbus_exp", 	this);
    ch0_exp		= new("ch0_exp", 	this);
    ch1_exp		= new("ch1_exp", 	this);
    ch2_exp		= new("ch2_exp", 	this);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    scoreboard		= router_scoreboard::type_id::create("scoreboard", this);
    reference		= router_reference::type_id::create("reference", this);
    
  endfunction: build_phase
  
  virtual function void connect_phase(uvm_phase phase);
    
    reference.yapp_out.connect(scoreboard.yapp_in);
    yapp_exp.connect(reference.yapp_in);
    hbus_exp.connect(reference.hbus_in);
    ch0_exp.connect(scoreboard.chan0_in);
    ch1_exp.connect(scoreboard.chan1_in);
    ch2_exp.connect(scoreboard.chan2_in);
    
  endfunction : connect_phase
  
endclass : router_module_env