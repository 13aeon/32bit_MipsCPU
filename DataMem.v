`timescale 1ns/1ps
// altered
module DataMem (reset,clk,rd,wr,addr,wdata,rdata);
input reset,clk;
input rd,wr;
input [31:0] addr;	//Address Must be Word Aligned
output [31:0] rdata;
input [31:0] wdata;

parameter RAM_SIZE = 256;
parameter RAM_SIZE_BIT = 8;

reg [31:0] RAMDATA [RAM_SIZE-1:0];

assign rdata= rd? RAMDATA[addr[RAM_SIZE_BIT + 1:2]]:32'b0;

always@(negedge clk) begin
	if (wr) RAMDATA[addr[RAM_SIZE_BIT + 1:2]]<=wdata;
end

endmodule
