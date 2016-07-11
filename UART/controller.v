module controller(
	input [7:0] rx_data,
	input rx_status, //收到一位
	input sysclk,
	input tx_status, //可以发送
	input reset,
	input [7:0] Int3,
	input OutputReady,
	output reg [7:0] tx_data,
	output tx_en,
	output reg [7:0] Int1,
	output reg [7:0] Int2,
	output InputReady,
	output Occupied
	);

    reg [1:0] rx_cnt;
    reg [1:0] tx_cnt;

    reg [1:0] InputReady_cnt;
    reg [1:0] tx_en_cnt;

    assign InputReady = (InputReady_cnt > 0)? 1'b1: 1'b0;
    assign tx_en = (tx_en_cnt > 0)? 1'b1: 1'b0;
    assign Occupied = (tx_status && tx_cnt == 2'b00)? 1'b0: 1'b1;

    reg pre_rx_status;
	
	always @(posedge sysclk or negedge reset)
	begin
		if(~reset) begin
			tx_data <= 0;
			Int1 <= 8'b0;
			Int2 <= 8'b0;
			rx_cnt <= 2'b00;
			tx_cnt <= 2'b00;
			pre_rx_status <= 0;
			InputReady_cnt <= 0;
			tx_en_cnt <= 0;
		end
		else begin
		    if(InputReady) InputReady_cnt <= InputReady_cnt - 2'd1;
		    else begin
			    if(~pre_rx_status && rx_status) begin
			        if(rx_cnt == 2'b00) begin
			        	if(rx_data == 8'b00001010) rx_cnt <= 2'd1;
			        end
			        else if(rx_cnt == 2'd1) begin
			            Int1[7:0] <= rx_data;
			            rx_cnt <= 2'd2;
			        end
			        else if(rx_cnt == 2'd2) begin
			            Int2[7:0] <= rx_data;
			            rx_cnt <= 2'd0;			    
			            InputReady_cnt <= 2'b11;
			        end
			        else rx_cnt <= 2'd0;
			    end
			end

			pre_rx_status <= rx_status;

			if(tx_en) tx_en_cnt <= tx_en_cnt - 2'b1;
			else begin
			    if(tx_status) begin
			        if(tx_cnt == 2'b00) begin
			        	if(OutputReady) tx_cnt <= 2'd1;
			        end
			        else if(tx_cnt == 2'd1) begin
			            tx_data <= Int3[7:0];
			            tx_cnt <= 2'd2;
			            tx_en_cnt <= 2'b11;
			        end
			        else tx_cnt <= 2'd0;
				end
			end
		end
	end
endmodule
