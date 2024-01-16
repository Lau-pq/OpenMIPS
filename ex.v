`include "defines.v"

module ex(
    input wire rst, // 复位信号
    input wire[`AluOpBus] aluop_i, // 执行阶段要进行的运算的子类型
    input wire[`AluSelBus] alusel_i, // 执行阶段要进行的运算的类型
    input wire[`RegBus] reg1_i, // 参与运算的源操作数1
    input wire[`RegBus] reg2_i, // 参与运算的源操作数2
    input wire[`RegAddrBus] wd_i, // 指令执行要写入的目的寄存器地址
    input wire wreg_i,  // 是否有要写入的目的寄存器

    // HILO 模块给出的 HI、LO 寄存器的值
    input wire[`RegBus] hi_i, // HILO 模块给出的 HI 寄存器的值
    input wire[`RegBus] lo_i, // HILO 模块给出的 LO 寄存器的值

    // 访存阶段的指令是否要写 HI、LO，用于检测 HI、LO寄存器带来的数据相关问题 
    input wire[`RegBus] mem_hi_i, // 处于访存阶段的指令要写入 HI 寄存器的值
    input wire[`RegBus] mem_lo_i, // 处于访存阶段的指令要写入 LO 寄存器的值
    input wire mem_whilo_i, // 处于访存阶段的指令是否要写 HI、LO寄存器

    // 回写阶段的指令是否要写 HI、LO，用于检测 HI、LO寄存器带来的数据相关问题
    input wire[`RegBus] wb_hi_i, // 处于回写阶段的指令要写入 HI 寄存器的值
    input wire[`RegBus] wb_lo_i, // 处于回写阶段的指令要写入 LO 寄存器的值
    input wire wb_whilo_i, // 处于回写阶段的指令是否要写 HI、LO寄存器

    // 处于执行阶段的指令对 HI、LO寄存器的写操作请求
    output reg[`RegBus] hi_o, // 执行阶段的指令要写入 HI 寄存器的值
    output reg[`RegBus] lo_o, // 执行阶段的指令要写入 LO 寄存器的值
    output reg whilo_o, // 执行阶段的指令是否要写 HI、LO寄存器

    // 执行的结果
    output reg[`RegAddrBus] wd_o, // 执行阶段的指令最终要写入的目的寄存器地址
    output reg wreg_o, // 执行阶段的指令最终是否有要写入的目的寄存器
    output reg[`RegBus] wdata_o // 执行阶段的指令最终要写入目的寄存器的值
);

reg[`RegBus] logicout; // 保存逻辑运算的结果
reg[`RegBus] shiftres; // 保存移位运算的结果
reg[`RegBus] moveres; // 保存移动操作的结果
reg[`RegBus] HI; // 保存 HI 寄存器的最新值
reg[`RegBus] LO; // 保存 LO寄存器的最新值

// ********** 得到最新的 HI、LO寄存器的值，解决数据相关问题 ***********
always @( *) begin
    if (rst == `RstEnable) begin
        {HI, LO} <= {`ZeroWord, `ZeroWord}; 
    end else if (mem_whilo_i == `WriteEnable) begin
        {HI, LO} <= {mem_hi_i, mem_lo_i}; // 访存阶段的指令要写 HI、LO寄存器
    end else if (wb_whilo_i == `WriteEnable) begin
        {HI, LO} <= {wb_hi_i, wb_lo_i}; // 回写阶段的指令要写 HI、LO寄存器
    end else begin
        {HI, LO} <= {hi_i, lo_i};
    end
end

// ********** 依据 aluop_i 指示的运算子类型进行运算 *************
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

// 进行移动运算
always @( *) begin
    if (rst == `RstEnable) begin
        moveres <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_MFHI_OP: begin // mfhi 指令，将 HI 的值作为移动操作的结果
                moveres <= HI;
            end
            `EXE_MFLO_OP: begin // mflo 指令，将 LO 的值作为移动操作的结果
                moveres <= LO;
            end
            `EXE_MOVZ_OP: begin // movz 指令，将 reg1_i 的值(rs)作为移动操作的结果
                moveres <= reg1_i;
            end
            `EXE_MOVN_OP: begin // movn 指令，将 reg1_i 的值(rs)作为移动操作的结果
                moveres <= reg1_i;
            end
            default: begin
                moveres <= `ZeroWord;
            end
        endcase
    end
end

//mthi, mtlo 指令，需要给出 whilo_o、hi_o、lo_o 的值
always @( *) begin
    if (rst == `RstEnable) begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end else if (aluop_i == `EXE_MTHI_OP) begin
        whilo_o <= `WriteEnable;
        hi_o <= reg1_i; // 写 HI 寄存器
        lo_o <= LO; // LO 保持不变
    end else if (aluop_i == `EXE_MTLO_OP) begin
        whilo_o <= `WriteEnable;
        hi_o <= HI; // HI 保持不变
        lo_o <= reg1_i; // 写 LO 寄存器
    end else begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end
end

// ***************** 依据 alusel_i 指示的运算类型，选择一个运算结果作为最终结果 ****************
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
        `EXE_RES_MOVE: begin // 选择移动运算结果为最终运算结果
            wdata_o <= moveres;
        end
        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end



endmodule