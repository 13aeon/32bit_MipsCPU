//SHIFT.v
module SHIFT_16(a,alufun,b,res);//a????b????

input [31:0]a;
input [1:0]alufun;
input b;
output [31:0]res;

assign res=(b==1&alufun==2'b00)?{a[15:0],16'h0000}:
           (b==1&((alufun==2'b01)|(alufun==2'b11&a[31]==0)))?{16'h0000,a[31:16]}:
           (b==1&alufun==2'b11&a[31]==1)?{16'hFFFF,a[31:16]}:
           a;

endmodule

module SHIFT_8(a,alufun,b,res);//a????b????

input [31:0]a;
input [1:0]alufun;
input b;
output [31:0]res;

assign res=(b==1&alufun==2'b00)?{a[23:0],8'h00}:
           (b==1&((alufun==2'b01)|(alufun==2'b11&a[31]==0)))?{8'h00,a[31:8]}:
           (b==1&alufun==2'b11&a[31]==1)?{8'hFF,a[31:8]}:
           a;

endmodule

module SHIFT_4(a,alufun,b,res);//a????b????

input [31:0]a;
input [1:0]alufun;
input b;
output [31:0]res;

assign res=(b==1&alufun==2'b00)?{a[27:0],4'h0}:
           (b==1&((alufun==2'b01)|(alufun==2'b11&a[31]==0)))?{4'h0,a[31:4]}:
           (b==1&alufun==2'b11&a[31]==1)?{4'hF,a[31:4]}:
           a;

endmodule

module SHIFT_2(a,alufun,b,res);//a????b????

input [31:0]a;
input [1:0]alufun;
input b;
output [31:0]res;

assign res=(b==1&alufun==2'b00)?{a[29:0],2'b00}:
           (b==1&((alufun==2'b01)|(alufun==2'b11&a[31]==0)))?{2'b00,a[31:2]}:
           (b==1&alufun==2'b11&a[31]==1)?{2'b11,a[31:2]}:
           a;

endmodule

module SHIFT_1(a,alufun,b,res);//a????b????

input [31:0]a;
input [1:0]alufun;
input b;
output [31:0]res;

assign res=(b==1&alufun==2'b00)?{a[30:0],1'b0}:
           (b==1&((alufun==2'b01)|(alufun==2'b11&a[31]==0)))?{1'b0,a[31:1]}:
           (b==1&alufun==2'b11&a[31]==1)?{1'b1,a[31:1]}:
           a;

endmodule

module SHIFT(a,alufun,b,res);//a????b????

input [31:0]a,b;
input [1:0]alufun;
output [31:0]res;

wire [31:0] res1,res2,res3,res4;

SHIFT_16 shift_16(.a(a),.alufun(alufun),.b(b[4]),.res(res1));
SHIFT_8 shift_8(.a(res1),.alufun(alufun),.b(b[3]),.res(res2));
SHIFT_4 shift_4(.a(res2),.alufun(alufun),.b(b[2]),.res(res3));
SHIFT_2 shift_2(.a(res3),.alufun(alufun),.b(b[1]),.res(res4));
SHIFT_1 shift_1(.a(res4),.alufun(alufun),.b(b[0]),.res(res));

endmodule