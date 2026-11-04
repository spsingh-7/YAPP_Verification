typedef enum bit {GOOD_PARITY, BAD_PARITY} parity_type_e;

class yapp_packet extends uvm_sequence_item;
  
  //Protocol Data
  rand bit[1:0] addr;
  rand bit[5:0] length;
  	   bit[7:0] parity;
  rand bit[7:0] payload[];
  
  //Control Knobs
  rand parity_type_e parity_type;
  rand int packet_delay;
  
  //Automation for Packet's Fields
  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(length, UVM_ALL_ON)
  	`uvm_field_int(parity, UVM_ALL_ON + UVM_BIN)
    `uvm_field_array_int(payload, UVM_ALL_ON)
  	`uvm_field_enum(parity_type_e, parity_type, UVM_ALL_ON)
  	`uvm_field_int(packet_delay, UVM_NOCOMPARE + UVM_UNSIGNED)
  `uvm_object_utils_end
  
  //Packet Methods
  function new(string name = "yapp_packet");
    super.new(name);
  endfunction : new
  
  
  function bit[7:0] calc_parity();  
    calc_parity = {length, addr};
    foreach(payload[i]) begin
      calc_parity = calc_parity^payload[i];
    end
  endfunction : calc_parity
  
  
  function void set_parity();
    parity = calc_parity();
    if(parity_type == BAD_PARITY) begin
      parity = ~parity;
    end
  endfunction : set_parity
  
  
  function void post_randomize();
    set_parity();
  endfunction : post_randomize
  
  
  //Packet Constraints
  constraint addr_c {
    addr inside {[0:2]}; 
  }
  
  constraint length_c {
    length == payload.size();
    length inside {[1:63]};
  }
  
  constraint parity_type_c {
    parity_type dist {GOOD_PARITY := 5, BAD_PARITY :=1}; 
  }
  
  constraint delay_c {
    packet_delay inside {[1:20]};
  }
  
  
endclass: yapp_packet



class short_yapp_packet extends yapp_packet;
  
  `uvm_object_utils(short_yapp_packet)
  
  function new(string name = "short_yapp_packet");
    super.new(name);
  endfunction : new
  
  constraint short_length_c {
   length < 15; 
  }
  
//   constraint addr_c{
//     addr inside {0,1}; 
//   }
  
endclass : short_yapp_packet
