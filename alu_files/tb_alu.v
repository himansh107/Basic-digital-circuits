`timescale 1us/1ns

module tb_alu();
	
	parameter BUS_WIDTH = 8;
	reg [3:0] opcode;
	reg [BUS_WIDTH-1:0] a,b;
	reg carry_in;
	wire [BUS_WIDTH-1:0] y;
	wire carry_out;
	wire borrow;
	wire zero;
	wire parity;
	wire invalid_op;
	
	
	localparam OP_ADD = 1;
	localparam OP_ADD_CARRY = 2;
	localparam OP_SUB = 3;
	localparam OP_INC = 4;
	localparam OP_DEC = 5;
	localparam OP_AND = 6;
	localparam OP_NOT = 7;
	localparam OP_ROL = 8;
	localparam OP_ROR = 9;
	integer success_count = 0, error_count = 0, test_count = 0, i = 0;
	
	
	alu
	
		#(.BUS_WIDTH(BUS_WIDTH))
		
	alu0 (
		.a(a),
		.b(b),
		.carry_in(carry_in),
		.opcode(opcode),
		.y(y),
		.carry_out(carry_out),
		.borrow(borrow),
		.zero(zero),
		.parity(parity),
		.invalid_op(invalid_op)
	);
	
	function [BUS_WIDTH+4 : 0] model_ALU(input [3:0] opcode,
		input [BUS_WIDTH-1:0] a,
		input [BUS_WIDTH-1:0] b,
		input carry_in);
		
		reg [BUS_WIDTH-1:0] y;
		reg carry_out;
		reg borrow;
		reg zero;
		reg parity;
		reg invalid_op;
  
	begin
		y =0; carry_out = 0; borrow = 0; invalid_op = 0;
		
		case(opcode)
			OP_ADD : begin {carry_out, y} = a+b; end
			OP_ADD_CARRY : begin {carry_out,y} = a+b+carry_in; end
			OP_SUB : begin {borrow, y} = a-b; end
			OP_INC : begin {carry_out,y} = a - 1'b1; end
			OP_DEC : begin {borrow,y} = a-1'b1; end
			OP_AND :  begin y = a & b; end
			OP_NOT : begin y = ~a; end
			OP_ROL : begin y = {a[BUS_WIDTH-2:0], a[BUS_WIDTH-1]}; end
			OP_ROR : begin y = {a[0], a[BUS_WIDTH-1:1]}; end
			default : begin invalid_op = 1; end
		endcase
	
	parity = ^y;
	zero = {y ==0};
	model_ALU = {invalid_op, parity, zero , borrow, carry_out, y};
end

endfunction

task compare_data (input [BUS_WIDTH+4 :0] expected_ALU,input [BUS_WIDTH+4:0] observed_ALU);
	
	begin	
		if (expected_ALU === observed_ALU) begin // use case equality opearator
				$display($time, " SUCCESS \t EXPECTED invalid_op=%0d, parity=%b, zero=%b, borrow=%b, carry_out=%b, y=%b", 
				                  expected_ALU[BUS_WIDTH+4], expected_ALU[BUS_WIDTH+3], expected_ALU[BUS_WIDTH+2],
								  expected_ALU[BUS_WIDTH+1], expected_ALU[BUS_WIDTH], expected_ALU[BUS_WIDTH-1:0]);
				$display($time, "         \t OBSERVED invalid_op=%0d, parity=%b, zero=%b, borrow=%b, carry_out=%b, y=%b", 
				                  observed_ALU[BUS_WIDTH+4], observed_ALU[BUS_WIDTH+3], observed_ALU[BUS_WIDTH+2],
								  observed_ALU[BUS_WIDTH+1], observed_ALU[BUS_WIDTH], observed_ALU[BUS_WIDTH-1:0]);
                success_count = success_count + 1;				
            end else begin
                $display($time, " ERROR \t EXPECTED invalid_op=%0d, parity=%b, zero=%b, borrow=%b, carry_out=%b, y=%b", 
				                  expected_ALU[BUS_WIDTH+4], expected_ALU[BUS_WIDTH+3], expected_ALU[BUS_WIDTH+2],
								  expected_ALU[BUS_WIDTH+1], expected_ALU[BUS_WIDTH], expected_ALU[BUS_WIDTH-1:0]);
				$display($time, "       \t OBSERVED invalid_op=%0d, parity=%b, zero=%b, borrow=%b, carry_out=%b, y=%b", 
				                  observed_ALU[BUS_WIDTH+4], observed_ALU[BUS_WIDTH+3], observed_ALU[BUS_WIDTH+2],
								  observed_ALU[BUS_WIDTH+1], observed_ALU[BUS_WIDTH], observed_ALU[BUS_WIDTH-1:0]);				
			    error_count = error_count + 1;
            end
            test_count = test_count + 1;			
		end
endtask


initial begin	
	
	for(i=0; i < 100 ; i=i+1) begin	
		opcode = $random % 10'd11;
		a = $random;
		b = $random;
		carry_in = $random;
		
		#1;
		$display($time, "TEST%0d opcode = %0d, a= %0d, b= %0d, carry_in = %0b", i,opcode,a,b,carry_in);
		compare_data(model_ALU(opcode,a,b,carry_in), {invalid_op, parity,zero,borrow,carry_out,y});
		#2;
	end

		$display($time, "TEST RESULTS success_count = %0d, error_count = %0d, test_count = %0d",
						success_count, error_count, test_count);
			#40; $stop;
	end
endmodule	
		