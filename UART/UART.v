module UART(
	input uart_rx,
	input sysclk,
	input reset,
	input [7:0] Int3,
	input OutputReady,
	output uart_tx,
	output [7:0] Int1,
	output [7:0] Int2,
	output InputReady,
	output Occupied
	);

	wire [7:0] rx_data;
	wire rx_status;
	wire [7:0] tx_data;
	wire tx_en;
	wire tx_status;
	wire bdclk;
	
	receiver receiver1(uart_rx, sysclk, bdclk, reset, rx_status, rx_data);
	generator generator1(sysclk, reset, bdclk);
	sender sender1(tx_data, tx_en, bdclk, sysclk, reset, tx_status, uart_tx);
	controller controller1(rx_data, rx_status, sysclk, tx_status, reset, Int3, OutputReady,
		tx_data, tx_en, Int1, Int2, InputReady, Occupied);

endmodule
	