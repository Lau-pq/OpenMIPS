`include "defines.v"

module ex_mem(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    // 来自执行阶段的信息
    input wire[`RegAddrBus] ex_wd, // 执行阶段的指令执行后要写入的目的寄存器地址
    input wire ex_wreg, // 执行阶段的指令执行后是否有要写入的目的寄存器
    input wire[`RegBus] ex_wdata, // 执行阶段的指令执行后要写入目的寄存器的值
    input wire[`RegBus] ex_hi, // 执行阶段的指令要写入 HI 寄存器的值
    input wire[`RegBus] ex_lo, // 执行阶段的指令要写入 LO 寄存器的值
    input wire ex_whilo, // 执行阶段的指令是否要写 HI、LO 寄存器

    // 来自控制模块的信息
    input wire[`StallBus] stall,

    input wire[`DoubleRegBus] hilo_i, // 保存的乘法结果
    input wire[1:0] cnt_i, // 下一个时钟周期是执行阶段的第几个时钟周期

    // 送到访存阶段的信息
    output reg[`RegAddrBus] mem_wd, // 访存阶段的指令要写入的目的寄存器地址
    output reg mem_wreg, // 访存阶段的指令是否有要写入的目的寄存器
    output reg[`RegBus] mem_wdata, // 访存阶段的指令要写入目的寄存器的值
    output reg[`RegBus] mem_hi, // 访存阶段的指令要写入 HI 寄存器的值
    output reg[`RegBus] mem_lo, // 访存阶段的指令要写入 LO 寄存器的值
    output reg mem_whilo,  // 访存阶段的指令是否要写 HI、LO寄存器

    output reg[`DoubleRegBus] hilo_o, // 保存的乘法结果
    output reg[1:0] cnt_o // 当前处于执行阶段的第几个时钟周期 
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= {`ZeroWord, `ZeroWord};
        cnt_o <= 2'b00;
    end else if ((stall[3] == `Stop) && (stall[4] == `NoStop)) begin // 执行暂停 访存继续 空指令
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= hilo_i; 
        cnt_o <= cnt_i; 
    end else if (stall[3] == `NoStop) begin // 执行继续
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;
        hilo_o <= {`ZeroWord, `ZeroWord}; 
        cnt_o <= 2'b00;
    end else begin
        hilo_o <= hilo_i;
        cnt_o <= cnt_i;
    end
end

endmodule