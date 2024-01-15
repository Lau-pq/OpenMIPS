`include "defines.v"

module ex(
    input wire rst, // 复位信号
    input wire[`AluOpBus] aluop_i, // 执行阶段要进行的运算的子类型
    input wire[`AluSelBus] alusel_i, // 执行阶段要进行的运算的类型
    input wire[`RegBus] reg1_i, // 参与运算的源操作数1
    input wire[`RegBus] reg2_i, // 参与运算的源操作数2
    input wire[`RegAddrBus] wd_i, // 指令执行要写入的目的寄存器地址
    input wire wreg_i,  // 是否有要写入的目的寄存器

    // 执行的结果
    output reg[`RegAddrBus] wd_o, // 执行阶段的指令最终要写入的目的寄存器地址
    output reg wreg_o, // 执行阶段的指令最终是否有要写入的目的寄存器
    output reg[`RegBus] wdata_o // 执行阶段的指令最终要写入目的寄存器的值
);

reg[`RegBus] logicout; // 保存逻辑运算的结果
reg[`RegBus] shiftres; // 保存移位运算的结果

// ********** 第一段：依据 aluop_i 指示的运算子类型进行运算 *************
// 进行逻辑运算
always @( *) begin
    if (rst == `RstEnable) begin
        logicout <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_OR_OP: begin // 逻辑或运算
                logicout <= reg1_i | reg2_i;
            end
            `EXE_AND_OP: begin // 逻辑与运算
                logicout <= reg1_i & reg2_i;
            end
            `EXE_NOR_OP: begin // 逻辑或非运算
               logicout <= ~(reg1_i | reg2_i);
            end
            `EXE_XOR_OP: begin // 逻辑异或运算
                logicout <= reg1_i ^ reg2_i;
            end
            default: begin
                logicout <= `ZeroWord;
            end
        endcase
    end
end

// 进行移位运算
always @( *) begin
    if (rst == `RstEnable) begin
        shiftres <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_SLL_OP: begin // 逻辑左移
                shiftres <= reg2_i << reg1_i[4:0];
            end
            `EXE_SRL_OP: begin // 逻辑右移
                shiftres <= reg2_i >> reg1_i[4:0];
            end
            `EXE_SRA_OP: begin // 算术右移
                shiftres <= ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
            end
            default: begin
                shiftres <= `ZeroWord;
            end   
        endcase
    end
end

// ***************** 第二段：依据 alusel_i 指示的运算类型，选择一个运算结果作为最终结果 ****************
always @( *) begin
    wd_o <= wd_i; // wd_o 等于 wd_i，要写的目的寄存器地址
    wreg_o <= wreg_i; // wreg_o 等于 wreg_i，表示是否要写目的寄存器
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout; // 选择逻辑运算结果为最终运算结果
        end
        `EXE_RES_SHIFT: begin
            wdata_o <= shiftres; // 选择移位运算结果为最终运算结果
        end
        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end

endmodule