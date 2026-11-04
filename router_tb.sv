class router_tb extends uvm_env;
  
  yapp_env 				env;			//YAPP UVC
  hbus_env 				henv;			//HBUS UVC
  channel_env 			ch0, ch1, ch2;	//Channel UVC
  clock_and_reset_env 	clk_rst_env;	//Clock and Reset UVC
  
  router_mcsequencer	v_seqr;			//Virtual Seqencer
  
  router_module_env		router_env;		//Router Module UVC Environment
  
  `uvm_component_utils(router_tb)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    uvm_config_db#(uvm_bitstream_t)::set(this,"henv","num_masters",1);
    uvm_config_db#(uvm_bitstream_t)::set(this,"henv","num_slaves",0);
    uvm_config_db#(uvm_bitstream_t)::set(this,"ch0","channel_id",0);
    uvm_config_db#(uvm_bitstream_t)::set(this,"ch1","channel_id",1);
    uvm_config_db#(uvm_bitstream_t)::set(this,"ch2","channel_id",2);
    
    super.build_phase(phase);
    
    env 		= yapp_env::type_id::create("env", this);
    henv 		= hbus_env::type_id::create("henv", this);
    ch0 		= channel_env::type_id::create("ch0", this);
    ch1 		= channel_env::type_id::create("ch1", this);
    ch2 		= channel_env::type_id::create("ch2", this);
    clk_rst_env	= clock_and_reset_env::type_id::create("clk_rst_env", this);
    
    v_seqr		= router_mcsequencer::type_id::create("v_seqr", this);
    
    router_env	= router_module_env::type_id::create("router_env", this);
    
    `uvm_info(get_name(), "Executing Build Phase of the Testbench", UVM_HIGH)
  endfunction : build_phase
  
  virtual function void connect_phase(uvm_phase phase);
    
    //Virtual sequencer Connection
    v_seqr.yapp_seqr = env.agent.sequencer;
    v_seqr.hbus_seqr = henv.masters[0].sequencer;
    
    //Scoreboard TLM Connection
    env.agent.monitor.yapp_out.connect(router_env.yapp_exp);
    henv.bus_monitor.item_collected_port.connect(router_env.hbus_exp);
    ch0.rx_agent.monitor.item_collected_port.connect(router_env.ch0_exp);
    ch1.rx_agent.monitor.item_collected_port.connect(router_env.ch1_exp);
    ch2.rx_agent.monitor.item_collected_port.connect(router_env.ch2_exp);
    
  endfunction : connect_phase
  
  
  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Executing \"start_of_simulation_phase\" of %s",get_name()), UVM_HIGH)
  endfunction : start_of_simulation_phase
  
endclass : router_tb