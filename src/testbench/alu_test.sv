
class alu_test extends uvm_test;
	`uvm_component_utils(alu_test)
	alu_env env;
	alu_config cfg;

	function new(string name="alu_test", uvm_component parent= null);
		super.new(name,parent);
	endfunction 
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cfg = alu_config::type_id::create("cfg");

  		if(!uvm_config_db#(virtual alu_if)::get(this,"","alu_if",cfg.vif))
			`uvm_fatal(get_type_name(),"Can't get the interface")
  		cfg.input_agent_is_active=UVM_ACTIVE;
  		cfg.output_agent_is_passive=UVM_PASSIVE;

  		uvm_config_db#(alu_config)::set(this,"*","alu_config",cfg);

		env = alu_env::type_id::create("env",this);
	endfunction 
	
	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction 

endclass

class test_1 extends alu_test;
	`uvm_component_utils(test_1)
	alu_seq s;
	arithmetic_seq s1;
	logical_seq s2;

	function new(string name="test_1", uvm_component parent= null);
		super.new(name,parent);
	endfunction 
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction 
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		s=alu_seq::type_id::create("s");
		s1=arithmetic_seq::type_id::create("s");
		s2=logical_seq::type_id::create("s");

		//fork 
	  	    begin
	       		s.start(env.in_agt.sqr);
	       		#30;
	       		s1.start(env.in_agt.sqr);
			#30;
	       		s2.start(env.in_agt.sqr);
	   		#30;
	  	    end
		//join
		#50;
		phase.drop_objection(this);
	endtask
endclass

