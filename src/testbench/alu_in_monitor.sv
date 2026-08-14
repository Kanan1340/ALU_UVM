
class alu_in_monitor extends uvm_monitor;

  `uvm_component_utils(alu_in_monitor)

  virtual alu_if vif;
  alu_config cfg;
  alu_seq_item tx;
  uvm_analysis_port #(alu_seq_item) ap;

  function new(string name = "alu_in_monitor", uvm_component parent = null);
    super.new(name,parent);
    ap = new("ap",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(alu_config)::get(this,"","alu_config",cfg))
      `uvm_fatal(get_type_name(),"Failed to get alu_config")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(vif.inp_mon_cb);
      tx = alu_seq_item::type_id::create("tx");
      tx.rst       = vif.inp_mon_cb.rst;
      tx.ce        = vif.inp_mon_cb.ce;
      tx.mode      = vif.inp_mon_cb.mode;
      tx.cin       = vif.inp_mon_cb.cin;
      tx.cmd       = vif.inp_mon_cb.cmd;
      tx.inp_valid = vif.inp_mon_cb.inp_valid;
      tx.OA        = vif.inp_mon_cb.OA;
      tx.OB        = vif.inp_mon_cb.OB;
      //if(tx.ce && !tx.rst)
      `uvm_info(get_type_name(),tx.sprint(),UVM_LOW)
      ap.write(tx);
    end
  endtask

endclass

