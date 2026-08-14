
class alu_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(alu_scoreboard)

  // Analysis_fifo
  uvm_tlm_analysis_fifo #(alu_seq_item) inp_fifo;
  uvm_tlm_analysis_fifo #(alu_seq_item) out_fifo;

  // Transactions
  alu_seq_item inp_tr;
  alu_seq_item out_tr;
  alu_seq_item exp_tr;

  int match;
  int mismatch;

  bit [`DW-1:0] oprd1;
  bit [`DW-1:0] oprd2;
  bit [`CW-1:0] cmd_tmp;
  int wait_cnt;
  bit got_opa;
  bit got_opb;
  bit [`DW-1:0] opa_tmp;
  bit [`DW-1:0] opb_tmp;

  function new(string name="alu_scoreboard",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    inp_fifo = new("inp_fifo",this);
    out_fifo = new("out_fifo",this);
  endfunction

  task run_phase(uvm_phase phase);
	forever begin
	   inp_tr = alu_seq_item::type_id::create("inp_tr");
	   exp_tr = alu_seq_item::type_id::create("exp_tr");
	   out_tr = alu_seq_item::type_id::create("out_tr");
 	   inp_fifo.get(inp_tr);
	   exp_tr.copy(inp_tr);
	   //$cast(exp_tr, inp_tr.clone());
	   ref_model(exp_tr);
	   out_fifo.get(out_tr);
	   validate_output();
	end
  endtask

  virtual task validate_output();
 	if(!exp_tr.rst && exp_tr.compare(out_tr))begin
 	   match++;
	   `uvm_info(get_type_name(),"COMPARE PASSED",UVM_LOW);
 	end
 	else begin
	   mismatch++;
	   `uvm_error(get_type_name(),$sformatf("\nEXPECTED %s \nACTUAL %s",exp_tr.sprint(), out_tr.sprint()));
 	end
  endtask

  virtual task ref_model(alu_seq_item t);

     if(t.rst) begin
        oprd1='0;
        oprd2='0;
        cmd_tmp='0;
	wait_cnt='0;
	got_opa='0;
	got_opb='0;
	opa_tmp='0;
	opb_tmp='0;
     end
     else if (t.inp_valid==2'b01) begin    
        oprd1=t.OA;
        cmd_tmp=t.cmd;
      end
     else if (t.inp_valid==2'b10)  begin    
        oprd2=t.OB;
        cmd_tmp=t.cmd;
      end
      else if (t.inp_valid==2'b11)  begin    
        oprd1=t.OA;
	oprd2=t.OB;
        cmd_tmp=t.cmd;
      end
      else begin    
        oprd1=0;
        oprd2=0;
        cmd_tmp=0;
	if(got_opa ^ got_opb)begin
	   if(wait_cnt<16)
		wait_cnt = wait_cnt + 1;
	   else if(wait_cnt==16) begin
		t.err = 1;
		wait_cnt = 0;
	   end
	end
      end 

     if(t.ce) begin
         if(t.rst) begin
            t.res='0;
            t.cout='0;
            t.oflow='0;
            t.G='0;
            t.E='0;
            t.L='0;
            t.err='0;
	    wait_cnt='0;
	    got_opa='0;
	    got_opb='0;
	  end
 
          else if(t.mode) begin
	  case(cmd_tmp)             
    	     4'b0000: begin             
              	{t.cout,t.res} = oprd1 + oprd2;
             end
	     4'b0001 :begin
             	t.oflow= (oprd1 < oprd2);
             	t.res=oprd1-oprd2;
             end
     	     4'b0010 :begin
               	{t.cout,t.res} = oprd1 + oprd2 + t.cin;            	
             end
	     4'b0011 :begin
            	t.oflow= oprd1 < (oprd2+t.cin);
            	t.res=oprd1 - oprd2 - t.cin;
             end
     	     4'b0100 :t.res=oprd1+1;     
     	     4'b0101 :t.res=oprd1-1;    
     	     4'b0110 :t.res=oprd2+1;     
     	     4'b0111 :t.res=oprd2-1; 
     	     4'b1000 :begin
            	t.res='0;
            	if(oprd1==oprd2) begin
               	   t.E=1'b1;
               	   t.G=1'b0;
               	   t.L=1'b0;
             	end
            	else if(oprd1>oprd2) begin
               	   t.E=1'b0;
               	   t.G=1'b1;
              	   t.L=1'b0;
             	end
                else begin
                   t.E=1'b0;
               	   t.G=1'b0;
               	   t.L=1'b1;
                end
             end
	     4'b1001: begin   
                   opa_tmp = oprd1 + 1;
                   opb_tmp = oprd2 + 1;
                   t.res = opa_tmp * opb_tmp;
             end
	     4'b1010: begin   
                   opa_tmp = oprd1 << 1;
                   opb_tmp = oprd2;
                   t.res = opa_tmp * opb_tmp; 
             end

	     default :begin
             t.res='0;
             t.cout=1'b0;
             t.oflow=1'b0;
             t.G=1'b0;
             t.E=1'b0;
             t.L=1'b0;
             t.err=1'b0;
             end
          endcase
        end

	else begin 
	case(cmd_tmp)    
             4'b0000:t.res={1'b0,oprd1&oprd2};     
             4'b0001:t.res={1'b0,~(oprd1&oprd2)};
	     4'b0010:t.res={1'b0,oprd1|oprd2};  
 	     4'b0011:t.res={1'b0,~(oprd1|oprd2)};
	     4'b0100:t.res={1'b0,oprd1^oprd2};     
             4'b0101:t.res={1'b0,~(oprd1^oprd2)};  
 	     4'b0110:t.res={1'b0,~oprd1};       
             4'b0111:t.res={1'b0,~oprd2};        
	     4'b1000:t.res={1'b0,oprd1>>1};       
             4'b1001:t.res={1'b0,oprd1<<1};
	     4'b1010:t.res={1'b0,oprd2>>1};      
             4'b1011:t.res={1'b0,oprd2<<1};      
	     4'b1100:begin 
		if(oprd2[7:4]!=0)
		     t.err = 1'b1;
		else 
		     t.res = (oprd1 << oprd2) | (oprd1 >> (`DW-oprd2));;
	     end
	     4'b1101:begin                      
                if(oprd2[7:4]!=0)
		     t.err = 1'b1;
		else 
		     t.res = (oprd1 >> oprd2) | (oprd1 << (`DW-oprd2));
	     end
             default:begin
               t.res='0;
               t.cout=1'b0;
               t.oflow=1'b0;
               t.G=1'b0;
               t.E=1'b0;
               t.L=1'b0;
               t.err=1'b0;
             end
          endcase
     	  end
    end
  endtask


  function void report_phase(uvm_phase phase);
	
	`uvm_info(get_type_name(),$sformatf("MATCH=%0d MISMATCH=%0d", match, mismatch), UVM_NONE);

  endfunction

endclass

