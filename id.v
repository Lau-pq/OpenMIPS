`include "defines.v"

module id(
    input wire rst, // 复位信号
    input wire[`InstAddrBus] pc_i, // 译码阶段的指令对应地址 
    input wire[`InstBus] inst_i, // 译码阶段的指令

    // 读取的 Regfile 的值 
    input wire[`RegBus] reg1_data_i, // 从 Regfile 输入的第一个读寄存器端口的输入
    input wire[`RegBus] reg2_data_i, // 从 Regfile 输入的第二个读寄存器端口的输入

    // 输出到 Regfile 的信息
    output reg reg1_read_o, // Regfile 模块的第一个读寄存器端口的读使能信号
    output reg reg2_read_o, // Regfile 模块的第二个读寄存器端口的读使能信号
    output reg[`RegAddrBus] reg1_addr_o, // Regfile 模块的第一个读寄存器端口的读地址信号
    output reg[`RegAddrBus] reg2_addr_o, // Regfile 模块的第二个读寄存器端口的读地址信号

    // 送到执行阶段的信息
    output reg[`AluOpBus] aluop_o, // 译码阶段的指令要进行的运算的子类型
    output reg[`AluSelBus] alusel_o, // 译码阶段的指令要进行的运算的类型
    output reg[`RegBus] reg1_o,// 译码阶段的指令要进行的运算的源操作数 1
    output reg[`RegBus] reg2_o, // 译码阶段的指令要进行的运算的源操作数 2
    output reg[`RegAddrBus] wd_o, // 译码阶段的指令要写入的目的寄存器地址
    output reg wreg_o // 译码阶段的指令是否有要写入的目的寄存器
);

// 取得指令的指令码，功能码
// 对于 ori 指令只需通过判断第 26-31 bit的值，即可判断是否是 ori 指令
wire[5:0] op = inst_i[31:26]; // op
wire[4:0] op2 = inst_i[10:6]; // R shamt
wire[5:0] op3 = inst_i[5:0]; // R func
wire[4:0] op4 = inst_i[20:16]; // rt

// 保存指令执行需要的立即数
reg[`RegBus] imm;

// 指示指令是否有效
reg instvalid;

// *************** 第一段：对指令进行译码 ***********************
always @( *) begin
    if (rst == `RstEnable) begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= `ZeroWord;
    end else begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= inst_i[15:11]; // rd
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvalid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21]; // rs 默认通过 Regfile 读端口1 读取的寄存器地址
        reg2_addr_o <= inst_i[20:16]; // rt 默认通过 Regfile 读端口2 读取的寄存器地址
        imm <= `ZeroWord;

        case (op)
            `EXE_ORI: begin // 根据 op 值判断是否是 ori 指令
                // ori 指令需要将结果写入目的寄存器，所以 wreg_o 为 WriteEnable
                wreg_o <= `WriteEnable;

                // 运算的子类型是逻辑 “或” 运算
                aluop_o <= `EXE_OR_OP;

                // 运算类型是逻辑运算
                alusel_o <= `EXE_RES_LOGIC;

                // 需要通过 Regfile 的读端口1 读取寄存器
                reg1_read_o <= 1'b1;

                // 不需要通过 Regfile 的读端口2 读取寄存器
                reg2_read_o <= 1'b0;

                // 指令执行需要的立即数
                imm <= {16'h0, inst_i[15:0]}; // 立即数无符号扩展

                // 指令执行要写的目的寄存器地址
                wd_o <= inst_i[20:16]; // rt

                // ori 指令是有效指令
                instvalid <= `InstValid;
            end
            default: begin
            end
        endcase
    end
end

// ******************* 第二段：确定进行运算的源操作数 1 *****************************8
always @( *) begin
    if (rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if (reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i; // Regfile 读端口1的输出值
    end else if (reg1_read_o == 1'b0) begin
        reg1_o <= imm; // 立即数
    end else begin
        reg1_o <= `ZeroWord;
    end
end

// ******************* 第三段：确定进行运算的源操作数 2 *****************************8
always @( *) begin
    if (rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if (reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i; // Regfile 读端口2的输出值
    end else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm; // 立即数
    end else begin
        reg2_o <= `ZeroWord;
    end
end

endmodule