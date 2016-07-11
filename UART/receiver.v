module receiver(
	input uart_rx,
	input sysclk,
	input bdclk,
	input reset,
	output reg rx_status,
	output reg [7:0] rx_data
);
	reg [4:0] status = 0;
	reg [7:0] memory = 0;
	reg start = 0;
	reg [3:0] num = 0;
	always @ (posedge bdclk or negedge reset)
	begin
		if(~reset) 
		begin
			num <= 0;
			start <= 0;
			status <= 0;
			memory <= 0;
		end
		else
		begin
			if(~(uart_rx|start)) begin start <= 1; status <= 0; end
			else if(rx_status) begin start <= 0; num <= 0; end
			else if(start)
			begin
				if(num == 0)
				begin
					if(status == 5'd23) begin num <= 1; memory[0] = uart_rx; status <= 0;end
					else status <= status + 5'd1;
				end
				else
				begin
					if(status == 5'd15)
					begin
						case(num)
						1:memory[1] = uart_rx;
						2:memory[2] = uart_rx;
						3:memory[3] = uart_rx;
						4:memory[4] = uart_rx;
						5:memory[5] = uart_rx;
						6:memory[6] = uart_rx;
						7:memory[7] = uart_rx;
						8:num = num;
						default:num = 0;
						endcase
						num <= num + 4'd1;
						status <= 0;
					end
					else status <= status + 5'd1;
				end
			end
		end
	end
	
	always @ (posedge sysclk or negedge reset)
	begin
		if(~reset) 
		begin
			rx_data <= 0;
			rx_status <= 0;
		end
		else
		begin
			if(num == 4'd9)
			begin
				rx_data <= memory;
				rx_status <= 1'b1;
			end
			else rx_status <= 1'b0;
		end
	end
endmodule
	
	