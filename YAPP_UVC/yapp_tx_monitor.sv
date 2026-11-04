class yapp_tx_monitor extends uvm_monitor;
  
  virtual interface yapp_if vif;
  yapp_packet pkt;
  int num_pkt_col;
    
  uvm_analysis_port#(yapp_packet)  yapp_out;
  
  `uvm_component_utils(yapp_tx_monitor)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    yapp_out = new("yapp_out", this);
  endfunction : new
    
  virtual function void connect_phase(uvm_phase phase);
    if(!yapp_vif_config::get(this, "", "vif", vif)) begin
      `uvm_error("NO_VIF","vif not set")
    end
  endfunction : connect_phase
  
  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Executing \"start_of_simulation_phase\" of %s",get_name()), UVM_HIGH)
  endfunction : start_of_simulation_phase
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the Monitor \"run_phase\"", UVM_LOW)
    @(posedge vif.reset);
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Reset Dropped", UVM_MEDIUM)
    
    forever begin
      pkt = yapp_packet::type_id::create("pkt");
      
      fork
        vif.collect_packet(pkt.length, pkt.addr, pkt.payload, pkt.parity);
        
        @(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_YAPP_Packet"));
      join
      
      pkt.parity_type = (pkt.parity == pkt.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
      
      yapp_out.write(pkt);
      
      end_tr(pkt);
      
      `uvm_info(get_type_name(), $sformatf("Packet Collected: \n%s",pkt.sprint()), UVM_LOW)
      num_pkt_col++;
    end
  endtask : run_phase
    
  virtual function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
  endfunction : report_phase
    
endclass : yapp_tx_monitor