
class alu_driver extends uvm_driver #(alu_seq_item);

  `uvm_component_utils(alu_driver)

  virtual alu_if vif;
  alu_config cfg;

  function new(string name = "alu_driver", uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(alu_config)::get(this,"","alu_config",cfg))
      `uvm_fatal(get_type_name(),"Failed to get alu_config")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = cfg.vif;
  endfunction

  task reset_dut();
    vif.drv_cb.rst       <= 1;
    vif.drv_cb.ce        <= 0;
    vif.drv_cb.mode      <= 0;
    vif.drv_cb.cin       <= 0;
    vif.drv_cb.cmd       <= 0;
    vif.drv_cb.inp_valid <= 0;
    vif.drv_cb.OA        <= 0;
    vif.drv_cb.OB        <= 0;

    repeat(3)
    @(vif.drv_cb);
    vif.drv_cb.rst <= 0;
    @(vif.drv_cb);
  endtask

  task drive();
    @(vif.drv_cb);
    vif.drv_cb.ce        <= req.ce;
    vif.drv_cb.mode      <= req.mode;
    vif.drv_cb.cmd       <= req.cmd;
    vif.drv_cb.inp_valid <= req.inp_valid;
    vif.drv_cb.OA        <= req.OA;
    vif.drv_cb.OB        <= req.OB;
    vif.drv_cb.cin       <= req.cin;
  endtask

  task run_phase(uvm_phase phase);
    reset_dut();
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      $display("-------------------------------------------------------------------");
      `uvm_info(" [DRV] ",$sformatf("RST:%0b OA=%0h OB=%0h V=%0b CMD=%0h M=%0b CE=%0b CIN=%0b",req.rst,$unsigned(req.OA),$unsigned(req.OB),req.inp_valid,req.cmd,req.mode,req.ce,req.cin),UVM_LOW)              	
      repeat(3)@(vif.drv_cb);
      seq_item_port.item_done();
    end
  endtask

endclass

