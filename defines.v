// **************************** 全局的宏定义 ****************************

`define RstEnable 1'b1 // 复位信号有效
`define RstDisable 1'b0 // 复位信号无效
`define ZeroWord 32'h0000_0000 // 32位的数值0
`define WriteEnable 1'b1 // 使能写
`define WriteDisable 1'b0 // 禁止写
`define ReadEnable 1'b1 // 使能读
`define ReadDisable 1'b0 // 禁止读
`define AluOpBus 7:0 // 译码阶段的输出 aluop_o 的宽度
`define AluSelBus 2:0 // 译码阶段的输出 alusel_o 的宽度
`define InstValid 1'b0 // 指令有效
`define InstInvalid 1'b1 // 指令无效
`define True_v 1'b1 // 逻辑‘真’
`define False_v 1'b0 // 逻辑‘假’
`define ChipEnable 1'b1 // 芯片使能
`define ChipDisable 1'b0 // 芯片禁止
`define InterruptAssert 1'b1 // 发生中断
`define InterruptNotAssert 1'b0 // 未发生中断

// **************************** 与具体指令有关的宏定义 ****************************
`define EXE_AND 6'b100100 // 指令 and 的功能码
`define EXE_OR 6'b100101 // 指令 or 的功能码
`define EXE_XOR 6'b100110 // 指令 xor 的功能码
`define EXE_NOR 6'b100111 // 指令 nor 的功能码

`define EXE_ANDI 6'b001100 // 指令 andi 的指令码
`define EXE_ORI 6'b001101 // 指令 ori 的指令码
`define EXE_XORI 6'b001110 // 指令 xori 的指令码
`define EXE_LUI 6'b001111 // 指令 lui 的指令码

`define EXE_SLL 6'b000000 // 指令 sll 的功能码 (nop、ssnop 可当作特殊的 sll)
`define EXE_SLLV 6'b000100 // 指令 sllv 的功能码
`define EXE_SRL 6'b000010 // 指令 srl 的功能码
`define EXE_SRLV 6'b000110 // 指令 srlv 的功能码
`define EXE_SRA 6'b000011 // 指令 sra 的功能码
`define EXE_SRAV 6'b000111 // 指令 srav 的功能码

`define EXE_MOVZ 6'b001010 // 指令 movz 的功能码
`define EXE_MOVN 6'b001011 // 指令 movn 的功能码
`define EXE_MFHI 6'b010000 // 指令 mfhi 的功能码
`define EXE_MTHI 6'b010001 // 指令 mthi 的功能码
`define EXE_MFLO 6'b010010 // 指令 mflo 的功能码
`define EXE_MTLO 6'b010011 // 指令 mtlo 的功能码

`define EXE_ADD 6'b100000 // 指令 add 的功能码
`define EXE_ADDU 6'b100001 // 指令 addu 的功能码
`define EXE_SUB 6'b100010 // 指令 sub 的功能码
`define EXE_SUBU 6'b100011 // 指令 subu 的功能码
`define EXE_SLT 6'b101010 // 指令 slt 的功能码
`define EXE_SLTU 6'b101011 // 指令 sltu 的功能码

`define EXE_ADDI 6'b001000 // 指令 addi 的指令码
`define EXE_ADDIU 6'b001001 // 指令 addiu 的指令码
`define EXE_SLTI 6'b001010 // 指令 slti 的指令码
`define EXE_SLTIU 6'b001011 // 指令 sltiu 的指令码

`define EXE_CLO 6'b100001 // 指令 clo 的功能码
`define EXE_CLZ 6'b100000 // 指令 clz 的功能码

`define EXE_MUL 6'b000010 // 指令 mul 的功能码
`define EXE_MULT 6'b011000 // 指令码 mult 的功能码
`define EXE_MULTU 6'b011001 // 指令 multu 的功能码

`define EXE_MADD 6'b000000 // 指令 madd 的功能码
`define EXE_MADDU 6'b000001 // 指令 maddu 的功能码
`define EXE_MSUB 6'b000100 // 指令 msub 的功能码
`define EXE_MSUBU 6'b000101 // 指令 msubu 的功能码

`define EXE_DIV  6'b011010 // 指令 div 的功能码
`define EXE_DIVU  6'b011011 // 指令 div 的功能码

`define EXE_J  6'b000010 // 指令 j 的指令码
`define EXE_JAL  6'b000011 // 指令 jal 的指令码 
`define EXE_JALR  6'b001001 // 指令 jalr 的功能码
`define EXE_JR  6'b001000 // 指令 jr 的功能码
`define EXE_BEQ  6'b000100 // 指令 beq 的指令码
`define EXE_BGTZ  6'b000111 // 指令 bgtz 的指令码
`define EXE_BLEZ  6'b000110 // 指令 blez 的指令码
`define EXE_BNE  6'b000101 // 指令 bne 的指令码
`define EXE_BLTZ  5'b00000 // 指令 bltz 的功能码
`define EXE_BLTZAL  5'b10000 // 指令 bltzal 的功能码
`define EXE_BGEZ  5'b00001 // 指令 bgez 的功能码
`define EXE_BGEZAL  5'b10001 // 指令 bgezal 的功能码

`define EXE_LB  6'b100000 // 指令 lb 的指令码
`define EXE_LBU  6'b100100 // 指令 lbu 的指令码
`define EXE_LH  6'b100001 // 指令 lh 的指令码
`define EXE_LHU  6'b100101 // 指令 lhu 的指令码
`define EXE_LL  6'b110000
`define EXE_LW  6'b100011 // 指令 lw 的指令码
`define EXE_LWL  6'b100010 // 指令 lwl 的指令码
`define EXE_LWR  6'b100110 // 指令 lwr 的指令码
`define EXE_SB  6'b101000 // 指令 sb 的指令码
`define EXE_SC  6'b111000
`define EXE_SH  6'b101001 // 指令 sh 的指令码
`define EXE_SW  6'b101011 // 指令 sw 的指令码
`define EXE_SWL  6'b101010 // 指令 swl 的指令码
`define EXE_SWR  6'b101110 // 指令 swr 的指令码

`define EXE_LL 6'b110000 // 指令 ll 的指令码
`define EXE_SC 6'b111000 // 指令 sc 的指令码  

`define EXE_SYNC 6'b001111 // 指令 sync 的功能码
`define EXE_PREF 6'b110011 // 指令 pref 的指令码

`define EXE_SPECIAL_INST 6'b000000 // SPECIAL 指令的指令码
`define EXE_SPECIAL2_INST 6'b011100 // SPECIAL2 指令的指令码
`define EXE_REGIMM_INST 6'b000001 // REGIMM 指令的指令码


// AluOp
`define EXE_AND_OP 8'b0010_0100
`define EXE_OR_OP 8'b0010_0101
`define EXE_XOR_OP 8'b0010_0110
`define EXE_NOR_OP 8'b0010_0111

`define EXE_SLL_OP 8'b0111_1100
`define EXE_SRL_OP 8'b0000_0010
`define EXE_SRA_OP 8'b0000_0011

`define EXE_MOVZ_OP  8'b0000_1010
`define EXE_MOVN_OP  8'b0000_1011
`define EXE_MFHI_OP  8'b0001_0000
`define EXE_MTHI_OP  8'b0001_0001
`define EXE_MFLO_OP  8'b0001_0010
`define EXE_MTLO_OP  8'b0001_0011

`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_ADD_OP  8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP  8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP  8'b01010110
`define EXE_CLZ_OP  8'b10110000
`define EXE_CLO_OP  8'b10110001

`define EXE_MULT_OP  8'b00011000
`define EXE_MULTU_OP  8'b00011001
`define EXE_MUL_OP  8'b10101001

`define EXE_MADD_OP  8'b10100110
`define EXE_MADDU_OP  8'b10101000
`define EXE_MSUB_OP  8'b10101010
`define EXE_MSUBU_OP  8'b10101011

`define EXE_DIV_OP  8'b00011010
`define EXE_DIVU_OP  8'b00011011

`define EXE_J_OP  8'b01001111
`define EXE_JAL_OP  8'b01010000
`define EXE_JALR_OP  8'b00001001
`define EXE_JR_OP  8'b00001000
`define EXE_BEQ_OP  8'b01010001
`define EXE_BGEZ_OP  8'b01000001
`define EXE_BGEZAL_OP  8'b01001011
`define EXE_BGTZ_OP  8'b01010100
`define EXE_BLEZ_OP  8'b01010011
`define EXE_BLTZ_OP  8'b01000000
`define EXE_BLTZAL_OP  8'b01001010
`define EXE_BNE_OP  8'b01010010

`define EXE_LB_OP  8'b11100000
`define EXE_LBU_OP  8'b11100100
`define EXE_LH_OP  8'b11100001
`define EXE_LHU_OP  8'b11100101
`define EXE_LL_OP  8'b11110000
`define EXE_LW_OP  8'b11100011
`define EXE_LWL_OP  8'b11100010
`define EXE_LWR_OP  8'b11100110
`define EXE_SB_OP  8'b11101000
`define EXE_SC_OP  8'b11111000
`define EXE_SH_OP  8'b11101001
`define EXE_SW_OP  8'b11101011
`define EXE_SWL_OP  8'b11101010
`define EXE_SWR_OP  8'b11101110

`define EXE_MFC0_OP 8'b01011101
`define EXE_MTC0_OP 8'b01100000

`define EXE_NOP_OP 8'b0000_0000

// AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_MOVE 3'b011	
`define EXE_RES_ARITHMETIC 3'b100	
`define EXE_RES_MUL 3'b101
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE 3'b111

`define EXE_RES_NOP 3'b000

// ************************** 与指令存储器 ROM 有关的宏定义 *************************

`define InstAddrBus 31:0 // ROM 的地址总线宽度
`define InstBus 31:0 // ROM 的数据总线宽度
`define InstMemNum 131017 // ROM 的实际大小为 128KB
`define InstMemNumLog2 17 // ROM 实际使用的地址线宽度

// ************************** 与数据存储器 DATA_RAM 有关的宏定义 *************************

`define DataAddrBus 31:0 // 地址总线宽度
`define DataBus 31:0 // 数据总线宽度
`define DataMemNum 131017 // RAM 的实际大小为 128KB
`define DataMemNumLog2 17 // RAM 实际使用的地址线宽度
`define ByteWidth 7:0 // 一个字节的宽度，8bit

// *********************** 与通用寄存器 Regfile 有关的宏定义 ***********************

`define RegAddrBus 4:0 // Regfile 模块的地址线宽度
`define RegBus 31:0 // Regfile 模块的数据线宽度
`define RegWidth 32 // 通用寄存器的宽度
`define DoubleRegWidth 64 // 两倍的通用寄存器的宽度
`define DoubleRegBus 63:0 // 两倍的通用寄存器的数据线宽度
`define RegNum 32 // 通用寄存器的数量
`define RegNumLog2 5 // 寻址通用寄存器使用的地址位数
`define NOPRegAddr 5'b00000

// *********************** 与流水线暂停有关的宏定义 ***********************
`define Stop 1'b1 // 流水线暂停
`define NoStop 1'b0 // 流水线继续
`define StallBus 5:0 // 控制信号宽度

//除法div
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0

// 转移指令
`define Branch 1'b1 // 转移
`define NotBranch 1'b0 // 不转移
`define InDelaySlot 1'b1 // 在延迟槽中
`define NotInDelaySlot 1'b0 // 不在延迟槽中

// 定义 CP0 中各个寄存器的地址
`define CP0_REG_COUNT 5'b01001 //可读写
`define CP0_REG_COMPARE 5'b01011 //可读写
`define CP0_REG_STATUS 5'b01100 //可读写
`define CP0_REG_CAUSE 5'b01101 //只读
`define CP0_REG_EPC 5'b01110 //可读写
`define CP0_REG_PRId 5'b01111 //只读
`define CP0_REG_CONFIG 5'b10000 //只读

