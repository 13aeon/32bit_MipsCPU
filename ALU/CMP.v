//CMP.v
module CMP(Z,V,N,alufun,res,a);
  
  input Z,V,N;
  input [31:0]a;
  input [2:0]alufun;
  output [31:0]res;
  
  assign res=
          (alufun==3'b001)?{31'b0,Z}:
          (alufun==3'b000)?{31'b0,~Z}:
          (alufun==3'b010)?{31'b0,N}:
          (alufun==3'b110)?{31'b0,a[31]|(~(|a))}:
          (alufun==3'b101)?{31'b0,a[31]}:
          (alufun==3'b111)?{31'b0,~a[31]&(|a)}:
          32'b0;
        
endmodule