`include "defines.v"

module mem_wb(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    // 访存阶段的结果
    input wire[`RegAddrBus] mem_wd, // 访存阶段的指令最终要写入的目的寄存器地址
    input wire mem_wreg, // 访存阶段的指令最终是否有要写入的目的寄存器
    input wire[`RegBus] mem_wdata, // 访存阶段的指令最终要写入目的寄存器的值

    // 送到回写阶段的信息
    output reg[`RegAddrBus] wb_wd, // 回写阶段的指令要写入的目的寄存器地址
    output reg wb_wreg, // 回写阶段的指令是否有要写入的目的寄存器
    output reg[`RegBus] wb_wdata // 回写阶段的指令要写入目的寄存器的值
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
    end else begin
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
    end
end

endmodule