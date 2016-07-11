`timescale 10ns/10ns
module test_cpu();
    
    reg reset = 1;
    reg clk = 1;
    reg [7:0] Switch = 0;
    reg uart_rx = 1;
    wire uart_tx;
    
    CPU cpu1(reset, clk, Switch, uart_rx, uart_tx, LED, DigiOut1, DigiOut2, DigiOut3, DigiOut4);

always begin
    while(1) #1 clk <= ~clk;
end

initial begin 
    #2 reset = 0;
    #2 reset = 1;

// send 10110101 B5
    #30000 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 1;

    // send 00001010 0A
    #30000 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;

    // send 00001000 08
    #30000 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;

    // send 00001100 0C
    #30000 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;

    // send 00001010 0A
    #30000 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;

    // send 00001000 08
    #30000 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;

    // send 00000001 01
    #30000 uart_rx = 0;
    #10417 uart_rx = 1;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 0;
    #10417 uart_rx = 1;
end
        
endmodule
