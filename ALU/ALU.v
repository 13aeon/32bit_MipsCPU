//ALU.v
module ALU(a,b,alufun,sign,res,zero);
  
  input [31:0]a,b;
  input [5:0]alufun;
  input sign;
  output [31:0]res;
  output zero;
  
  wire [31:0] res1,res2,res3,res4;
  wire Z,V,N;
  
  ADD add(.a(a),.b(b),.sign(sign),.alufun(alufun[0]),.res(res1),.Z(Z),.V(V),.N(N));
  CMP cmp(.Z(Z),.V(V),.N(N),.alufun(alufun[3:1]),.res(res2),.a(a));
  LOGIC logic1(.a(a),.b(b),.alufun(alufun[3:0]),.res(res3));
  SHIFT shift(.a(b),.alufun(alufun[1:0]),.b(a),.res(res4));
  
  assign res=(alufun[5:4]==2'b00)?res1:
             (alufun[5:4]==2'b11)?res2:
             (alufun[5:4]==2'b01)?res3:
             (alufun[5:4]==2'b10)?res4:
             32'b0;
    
    assign zero=
          (alufun[3:1]==3'b001)?({1'b0,~b}+{32'b0,1'b1}+{1'b0,a}=={1'b1,32'b0}):
          (alufun[3:1]==3'b000)?({1'b0,~b}+{32'b0,1'b1}+{1'b0,a}!={1'b1,32'b0}):
          //(alufun[3:1]==3'b010)?N:
          (alufun[3:1]==3'b110)?a[31]|(~(|a[30:0])):
          (alufun[3:1]==3'b101)?a[31]:
          (alufun[3:1]==3'b111)?~a[31]&(|a[30:0]):
          1'b0;  
             
endmodule

