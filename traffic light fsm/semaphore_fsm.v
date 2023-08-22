module semaphore_fsm (
	input clk,
	input rst_n,
	input enable,
	output reg red,
	output reg yellow,
	output reg green,
	output [3:0] state_out
);

	parameter [3:0] OFF  = 4'b0001,
					RED = 4'b0010,
					YELLOW_RED = 4'b0011,
					YELLOW = 4'b0101,
					GREEN = 4'b0100;
					
				
		reg [3:0] state;
		reg [3:0] next_state;
		reg [5:0] timer ;
		reg timer_clear;
		
		
		always @(*) begin
			next_state = OFF;
			red = 0;
			yellow = 0;
			green = 0;
			timer_clear = 0;
			
			case(state)
					OFF  : begin 
								if(enable) next_state = RED;
								end 
					RED : begin 
								red = 1;
									if(timer == 6'd50)  begin	
										next_state  = YELLOW_RED;
										timer_clear = 1;
									end else begin	
										next_state = RED;
									end
								end
					YELLOW_RED : begin 
								red = 1;
								yellow = 1;
								if(timer == 6'd10) begin	
									next_state = GREEN;
									timer_clear = 1;
								end else begin	
									next_state = YELLOW_RED;
								end
							end
							
					GREEN : begin 
							 green = 1;
							 if(timer == 6'd30) begin	
								next_state = YELLOW;
								timer_clear = 1;
							end else begin	
								next_state = GREEN;
							end
						end
						
					YELLOW : begin 
							 yellow = 1;
							 if(timer == 6'd10) begin	
								next_state = RED;
								timer_clear = 1;
							end else begin	
								next_state = YELLOW;
							end
						end
						
				default : next_state = OFF;
			endcase
			
		if(!enable) begin	next_state = OFF;
		end
	end
	
	always @(posedge clk or negedge rst_n) begin	
		if(!rst_n) 
			state <=OFF;
		else	
			state <= next_state;
		end
		
		assign state_out = state;
		
	always @(posedge clk or negedge rst_n) begin
		 if(!rst_n)
			timer <= 0;
		else if ((timer_clear == 1) || (!enable))
			timer <= 0;
		else if (state != OFF)
			timer <= timer + 1'b1;
	end
endmodule