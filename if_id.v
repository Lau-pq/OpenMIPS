`include "defines.v"

module if_id(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    // 来自取指阶段的信号，InstBus 表示指令宽度 为32
    input wire[`InstAddrBus] if_pc, // 取指阶段取得的指令对应的地址
    input wire[`InstBus] if_inst, // 取指阶段取得的指令

    // 对应译码阶段的信号
    output reg[`InstAddrBus] id_pc, // 译码阶段的指令对应的地址
    output reg[`InstBus] id_inst // 译码阶段的指令
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc <= `ZeroWord; // 复位的时候 pc 为 0
        id_inst <= `ZeroWord; // 复位的时候指令也为 0，实际就是空指令
    end else begin
        id_pc <= if_pc; // 其余时刻向下传递取指阶段的值
        id_inst <= if_inst;
    end
end
endmodule