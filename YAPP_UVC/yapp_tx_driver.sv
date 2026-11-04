class yapp_tx_driver extends uvm_driver#(yapp_packet);
  
  int num_sent;
  virtual interface yapp_if vif;
  
  `uvm_component_utils(yapp_tx_driver)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
    
  virtual function void connect_phase(uvm_phase phase);
    if(!yapp_vif_config::get(this,"","vif",vif)) begin
      `uvm_error("NO_VIF","vif not set")
    end
  endfunction : connect_phase
    
  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Executing \"start_of_simulation_phase\" of %s",get_name()), UVM_HIGH)
  endfunction : start_of_simulation_phase
  
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the Driver \"run_phase\"", UVM_LOW)
    fork
      get_and_drive();		//Process 1
      reset_signals();		//Process 2
    join
  endtask : run_phase
  
  task get_and_drive();
    //Assert and De-assert the reset signal
    @(posedge vif.reset);
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Reset Dropped", UVM_MEDIUM)
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name(), $sformatf("Sending Packet:\n%s", req.sprint()), UVM_HIGH)
      
      fork
        begin																	//Process 2.a
          foreach(req.payload[i])
            vif.payload_mem[i] = req.payload[i];
          vif.send_to_dut(req.length, req.addr, req.parity, req.packet_delay);
        end
        
        @(posedge vif.drvstart) void'(begin_tr(req, "Driver_YAPP_Packet"));		//Process 2.b
      join
      
      end_tr(req);
      num_sent++;
      
      seq_item_port.item_done();
    end
    
  endtask : get_and_drive
  
  
  task reset_signals();
    forever
      vif.yapp_reset();
  endtask : reset_signals
  
  virtual function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction : check_phase
  
  virtual function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: YAPP TX driver sent %0d packets", num_sent), UVM_LOW)
  endfunction : report_phase
  
endclass : yapp_tx_driver