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

// **************************** 全与具体指令有关的宏定义 ****************************

`define EXE_ORI 6'b00_1101 // 指令 ori 的指令码
`define EXE_NOP 6'b00_0000

// AluOp
`define EXE_OR_OP 8'b0010_0101
`define EXE_NOP_OP 8'b0000_0000

// AluSel
`define EXE_RES_LOGIC 3'b001

`define EXE_RES_NOP 3'b000

// ************************** 与指令存储器 ROM 有关的宏定义 *************************

`define InstAddrBus 31:0 // ROM 的地址总线宽度
`define InstBus 31:0 // ROM 的数据总线宽度
`define InstMemNum 131017 // ROM 的实际大小为 128KB
`define InstMemNumLog2 17 // ROM 实际使用的地址线宽度

// *********************** 与通用寄存器 Regfile 有关的宏定义 ***********************

`define RegAddrBus 4:0 // Regfile 模块的地址线宽度
`define RegBus 31:0 // Regfile 模块的数据线宽度
`define RegWidth 32 // 通用寄存器的宽度
`define DoubleRegWidth 64 // 两倍的通用寄存器的宽度
`define DoubleRegBus 63:0 // 两倍的通用寄存器的数据线宽度
`define RegNum 32 // 通用寄存器的数量
`define RegNumLog2 5 // 寻址通用寄存器使用的地址位数
`define NOPRegAddr 5'b0_0000
