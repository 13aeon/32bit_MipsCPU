
module Control(OpCode, Funct, IRQ, Core, PCSrc, RePCSrc, RegDst, RegWr, ALUSrc1, ALUSrc2,
        ALUFun, Sign, MemWr, MemRd, MemtoReg, ExtOp, LuOp);

    input [5:0] OpCode;
    input [5:0] Funct;
    input IRQ;
    input Core;

    output [2:0] PCSrc;
    output [1:0] RePCSrc;
    output [1:0] RegDst;
    output RegWr;
    output ALUSrc1;
    output ALUSrc2;
    output [5:0] ALUFun;
    output Sign;
    output MemWr;
    output MemRd;
    output [1:0] MemtoReg;
    output ExtOp;
    output LuOp;

    wire Except; // 异常

    assign Except = 
        ((OpCode == 6'h00 && (
            Funct == 6'h00 ||
            (Funct >= 6'h20 && Funct <= 6'h27) ||
            Funct == 6'h02 ||
            Funct == 6'h03 ||
            Funct == 6'h2a ||
            Funct == 6'h2b ||
            Funct == 6'h08 ||
            Funct == 6'h09
            )) ||
        (OpCode >= 6'h01 && OpCode <= 6'h0c) ||
        (OpCode == 6'h23) ||
        (OpCode == 6'h2b) ||
        (OpCode == 6'h0f))? 1'b0: 1'b1;

    assign RePCSrc[1:0] = 
        (OpCode == 6'h02 || OpCode == 6'h03)? 2'b10:
        (OpCode == 6'h01 || (OpCode >= 6'h04 && OpCode <= 6'h07))? 2'b01:
        (OpCode == 6'h00 && (Funct == 6'h08 || Funct == 6'h09))? 2'b11:
        2'b00;
    
    assign PCSrc[2:0] = 
        (Except && ~Core)? 3'b101:
        (IRQ && ~Core)? 3'b100:
        {1'b0, RePCSrc};
    
    assign RegDst[1:0] = 
        ((IRQ || Except) && ~Core)? 2'b11:
        (OpCode == 6'h03)? 2'b10:
        (OpCode > 6'h00)? 2'b01:
        2'b00;

    assign RegWr = 
        ((IRQ || Except) && ~Core)? 1'b1:
        (OpCode == 6'h2b || (OpCode >= 6'h04 && OpCode <= 6'h07) ||
        OpCode == 6'h01 || OpCode == 6'h02)? 1'b0:
        (OpCode == 6'h00 && Funct == 6'h08)? 1'b0: 1'b1;

    assign ALUSrc1 = (OpCode == 6'h00 && Funct <= 6'h03)? 1'b1: 1'b0;

    assign ALUSrc2 = 
        (OpCode == 6'h04 || OpCode == 6'h05)? 1'b0:
        (OpCode > 6'h00)? 1'b1: 1'b0;

    parameter aluADD = 6'b000000;
    parameter aluSUB = 6'b000001;
    parameter aluAND = 6'b011000;
    parameter aluOR  = 6'b011110;
    parameter aluXOR = 6'b010110;
    parameter aluNOR = 6'b010001;
    parameter aluA   = 6'b011010;
    parameter aluSLL = 6'b100000;
    parameter aluSRL = 6'b100001;
    parameter aluSRA = 6'b100011;
    parameter aluEQ  = 6'b110011;
    parameter aluNEQ = 6'b110001;
    parameter aluLT  = 6'b110101;
    parameter aluLEZ = 6'b111101;
    parameter aluLTZ = 6'b111011;
    parameter aluGTZ = 6'b111111;

    assign ALUFun [5:0] = 
        (OpCode == 6'h00)? 
            (   (Funct == 6'h20)? aluADD:
                (Funct == 6'h21)? aluADD:
                (Funct == 6'h22)? aluSUB:
                (Funct == 6'h23)? aluSUB:
                (Funct == 6'h24)? aluAND:
                (Funct == 6'h25)? aluOR:
                (Funct == 6'h26)? aluXOR:
                (Funct == 6'h27)? aluNOR:
                (Funct == 6'h00)? aluSLL:
                (Funct == 6'h02)? aluSRL:
                (Funct == 6'h03)? aluSRA:
                (Funct == 6'h2a)? aluLT:
                (Funct == 6'h2b)? aluLT:
                aluADD
            ):
        (OpCode == 6'h0c)? aluAND:
        (OpCode == 6'h0a)? aluLT:
        (OpCode == 6'h0b)? aluLT:
        (OpCode == 6'h04)? aluEQ:
        (OpCode == 6'h05)? aluNEQ:
        (OpCode == 6'h06)? aluLEZ:
        (OpCode == 6'h07)? aluGTZ:
        (OpCode == 6'h01)? aluLTZ:
        aluADD;

    assign Sign = 
        (OpCode == 6'h09 || OpCode == 6'h0b || 
            (OpCode == 6'h00 && (Funct == 6'h21 || Funct == 6'h23 || Funct == 6'h2b)))? 1'b0: 1'b1;

    assign MemRd = (OpCode == 6'h23)? 1'b1: 1'b0;
    
    assign MemWr = (OpCode == 6'h2b)? 1'b1: 1'b0;

    assign MemtoReg[1:0] = 
        ((IRQ || Except) && ~Core)? 2'b10:
        (OpCode == 6'h03 || OpCode == 6'h00 && Funct == 6'h09)? 2'b10:
        (OpCode == 6'h23)? 2'b01: 2'b00;

    assign ExtOp = (OpCode == 6'h0c)? 1'b0: 1'b1;
    
    assign LuOp = (OpCode == 6'h0f)? 1'b1: 1'b0;
    
endmodule