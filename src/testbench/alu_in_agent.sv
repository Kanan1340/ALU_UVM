
class alu_in_agent extends uvm_agent;

`uvm_component_utils(alu_in_agent)

alu_driver drv;
alu_seqr sqr;
alu_in_monitor mon;
alu_config cfg;

function new(string name="alu_in_agent", uvm_component parent=null);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(alu_config)::get(this,"","alu_config",cfg))
		`uvm_fatal(get_type_name(),"Input agent can not access VI")
	mon = alu_in_monitor::type_id::create("mon",this);
	if(cfg.input_agent_is_active==UVM_ACTIVE)begin
		drv = alu_driver::type_id::create("drv",this);
		sqr = alu_seqr::type_id::create("sqr",this);
	end	
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(cfg.input_agent_is_active==UVM_ACTIVE)begin
		drv.seq_item_port.connect(sqr.seq_item_export);
	end
endfunction 

endclass

