class router_reference extends uvm_component;
  
  //Analysis imp decl macros for YAPP and HBUS
  `uvm_analysis_imp_decl(_yapp)
  `uvm_analysis_imp_decl(_hbus)
  
  uvm_analysis_imp_yapp#(yapp_packet, router_reference) yapp_in;
  uvm_analysis_imp_hbus#(hbus_transaction, router_reference) hbus_in;
  
  //Analysis port for YAPP
  uvm_analysis_port#(yapp_packet) yapp_out;
  
  protected bit[5:0] 	max_size;		//Mirrors the maxpktsize field of ctrl_reg of DUT Registers
  protected bit			r_en;			//Mirrors the router_en field of the en_reg of the DUT Register
  
  //Packet Drop Statistics
  int packet_cnt;
  int invld_pkt_cnt;
  int en_violation_cnt;
  int addr_violation_cnt;
  
  `uvm_component_utils(router_reference)
  
  function new(string name, uvm_component parent);
    
    super.new(name, parent);
    yapp_out	= new("yapp_out", this);
    yapp_in		= new("yapp_in", this);
    hbus_in		= new("hbus_in", this);
    
  endfunction : new
  
  
  function void write_hbus(input hbus_transaction packet);
    
    if(packet.hwr_rd == HBUS_WRITE)
      case(packet.haddr)
        'h1000 : max_size	= packet.hdata[5:0];
        'h1001 : r_en		= packet.hdata[0];
      endcase
  endfunction : write_hbus
  
  
  function void write_yapp(input yapp_packet packet);
    
    packet_cnt++;
    
    if((packet.length <= max_size) && (r_en) && (packet.addr inside {0,1,2}))
      yapp_out.write(packet);
    
    if(!r_en)
      en_violation_cnt++;
    
    if(packet.length > max_size)
      invld_pkt_cnt++;
    
    if(packet.addr == 3)
      addr_violation_cnt++;
    
  endfunction : write_yapp
  
  
  virtual function void report_phase(uvm_phase phase);
    
    `uvm_info(get_type_name(),
              $sformatf("Report: \n\n Router Reference Packet Stastistics \n Total Packet Received: %0d\n Invalid Sized Packet: %0d\n Enable Violating Packet: %0d\n Address Violating Packet: %0d", packet_cnt, invld_pkt_cnt, en_violation_cnt, addr_violation_cnt),
              UVM_NONE)
    
    if((invld_pkt_cnt + en_violation_cnt + addr_violation_cnt)>0)
      `uvm_error(get_type_name(), "Status: \n\nPacket Violations")
      
  endfunction : report_phase
  
endclass : router_reference