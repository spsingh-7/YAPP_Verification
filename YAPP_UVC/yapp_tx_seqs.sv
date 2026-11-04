class yapp_base_seq extends uvm_sequence #(yapp_packet);
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_base_seq)

  // Constructor
  function new(string name="yapp_base_seq");
    super.new(name);
  endfunction

  task pre_body();
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

  task post_body();
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

endclass : yapp_base_seq




class yapp_5_packets extends yapp_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_5_packets)

  // Constructor
  function new(string name="yapp_5_packets");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_5_packets sequence", UVM_LOW)
     repeat(5)
      `uvm_do(req)
  endtask
  
endclass : yapp_5_packets
       
       

       
class yapp_1_seq extends yapp_base_seq;
  
  `uvm_object_utils(yapp_1_seq)
  
  function new(string name = "yapp_1_seq");
    super.new(name);
  endfunction : new
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing: %s", get_type_name()), UVM_HIGH)
    `uvm_do_with(req, {addr == 1;})
  endtask : body
         
endclass : yapp_1_seq
    
    

    
class yapp_012_seq extends yapp_base_seq;
  
  rand bit[1:0] seq_addr;
  
  `uvm_object_utils_begin(yapp_012_seq)
  	`uvm_field_int(seq_addr, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "yapp_012_seq");
    super.new(name);
  endfunction : new
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing: %s", get_type_name()), UVM_HIGH)
    `uvm_do_with(req, {addr == 0;})
    `uvm_do_with(req, {addr == 1;})
    `uvm_do_with(req, {addr == 2;})
  endtask : body
  
endclass : yapp_012_seq
    
    

    
class yapp_111_seq extends yapp_base_seq;
  
  yapp_1_seq y1s;
  
  `uvm_object_utils(yapp_111_seq)
  
  function new(string name = "yapp_111_seq");
    super.new(name);
  endfunction : new
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing: %s", get_type_name()), UVM_HIGH)
    repeat(3) begin
      `uvm_do(y1s);
    end
  endtask : body

endclass : yapp_111_seq
    
    

    
class yapp_repeat_addr_seq extends yapp_base_seq;
  
  rand bit[1:0] seq_addr;
  
  `uvm_object_utils_begin(yapp_repeat_addr_seq)
  	`uvm_field_int(seq_addr, UVM_ALL_ON)
  `uvm_object_utils_end
  
  constraint seq_addr_c{
    seq_addr inside {[0:2]}; 
  }
  function new(string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction : new
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing Sequence: %s", get_type_name()), UVM_HIGH)
    repeat(2) begin
      `uvm_do_with(req,{req.addr == seq_addr;})
      /*
      Alternative Implementation
      
      `uvm_do(req)
      seq_addr = req.addr;
      `uvm_do_with(req,{req.addr == aeq_addr})
      */
    end
  endtask : body

endclass : yapp_repeat_addr_seq
    
    


    
class yapp_incr_payload_seq extends yapp_base_seq;
  
  `uvm_object_utils(yapp_incr_payload_seq)
  
  function new(string name = "yapp_incr_payload_seq");
    super.new(name);
  endfunction : new
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing Sequence: %s", get_type_name()), UVM_HIGH)
    `uvm_create(req)
    void'(req.randomize());
    foreach(req.payload[i]) begin
      req.payload[i] = i;
    end
    req.set_parity();
    `uvm_send(req)
  endtask : body

endclass : yapp_incr_payload_seq
    


    
class yapp_rand_seq extends yapp_base_seq;
  
  rand int count;
  
  `uvm_object_utils_begin(yapp_rand_seq)
  	`uvm_field_int(count, UVM_ALL_ON)
  `uvm_object_utils_end
  
  constraint count_c{
   count >= 1;
   count <= 10;
  }
  
  function new(string name = "yapp_rand_seq");
    super.new(name);
  endfunction : new
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing Sequence: %s", get_type_name()), UVM_HIGH)
    `uvm_info(get_type_name(), $sformatf("The count value is: %0d",count), UVM_LOW)
    repeat(count) begin
      `uvm_do(req)
    end
  endtask : body
  
endclass : yapp_rand_seq      
    


    
class six_yapp_seq extends yapp_base_seq;
  
  yapp_rand_seq				rand_seq;
  
  `uvm_object_utils(six_yapp_seq)
  
  function new(string name = "six_yapp_seq");
    super.new(name);
  endfunction : new
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing Sequence: %s", get_type_name()), UVM_HIGH)
    `uvm_do_with(rand_seq, {count == 6;})
  endtask : body
  
endclass : six_yapp_seq
    


    
class yapp_exhaustive_seq extends yapp_base_seq;
  
  yapp_1_seq				seq1;
  yapp_012_seq				seq012;
  yapp_111_seq				seq111;
  yapp_repeat_addr_seq		seq_rep_addr;
  yapp_incr_payload_seq		seq_inc_payload;
  yapp_rand_seq				seq_rand;
  six_yapp_seq				seq_six_pkt;
  
  `uvm_object_utils(yapp_exhaustive_seq)
  
  function new(string name = "yapp_exhaustive_seq");
    super.new(name);
  endfunction : new
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing Sequence: %s", get_type_name()), UVM_HIGH)
    `uvm_do(seq1)
    `uvm_do(seq012)
    `uvm_do(seq111)
    `uvm_do(seq_rep_addr)
    `uvm_do(seq_inc_payload)
    `uvm_do(seq_rand)
    `uvm_do(seq_six_pkt)
  endtask : body
  
endclass : yapp_exhaustive_seq
    


    
class yapp_exhaustive_addr_seq extends yapp_base_seq;
      
  `uvm_object_utils(yapp_exhaustive_addr_seq)
  
  function new(string name = "yapp_exhaustive_addr_seq");
    super.new(name);
  endfunction : new
  
  virtual task body();
    
    `uvm_info(get_type_name(), $sformatf("Executing Sequence: %s",get_type_name()), UVM_HIGH)
    for(int i = 0; i < 4; i++) begin
      `uvm_info(get_type_name(), $sformatf("Executing Sequence for address: %0d",i), UVM_HIGH)
      for(bit[5:0] len = 1; len<=22; len++) begin
        `uvm_create(req)
        if (i <3) begin
          void'(req.randomize() with {addr == i; length == len; parity_type dist {BAD_PARITY:=20, GOOD_PARITY:=80};});
        end else begin
          void'(req.randomize() with {parity_type dist {BAD_PARITY:=20, GOOD_PARITY:=80};});
          req.addr = 3;
          req.set_parity();
        end
        `uvm_send(req)
      end
    end
    
  endtask : body

endclass : yapp_exhaustive_addr_seq