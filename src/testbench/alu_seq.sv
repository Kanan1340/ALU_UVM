
class alu_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_seq)

  function new(string name="alu_seq");
    super.new(name);
  endfunction

  task send(bit[1:0] inp_valid=2'b11,
            bit ce=1,
            bit mode=1,
            bit[3:0] cmd=0,
            bit cin=0,
            bit[7:4] ob_msb=0);

    req=alu_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {
      this.inp_valid==local::inp_valid;
      this.ce==local::ce;
      this.mode==local::mode;
      this.cmd==local::cmd;
      this.cin==local::cin;
      this.OB[7:4]==local::ob_msb;
    });
    finish_item(req);
  endtask

  task body();
  endtask

endclass
//////////////

class reset_seq extends alu_seq;
  `uvm_object_utils(reset_seq)

  function new(string name="reset_seq");
    super.new(name);
  endfunction

  task body();
    send(2'b00,0);
    repeat(3)
      send(2'b00,0);
    send();
    send(2'b11,1,1,2,1);
  endtask

endclass
//////////////

class arithmetic_seq extends alu_seq;
  `uvm_object_utils(arithmetic_seq)

  function new(string name="arithmetic_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0;i<11;i++) begin
      if(i==2 || i==3)
        send(2'b11,1,1,i,1);
      else
        send(2'b11,1,1,i);
    end
  endtask

endclass
/////////////////

class logical_seq extends alu_seq;
  `uvm_object_utils(logical_seq)

  function new(string name="logical_seq");
    super.new(name);
  endfunction

  task body();

    for(int i=0;i<12;i++)
      send(2'b11,1,0,i);

    send(2'b11,1,0,12,0,4'hF);
    send(2'b11,1,0,13,0,4'hF);

  endtask

endclass

////////////////

class random_seq extends alu_seq;
  `uvm_object_utils(random_seq)

  function new(string name="random_seq");
    super.new(name);
  endfunction

  task body();
    repeat(50) begin
      req=alu_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      finish_item(req);
    end
  endtask

endclass
///////////////

class regression_seq extends alu_seq;
  `uvm_object_utils(regression_seq)

  reset_seq r;
  arithmetic_seq a;
  logical_seq l;
  random_seq rd;

  function new(string name="regression_seq");
    super.new(name);
  endfunction

  task body();
    r=reset_seq::type_id::create("r");
    a=arithmetic_seq::type_id::create("a");
    l=logical_seq::type_id::create("l");
    rd=random_seq::type_id::create("rd");

    r.start(m_sequencer);
    a.start(m_sequencer);
    l.start(m_sequencer);
    rd.start(m_sequencer);
  endtask

endclass

