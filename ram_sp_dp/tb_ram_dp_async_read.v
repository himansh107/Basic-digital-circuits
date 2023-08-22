`timescale 1us/1ns
	module tb_ram_dp_async_read();
	
	localparam WIDTH = 8;
	localparam DEPTH = 16;
	localparam DEPTH_LOG = $clog2(DEPTH);
	
	reg clk;
	reg we_n;
	reg [DEPTH_LOG-1:0] addr_wr;
	reg [DEPTH_LOG-1:0] addr_rd;
	reg [WIDTH-1:0] data_wr;
	wire [WIDTH-1:0] data_rd;
	
	integer i;
	integer num_tests = 0;
	integer test_count = 0;
	integer success_count = 0;
	integer error_count = 0;
	reg [DEPTH_LOG-1:0] rand_addr_wr;
	
	ram_dp_async_read
	
		#( .WIDTH(WIDTH),
		.DEPTH(DEPTH)
		) ram_dual_port0
		
		( .we_n(we_n),
		.clk(clk),
		.addr_wr(addr_wr),
		.addr_rd(addr_rd),
		.data_rd(data_rd),
		.data_wr(data_wr)
			);
			
			initial begin
				clk = 0;
			forever begin	
				#1; clk = ~clk;
			end
		end
		
		initial begin
		#1;
	success_count = 0; error_count = 0; test_count = 0;
	num_tests = DEPTH;
	#1.3;
	
	$display($time, "Test1 start");
	
	for(i = 0; i<num_tests; i=i+1) begin
		data_wr = $random;
		write_data(data_wr, i);
		read_data(i);
		#0.1;
		compare_data(i,data_wr,data_rd);
	end
	
	$display($time, "Test2 start");
	for(i =0 ; i < num_tests; i= i+1) begin	
		rand_addr_wr = $random %DEPTH;
		data_wr = (rand_addr_wr << 4) | ((rand_addr_wr%2) ? 4'hA : 4'h5);
		write_data(data_wr,rand_addr_wr);
		read_data(rand_addr_wr);
		#0.1;
		compare_data(rand_addr_wr,data_wr,data_rd);
	end

$display($time, "TEST RESULTS success_count = %0d, error_count = %0d, test_count = %0d",
			success_count,error_count,test_count);
#40; $stop;			
end


task write_data (input [WIDTH-1:0] data_in, input [DEPTH_LOG-1:0] address_in);
	begin 
		@(posedge clk);
		we_n = 1; data_wr = data_in; addr_wr = address_in;
		@(posedge clk);
		we_n = 0;
	end
endtask

task read_data(input [DEPTH_LOG-1:0] address_in);
	begin 
		addr_rd =address_in;
	end
endtask

	task compare_data(input [DEPTH_LOG-1:0] address,
					  input [WIDTH-1:0] expected_data,
					  input[WIDTH-1:0] observed_data);
					  
		begin	
			if(expected_data === observed_data) begin	
				$display($time, "SUCCESS address = %0d, expected_data = %0x, observed_data = %0x", address, expected_data,observed_data);
				success_count = success_count + 1;
				end else begin
				$display($time, "ERROR address = %0d, expected_data = %0x, observed_data = %0x",address,expected_data,observed_data);
				error_count = error_count + 1;
				end
				test_count = test_count + 1;
			end
		endtask
		
	endmodule