//Pipeline CPU
module CPU(reset, clk, Switch, uart_rx, uart_tx, LED, DigiOut1, DigiOut2, DigiOut3, DigiOut4);
    
    input reset, clk, Switch, uart_rx;
    wire [7:0] Switch;

    output uart_tx, LED, DigiOut1, DigiOut2, DigiOut3, DigiOut4;
    wire [7:0] LED;
    wire [6:0] DigiOut1, DigiOut2, DigiOut3, DigiOut4;
    
    reg [31:0] PC;
    wire [31:0] PC_next;
    wire [31:0] PC_plus_4;
    wire [2:0] PCSrc;

    wire loaduse;

    assign PC_plus_4[30:0] = PC[30:0] + 31'd4;
    assign PC_plus_4[31] = PC[31];
    
    wire [31:0] Instruction;
    ROM rom1(.addr(PC), .data(Instruction));

 //stage IF - ID
    reg [31:0] IF_ID_PC_plus_4;
    reg [31:0] IF_ID_Instr;
    wire ID_FLUSH, IF_FLUSH;  
    //TODO : FLUSH BRANCH JUMP  
    always @(negedge reset or posedge clk)
        begin
            if (~reset)
            begin
                IF_ID_PC_plus_4 <= 0;
                IF_ID_Instr <= 0;                
            end
            else begin
              if (IF_FLUSH | loaduse) begin
                  IF_ID_PC_plus_4 <= 0;
                  IF_ID_Instr <= 0; 
              end
              else begin
                IF_ID_PC_plus_4 <=  PC_plus_4;
                IF_ID_Instr <=  Instruction;
              end                 
            end

        end    

    wire [1:0] RegDst;
    wire RegWr;
    wire ALUSrc1;
    wire ALUSrc2;
    wire [5:0] ALUFun;
    wire Sign;
    wire MemWr;
    wire MemRd;
    wire [1:0] MemtoReg;
    wire ExtOp;
    wire LuOp;
    wire Jump;
    wire Branch;
    wire IRQ;
    wire [1:0] RePCSrc;

    Control control1(
        .OpCode(IF_ID_Instr[31:26]), .Funct(IF_ID_Instr[5:0]), .IRQ(IRQ), .Core(PC[31]), 
        .PCSrc(PCSrc), .RePCSrc(RePCSrc), .RegDst(RegDst), .RegWr(RegWr),
        .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), 
        .ALUFun(ALUFun), .Sign(Sign),
        .MemWr(MemWr), .MemRd(MemRd), .MemtoReg(MemtoReg),
        .ExtOp(ExtOp), .LuOp(LuOp));

    assign Branch = (PCSrc == 3'b001);
    assign Jump   = ((PCSrc == 3'b010) ||(PCSrc == 3'b011) || (PCSrc == 3'b100)|| (PCSrc == 3'b101)|| (PCSrc == 3'b110));
    wire [15:0] Imm16;
    assign Imm16 = IF_ID_Instr[15:0];

    wire [4:0] Shamt;
    assign Shamt = IF_ID_Instr[10:6];

    wire [4:0] Rd;
    assign Rd = IF_ID_Instr[15:11];

    wire [4:0] Rt;
    assign Rt = IF_ID_Instr[20:16];

    wire [4:0] Rs;
    assign Rs = IF_ID_Instr[25:21];  

    wire [31:0] DataBusA, DataBusB;
    reg  [31:0] DataBusC;
    assign loaduse = (IF_ID_Instr[31:26] == 6'b100011) & (Rt == Instruction[25:21] | Rt == Instruction[20:16]);

    wire [4:0] AddrC;
    assign AddrC = (RegDst == 2'b00)? Rd:
                   (RegDst == 2'b01)? Rt:
                   (RegDst == 2'b10)? 5'd31: //Ra
                   5'd26; //Xp


 
    wire [31:0] EXTOut;
    assign EXTOut = {ExtOp? {16{Imm16[15]}}: 16'h0000, Imm16};
  
    wire [31:0] LUOut;
    assign LUOut = LuOp? {Imm16, 16'h0000}: EXTOut;
    
    wire [31:0] JT;
    assign JT = {IF_ID_PC_plus_4[31:28], IF_ID_Instr[25:0], 2'b00};
    
    reg [31:0]  ID_EX_PC_plus_4;
    reg [31:0]  ID_EX_DataBusA;
    reg [31:0]  ID_EX_DataBusB;
    reg  ID_EX_Sign;
    reg [4:0] ID_EX_Shamt;
    reg [5:0] ID_EX_ALUFun;
    reg [31:0]ID_EX_LUOut;
    reg [31:0]ID_EX_EXTOut;
    reg [1:0] ID_EX_RePCSrc;
    reg [31:0] ID_EX_JT;
    reg ID_EX_Jump;
    //2.1 To EX
    reg [1:0]ID_EX_RegDst;
    reg ID_EX_ALUSrc1;
    reg ID_EX_ALUSrc2;
    //2.2 To MEM
    reg ID_EX_Branch;
    reg ID_EX_MemWrite;
    reg ID_EX_MemRead;
    //2.3 To WB
    reg [1:0]ID_EX_MemToReg;
    reg ID_EX_RegWrite;
    reg [4:0] ID_EX_AddrC;

    //3.0 For stage EX to MEM;            
    reg [31:0] EX_MEM_ALUOut;
    reg [31:0] EX_MEM_PC_plus_4;
    reg [31:0] EX_MEM_JT;
    //3.1 To MEM  
    reg [1:0]EX_MEM_RePCSrc;
    reg EX_MEM_MemWrite;
    reg EX_MEM_MemRead;
    reg [31:0]EX_MEM_DataBusB;
    reg [4:0]  EX_MEM_RegWriteAddress;  //rt or rd
    //3.2 To WB
    reg [1:0]EX_MEM_MemToReg;
    reg EX_MEM_RegWrite;
    reg [31:0] EX_MEM_Branch_target;

    reg [31:0] MEM_WB_PC_plus_4;
    reg [31:0] MEM_WB_ALUOut;
    reg [31:0] MEM_WB_ReadData;
    reg [4:0]  MEM_WB_RegWriteAddress;
    reg        MEM_WB_RegWrite;
    reg        MEM_WB_MemToReg;
    wire [31:0] ALUIn1;
    wire [31:0] ALUIn2;
    wire [31:0] ALUOut;
    wire [31:0] ReadData;

    always @(negedge reset or posedge clk)
        begin
          //2.0 For Stage ID To EX
          if (~reset)
          begin
             ID_EX_PC_plus_4    <=  0;
             ID_EX_DataBusA <=  0;
             ID_EX_DataBusB <= 0;
             ID_EX_Sign      <= 0;
             ID_EX_Shamt     <= 0;
             ID_EX_ALUFun      <= 0;
             ID_EX_LUOut       <= 0;
             ID_EX_EXTOut       <= 0;
             ID_EX_RePCSrc      <= 0;
             //2.1 To EX
             ID_EX_RegDst       <= 0;
             ID_EX_ALUSrc1       <= 0;
             ID_EX_ALUSrc2       <= 0;
             //2.2 To MEM
             ID_EX_AddrC        <= 0;
             ID_EX_Branch       <= 0;
             ID_EX_MemWrite     <= 0;
             ID_EX_MemRead      <= 0;
             //2.3 To WB
             ID_EX_MemToReg     <= 0;
             ID_EX_RegWrite     <= 0;
             ID_EX_JT           <= 0;
             ID_EX_Jump         <= 0;
          end
          else           
          begin
          if (ID_FLUSH)
          begin
             ID_EX_PC_plus_4    <=  0;
             ID_EX_DataBusA <=  0;
             ID_EX_DataBusB <= 0;
             ID_EX_Sign      <= 0;
             ID_EX_Shamt     <= 0;
             ID_EX_ALUFun      <= 0;
             ID_EX_LUOut       <= 0;
             ID_EX_EXTOut       <= 0;
             ID_EX_RePCSrc      <= 0;
             //2.1 To EX
             ID_EX_RegDst       <= 0;
             ID_EX_ALUSrc1       <= 0;
             ID_EX_ALUSrc2       <= 0;
             //2.2 To MEM
             ID_EX_AddrC        <= 0;
             ID_EX_Branch       <= 0;
             ID_EX_MemWrite     <= 0;
             ID_EX_MemRead      <= 0;
             //2.3 To WB
             ID_EX_MemToReg     <= 0;
             ID_EX_RegWrite     <= 0;
             ID_EX_JT           <= 0;  
             ID_EX_Jump         <= 0; 
          end else begin
            if ((ID_EX_RegWrite & ID_EX_AddrC != 0) | (EX_MEM_RegWriteAddress != 0 & EX_MEM_RegWrite) )
            begin
              if (EX_MEM_RegWriteAddress == IF_ID_Instr[25:21] &  
                (ID_EX_AddrC != IF_ID_Instr[25:21]| ~ ID_EX_RegWrite))
                 ID_EX_DataBusA <=   (EX_MEM_MemToReg == 2'b00)? EX_MEM_ALUOut:
                      (EX_MEM_MemToReg == 2'b01)? ReadData:
                       (EX_MEM_RePCSrc == 3'b001)? EX_MEM_Branch_target:
                        (EX_MEM_RePCSrc == 3'b010)? EX_MEM_JT:EX_MEM_PC_plus_4;
              else begin if (ID_EX_AddrC == IF_ID_Instr[25:21])
                 ID_EX_DataBusA <=  ALUOut;
              else   ID_EX_DataBusA <=  DataBusA;
              end
            end
            else
            begin
               ID_EX_DataBusA <=  DataBusA;
            end
            if ((ID_EX_RegWrite & ID_EX_AddrC != 0) | (EX_MEM_RegWriteAddress != 0 & EX_MEM_RegWrite)) 
            begin     
             if (EX_MEM_RegWriteAddress == IF_ID_Instr[20:16] & 
              (ID_EX_AddrC != IF_ID_Instr[20:16] | ~ ID_EX_RegWrite))
               ID_EX_DataBusB <=  (EX_MEM_MemToReg == 2'b00)? EX_MEM_ALUOut:
                      (EX_MEM_MemToReg == 2'b01)? ReadData:
                       (EX_MEM_RePCSrc == 3'b001)? EX_MEM_Branch_target:
                        (EX_MEM_RePCSrc == 3'b010)? EX_MEM_JT:EX_MEM_PC_plus_4;
            else begin if (ID_EX_AddrC == IF_ID_Instr[20:16])
               ID_EX_DataBusB <=  ALUOut;
               else ID_EX_DataBusB <=  DataBusB; 
               end
            end
            else
            begin
               ID_EX_DataBusB <=  DataBusB;            
            end
            if (IRQ & (~PC[31]) & ID_EX_Jump) begin
                ID_EX_RegWrite <=  1;
                ID_EX_RePCSrc  <=  2'b10;
            end 
            else begin
                ID_EX_Jump         <= Jump;
                ID_EX_RegWrite     <=  RegWr;
                ID_EX_RePCSrc     <= RePCSrc;
                ID_EX_JT           <=  JT;
            end
             ID_EX_PC_plus_4    <=  IF_ID_PC_plus_4;
             ID_EX_Sign      <=  Sign;
             ID_EX_Shamt     <=  Shamt;
             ID_EX_ALUFun      <=  ALUFun;
             ID_EX_LUOut       <=  LUOut;
             ID_EX_EXTOut       <=  EXTOut;
             //2.1 To EX
             ID_EX_RegDst       <=  RegDst;
             ID_EX_ALUSrc1       <=  ALUSrc1;
             ID_EX_ALUSrc2       <=  ALUSrc2;
             //2.2 To MEM
             ID_EX_AddrC        <=  AddrC;
             ID_EX_Branch       <=  Branch;
             ID_EX_MemWrite     <=  MemWr;
             ID_EX_MemRead      <=  MemRd;
             //2.3 To WB
             ID_EX_MemToReg     <=  MemtoReg;
          end
		end
        end


    assign ALUIn1 = ID_EX_ALUSrc1? {17'h00000, ID_EX_Shamt}: ID_EX_DataBusA;
    assign ALUIn2 = ID_EX_ALUSrc2? ID_EX_LUOut: ID_EX_DataBusB;
    ALU alu1(.a(ALUIn1), .b(ALUIn2), .alufun(ID_EX_ALUFun), .sign(ID_EX_Sign), .res(ALUOut));
    wire [31:0] ConBA; 
    assign ConBA = ID_EX_PC_plus_4 + {ID_EX_EXTOut[29:0], 2'b00};
    
    wire [31:0] Branch_target;
    assign Branch_target = (ALUOut[0])? ConBA: ID_EX_PC_plus_4;

    assign IF_FLUSH = Jump | (ID_EX_Branch & ALUOut[0]);
    assign ID_FLUSH = ID_EX_Branch & ALUOut[0];
    

    always @(negedge reset or posedge clk)
    begin
        if(~reset) begin
          EX_MEM_PC_plus_4 <= 0;
          EX_MEM_ALUOut <= 0;
          EX_MEM_MemWrite <= 0;
          EX_MEM_MemRead <= 0;
          EX_MEM_MemToReg <= 0;
          EX_MEM_RegWrite <= 0;
          EX_MEM_DataBusB <= 0;
          EX_MEM_RegWriteAddress <= 0;  
          EX_MEM_RePCSrc  <= 0;
          EX_MEM_Branch_target <= 0;
          EX_MEM_JT   <= 0;
        end
    else begin
          EX_MEM_PC_plus_4 <= ID_EX_PC_plus_4;
          EX_MEM_ALUOut <= ALUOut;
          EX_MEM_MemWrite <= ID_EX_MemWrite;
          EX_MEM_MemRead <= ID_EX_MemRead;
          EX_MEM_MemToReg <= ID_EX_MemToReg;
          EX_MEM_RegWrite <= ID_EX_RegWrite;
          EX_MEM_DataBusB <= ID_EX_DataBusB;
          EX_MEM_RegWriteAddress <= ID_EX_AddrC;
          EX_MEM_RePCSrc  <= ID_EX_RePCSrc;
          EX_MEM_Branch_target <= Branch_target;
          EX_MEM_JT   <= ID_EX_JT;
      end
    end
    

    wire DataWr,DataRd;
    wire [31:0] DataRdata;
    assign DataWr = (EX_MEM_ALUOut[31:28] == 4'h4)? 1'b0: EX_MEM_MemWrite;
    assign DataRd = (EX_MEM_ALUOut[31:28] == 4'h4)? 1'b0: EX_MEM_MemRead;
    DataMem dataMem1(.reset(reset),.clk(clk),.rd(DataRd),.wr(DataWr),.addr(EX_MEM_ALUOut),.wdata(EX_MEM_DataBusB),.rdata(DataRdata));

    wire PerWr,PerRd;
    wire [31:0] PerRdata;
    wire [11:0] digi;
    wire [7:0] Int1, Int2, Int3;
    wire InputReady, Occupied, OutputReady;
    assign PerWr = (EX_MEM_ALUOut[31:28] == 4'h4)? EX_MEM_MemWrite: 0;
    assign PerRd = (EX_MEM_ALUOut[31:28] == 4'h4)? EX_MEM_MemRead: 0;
    Peripheral peripheral1(.reset(reset),.clk(clk),.rd(PerRd),.wr(PerWr),.addr(EX_MEM_ALUOut),
        .wdata(EX_MEM_DataBusB),.Int1(Int1),.Int2(Int2),.InputReady(InputReady),.Occupied(Occupied),
        .rdata(PerRdata),.led(LED),.switch(Switch),.digi(digi),.irqout(IRQ),.Int3(Int3),.OutputReady(OutputReady));
        
    UART uart1(.uart_rx(uart_rx),.sysclk(clk),.reset(reset),.Int3(Int3),.OutputReady(OutputReady),
        .uart_tx(uart_tx),.Int1(Int1),.Int2(Int2),.InputReady(InputReady),.Occupied(Occupied));

    assign ReadData = (EX_MEM_ALUOut[31:28] == 4'h4)? PerRdata: DataRdata;


    always @(negedge reset or posedge clk)
    begin
      if (~reset)
        begin
            MEM_WB_RegWriteAddress = 0;
            MEM_WB_RegWrite = 0;
        end  
        else begin
            MEM_WB_RegWriteAddress = EX_MEM_RegWriteAddress;
            MEM_WB_RegWrite = EX_MEM_RegWrite;
            DataBusC = (EX_MEM_MemToReg == 2'b00)? EX_MEM_ALUOut:
                      (EX_MEM_MemToReg == 2'b01)? ReadData:
                       (EX_MEM_RePCSrc == 2'b01)? EX_MEM_Branch_target:
                        (EX_MEM_RePCSrc == 2'b10)? EX_MEM_JT:EX_MEM_PC_plus_4;
        end
    end
    
    // assign DataBusC = (MEM_WB_MemToReg == 2'b00)? MEM_WB_ALUOut:
    //                   (MEM_WB_MemToReg == 2'b01)? MEM_WB_ReadData:
    //                    MEM_WB_PC_plus_4;

    RegFile regFile1( .reset(reset), .clk(clk), .addr1(Rs), .data1(DataBusA),
        .addr2(Rt), .data2(DataBusB), .wr(MEM_WB_RegWrite), .addr3(MEM_WB_RegWriteAddress), .data3(DataBusC));
    
    assign PC_next = (PCSrc == 3'b000)? PC_plus_4:
                     (PCSrc == 3'b001)? Branch_target:
                     (PCSrc == 3'b010)? JT:
                     (PCSrc == 3'b011)? DataBusA:
                     (PCSrc == 3'b100)? 32'h80000004: //ILLOP
                     32'h80000008; //XADR
    
    always @(negedge reset or posedge clk)
    begin
        if (~reset)
            PC <= 32'h00000000;
        else
        if (ID_EX_Branch & ALUOut[0])
        PC <= Branch_target;
        else if (loaduse)
            PC <= PC;
            else if (PCSrc > 1)
            PC <= PC_next;
            else
            PC <= PC_plus_4;
    end

    digitube_scan digitube_scan1(.digi_in(digi), .digi_out1(DigiOut1),
        .digi_out2(DigiOut2), .digi_out3(DigiOut3), .digi_out4(DigiOut4));
  

endmodule