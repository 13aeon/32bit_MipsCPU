//ADD.v
module ADD(a,b,sign,alufun,res,Z,V,N);
  
  input [31:0]a,b;
  input sign,alufun;
  output [31:0]res;
  output Z,V,N;
  
  wire [31:0]b1;
  wire forward;
  
  assign b1=(alufun==1)?(~b)+1:b;
  assign {forward,res}=(alufun==1)?(~b)+1+a:b+a;

  assign Z=~|res;
  assign V=sign&(a[31]^~b1[31])&(a[31]^res[31]);
  assign N=(sign&res[31]&~V)|(~sign&~forward);

endmodule