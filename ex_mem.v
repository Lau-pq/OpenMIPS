`include "defines.v"

module ex_mem(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    // 来自执行阶段的信息
    input wire[`RegAddrBus] ex_wd, // 执行阶段的指令执行后要写入的目的寄存器地址
    input wire ex_wreg, // 执行阶段的指令执行后是否有要写入的目的寄存器
    input wire[`RegBus] ex_wdata, // 执行阶段的指令执行后要写入目的寄存器的值

    // 送到访存阶段的信息
    output reg[`RegAddrBus] mem_wd, // 访存阶段的指令要写入的目的寄存器地址
    output reg mem_wreg, // 访存阶段的指令是否有要写入的目的寄存器
    output reg[`RegBus] mem_wdata // 访存阶段的指令要写入目的寄存器的值
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
    end else begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
    end
end

endmodule