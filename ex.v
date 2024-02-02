`include "defines.v"

module ex(
    input wire rst, // 复位信号
    input wire[`AluOpBus] aluop_i, // 执行阶段要进行的运算的子类型
    input wire[`AluSelBus] alusel_i, // 执行阶段要进行的运算的类型
    input wire[`RegBus] reg1_i, // 参与运算的源操作数1
    input wire[`RegBus] reg2_i, // 参与运算的源操作数2
    input wire[`RegAddrBus] wd_i, // 指令执行要写入的目的寄存器地址
    input wire wreg_i,  // 是否有要写入的目的寄存器

    // 关于异常
    input wire[31:0] excepttype_i, // 译码阶段收集到的异常信息
    input wire[`RegBus] current_inst_address_i, // 执行阶段指令的地址

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

    input wire[`DoubleRegBus] hilo_temp_i, // 第一个执行周期得到的乘法结果
    input wire[1:0] cnt_i, // 当前处于执行阶段的第几个时钟周期

    // 来自除法模块的输入
    input wire[`DoubleRegBus] div_result_i, // 除法运算结果
    input wire div_ready_i, // 除法运算是否结束

    input wire[`RegBus] link_address_i, // 处于执行阶段的转移指令要保存的返回地址
    input wire is_in_delayslot_i, // 当前执行阶段的指令是否位于延迟槽

    input wire[`RegBus] inst_i, // 当前处于执行阶段的指令

    // 访存阶段的指令是否要写 CP0 中的寄存器，用来检测数据相关
    input wire mem_cp0_reg_we, // 访存阶段的指令是否要写 CP0 中的寄存器
    input wire[4:0] mem_cp0_reg_write_addr, // 访存阶段的指令要写的 CP0 中寄存器的地址
    input wire[`RegBus] mem_cp0_reg_data, // 访存阶段的指令要写入 CP0 中寄存器的数据

    // 回写阶段的指令是否要写 CP0 中的寄存器，用来检测数据相关
    input wire wb_cp0_reg_we, // 访存阶段的指令是否要写 CP0 中的寄存器
    input wire[4:0] wb_cp0_reg_write_addr, // 访存阶段的指令要写的 CP0 中寄存器的地址
    input wire[`RegBus] wb_cp0_reg_data, // 访存阶段的指令要写入 CP0 中寄存器的数据

    // 与 CP0 直接相连，用于读取其中指定寄存器的值
    input wire[`RegBus] cp0_reg_data_i, 
    output reg[4:0] cp0_reg_read_addr_o, 

    // 向流水线下一级传递，用于写 CP0 中的指定寄存器
    output reg cp0_reg_we_o, 
    output reg[4:0] cp0_reg_write_addr_o, 
    output reg[`RegBus] cp0_reg_data_o,  

    // 处于执行阶段的指令对 HI、LO寄存器的写操作请求
    output reg[`RegBus] hi_o, // 执行阶段的指令要写入 HI 寄存器的值
    output reg[`RegBus] lo_o, // 执行阶段的指令要写入 LO 寄存器的值
    output reg whilo_o, // 执行阶段的指令是否要写 HI、LO寄存器

    // 执行的结果
    output reg[`RegAddrBus] wd_o, // 执行阶段的指令最终要写入的目的寄存器地址
    output reg wreg_o, // 执行阶段的指令最终是否有要写入的目的寄存器
    output reg[`RegBus] wdata_o, // 执行阶段的指令最终要写入目的寄存器的值

    output reg[`DoubleRegBus] hilo_temp_o, // 第一个执行周期得到的乘法结果
    output reg[1:0] cnt_o, // 下一个时钟周期处于执行阶段的第几个时钟周期

    output reg[`RegBus] div_opdata1_o, // 被除数
    output reg[`RegBus] div_opdata2_o, // 除数
    output reg div_start_o, // 是否开始除法运算
    output reg signed_div_o, // 是否是有符号除法，为 1表示是有符号除法

    output reg stallreq,  // 流实现是否暂停

    // 为加载、存储指令准备的
    output wire[`AluOpBus] aluop_o, // 执行阶段的指令要进行的运算子类型
    output wire[`RegBus] mem_addr_o, // 加载、存储指令对应的存储器地址
    output wire[`RegBus] reg2_o, // 存储指令要存储的数据，或者 lwl、lwr 指令要加载到的目的寄存器的原始值

    // 关于异常
    output wire[31:0] excepttype_o, // 译码阶段、执行阶段收集到的异常信息
    output wire is_in_delayslot_o, // 执行阶段的指令是否是延迟槽指令
    output wire[`RegBus] current_inst_address_o // 执行阶段指令的地址
);

reg[`RegBus] logicout; // 保存逻辑运算的结果
reg[`RegBus] shiftres; // 保存移位运算的结果
reg[`RegBus] moveres; // 保存移动操作的结果
reg[`RegBus] arithmeticres; // 保存算术运算的结果
reg[`DoubleRegBus] mulres; // 保存乘法结果，宽度为 64位
reg[`RegBus] HI; // 保存 HI 寄存器的最新值
reg[`RegBus] LO; // 保存 LO寄存器的最新值

wire ov_sum; // 保存溢出情况
wire reg1_eq_reg2; // 第一个操作数是否等于第二个操作数
wire reg1_lt_reg2; // 第一个操作数是否小于第二个操作数
wire[`RegBus] reg2_i_mux; // 保存输入的第二个操作数 reg2_i 的补码
wire[`RegBus] reg1_i_not; // 保存输入的第一个操作数 reg1_i 取反后的值
wire[`RegBus] result_sum; // 保存加法结果
wire[`RegBus] opdata1_mult; // 乘法操作中的被乘数
wire[`RegBus] opdata2_mult; // 乘法操作中的乘数
wire[`DoubleRegBus] hilo_temp; // 临时保存乘法结果，宽度为 64位
reg[`DoubleRegBus] hilo_temp1; // 最终运算结果
reg stallreq_for_madd_msub; // 是否由于乘累加、乘累减运算导致流水线暂停
reg stallreq_for_div; // 是否由于除法运算导致流水线暂停

reg trapassert; // 表示是否有自陷异常
reg ovassert; // 表示是否有溢出异常

// 第 10 bit 表示是否有自陷异常，第 11 bit 表示是否有溢出异常
assign excepttype_o = {excepttype_i[31:12], ovassert, trapassert, excepttype_i[9:8], 8'h00};
assign is_in_delayslot_o = is_in_delayslot_i;
assign current_inst_address_o = current_inst_address_i;

// ******************** 计算变量的值 ***********************
// 减法 或 有符号比较 reg2_i_mux 为 reg2_i 补码，否则为 reg2_i
assign reg2_i_mux = (
    (aluop_i == `EXE_SUB_OP) || 
    (aluop_i == `EXE_SUBU_OP) || 
    (aluop_i == `EXE_SLT_OP) ||
    (aluop_i == `EXE_TLT_OP) || 
    (aluop_i == `EXE_TLTI_OP) || 
    (aluop_i == `EXE_TGE_OP) ||
    (aluop_i == `EXE_TGEI_OP)) ? 
    (~reg2_i)+1 : reg2_i;  

// 加法 result_sum 为加法运算结果
// 减法 result_sum 为减法运算结果
// 有符号比较运算 result_sum 减法运算结果 判断是否小于 0 

assign result_sum = reg1_i + reg2_i_mux;

// 计算是否溢出
assign ov_sum = 
    ((!reg1_i[31] && !reg2_i_mux[31]) && // reg1_i 正, reg2_i_mux 正
    result_sum[31]) || // 两者之和为负数
    ((reg1_i[31] && reg2_i_mux[31]) && // reg1_i 负, reg2_i_mux 负
    (!result_sum[31])); // 两者之和为正数

// 计算操作数 1是否小于操作数 2
assign reg1_lt_reg2 = (
    (aluop_i == `EXE_SLT_OP) ||
    (aluop_i == `EXE_TLT_OP) ||
    (aluop_i == `EXE_TLTI_OP) ||
    (aluop_i == `EXE_TGE_OP) ||
    (aluop_i == `EXE_TGEI_OP)) ? // 有符号比较运算
    ((reg1_i[31] && !reg2_i[31]) || // reg1_i负, reg2_i正, reg1_i < reg2_i
    (!reg1_i[31] && !reg2_i[31] && result_sum[31]) || // reg1_i正, reg2_i正, 差 < 0
    (reg1_i[31] && reg2_i[31] && result_sum[31])) // reg1_i负, reg2_i负, 差 < 0
    : (reg1_i < reg2_i); // 无符号数比较

// 对操作数 1 逐位取反，赋给 reg1_i_not
assign reg1_i_not = ~reg1_i;

// 取得乘法运算的被乘数，如果是有符号乘法且被乘数是负数，取补码
assign opdata1_mult = 
    (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) ||
    (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) &&
    (reg1_i[31])) ? (~reg1_i + 1) : reg1_i;

// 取得乘法运算的乘数，如果是有符号乘法且乘数是负数，取补码
assign opdata2_mult = 
    (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) ||
    (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) &&
    (reg2_i[31])) ? (~reg2_i + 1) : reg2_i;

// 得到临时乘法结果，保存在变量 hilo_temp 中
assign hilo_temp = opdata1_mult * opdata2_mult;

// aluop_o 会传递到访存阶段，届时将利用其确定加载、存储类型
assign aluop_o = aluop_i;

assign mem_addr_o = reg1_i + {{16{inst_i[15]}}, inst_i[15:0]}; // reg1_i为 base、inst_i[15:0] 为 offset

assign reg2_o = reg2_i;

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
            `EXE_MFC0_OP: begin
                cp0_reg_read_addr_o <= inst_i[15:11]; // 要从 CP0 中读取的寄存器的地址
                moveres <= cp0_reg_data_i; // 读取到的 CP0 中指定寄存器的值

                if (mem_cp0_reg_we == `WriteEnable && mem_cp0_reg_write_addr == inst_i[15:11]) begin // 判断是否存在数据相关
                    moveres <= mem_cp0_reg_data; // 与访存阶段存在数据相关
                end else if (wb_cp0_reg_we == `WriteEnable && wb_cp0_reg_write_addr == inst_i[15:11]) begin
                    moveres <= wb_cp0_reg_data; // 与回写阶段存在数据相关
                end
            end
            default: begin
                moveres <= `ZeroWord;
            end
        endcase
    end
end

// 进行算术运算
always @( *) begin
    if (rst == `RstEnable) begin
        arithmeticres <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_SLT_OP, `EXE_SLTU_OP: begin
                arithmeticres <= reg1_lt_reg2; // 比较运算
            end
            `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
                arithmeticres <= result_sum; // 加法运算
            end
            `EXE_SUB_OP, `EXE_SUBU_OP: begin 
                arithmeticres <= result_sum; // 减法运算
            end
            `EXE_CLZ_OP: begin // 计数运算 clz
                arithmeticres <= reg1_i[31] ? 0 : reg1_i[30] ? 1 :
                                reg1_i[29] ? 2 : reg1_i[28] ? 3 :
                                reg1_i[27] ? 4 : reg1_i[26] ? 5 :
                                reg1_i[25] ? 6 : reg1_i[24] ? 7 :
                                reg1_i[23] ? 8 : reg1_i[22] ? 9 :
                                reg1_i[21] ? 10 : reg1_i[20] ? 11 :
                                reg1_i[19] ? 12 : reg1_i[18] ? 13 :
                                reg1_i[17] ? 14 : reg1_i[16] ? 15 :
                                reg1_i[15] ? 16 : reg1_i[14] ? 17 :
                                reg1_i[13] ? 18 : reg1_i[12] ? 19 :
                                reg1_i[11] ? 20 : reg1_i[10] ? 21 :
                                reg1_i[9] ? 22 : reg1_i[8] ? 23 :
                                reg1_i[7] ? 24 : reg1_i[6] ? 25 :
                                reg1_i[5] ? 26 : reg1_i[4] ? 27 :
                                reg1_i[3] ? 28 : reg1_i[2] ? 29 :
                                reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32;
            end
            `EXE_CLO_OP: begin // 计数运算 clo
                arithmeticres <= reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 :
                                reg1_i_not[29] ? 2 : reg1_i_not[28] ? 3 :
                                reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
                                reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 :
                                reg1_i_not[23] ? 8 : reg1_i_not[22] ? 9 :
                                reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
                                reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 :
                                reg1_i_not[17] ? 14 : reg1_i_not[16] ? 15 :
                                reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 :
                                reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 :
                                reg1_i_not[11] ? 20 : reg1_i_not[10] ? 21 :
                                reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 :
                                reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 :
                                reg1_i_not[5] ? 26 : reg1_i_not[4] ? 27 :
                                reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 :
                                reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32;
            end
            default: begin
                arithmeticres <= `ZeroWord;
            end
        endcase
    end
end

// 进行乘法运算
always @( *) begin
    if (rst == `RstEnable) begin
        mulres <= {`ZeroWord, `ZeroWord};
    end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP) ||
                (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) begin // 有符号乘法
        if (reg1_i[31] ^ reg2_i[31]) begin // 异号
            mulres <= ~hilo_temp + 1; // 补码
        end else begin
            mulres <= hilo_temp;
        end
    end else begin
        mulres <= hilo_temp; // 无符号乘法
    end
end

// madd、maddu、msub、msubu 指令
always @( *) begin
    if (rst == `RstEnable) begin
        hilo_temp_o <= {`ZeroWord, `ZeroWord};
        cnt_o <= 2'b00;
        stallreq_for_madd_msub <= `NoStop;
    end else begin
        case (aluop_i)
            `EXE_MADD_OP, `EXE_MADDU_OP: begin // madd、maddu 指令
                if (cnt_i == 2'b00) begin // 执行阶段第一个时钟周期 
                    hilo_temp_o <= mulres;
                    cnt_o <= 2'b01;
                    hilo_temp1 <= {`ZeroWord, `ZeroWord};
                    stallreq_for_madd_msub <= `Stop;
                end else if (cnt_i == 2'b01) begin // 执行阶段的第二个时钟周期
                    hilo_temp_o <= {`ZeroWord, `ZeroWord};
                    cnt_o <= 2'b10;
                    hilo_temp1 <= hilo_temp_i + {HI, LO};
                    stallreq_for_madd_msub <= `NoStop;
                end
            end
            `EXE_MSUB_OP, `EXE_MSUBU_OP: begin // msub、msubu 指令
                if (cnt_i == 2'b00) begin // 执行阶段第一个时钟周期 
                    hilo_temp_o <= ~mulres + 1;
                    cnt_o <= 2'b01;
                    hilo_temp1 <= {`ZeroWord, `ZeroWord};
                    stallreq_for_madd_msub <= `Stop;
                end else if (cnt_i == 2'b01) begin // 执行阶段的第二个时钟周期
                    hilo_temp_o <= {`ZeroWord, `ZeroWord};
                    cnt_o <= 2'b10;
                    hilo_temp1 <= hilo_temp_i + {HI, LO};
                    stallreq_for_madd_msub <= `NoStop;
                end
            end
            default: begin
                hilo_temp_o <= {`ZeroWord, `ZeroWord};
                cnt_o <= 2'b00;
                stallreq_for_madd_msub <= `NoStop;
            end
        endcase
    end
end

// 输出 DIV 模块控制信息，获取 DIV 模块给出的结果
always @( *) begin
    if (rst == `RstEnable) begin
        stallreq_for_div <= `NoStop;
        div_opdata1_o <= `ZeroWord;
        div_opdata2_o <= `ZeroWord;
        div_start_o <= `DivStop;
        signed_div_o <= 1'b0;
    end else begin
        case (aluop_i)
            `EXE_DIV_OP: begin // div 指令
                if (div_ready_i == `DivResultNotReady) begin
                    div_opdata1_o <= reg1_i; // 被除数
                    div_opdata2_o <= reg2_i; // 除数
                    div_start_o <= `DivStart; // 开始除法运算
                    signed_div_o <= 1'b1; // 有符号除法
                    stallreq_for_div <= `Stop; // 请求流水线暂停
                end else if (div_ready_i == `DivResultReady) begin
                    div_opdata1_o <= reg1_i; // 被除数
                    div_opdata2_o <= reg2_i; // 除数
                    div_start_o <= `DivStop; // 结束除法运算
                    signed_div_o <= 1'b1; // 有符号除法
                    stallreq_for_div <= `NoStop; // 不再请求流水线暂停
                end else begin
                    div_opdata1_o <= `ZeroWord;
                    div_opdata2_o <= `ZeroWord;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b0;
                    stallreq_for_div <= `NoStop;
                end
            end
            `EXE_DIVU_OP: begin // divu 指令
                if (div_ready_i == `DivResultNotReady) begin
                    div_opdata1_o <= reg1_i; // 被除数
                    div_opdata2_o <= reg2_i; // 除数
                    div_start_o <= `DivStart; // 开始除法运算
                    signed_div_o <= 1'b0; // 无符号除法
                    stallreq_for_div <= `Stop; // 请求流水线暂停
                end else if (div_ready_i == `DivResultReady) begin
                    div_opdata1_o <= reg1_i; // 被除数
                    div_opdata2_o <= reg2_i; // 除数
                    div_start_o <= `DivStop; // 结束除法运算
                    signed_div_o <= 1'b0; // 无符号除法
                    stallreq_for_div <= `NoStop; // 不再请求流水线暂停
                end else begin
                    div_opdata1_o <= `ZeroWord;
                    div_opdata2_o <= `ZeroWord;
                    div_start_o <= `DivStop;
                    signed_div_o <= 1'b0;
                    stallreq_for_div <= `NoStop;
                end
            end
            default: begin
                div_opdata1_o <= `ZeroWord;
                div_opdata2_o <= `ZeroWord;
                div_start_o <= `DivStop;
                signed_div_o <= 1'b0;
                stallreq_for_div <= `NoStop;
            end  
        endcase
    end
end

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

//HI、LO 寄存器写信息
always @( *) begin
    if (rst == `RstEnable) begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end else if ((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
        whilo_o <= `WriteEnable;
        hi_o <= hilo_temp1[63:32];
        lo_o <= hilo_temp1[31:0];
    end else if ((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin
        whilo_o <= `WriteEnable;
        hi_o <= hilo_temp1[63:32];
        lo_o <= hilo_temp1[31:0];
    end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin // mult、multu 指令
        whilo_o <= `WriteEnable;
        hi_o <= mulres[63:32];
        lo_o <= mulres[31:0];
    end else if (aluop_i == `EXE_MTHI_OP) begin
        whilo_o <= `WriteEnable;
        hi_o <= reg1_i; // 写 HI 寄存器
        lo_o <= LO; // LO 保持不变
    end else if (aluop_i == `EXE_MTLO_OP) begin
        whilo_o <= `WriteEnable;
        hi_o <= HI; // HI 保持不变
        lo_o <= reg1_i; // 写 LO 寄存器
    end else if ((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
        whilo_o <= `WriteEnable;
        hi_o <= div_result_i[63:32];
        lo_o <= div_result_i[31:0];
    end else begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end
end

// ***************** 依据 alusel_i 指示的运算类型，选择一个运算结果作为最终结果 ****************
always @( *) begin
    wd_o <= wd_i; // wd_o 等于 wd_i，要写的目的寄存器地址
    if (((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
        wreg_o <= `WriteDisable; // add、addi、sub 指令发生溢出, 不写目的寄存器 
        ovassert <= 1'b1; // 发生了溢出异常
    end else begin
        wreg_o <= wreg_i; // wreg_o 等于 wreg_i，表示是否要写目的寄存器 
        ovassert <= 1'b0; // 未发生溢出异常       
    end
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout; // 选择逻辑运算结果为最终运算结果
        end
        `EXE_RES_SHIFT: begin
            wdata_o <= shiftres; // 选择移位运算结果为最终运算结果
        end
        `EXE_RES_MOVE: begin 
            wdata_o <= moveres; // 选择移动运算结果为最终运算结果
        end 
        `EXE_RES_ARITHMETIC: begin
            wdata_o <= arithmeticres; // 除乘法外的简单算数操作指令
        end
        `EXE_RES_MUL: begin
            wdata_o <= mulres[31:0]; // 乘法指令 mul
        end
        `EXE_RES_JUMP_BRANCH: begin
            wdata_o <= link_address_i; // 跳转指令
        end
        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end

// **************** 暂停流水线 *****************
always @( *) begin
    stallreq = stallreq_for_madd_msub || stallreq_for_div;
end

// ************** 给出 mtc0 指令的执行效果 ****************
always @( *) begin
    if (rst == `RstEnable) begin
        cp0_reg_write_addr_o <= 5'b00000;
        cp0_reg_we_o <= `WriteDisable;
        cp0_reg_data_o <= `ZeroWord;
    end else if (aluop_i == `EXE_MTC0_OP) begin // 是 mtc0 指令
        cp0_reg_write_addr_o <= inst_i[15:11];
        cp0_reg_we_o <= `WriteEnable;
        cp0_reg_data_o <= reg1_i;
    end else begin
        cp0_reg_write_addr_o <= 5'b00000;
        cp0_reg_we_o <= `WriteDisable;
        cp0_reg_data_o <= `ZeroWord;
    end
end

// ************** 判断是否发生自陷异常 ******************
always @( *) begin
    if (rst == `RstEnable) begin
        trapassert <= `TrapNotAssert;
    end else begin
        trapassert <= `TrapNotAssert; // 默认没有自陷异常
        case (aluop_i)
            // teq、teqi 指令
            `EXE_TEQ_OP, `EXE_TEQI_OP: begin 
                if (reg1_i == reg2_i) begin
                    trapassert <= `TrapAssert;
                end
            end
            // tge、tgei、tgeiu、tgeu 指令
            `EXE_TGE_OP, `EXE_TGEI_OP, `EXE_TGEIU_OP, `EXE_TGEU_OP: begin 
                if (~reg1_lt_reg2) begin
                    trapassert <= `TrapAssert;
                end
            end
            // tlt、tlti、tltiu、tltu 指令
            `EXE_TLT_OP, `EXE_TLTI_OP, `EXE_TLTIU_OP, `EXE_TLTU_OP: begin 
                if (reg1_lt_reg2) begin
                    trapassert <= `TrapAssert;
                end
            end
            // tne、tnei 指令
            `EXE_TNE_OP, `EXE_TNEI_OP: begin
                if (reg1_i != reg2_i) begin
                    trapassert <= `TrapAssert;
                end
            end
            default: begin
                trapassert <= `TrapNotAssert;
            end  
        endcase
    end
end

endmodule