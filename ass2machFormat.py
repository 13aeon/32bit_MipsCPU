# -*- coding: utf-8 -*-
import sys

def num2bin(num, bits):   #数字字符串转二进制串,可以完成十六进制和十进制的通用转换
    if num.lower().startswith('0x'):
        return hex2bin(num[2:], bits)
    else:
        return dec2bin(num, bits)

def dec2bin(dec, bits):  #十进制转二进制串
    num = int(dec)
    if num >= 0:
        return ("{0:0%db}" % bits).format(num)    #转换成二进制并补足bits位
    else:
        return ("{0:0%db}" % bits).format(2**bits + num)    #负数要取补码表示

def hex2bin(hex, bits):  #十六进制转二进制串
    d = {'0':'0000', '1':'0001', '2':'0010', '3':'0011','4':'0100', '5':'0101', '6':'0110', '7':'0111','8':'1000', '9':'1001', 'a':'1010', 'b':'1011','c':'1100', 'd':'1101', 'e':'1110', 'f':'1111'}
    bin = ''
    for i in hex:    #对大写字母也兼容
        bin += d[i.lower()]
    if len(bin) < bits:
        bin = bin[0] * (bits - len(bin)) + bin  #补足bits位
    else:
        bin = bin[-bits:]  #取后bits位
    return bin

def bin2hex(bin):    #二进制转16进制,如果输入不是整四位的会自动补齐
    d = {'0000':'0', '0001':'1', '0010':'2', '0011':'3','0100':'4', '0101':'5', '0110':'6', '0111':'7','1000':'8', '1001':'9', '1010':'a', '1011':'b','1100':'c', '1101':'d', '1110':'e', '1111':'f'}
    hex = ''
    temp = ''
    if len(bin)%4!=0:
        bin='0'*(4-len(bin))+bin
    for bit in bin:
        temp+=bit
        if len(temp) == 4:
            hex += d[temp]
            temp = ''
    return hex

def reg2bin(reg):    #把寄存器名转化为二进制串
    regs = ['$zero', '$at', '$v0', '$v1', '$a0', '$a1', '$a2', '$a3','$t0', '$t1', '$t2', '$t3', '$t4', '$t5', '$t6', '$t7','$s0', '$s1', '$s2', '$s3', '$s4', '$s5', '$s6', '$s7','$t8', '$t9', '$k0', '$k1', '$gp', '$sp', '$fp', '$ra']
    return num2bin(str(regs.index(reg)), 5)

def isLabel(line):    #找出含有冒号的语句
    return ':' in line

def LS2bin(op, argv):    #转化lw，sw语句为二进制串
    d={'lw':'0x23','sw':'0x2b'}
    opcode=num2bin(d[op],6)
    rs =reg2bin( argv[1][argv[1].index('(')+1:argv[1].index(')')])
    rt = reg2bin(argv[0])
    offset = num2bin(argv[1][:argv[1].index('(')],16)
    return opcode + rs + rt + offset

def Lui2bin(op, argv):    #转化lui语句为二进制串
    opcode=num2bin('0x0f',6)
    rs='0'*5
    rt=reg2bin(argv[0])
    imm=num2bin(argv[1], 16)
    return opcode+rs+rt+imm

def R2bin(op, argv):    #转化add,addu,sub,subu,and,or,xor,nor,slt,sltu指令为二进制串
    opcode = '0' * 6
    rs=reg2bin(argv[1])
    rt=reg2bin(argv[2])
    rd= reg2bin(argv[0])
    d = {'add':'0x20', 'addu':'0x21', 'sub':'0x22', 'subu':'0x23', 'and':'0x24', 'or':'0x25', 'xor':'0x26', 'nor':'0x27','slt':'0x2a','sltu':'0x2b'}
    funt = num2bin(d[op],6)
    return opcode + rs+ rt+rd + '0' * 5 + funt

def ImmR2bin(op, argv):    #转化addi,addiu,slti,sltiu,andi指令为二进制串
    d={'addi':'0x08','andiu':'0x09','slti':'0x0a','sltiu':'0x0b','andi':'0x0c'}
    opcode=num2bin(d[op],6)
    rs=reg2bin(argv[1])
    rt=reg2bin(argv[0])
    imm=num2bin(argv[2], 16)
    return opcode + rs+rt+imm

def Shift2bin(op, argv):    #转化sll,srl,sra指令为二进制串
    opcode='0'*6
    rs='0'*5
    rt=reg2bin(argv[1])
    rd=reg2bin(argv[0])
    shamt=num2bin(argv[2],5)
    d={'sll':'0x00','srl':'0x02','sra':'0x03'}
    funt=num2bin(d[op],6)
    return opcode+rs+rt+rd+shamt+funt

def Branch2bin(op, argv, labels, cur_addr):    #转化beq指令为二进制串
    d={'beq':'0x04','bne':'0x05','blez':'0x06','bgtz':'0x07','bltz':'0x04'}
    opcode=num2bin(d[op],6)
    rs=reg2bin(argv[0])
    offset_label = argv[-1]
    tar_addr = labels[offset_label]
    offset = num2bin(str(tar_addr - cur_addr - 1), 16)
    if len(argv)==3:
        rt=reg2bin(argv[1])
    else:
        rt='0'*5
    return opcode+rs+rt+offset

def Jump2bin(op, argv, labels):    #转化j，jal指令为二进制串
    d={'j':'0x02','jal':'0x03'}
    opcode=num2bin(d[op],6)
    target=num2bin(str(labels[argv[0]]), 26)
    return opcode+target

def JumpReg2bin(op, argv):    #转化jr指令为二进制串
    opcode='0'*6
    rs=reg2bin(argv[0])
    rt='0'*5
    rd='0'*5
    shamt='0'*5
    funt=num2bin('0x08',6)
    return opcode+rs+rt+rd+shamt+funt

def JumpandLinkReg2bin(op,argv):    #转化jalr指令为二进制串
    opcode='0'*6
    rs=reg2bin(argv[1])
    rt='0'*5
    rd=reg2bin(argv[0])
    shamt='0'*5
    funt=num2bin('0x09',6)
    return opcode+rs+rt+rd+shamt+funt

def Instruction2bin(instruction, labels, cur_addr):    #把指令转化为二进制串，分别调用前面的各个函数
    l0 = instruction.split()
    op = l0.pop(0)
    if op =='nop':
        return Shift2bin('sll', ['$zero','$zero','0'])
    else:
        l1 = l0.pop(0)
        l = l1.split(',')
        if op in ['lw', 'sw']:
            return LS2bin(op, l)
        elif op == 'lui':
            return Lui2bin(op, l)
        elif op in ['add', 'addu', 'sub', 'subu','and', 'or', 'xor', 'nor','slt', 'sltu']:
            return R2bin(op, l)
        elif op in ['addi', 'addiu', 'andi', 'slti', 'sltiu']:
            return ImmR2bin(op, l)
        elif op in ['sll', 'srl', 'sra']:
            return Shift2bin(op, l)
        elif op in ['beq','bne','blez','bgtz','bltz']:
            return Branch2bin(op, l, labels, cur_addr)
        elif op in ['j', 'jal']:
            return Jump2bin(op, l, labels)
        elif op =='jr':
            return JumpReg2bin(op, l)
        elif op == 'jalr':
            return JumpandLinkReg2bin(op,l)
  
ass=open('assembly.txt','r')    #读取文件
mach=open('rom.v','w')
lines = [line for line in ass]
labels = {}
instructions = []
mach.write('''
module ROM (addr,data);
input [31:0] addr;
output reg [31:0] data;
//localparam ROM_SIZE = 32;
//reg [31:0] ROM_DATA[ROM_SIZE-1:0];

always@(*)
	case(addr[8:2])	//Address Must Be Word Aligned.
''')

for line in lines:    #整理出label的地址对应关系，默认地址从0开始,要求不能有空行
    if isLabel(line)==1:
        labels[line[:-2]] = len(instructions)    #之所以是-2是因为输入的时候后面还有\0
    else:
        instructions.append(line)
for i in range(len(instructions)):
    bin = Instruction2bin(instructions[i], labels, i)
    mach.write('        ' + (str(i)+':').ljust(8) + 'data <= 32\'h' + bin2hex(bin) +
               ';    //' + (hex(i*4)).ljust(6) +instructions[i])
    #mach.write(bin + '\n')    #调试时用来检验结果的2进制输出
mach.write('''      default:  data <= 32'h08000000;
    endcase
endmodule
''')
ass.close()
mach.close()
