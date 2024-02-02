`include "defines.v"

module if_id(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    // 来自取指阶段的信号，InstBus 表示指令宽度 为32
    input wire[`InstAddrBus] if_pc, // 取指阶段取得的指令对应的地址
    input wire[`InstBus] if_inst, // 取指阶段取得的指令

    // 来自控制模块 ctrl 的信息
    input wire[`StallBus] stall,

    input wire flush, // 流水线清除信号 

    // 对应译码阶段的信号
    output reg[`InstAddrBus] id_pc, // 译码阶段的指令对应的地址
    output reg[`InstBus] id_inst // 译码阶段的指令
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc <= `ZeroWord; // 复位的时候 pc 为 0
        id_inst <= `ZeroWord; // 复位的时候指令也为 0，实际就是空指令
    end else if (flush == 1'b1) begin
        // 异常发生 清除流水线 复位
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
    end else if ((stall[1] == `Stop) && (stall[2] == `NoStop)) begin // 取指暂停 译码继续 空指令
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
    end else if (stall[1] == `NoStop) begin // 取指继续 
        id_pc <= if_pc; // 其余时刻向下传递取指阶段的值
        id_inst <= if_inst;
    end
end
endmodule