`timescale 1us/1ns

	module tb_semaphore_fsm();
	
	reg clk = 0;
	reg rst_n;
	reg enable;
	wire yellow;
	wire green;
	wire [3:0] state_out;

	parameter [3:0] OFF = 4'b0001,
					RED = 4'b0010,
					YELLOW  = 4'b0101,
					YELLOW_RED = 4'b0011,
					GREEN = 4'b0100;

	semaphore_fsm SEM0(
			.clk(clk),
			.rst_n(rst_n),
			.enable(enable),
			.red(red),
			.yellow(yellow),
			.green(green),
			.state_out(state_out)
		);
		
		initial begin	
			forever begin 
				#1; clk = ~clk;
			end
		end
		
	initial begin 
		$monitor ($time, "enable = %b, red =%b, yellow = %b, green = %b", enable, red, yellow, green);
	
	rst_n = 0; #2.5; rst_n = 1;
	enable = 0;
	repeat(10) @(posedge clk);
	enable = 1;
	
	repeat(2) begin	
		wait (state_out === GREEN);
		@(state_out);
	end
	
	wait(state_out === YELLOW_RED);
	@(posedge clk); enable = 0;
		
	repeat(10) @(posedge clk);
	@(posedge clk); enable = 1;
	
	#40 $stop;
	end
endmodule