`include "defines.v"

module ex_mem(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    input wire flush, // 流水线清楚信号 

    // 来自执行阶段的信息
    input wire[`RegAddrBus] ex_wd, // 执行阶段的指令执行后要写入的目的寄存器地址
    input wire ex_wreg, // 执行阶段的指令执行后是否有要写入的目的寄存器
    input wire[`RegBus] ex_wdata, // 执行阶段的指令执行后要写入目的寄存器的值
    input wire[`RegBus] ex_hi, // 执行阶段的指令要写入 HI 寄存器的值
    input wire[`RegBus] ex_lo, // 执行阶段的指令要写入 LO 寄存器的值
    input wire ex_whilo, // 执行阶段的指令是否要写 HI、LO 寄存器

    input wire ex_cp0_reg_we, // 执行阶段的指令是否要写 CP0 中的寄存器
    input wire[4:0] ex_cp0_reg_write_addr, // 执行阶段的指令要写的 CP0 中寄存器的地址
    input wire[`RegBus] ex_cp0_reg_data, // 执行阶段的指令要写入 CP0 中寄存器的数据

    input wire[31:0] ex_excepttype, // 译码、执行阶段收集到的异常信息
    input wire ex_is_in_delayslot, // 执行阶段的指令是否是延迟槽指令
    input wire[`RegBus] ex_current_inst_address, // 执行阶段指令的地址

    // 来自控制模块的信息
    input wire[`StallBus] stall,

    input wire[`DoubleRegBus] hilo_i, // 保存的乘法结果
    input wire[1:0] cnt_i, // 下一个时钟周期是执行阶段的第几个时钟周期

    // 为实现加载、存储指令而添加的输入接口
    input wire[`AluOpBus] ex_aluop, // 执行阶段的指令要进行的运算子类型
    input wire[`RegBus] ex_mem_addr, // 执行阶段的加载、存储指令对应的存储器地址
    input wire[`RegBus] ex_reg2, // 执行阶段的存储指令要存储的数据，或者 lwl、lwr 指令要写入的目的寄存器的原始值

    // 送到访存阶段的信息
    output reg[`RegAddrBus] mem_wd, // 访存阶段的指令要写入的目的寄存器地址
    output reg mem_wreg, // 访存阶段的指令是否有要写入的目的寄存器
    output reg[`RegBus] mem_wdata, // 访存阶段的指令要写入目的寄存器的值
    output reg[`RegBus] mem_hi, // 访存阶段的指令要写入 HI 寄存器的值
    output reg[`RegBus] mem_lo, // 访存阶段的指令要写入 LO 寄存器的值
    output reg mem_whilo,  // 访存阶段的指令是否要写 HI、LO寄存器

    output reg mem_cp0_reg_we, // 访存阶段的指令是否要写 CP0 中的寄存器
    output reg[4:0] mem_cp0_reg_write_addr, // 访存阶段的指令是否要写的 CP0 中寄存器的地址
    output reg[`RegBus] mem_cp0_reg_data, // 访存阶段的指令要写入 CP0 中寄存器的数据

    output reg[`DoubleRegBus] hilo_o, // 保存的乘法结果
    output reg[1:0] cnt_o, // 当前处于执行阶段的第几个时钟周期 

    output reg[31:0] mem_excepttype, // 译码、执行阶段收集到的异常信息
    output reg mem_is_in_delayslot, // 访存阶段的指令是否是延迟槽指令
    output reg[`RegBus] mem_current_inst_address, // 访存阶段指令的地址

    // 为实现加载、存储指令而添加的输出端口
    output reg[`AluOpBus] mem_aluop, // 访存阶段的指令要进行的运算的子类型
    output reg[`RegBus] mem_mem_addr, // 访存阶段的加载、存储指令对应的存储器地址
    output reg[`RegBus] mem_reg2 // 访存阶段的存储指令要存储的数据，或者 lwl、lwr 指令要写入的目的寄存器的原始值
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin // 复位
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= {`ZeroWord, `ZeroWord};
        cnt_o <= 2'b00;
        mem_aluop <= `EXE_NOP_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2 <= `ZeroWord;
        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= 5'b00000; 
        mem_cp0_reg_data <= `ZeroWord; 
        mem_excepttype <= `ZeroWord;
        mem_is_in_delayslot <= `NotInDelaySlot;
        mem_current_inst_address <= `ZeroWord;
    end else if (flush == 1'b1) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= {`ZeroWord, `ZeroWord};
        cnt_o <= 2'b00;
        mem_aluop <= `EXE_NOP_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2 <= `ZeroWord;
        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= 5'b00000; 
        mem_cp0_reg_data <= `ZeroWord; 
        mem_excepttype <= `ZeroWord;
        mem_is_in_delayslot <= `NotInDelaySlot;
        mem_current_inst_address <= `ZeroWord;
    end else if ((stall[3] == `Stop) && (stall[4] == `NoStop)) begin // 执行暂停 访存继续 空指令
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= hilo_i; 
        cnt_o <= cnt_i;
        mem_aluop <= `EXE_NOP_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2 <= `ZeroWord;
        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= 5'b00000; 
        mem_cp0_reg_data <= `ZeroWord; 
        mem_excepttype <= `ZeroWord;
        mem_is_in_delayslot <= `NotInDelaySlot;
        mem_current_inst_address <= `ZeroWord;
    end else if (stall[3] == `NoStop) begin // 执行继续
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;
        hilo_o <= {`ZeroWord, `ZeroWord}; 
        cnt_o <= 2'b00;
        mem_aluop <= ex_aluop;
        mem_mem_addr <= ex_mem_addr;
        mem_reg2 <= ex_reg2;
        
        // 在执行阶段没有暂停的时候，将对 CP0 中寄存器的写信息传递到访存阶段
        mem_cp0_reg_we <= ex_cp0_reg_we;
        mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr; 
        mem_cp0_reg_data <= ex_cp0_reg_data; 

        mem_excepttype <= ex_excepttype;
        mem_is_in_delayslot <= ex_is_in_delayslot;
        mem_current_inst_address <= ex_current_inst_address;
    end else begin
        hilo_o <= hilo_i;
        cnt_o <= cnt_i;
    end
end

endmodule