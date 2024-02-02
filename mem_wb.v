`include "defines.v"

module mem_wb(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    input wire flush, // 流水线清除信号 

    // 访存阶段的结果
    input wire[`RegAddrBus] mem_wd, // 访存阶段的指令最终要写入的目的寄存器地址
    input wire mem_wreg, // 访存阶段的指令最终是否有要写入的目的寄存器
    input wire[`RegBus] mem_wdata, // 访存阶段的指令最终要写入目的寄存器的值
    input wire[`RegBus] mem_hi, // 访存阶段的指令要写入 HI 寄存器的值
    input wire[`RegBus] mem_lo, // 访存阶段的指令要写入 LO 寄存器的值
    input wire mem_whilo, // 访存阶段的指令是否要写 HI、LO寄存器  

    input wire mem_cp0_reg_we, // 访存阶段的指令是否要写 CP0 中的寄存器
    input wire[4:0] mem_cp0_reg_write_addr, // 访存阶段的指令要写的 CP0 中寄存器的地址
    input wire[`RegBus] mem_cp0_reg_data, // 访存阶段的指令要写入 CP0 中寄存器的数据 

    // 来自控制模块的信息
    input wire[`StallBus] stall, 

    // 与 LLbit 模块有关的信息
    input wire mem_LLbit_we, // 访存阶段的指令是否要写 LLbit 寄存器
    input wire mem_LLbit_value, // 访存阶段的指令要写入 LLbit 寄存器的值  

    // 送到回写阶段的信息
    output reg[`RegAddrBus] wb_wd, // 回写阶段的指令要写入的目的寄存器地址
    output reg wb_wreg, // 回写阶段的指令是否有要写入的目的寄存器
    output reg[`RegBus] wb_wdata, // 回写阶段的指令要写入目的寄存器的值
    output reg[`RegBus] wb_hi, // 回写阶段的指令要写入 HI 寄存器的值
    output reg[`RegBus] wb_lo, // 回写阶段的指令要写入 LO 寄存器的值
    output reg wb_whilo, // 回写阶段的指令是否要写 HI、LO寄存器 

    output reg wb_cp0_reg_we, // 回写阶段的指令是否要写 CP0 中的寄存器
    output reg[4:0] wb_cp0_reg_write_addr, // 回写阶段的指令要写的 CP0 中的寄存器的地址
    output reg[`RegBus] wb_cp0_reg_data, // 回写阶段的指令要写入 CP0 中寄存器的数据

    // 与 LLbit 模块有关的信息
    output reg wb_LLbit_we, // 回写阶段的指令是否要写 LLbit 寄存器
    output reg wb_LLbit_value // 回写阶段的指令要写入 LLbit 寄存器的值
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin // 复位
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
        wb_hi <= `ZeroWord;
        wb_lo <= `ZeroWord;
        wb_whilo <= `WriteDisable;
        wb_LLbit_we <= 1'b0;
        wb_LLbit_value <= 1'b0;
        wb_cp0_reg_we <= `WriteDisable;
        wb_cp0_reg_write_addr <= 5'b00000;
        wb_cp0_reg_data <= `ZeroWord;
    end else if (flush == 1'b1) begin // 清除流水线
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
        wb_hi <= `ZeroWord;
        wb_lo <= `ZeroWord;
        wb_whilo <= `WriteDisable;
        wb_LLbit_we <= 1'b0;
        wb_LLbit_value <= 1'b0;
        wb_cp0_reg_we <= `WriteDisable;
        wb_cp0_reg_write_addr <= 5'b00000;
        wb_cp0_reg_data <= `ZeroWord;
    end else if ((stall[4] == `Stop) && (stall[5] == `NoStop)) begin // 访存暂停 回写继续 空指令
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
        wb_hi <= `ZeroWord;
        wb_lo <= `ZeroWord;
        wb_whilo <= `WriteDisable;
        wb_LLbit_we <= 1'b0;
        wb_LLbit_value <= 1'b0;
        wb_cp0_reg_we <= `WriteDisable;
        wb_cp0_reg_write_addr <= 5'b00000;
        wb_cp0_reg_data <= `ZeroWord;
    end else if (stall[4] == `NoStop) begin // 访存继续
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
        wb_hi <= mem_hi;
        wb_lo <= mem_lo;
        wb_whilo <= mem_whilo;
        wb_LLbit_we <= mem_LLbit_we;
        wb_LLbit_value <= mem_LLbit_value;
        wb_cp0_reg_we <= mem_cp0_reg_we;
        wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
        wb_cp0_reg_data <= mem_cp0_reg_data;
    end
end

endmodule