
class alu_env extends uvm_env;

	`uvm_component_utils(alu_env)
	alu_in_agent in_agt;
	alu_out_agent out_agt;
	alu_scoreboard scb;
	alu_config cfg;
	
	function new(string name = "alu_env",uvm_component parent = null);
		super.new(name,parent);
	endfunction 

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(alu_config)::get(this,"","alu_config",cfg))
			`uvm_fatal(get_type_name(),"ENV can not access VI")
		in_agt = alu_in_agent::type_id::create("in_agt",this);
		out_agt = alu_out_agent::type_id::create("out_agt",this);
		scb = alu_scoreboard::type_id::create("scb",this);
	endfunction 

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		in_agt.mon.ap.connect(scb.inp_fifo.analysis_export);		
		out_agt.mon.ap.connect(scb.out_fifo.analysis_export);
	endfunction 

endclass

