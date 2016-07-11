//LOGIC.v
module LOGIC(a,b,alufun,res);
  
  input [31:0]a,b;
  input [3:0]alufun;
  output [31:0]res;
  
  assign res=(alufun==4'b1000)?a&b:
             (alufun==4'b1110)?a|b:
             (alufun==4'b0110)?a^b:
             (alufun==4'b0001)?~(a|b):
             (alufun==4'b1010)?a:
             32'b0;
             
endmodule