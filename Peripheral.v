`timescale 1ns/1ps
module Peripheral (reset,clk,rd,wr,addr,wdata, Int1, Int2, InputReady, Occupied,
    rdata,led,switch,digi,irqout, Int3, OutputReady);
input reset,clk;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
input [7:0] Int1;
input [7:0] Int2;
input InputReady;
input Occupied;

output reg [31:0] rdata;
output reg [7:0] led;
input [7:0] switch;
output reg [11:0] digi;
output irqout;
output [7:0] Int3;
output OutputReady;


reg [31:0] TH,TL;
reg [2:0] TCON;
assign irqout = TCON[2];

reg [7:0] DATA1, DATA2, DATA3;
reg [1:0] UARTCON;
assign OutputReady = UARTCON[1];
assign Int3 = DATA3;

always@(*) begin
    if(rd) begin
        case(addr)
            32'h40000000: rdata <= TH;            
            32'h40000004: rdata <= TL;            
            32'h40000008: rdata <= {29'b0,TCON};                
            32'h4000000C: rdata <= {24'b0,led};            
            32'h40000010: rdata <= {24'b0,switch};
            32'h40000014: rdata <= {20'b0,digi};

            32'h40000018: rdata <= {24'b0,DATA1}; 
            32'h4000001c: rdata <= {24'b0,DATA2}; 
            32'h40000020: rdata <= {24'b0,DATA3}; 
            32'h40000024: rdata <= {29'b0,Occupied,UARTCON};
            default: rdata <= 32'b0;
        endcase
    end
    else
        rdata <= 32'b0;
end

always@(negedge reset or negedge clk) begin
    if(~reset) begin
        TH <= 32'b0;
        TL <= 32'b0;
        TCON <= 3'b0;
        DATA1 <= 8'd0;
        DATA2 <= 8'd0;
        DATA3 <= 8'b0;
        UARTCON <= 2'b0;
        led <= 8'b0;
        digi <= 12'b0;
    end
    else begin
        if(TCON[0]) begin    //timer is enabled
            if(TL==32'hffffffff) begin
                TL <= TH;
                if(TCON[1]) begin 
                    TCON[2] <= 1'b1;        //irq is enabled
                end
            end
            else TL <= TL + 1;
        end

        if(InputReady) begin
            DATA1 <= Int1;
            DATA2 <= Int2;
            UARTCON[0] <= 1;
        end

        if(UARTCON[1]) begin
            UARTCON[1] <= 0;
        end
        
        if(wr) begin
            case(addr)
                32'h40000000: TH <= wdata;
                32'h40000004: TL <= wdata;
                32'h40000008: TCON <= wdata[2:0];        
                32'h4000000C: led <= wdata[7:0];            
                32'h40000014: digi <= wdata[11:0];
                32'h40000018: DATA1 <= wdata[7:0];
                32'h4000001c: DATA2 <= wdata[7:0];
                32'h40000020: DATA3 <= wdata[7:0];
                32'h40000024: UARTCON <= wdata[1:0];
                default: ;
            endcase
        end
    end
end
endmodule

