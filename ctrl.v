`include "defines.v"

module ctrl(
    input wire rst, // 复位信号
    input wire stallreq_from_id, // 处于译码阶段的指令是否请求流水线暂停 
    input wire stallreq_from_ex, // 处于执行阶段的指令是否请求流水线暂停
    output reg[`StallBus] stall // 暂停流水线控制信号
    // stall[0]为 1表示取值地址 PC保持不变
    // stall[1]为 1表示取指阶段暂停 
    // stall[2]为 1表示译码阶段暂停 
    // stall[3]为 1表示执行阶段暂停 
    // stall[4]为 1表示访存阶段暂停 
    // stall[5]为 1表示写回阶段暂停 
);

always @( *) begin
    if (rst == `RstEnable) begin
        stall <= 6'b000000;
    end else if (stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;
    end else if (stallreq_from_id == `Stop) begin
        stall <= 6'b000111;
    end else begin
        stall <= 6'b000000;
    end
end

endmodule