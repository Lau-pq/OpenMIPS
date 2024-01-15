`include "defines.v"

module id(
    input wire rst, // 复位信号
    input wire[`InstAddrBus] pc_i, // 译码阶段的指令对应地址 
    input wire[`InstBus] inst_i, // 译码阶段的指令

    // 读取的 Regfile 的值 
    input wire[`RegBus] reg1_data_i, // 从 Regfile 输入的第一个读寄存器端口的输入
    input wire[`RegBus] reg2_data_i, // 从 Regfile 输入的第二个读寄存器端口的输入

    // 处于执行阶段的指令的运算结果
    input wire ex_wreg_i, // 处于执行阶段的指令是否要写目的寄存器
    input wire[`RegBus] ex_wdata_i, // 处于执行阶段的指令要写的目的寄存器的地址
    input wire[`RegAddrBus] ex_wd_i, // 处于执行阶段的指令要写入目的寄存器的数据

    // 处于访存阶段的指令的运算结果
    input wire mem_wreg_i, // 处于访存阶段的指令是否有要写的目的寄存器
    input wire[`RegBus] mem_wdata_i, // 处于访存阶段的指令要写的目的寄存器地址
    input wire[`RegAddrBus] mem_wd_i, // 处于访存阶段的指令要写入目的寄存器的数据

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
wire[4:0] shamt = inst_i[10:6]; // R shamt
wire[5:0] func = inst_i[5:0]; // R func
wire[4:0] rs = inst_i[25:21]; // rs
wire[4:0] rt = inst_i[20:16]; // rt
wire[4:0] rd = inst_i[15:11]; // rd

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
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= `ZeroWord;
    end else begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= rd; // rd
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvalid;
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= rs; // rs 默认通过 Regfile 读端口1 读取的寄存器地址
        reg2_addr_o <= rt; // rt 默认通过 Regfile 读端口2 读取的寄存器地址
        imm <= `ZeroWord;

        case (op)
            `EXE_SPECIAL_INST: begin
                case (shamt)
                    5'b00000: begin
                        case (func)
                            `EXE_OR: begin // or 指令
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_OR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_AND: begin // and 指令
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_AND_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= `ReadEnable; 
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_XOR: begin // xor 指令
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_XOR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_NOR: begin // nor 指令
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_NOR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SLLV: begin // sllv 指令
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SLL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SRLV: begin // srlv 指令
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SRAV: begin // srav 指令
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRA_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SYNC: begin // sync 指令
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_NOP_OP;
                                alusel_o <= `EXE_RES_NOP;
                                reg1_read_o <= `ReadDisable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            default: begin
                            end  
                        endcase
                    end
                    default: begin
                    end  
                endcase
            end
            `EXE_ORI: begin // ori 指令
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {16'h0, inst_i[15:0]};
                wd_o <= rt;
                instvalid <= `InstValid; 
            end
            `EXE_ANDI: begin // andi 指令
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_AND_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {16'h0, inst_i[15:0]};
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_XORI: begin // xori 指令
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_XOR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {16'h0, inst_i[15:0]};
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_LUI: begin // lui 指令
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {inst_i[15:0], 16'h0};
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_PREF: begin // pref 指令
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_NOP_OP;
                alusel_o <= `EXE_RES_NOP;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
                instvalid <= `InstValid;
            end
            default: begin
            end
        endcase

        if (inst_i[31:21] == 11'b000_0000_0000) begin
            if (func == `EXE_SLL) begin // sll 指令
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SLL_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadEnable;
                imm[4:0] <= shamt;
                wd_o <= rd;
                instvalid <= `InstValid;
            end else if (func == `EXE_SRL) begin // srl 指令
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SRL_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadEnable;
                imm[4:0] <= shamt;
                wd_o <= rd;
                instvalid <= `InstValid;
            end else if (func == `EXE_SRA) begin // sra 指令
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SRA_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadEnable;
                imm[4:0] <= shamt;
                wd_o <= rd;
                instvalid <= `InstValid;
            end
        end
    end
end

// ******************* 第二段：确定进行运算的源操作数 1 *****************************
// 增加了两种情况
always @( *) begin
    if (rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if ((reg1_read_o == `ReadEnable) && (ex_wreg_i == `WriteEnable) && (ex_wd_i == reg1_addr_o)) begin
        // 如果 Regfile 模块读端口1要读取的寄存器就是执行阶段要写的目的寄存器，直接把执行阶段的结果 ex_wdata_i 作为 reg1_o 的值
        reg1_o <= ex_wdata_i; 
    end else if ((reg1_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_wd_i == reg1_addr_o)) begin
        // 如果 Regfile 模块读端口1要读取的寄存器就是访存阶段要写的目的寄存器，直接把访存阶段的结果 mem_wdata_i 作为 reg1_o 的值
        reg1_o <= mem_wdata_i;
    end else if (reg1_read_o == `ReadEnable) begin
        reg1_o <= reg1_data_i; // Regfile 读端口1的输出值
    end else if (reg1_read_o == `ReadDisable) begin
        reg1_o <= imm; // 立即数
    end else begin
        reg1_o <= `ZeroWord;
    end
end

// ******************* 第三段：确定进行运算的源操作数 2 *****************************
// 增加了两种情况
always @( *) begin
    if (rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if ((reg2_read_o == `ReadEnable) && (ex_wreg_i == `WriteEnable) && (ex_wd_i == reg2_addr_o)) begin
        // 如果 Regfile 模块读端口2要读取的寄存器就是执行阶段要写的目的寄存器，直接把执行阶段的结果 ex_wdata_i 作为 reg2_o 的值
        reg2_o <= ex_wdata_i; 
    end else if ((reg2_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_wd_i == reg2_addr_o)) begin
        // 如果 Regfile 模块读端口2要读取的寄存器就是访存阶段要写的目的寄存器，直接把访存阶段的结果 mem_wdata_i 作为 reg2_o 的值
        reg2_o <= mem_wdata_i;
    end else if (reg2_read_o == `ReadEnable) begin
        reg2_o <= reg2_data_i; // Regfile 读端口2的输出值
    end else if (reg2_read_o == `ReadDisable) begin
        reg2_o <= imm; // 立即数
    end else begin
        reg2_o <= `ZeroWord;
    end
end

endmodule