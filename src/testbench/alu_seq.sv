
class alu_seq extends uvm_sequence #(alu_seq_item);
	`uvm_object_utils(alu_seq)
	
	function new(string name = "alu_seq");
		super.new(name);
	endfunction 

	task body();
		req=alu_seq_item::type_id::create("req");
		start_item(req);
		assert(req.randomize() with {soft mode==1'b1;cmd==4'b0000;OA=='d3;OB=='d3;inp_valid==2'd3;});
		finish_item(req);		
	endtask
endclass

class arithmetic_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(arithmetic_seq)

  function new(string name="arithmetic_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0; i<11; i++)begin 
    	req = alu_seq_item::type_id::create("req");
    	start_item(req);
    	assert(req.randomize() with {mode==1;cmd==i;inp_valid==2'd3;});
    	finish_item(req);
    end
  endtask
endclass

class logical_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(logical_seq)

  function new(string name="logical_seq");
    super.new(name);
  endfunction

  task body();
    for(int i=0; i<14; i++)begin 
    	req = alu_seq_item::type_id::create("req");
    	start_item(req);
    	assert(req.randomize() with {mode==0;cmd==i;inp_valid==2'd3;});
    	finish_item(req);
    end
  endtask
endclass

