class ctrl_reg extends uvm_reg;
  `uvm_object_utils(ctrl_reg)
  rand uvm_reg_field plen;
  function new(string name = "ctrl_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
    plen = uvm_reg_field::type_id::create("plen");
    plen.configure(this, 6, 0, "RW", 0, 8'h63, 1, 1, 0);
  endfunction
endclass

class en_reg extends uvm_reg;
  `uvm_object_utils(en_reg)
  rand uvm_reg_field router_en;
  rand uvm_reg_field parity_err_cnt_en;
  rand uvm_reg_field oversized_pkt_cnt_en;
  rand uvm_reg_field addr0_cnt_en;
  rand uvm_reg_field addr1_cnt_en;
  rand uvm_reg_field addr2_cnt_en;
  rand uvm_reg_field addr3_cnt_en;
  function new(string name = "en_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
    router_en = uvm_reg_field::type_id::create("router_en");
    router_en.configure(this, 1, 0, "RW", 0, 8'h1, 1, 1, 0);
    parity_err_cnt_en = uvm_reg_field::type_id::create("parity_err_cnt_en");
    parity_err_cnt_en.configure(this, 1, 1, "RW", 0, 8'h1, 1, 1, 0);
    oversized_pkt_cnt_en = uvm_reg_field::type_id::create("oversized_pkt_cnt_en");
    oversized_pkt_cnt_en.configure(this, 1, 2, "RW", 0, 8'h1, 1, 1, 0);
    addr0_cnt_en = uvm_reg_field::type_id::create("addr0_cnt_en");
    addr0_cnt_en.configure(this, 1, 4, "RW", 0, 8'h1, 1, 1, 0);
    addr1_cnt_en = uvm_reg_field::type_id::create("addr1_cnt_en");
    addr1_cnt_en.configure(this, 1, 5, "RW", 0, 8'h1, 1, 1, 0);
    addr2_cnt_en = uvm_reg_field::type_id::create("addr2_cnt_en");
    addr2_cnt_en.configure(this, 1, 6, "RW", 0, 8'h1, 1, 1, 0);
    addr3_cnt_en = uvm_reg_field::type_id::create("addr3_cnt_en");
    addr3_cnt_en.configure(this, 1, 7, "RW", 0, 8'h1, 1, 1, 0);
  endfunction
endclass

class parity_err_cnt_reg extends uvm_reg;
  `uvm_object_utils(parity_err_cnt_reg)
  function new(string name = "parity_err_cnt_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
  endfunction
endclass

class oversized_pkt_cnt_reg extends uvm_reg;
  `uvm_object_utils(oversized_pkt_cnt_reg)
  function new(string name = "oversized_pkt_cnt_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
  endfunction
endclass

class addr3_cnt_reg extends uvm_reg;
  `uvm_object_utils(addr3_cnt_reg)
  function new(string name = "addr3_cnt_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
  endfunction
endclass

class addr0_cnt_reg extends uvm_reg;
  `uvm_object_utils(addr0_cnt_reg)
  function new(string name = "addr0_cnt_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
  endfunction
endclass

class addr1_cnt_reg extends uvm_reg;
  `uvm_object_utils(addr1_cnt_reg)
  function new(string name = "addr1_cnt_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
  endfunction
endclass

class addr2_cnt_reg extends uvm_reg;
  `uvm_object_utils(addr2_cnt_reg)
  function new(string name = "addr2_cnt_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
  endfunction
endclass

class mem_size_reg extends uvm_reg;
  `uvm_object_utils(mem_size_reg)
  function new(string name = "mem_size_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
  endfunction
endclass

class yapp_mem extends uvm_mem;
  `uvm_object_utils(yapp_mem)
  function new(string name = "yapp_mem");
    super.new(name, 256, 8, "RW");
  endfunction
endclass

class yapp_pkt_mem extends uvm_mem;
  `uvm_object_utils(yapp_pkt_mem)
  function new(string name = "yapp_pkt_mem");
    super.new(name, 64, 8, "RO");
  endfunction
endclass

class yapp_router_regs_t extends uvm_reg_block;
  `uvm_object_utils(yapp_router_regs_t)
  rand ctrl_reg ctrl_reg_inst;
  rand en_reg en_reg_inst;
  rand parity_err_cnt_reg parity_err_cnt_reg_inst;
  rand oversized_pkt_cnt_reg oversized_pkt_cnt_reg_inst;
  rand addr3_cnt_reg addr3_cnt_reg_inst;
  rand addr0_cnt_reg addr0_cnt_reg_inst;
  rand addr1_cnt_reg addr1_cnt_reg_inst;
  rand addr2_cnt_reg addr2_cnt_reg_inst;
  rand mem_size_reg mem_size_reg_inst;
  rand yapp_mem yapp_mem_inst;
  rand yapp_pkt_mem yapp_pkt_mem_inst;
  uvm_reg_map router;
  uvm_reg_map router_yapp_regs;
  function new(string name = "yapp_router_regs_t");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  virtual function void build();
    ctrl_reg_inst = ctrl_reg::type_id::create("ctrl_reg_inst");
    ctrl_reg_inst.configure(this, null, "");
    ctrl_reg_inst.build();
    en_reg_inst = en_reg::type_id::create("en_reg_inst");
    en_reg_inst.configure(this, null, "");
    en_reg_inst.build();
    parity_err_cnt_reg_inst = parity_err_cnt_reg::type_id::create("parity_err_cnt_reg_inst");
    parity_err_cnt_reg_inst.configure(this, null, "");
    parity_err_cnt_reg_inst.build();
    oversized_pkt_cnt_reg_inst = oversized_pkt_cnt_reg::type_id::create("oversized_pkt_cnt_reg_inst");
    oversized_pkt_cnt_reg_inst.configure(this, null, "");
    oversized_pkt_cnt_reg_inst.build();
    addr3_cnt_reg_inst = addr3_cnt_reg::type_id::create("addr3_cnt_reg_inst");
    addr3_cnt_reg_inst.configure(this, null, "");
    addr3_cnt_reg_inst.build();
    addr0_cnt_reg_inst = addr0_cnt_reg::type_id::create("addr0_cnt_reg_inst");
    addr0_cnt_reg_inst.configure(this, null, "");
    addr0_cnt_reg_inst.build();
    addr1_cnt_reg_inst = addr1_cnt_reg::type_id::create("addr1_cnt_reg_inst");
    addr1_cnt_reg_inst.configure(this, null, "");
    addr1_cnt_reg_inst.build();
    addr2_cnt_reg_inst = addr2_cnt_reg::type_id::create("addr2_cnt_reg_inst");
    addr2_cnt_reg_inst.configure(this, null, "");
    addr2_cnt_reg_inst.build();
    mem_size_reg_inst = mem_size_reg::type_id::create("mem_size_reg_inst");
    mem_size_reg_inst.configure(this, null, "");
    mem_size_reg_inst.build();
    yapp_mem_inst = yapp_mem::type_id::create("yapp_mem_inst");
    yapp_mem_inst.configure(this);
    yapp_pkt_mem_inst = yapp_pkt_mem::type_id::create("yapp_pkt_mem_inst");
    yapp_pkt_mem_inst.configure(this);
    router = create_map("router", 'h1100, 1, UVM_LITTLE_ENDIAN);
    router_yapp_regs = create_map("router_yapp_regs", 'h1000, 1, UVM_LITTLE_ENDIAN);
    router_yapp_regs.add_reg(ctrl_reg_inst, 'h00, "RW");
    router_yapp_regs.add_reg(en_reg_inst, 'h01, "RW");
    router_yapp_regs.add_reg(parity_err_cnt_reg_inst, 'h04, "RO");
    router_yapp_regs.add_reg(oversized_pkt_cnt_reg_inst, 'h05, "RO");
    router_yapp_regs.add_reg(addr3_cnt_reg_inst, 'h06, "RO");
    router_yapp_regs.add_reg(addr0_cnt_reg_inst, 'h9, "RO");
    router_yapp_regs.add_reg(addr1_cnt_reg_inst, 'ha, "RO");
    router_yapp_regs.add_reg(addr2_cnt_reg_inst, 'hb, "RO");
    router_yapp_regs.add_reg(mem_size_reg_inst, 'hd, "RO");
    router.add_mem(yapp_mem_inst, 'h1100, "RW");
    router_yapp_regs.add_mem(yapp_pkt_mem_inst, 'h1010, "RO");
  endfunction
endclass
