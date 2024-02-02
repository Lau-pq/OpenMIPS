`include "defines.v"

module ctrl(
    input wire rst, // 复位信号
    input wire stallreq_from_id, // 处于译码阶段的指令是否请求流水线暂停 
    input wire stallreq_from_ex, // 处于执行阶段的指令是否请求流水线暂停

    // 来自 MEM 模块
    input wire[31:0] excepttype_i, // 最终的异常类型 
    input wire[`RegBus] cp0_epc_i, // EPC 寄存器的最新值

    output reg[`RegBus] new_pc, // 异常处理入口地址
    output reg flush, // 是否清楚流水线

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
        flush <= 1'b0;
		new_pc <= `ZeroWord;
    end else if (excepttype_i != `ZeroWord) begin // 发生异常
        flush <= 1'b1;
        stall <= 6'b000000;
        case (excepttype_i)
            32'h00000001: begin // 中断
                new_pc <= 32'h00000020;
            end
            32'h00000008: begin // 系统调用异常 syscall
                new_pc <= 32'h00000040;
            end
            32'h0000000a: begin // 无效指令异常
                new_pc <= 32'h00000040;
            end
            32'h0000000d: begin // 自陷异常
                new_pc <= 32'h00000040;
            end
            32'h0000000c: begin // 溢出异常
                new_pc <= 32'h00000040;
            end
            32'h0000000e: begin // 异常返回指令 eret
                new_pc <= cp0_epc_i;
            end
            default: begin
            end
        endcase
    end else if (stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;
        flush <= 1'b0;
    end else if (stallreq_from_id == `Stop) begin
        stall <= 6'b000111;
        flush <= 1'b0;
    end else begin
        stall <= 6'b000000;
        flush <= 1'b0;
        new_pc <= `ZeroWord;
    end
end

endmodule