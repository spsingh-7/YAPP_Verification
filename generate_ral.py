import xml.etree.ElementTree as ET

def fix_xml(xml_file):
    with open(xml_file, 'r') as f:
        content = f.read()
    # Fix the unbound prefix error automatically
    content = content.replace('vendorExtensions:', 'cadence:')
    with open('fixed_yapp_router_regs.xml', 'w') as f:
        f.write(content)
    return ET.parse('fixed_yapp_router_regs.xml')

def to_sv_hex(val):
    """Converts C-style hex (0x...) to SystemVerilog hex ('h...)."""
    if val is None: return "'h0"
    val = str(val).strip()
    if val.lower().startswith('0x'):
        return f"'h{val[2:]}"
    return val

def to_uvm_access(access):
    """Converts IP-XACT access strings to UVM standard short strings."""
    if access is None: return "RW"
    access = str(access).strip()
    if 'read-write' in access: return "RW"
    if 'read-only' in access: return "RO"
    if 'write-only' in access: return "WO"
    return "RW"

def generate():
    tree = fix_xml('yapp_router_regs.xml')
    root = tree.getroot()
    ns = {'spirit': 'http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009'}
    
    mem_map = root.find('.//spirit:memoryMap', ns)
    blocks = mem_map.findall('spirit:addressBlock', ns)
    
    regs = []
    mems = []
    
    for block in blocks:
        name = block.find('spirit:name', ns).text
        base = to_sv_hex(block.find('spirit:baseAddress', ns).text)
        rng = int(block.find('spirit:range', ns).text, 16)
        width = int(block.find('spirit:width', ns).text)
        usage_el = block.find('spirit:usage', ns)
        usage = usage_el.text if usage_el is not None else 'register'
        access_el = block.find('spirit:access', ns)
        access = to_uvm_access(access_el.text) if access_el is not None else "RW"
        
        if usage == 'memory':
            mems.append({'name': name, 'base': base, 'size': rng // (width//8), 'width': width, 'access': access})
        else:
            for reg in block.findall('spirit:register', ns):
                rname = reg.find('spirit:name', ns).text
                roffset = to_sv_hex(reg.find('spirit:addressOffset', ns).text)
                rsize = reg.find('spirit:size', ns).text
                raccess_el = reg.find('spirit:access', ns)
                raccess = to_uvm_access(raccess_el.text) if raccess_el is not None else "RW"
                reset_el = reg.find('.//spirit:value', ns)
                rreset = reset_el.text if reset_el is not None else '0x00'
                
                fields = []
                for field in reg.findall('spirit:field', ns):
                    fields.append({
                        'name': field.find('spirit:name', ns).text,
                        'offset': field.find('spirit:bitOffset', ns).text,
                        'width': field.find('spirit:bitWidth', ns).text
                    })
                regs.append({'name': rname, 'offset': roffset, 'size': rsize, 'access': raccess, 'reset': rreset, 'fields': fields})

    # 1. Generate yapp_router_regs_rdb.sv (NO PACKAGE WRAPPER - JUST CLASSES)
    with open('yapp_router_regs_rdb.sv', 'w') as f:
        # Register Classes
        for r in regs:
            f.write(f"class {r['name']} extends uvm_reg;\n")
            f.write(f"  `uvm_object_utils({r['name']})\n")
            for fld in r['fields']:
                f.write(f"  rand uvm_reg_field {fld['name']};\n")
            f.write(f"  function new(string name = \"{r['name']}\");\n")
            f.write(f"    super.new(name, {r['size']}, UVM_NO_COVERAGE);\n")
            f.write(f"  endfunction\n")
            f.write(f"  virtual function void build();\n")
            for fld in r['fields']:
                f.write(f"    {fld['name']} = uvm_reg_field::type_id::create(\"{fld['name']}\");\n")
                f.write(f"    {fld['name']}.configure(this, {fld['width']}, {fld['offset']}, \"{r['access']}\", 0, {r['size']}'h{int(r['reset'], 16)}, 1, 1, 0);\n")
            f.write(f"  endfunction\n")
            f.write(f"endclass\n\n")
            
        # Memory Classes
        for m in mems:
            f.write(f"class {m['name']} extends uvm_mem;\n")
            f.write(f"  `uvm_object_utils({m['name']})\n")
            f.write(f"  function new(string name = \"{m['name']}\");\n")
            f.write(f"    super.new(name, {m['size']}, {m['width']}, \"{m['access']}\");\n")
            f.write(f"  endfunction\n")
            f.write(f"endclass\n\n")
            
        # Register Block Class
        f.write(f"class yapp_router_regs_t extends uvm_reg_block;\n")
        f.write(f"  `uvm_object_utils(yapp_router_regs_t)\n")
        for r in regs: f.write(f"  rand {r['name']} {r['name']}_inst;\n")
        for m in mems: f.write(f"  rand {m['name']} {m['name']}_inst;\n")
        
        f.write(f"  uvm_reg_map router;\n")
        f.write(f"  uvm_reg_map router_yapp_regs;\n")
        
        f.write(f"  function new(string name = \"yapp_router_regs_t\");\n")
        f.write(f"    super.new(name, UVM_NO_COVERAGE);\n")
        f.write(f"  endfunction\n")
        f.write(f"  virtual function void build();\n")
        
        for r in regs:
            f.write(f"    {r['name']}_inst = {r['name']}::type_id::create(\"{r['name']}_inst\");\n")
            f.write(f"    {r['name']}_inst.configure(this, null, \"\");\n")
            f.write(f"    {r['name']}_inst.build();\n")
        for m in mems:
            f.write(f"    {m['name']}_inst = {m['name']}::type_id::create(\"{m['name']}_inst\");\n")
            f.write(f"    {m['name']}_inst.configure(this);\n")
            
        f.write(f"    router = create_map(\"router\", 'h1100, 1, UVM_LITTLE_ENDIAN);\n")
        f.write(f"    router_yapp_regs = create_map(\"router_yapp_regs\", 'h1000, 1, UVM_LITTLE_ENDIAN);\n")
        
        for r in regs:
            f.write(f"    router_yapp_regs.add_reg({r['name']}_inst, {r['offset']}, \"{r['access']}\");\n")
        for m in mems:
            if m['name'] == 'yapp_mem':
                f.write(f"    router.add_mem({m['name']}_inst, {m['base']}, \"{m['access']}\");\n")
            else:
                f.write(f"    router_yapp_regs.add_mem({m['name']}_inst, {m['base']}, \"{m['access']}\");\n")
                
        f.write(f"  endfunction\n")
        f.write(f"endclass\n")
    print("Generated: yapp_router_regs_rdb.sv")

    # 2. Generate cdns_uvmreg_utils_pkg.sv (WITH PACKAGE WRAPPER)
    with open('cdns_uvmreg_utils_pkg.sv', 'w') as f:
        f.write("`include \"uvm_macros.svh\"\n")
        f.write("import uvm_pkg::*;\n\n")
        f.write("package cdns_uvmreg_utils_pkg;\n")
        f.write("  `include \"yapp_router_regs_rdb.sv\"\n")
        f.write("endpackage\n")
    print("Generated: cdns_uvmreg_utils_pkg.sv")

    # 3. Generate quicktest.sv
    with open('quicktest.sv', 'w') as f:
        f.write("`include \"uvm_macros.svh\"\n")
        f.write("import uvm_pkg::*;\n")
        f.write("import cdns_uvmreg_utils_pkg::*;\n\n")
        f.write("class qt_test extends uvm_test;\n")
        f.write("  `uvm_component_utils(qt_test)\n")
        f.write("  yapp_router_regs_t model;\n")
        f.write("  function new(string name, uvm_component parent);\n")
        f.write("    super.new(name, parent);\n")
        f.write("  endfunction\n")
        f.write("  virtual function void build_phase(uvm_phase phase);\n")
        f.write("    super.build_phase(phase);\n")
        f.write("    model = yapp_router_regs_t::type_id::create(\"model\", this);\n")
        f.write("    model.build();\n")
        f.write("    model.lock_model();\n")
        f.write("  endfunction\n")
        f.write("  virtual task run_phase(uvm_phase phase);\n")
        f.write("    phase.raise_objection(this);\n")
        f.write("    `uvm_info(\"QT_TEST\", \"Starting Register Reset Test\", UVM_LOW)\n")
        f.write("    model.reset();\n")
        f.write("    model.print(uvm_default_tree_printer);\n")
        f.write("    model.router_yapp_regs.print();\n")
        f.write("    `uvm_info(\"QT_TEST\", \"Register Reset Test Complete\", UVM_LOW)\n")
        f.write("    phase.drop_objection(this);\n")
        f.write("  endtask\n")
        f.write("endclass\n")
    print("Generated: quicktest.sv")

if __name__ == "__main__":
    generate()