module sender(
	input [7:0] tx_data,
	input tx_en,
	input bdclk,
	input sysclk,
	input reset,
	output tx_status_out,
	output reg uart_tx = 1
	);
	
	reg [3:0] num = 0;
	reg [4:0] status = 0;
	reg tx_status = 1;

	assign tx_status_out = (tx_status && num == 4'b0000)? 1'b1: 1'b0;
	
	always @(posedge sysclk or negedge reset)
	begin
		if(~reset)	tx_status <= 1;
		else 
		begin 
			if(tx_en) tx_status <= 0;
			else if(num == 4'd10) tx_status <= 1;
		end
	end
	
	always @(posedge bdclk or negedge reset)
	begin
		if(~reset)
		begin
			uart_tx <= 1;
			status <= 0;
			num <= 0;
		end
		else
		begin
			if(~tx_status)
			begin
				if(status == 5'd15)
				begin
					case(num)
					0:uart_tx <= 0;
					1:uart_tx <= tx_data[0];
					2:uart_tx <= tx_data[1];
					3:uart_tx <= tx_data[2];
					4:uart_tx <= tx_data[3];
					5:uart_tx <= tx_data[4];
					6:uart_tx <= tx_data[5];
					7:uart_tx <= tx_data[6];
					8:uart_tx <= tx_data[7];
					9:uart_tx <= 1;
					default:begin num <= 0; uart_tx <= 1; end
					endcase
					num <= num + 4'd1;
					status <= 0;
				end
				else status <= status + 5'd1;
			end
			else
			  if(num == 4'd10) begin num <= 0; uart_tx <= 1; end
		end
	end
	
endmodule
					