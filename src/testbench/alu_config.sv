
class alu_config extends uvm_object;
 `uvm_object_utils(alu_config)

  //virtual interface 
  virtual alu_if vif;
  //agent status 
  uvm_active_passive_enum input_agent_is_active;
  uvm_active_passive_enum output_agent_is_passive;

  function new(string name="alu_config");
	super.new(name);
	input_agent_is_active  = UVM_ACTIVE;
	output_agent_is_passive = UVM_PASSIVE;
  endfunction

endclass

