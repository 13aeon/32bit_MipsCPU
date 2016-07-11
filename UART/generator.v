module generator(
	input sysclk,
	input reset,
	output reg bdclk = 0
	);
	
	reg [7:0] status = 0;

	always @(posedge sysclk or negedge reset)
	begin
		if(~reset)
		begin
			bdclk <= 0;
			status <= 0;
		end
		else
		begin
			if(status == 8'd163) begin bdclk <= ~bdclk; status <= 0; end
			else status <= status + 8'd1;
		end
	end
	
endmodule
