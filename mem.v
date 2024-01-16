`include "defines.v"

module mem(
    input wire rst, // 复位信号

    // 来自执行阶段的信息
    input wire[`RegAddrBus] wd_i, // 访存阶段的指令要写入的目的寄存器的地址 
    input wire wreg_i, // 访存阶段的指令是否有要写入的目的寄存器
    input wire[`RegBus] wdata_i, // 访存阶段的指令要写入目的寄存器的值
    input wire[`RegBus] hi_i, // 访存阶段的指令要写入 LO 寄存器的值
    input wire[`RegBus] lo_i, // 访存阶段的指令要写入 HI 寄存器的值
    input wire[`RegBus] whilo_i, // 访存阶段的指令是否要写 HI、LO 寄存器

    // 访存阶段的结果
    output reg[`RegAddrBus] wd_o, // 访存阶段的指令最终要写入的目的寄存器的地址
    output reg wreg_o, // 访存阶段的指令最终是否有要写入的目的寄存器
    output reg[`RegBus] wdata_o, // 访存阶段的指令最终要写入目的寄存器的值
    output reg[`RegBus] hi_o, // 访存阶段的指令最终要写入 HI 寄存器的值
    output reg[`RegBus] lo_o, // 访存阶段的指令最终要写入 LO 寄存器的值
    output reg[`RegBus] whilo_o // 访存阶段的指令最终是否要写 HI、LO 寄存器
);

always @( *) begin
    if (rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
        whilo_o <= `WriteDisable;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        hi_o <= hi_i;
        lo_o <= lo_i;
        whilo_o <= whilo_i;
    end
end

endmodule