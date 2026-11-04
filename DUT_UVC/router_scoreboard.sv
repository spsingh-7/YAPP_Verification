typedef enum bit {EQUALITY, UVM} comp_t;

class router_scoreboard extends uvm_scoreboard;
  
  yapp_packet q_0[$];		//Queue for Ch_0 Packet
  yapp_packet q_1[$];		//Queue for Ch_1 Packet
  yapp_packet q_2[$];		//Queue for Ch_2 Packet
  
  //Scoreboard Stastistics
  int packets_in, in_dropped;
  int packets_ch0, compare_ch0, miscompare_ch0, dropped_ch0;
  int packets_ch1, compare_ch1, miscompare_ch1, dropped_ch1;
  int packets_ch2, compare_ch2, miscompare_ch2, dropped_ch2;
  
  //Analysis decl macros for different interfaces
  `uvm_analysis_imp_decl(_yapp)
  `uvm_analysis_imp_decl(_chan0)
  `uvm_analysis_imp_decl(_chan1)
  `uvm_analysis_imp_decl(_chan2)
  
  //Switch for compare policy
  comp_t compare_policy = UVM;
  
  //Analysis imp instances for different interfaces
  uvm_analysis_imp_yapp	#(yapp_packet, router_scoreboard)		yapp_in;
  uvm_analysis_imp_chan0#(channel_packet, router_scoreboard)	chan0_in;
  uvm_analysis_imp_chan1#(channel_packet, router_scoreboard)	chan1_in;
  uvm_analysis_imp_chan2#(channel_packet, router_scoreboard)	chan2_in;
  
  `uvm_component_utils_begin(router_scoreboard)
  	`uvm_field_enum(comp_t, compare_policy, UVM_ALL_ON)
  `uvm_component_utils_end
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    yapp_in 	= new("yapp_in", this);		//YAPP analysis imp object
    chan0_in	= new("chan0_in", this);	//CH_0 analysis imp object
    chan1_in	= new("chan1_in", this);	//CH_1 analysis imp object
    chan2_in	= new("chan2_in", this);	//CH_2 analysis imp object
  endfunction : new
  
  
  
  //Verilog Equality Method
  virtual function bit pkt_compare(yapp_packet yp, channel_packet cp);
    
    if(yp.addr != cp.addr) begin
      `uvm_error(get_type_name(), $sformatf("Address Mismatch -> YAPP: %0d | CH: %0d", yp.addr, cp.addr))
      return(0);
    end
    
    if(yp.length != cp.length) begin
      `uvm_error(get_type_name(), $sformatf("Length Mismatch -> YAPP: %0d | CH: %0d", yp.length, cp.length))
      return(0);
    end
    
    if(yp.parity_type.name() != cp.parity_type.name()) begin
      `uvm_error(get_type_name(), $sformatf("Parity Type Mismatch -> YAPP: %s | CH: %s", yp.parity_type.name(), cp.parity_type.name()))
      return(0);
    end
    
    if(yp.parity != cp.parity) begin
      `uvm_error(get_type_name(), $sformatf("Parity Mismatch -> YAPP: %b | CH: %b",yp.parity,cp.parity))
      return(0);
    end
    
    for(int i=0; i < yp.length; i++) begin
      if(yp.payload[i] != cp.payload[i])begin
        `uvm_error(get_type_name(), $sformatf("Payload[%0d] Mismatch -> YAPP: %0d | CH: %0d",i, yp.payload[i], cp.payload[i]))
        return(0);
      end
    end
    
    return(1);
    
  endfunction : pkt_compare
  
  
  
  //UVM Comparer method
  virtual function bit uvm_compare(input yapp_packet yp, input channel_packet cp, uvm_comparer comparer = null);
    
    string str;
    
    if(comparer == null)
      comparer = new();
    uvm_compare = comparer.compare_field("addr", yp.addr, cp.addr, 2);
    uvm_compare &= comparer.compare_field("length", yp.length, cp.length, 6);
    uvm_compare &= comparer.compare_field("parity", yp.parity, cp.parity, 8);
    foreach(yp.payload[i]) begin
      str.itoa(i);
      uvm_compare &= comparer.compare_field({"payload[",str,"]"}, yp.payload[i], cp.payload[i], 8);
    end
    
  endfunction : uvm_compare
  
  //YAPP write() implementation
  function void write_yapp(input yapp_packet packet);
    
    yapp_packet ypkt;
    $cast(ypkt, packet.clone());
    
    packets_in += 1;
    
    case(ypkt.addr)
      2'b00 : begin 
        		q_0.push_back(ypkt);
        		`uvm_info(get_type_name(), "Adding Packet to Scoreboard Queue 0", UVM_HIGH)
      		  end
      2'b01 : begin
        		q_1.push_back(ypkt);
        		`uvm_info(get_type_name(), "Adding Packet to Scoreboard Queue 1", UVM_HIGH)
      		  end
      2'b10 : begin
        		q_2.push_back(ypkt);
        		`uvm_info(get_type_name(), "Adding Packet to Scoreboard Queue 2", UVM_HIGH)
      		  end
      default: begin
        		`uvm_info(get_type_name(), $sformatf("Packet Dropped: Bad Address = %0d\n%s",ypkt.addr, ypkt.sprint()), UVM_LOW)
        		in_dropped++;
               end
    endcase
    
  endfunction : write_yapp
  
  //CH_0 write() implementation
  function void write_chan0(input channel_packet cp);
    
    yapp_packet yp;
    bit pktcompare;
    packets_ch0++;
    
    //This case will arise when queue was empty and there was no input provided, but we have an output transaction on Channel_0.
    if(q_0.size() == 0) begin
      `uvm_error(get_type_name(),
                 $sformatf("Scoreboard Eroor [EMPTY]: Received Unexpected Channel_0 Packets!\n%s: ", cp.sprint()))
      dropped_ch0++;
      return;    
    end
    
    if(compare_policy == UVM)
      //Using custom Compare method
      pktcompare = uvm_compare(q_0[0], cp);
    else
      //Using Verilog Equality method
      pktcompare = pkt_compare(q_0[0], cp);
    
    if(pktcompare) begin
      void'(q_0.pop_front());
      `uvm_info(get_type_name(),
                $sformatf("Scoreboard Compare MATCH: Channel_0 Packet \n%s", cp.sprint()),
                UVM_MEDIUM)
      compare_ch0++;
    end else begin
      yp = q_0[0];
      `uvm_warning(get_type_name(),
                   $sformatf("Scoreboard Error [MISCOMPARE]: Received Channel_0 Packet:\n%s\nExpected Channel_0 Packet: \n%s",yp.sprint(),cp.sprint()))
      miscompare_ch0++;
    end
    
  endfunction : write_chan0
  
  //CH_1 write() implementation
  function void write_chan1(input channel_packet cp);
    
    yapp_packet yp;
    bit pktcompare;
    packets_ch1++;
    
    //This case will arise when queue was empty and there was no input provided, but we have an output transaction on Channel_1.
    if(q_1.size() == 0) begin
      `uvm_error(get_type_name(),
                 $sformatf("Scoreboard Eroor [EMPTY]: Received Unexpected Channel_1 Packets!\n%s: ", cp.sprint()))
      dropped_ch1++;
      return;    
    end
    
    if(compare_policy == UVM)
      //Using custom Compare method
      pktcompare = uvm_compare(q_1[0], cp);
    else
      //Using Verilog Equality method
      pktcompare = pkt_compare(q_1[0], cp);
    
    if(pktcompare) begin
      void'(q_1.pop_front());
      `uvm_info(get_type_name(),
                $sformatf("Scoreboard Compare MATCH: Channel_1 Packet \n%s", cp.sprint()),
                UVM_MEDIUM)
      compare_ch1++;
    end else begin
      yp = q_1[0];
      `uvm_warning(get_type_name(),
                   $sformatf("Scoreboard Error [MISCOMPARE]: Received Channel_1 Packet:\n%s\nExpected Channel_1 Packet: \n%s",yp.sprint(),cp.sprint()))
      miscompare_ch1++;
    end
    
  endfunction : write_chan1
  
  //CH_2 write() implementation
  function void write_chan2(input channel_packet cp);
    
    yapp_packet yp;
    bit pktcompare;
    packets_ch2++;
    
    //This case will arise when queue was empty and there was no input provided, but we have an output transaction on Channel_2.
    if(q_2.size() == 0) begin
      `uvm_error(get_type_name(),
                 $sformatf("Scoreboard Eroor [EMPTY]: Received Unexpected Channel_2 Packets!\n%s: ", cp.sprint()))
      dropped_ch2++;
      return;    
    end
    
    if(compare_policy == UVM)
      //Using custom Compare method
      pktcompare = uvm_compare(q_2[0], cp);
    else
      //Using Verilog Equality method
      pktcompare = pkt_compare(q_2[0], cp);
    
    if(pktcompare) begin
      void'(q_2.pop_front());
      `uvm_info(get_type_name(),
                $sformatf("Scoreboard Compare MATCH: Channel_2 Packet \n%s", cp.sprint()),
                UVM_MEDIUM)
      compare_ch2++;
    end else begin
      yp = q_2[0];
      `uvm_warning(get_type_name(),
                   $sformatf("Scoreboard Error [MISCOMPARE]: Received Channel_2 Packet:\n%s\nExpected Channel_2 Packet: \n%s",yp.sprint(),cp.sprint()))
      miscompare_ch2++;
    end
    
  endfunction : write_chan2
  
  
  
  virtual function void check_phase(uvm_phase phase);
    
    `uvm_info(get_type_name(), "Checking Router Scoreboard", UVM_LOW)
    
    if(q_0.size() || q_1.size() || q_2.size())
      `uvm_error(get_type_name(), $sformatf("Check: \n\n [WARNING] Router Scoreboard Queue is NOT Empty:\n Chan 0: %0d\n  Chan 1: %0d\n. Chan 2: %0d", q_0.size(), q_1.size(), q_2.size()))
      
     else
       `uvm_info(get_type_name(), "Check: \n\n	Router Scoreboard Empty! \n", UVM_LOW)
    
  endfunction : check_phase
  
  
  virtual function void report_phase(uvm_phase phase);
    
    `uvm_info(get_type_name(), $sformatf("Report:\n\n	Scoreboard Packet Stastistics \n Packets In: %0d	Packets Dropped: %0d\n Channel 0 -> Total: %0d		Pass: %0d		Miscompare: %0d		Dropped: %0d\n Channel 1 -> Total: %0d		Pass: %0d		Miscompare: %0d		Dropped: %0d\n Channel 2 -> Total: %0d		Pass: %0d		Miscompare: %0d		Dropped: %0d", packets_in, in_dropped, packets_ch0, compare_ch0, miscompare_ch0, dropped_ch0, packets_ch1, compare_ch1, miscompare_ch1, dropped_ch1, packets_ch2, compare_ch2, miscompare_ch2, dropped_ch2), UVM_LOW)
    
    if((miscompare_ch0 + miscompare_ch1 + miscompare_ch2 + dropped_ch0 + dropped_ch1 + dropped_ch2) > 0)
      `uvm_error(get_type_name(), "Status: \n\nSimulation FAILED\n")
    else
      `uvm_info(get_type_name(), "Status: \n\nSimulation PASSED\n",UVM_NONE)
    
  endfunction : report_phase
  
endclass : router_scoreboard