`timescale 1us/1ns

module tb_fifo_sync();

	parameter FIFO_DEPTH = 8;
	parameter DATA_WIDTH = 32;
	reg clk = 0;
	reg rst_n;
	reg cs;
	reg wr_en;
	reg rd_en;
	reg [DATA_WIDTH- 1:0] data_in;
	reg [DATA_WIDTH-1:0] data_out;
	wire empty;
	wire full;
	
	integer i;

	fifo_sync
		#(.FIFO_DEPTH(FIFO_DEPTH),
		   .DATA_WIDTH(DATA_WIDTH))  
		FIFO0
		( .clk(clk),
		  .rst_n(rst_n),
		  .cs(cs),
		  .wr_en(wr_en),
		  .rd_en(rd_en),
		  .data_in(data_in),
		  .data_out(data_out),
		  .empty(empty),
		  .full(full));
			
			

task write_data (input [DATA_WIDTH-1:0] d_in);
	begin
		@(posedge clk);
			cs = 1; wr_en = 1;
			data_in = d_in;
			$display($time, "write_data data_in = %0d", data_in);
			@(posedge clk);
				cs = 1; wr_en = 0;
			end
endtask


task read_data();
	begin	
		@(posedge clk);
		cs = 1; rd_en = 1;
		@(posedge clk);
		#0.1;
		$display($time, " read_data data_out = %0d", data_out);
		cs =  1; rd_en = 0;
	end
endtask

	always begin #0.5 clk = ~clk; end
	
	initial begin
		#1;
		rst_n =0 ; rd_en = 0; wr_en = 0;

		#1.3;
		rst_n = 1;
		$display($time, "\n SCENARIO 1");
		write_data(1);
		write_data(10);
		write_data(100);
		read_data();
		read_data();
		read_data();
		read_data();
		
		$display($time, " \n SCENARIO 2");
		for(i=0; i<FIFO_DEPTH; i = i+1) begin
			write_data(2**i);
			read_data();
		end
		
		$display($time, "\n SCENARIO 3");
		for(i =0; i < FIFO_DEPTH; i = i+1) begin	
			write_data(2**i);
		end
		
		for(i =0; i < FIFO_DEPTH; i = i+1) begin
			read_data();
		end
		
		#40 $stop;
	end
endmodule
