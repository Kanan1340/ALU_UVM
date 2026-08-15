
class alu_seq_item extends uvm_sequence_item;
  rand bit [`DW-1:0] OA;
  rand bit [`DW-1:0] OB;
  rand bit [1:0] inp_valid;
  rand bit [`CW-1:0] cmd;
  rand bit mode;
  rand bit ce;
  rand bit cin;
  bit [`DW*2-1:0] res;
  bit rst,err,oflow,cout,G,E,L;

	`uvm_object_utils_begin(alu_seq_item)
		`uvm_field_int(rst,UVM_ALL_ON)
		`uvm_field_int(OA,UVM_ALL_ON)
		`uvm_field_int(OB,UVM_ALL_ON)
		`uvm_field_int(inp_valid,UVM_ALL_ON)
		`uvm_field_int(cmd,UVM_ALL_ON)
		`uvm_field_int(mode,UVM_ALL_ON)
		`uvm_field_int(cin,UVM_ALL_ON)
		`uvm_field_int(ce,UVM_ALL_ON)
		`uvm_field_int(res,UVM_ALL_ON)
		`uvm_field_int(err,UVM_ALL_ON)
		`uvm_field_int(oflow,UVM_ALL_ON)
		`uvm_field_int(cout,UVM_ALL_ON)
		`uvm_field_int(G,UVM_ALL_ON)
		`uvm_field_int(E,UVM_ALL_ON)
		`uvm_field_int(L,UVM_ALL_ON)
	`uvm_object_utils_end
 
  constraint ce_c {
    ce dist {1:=9, 0:=1};
  }

  constraint mode_c {
    mode dist {1:=1, 0:=1};
  }

  constraint inp_valid_c {
    inp_valid dist {
      2'b11 := 60,
      2'b01 := 15,
      2'b10 := 15,
      2'b00 := 10
    };
  }

  constraint cmd_c {
    if(mode)
      cmd inside {[4'd0:4'd10]};
    else
      cmd inside {[4'd0:4'd13]};
  }

  constraint cin_c {
    if(mode && (cmd inside {4'd2,4'd3}))
      cin dist {0:=1,1:=1};
    else
      cin == 0;
  }

 function new(string name="alu_seq_item");
	super.new(name);
 endfunction
endclass 

