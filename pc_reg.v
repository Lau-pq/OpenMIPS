`include "defines.v"

module pc_reg (
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    input wire[`StallBus] stall, // 来自控制模块 ctrl 的信息

    // 关于异常处理
    input wire flush, // 流水线清除信号
    input wire[`RegBus] new_pc, // 异常处理例程入口地址

    // 来自译码阶段 ID 模块的信息
    input wire branch_flag_i, // 是否发生转移
    input wire[`RegBus] branch_target_address_i, // 转移到的目标地址   

    output reg[`InstAddrBus] pc, // 要读取的指令地址
    output reg ce // 指令存储器使能信号
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        ce <= `ChipDisable; // 复位的时候指令存储器禁用
    end else begin
        ce <= `ChipEnable; // 复位结束后，指令存储器使能
    end
end

always @(posedge clk) begin
    if (ce == `ChipDisable) begin
        pc <= 32'h0000_0000; // 指令存储器禁用的时候，pc为 0 
    end else begin
        if (flush == 1'b1) begin 
            // 异常发生 从 ctrl 模块给出的异常处理例程入口地址 new_pc 处取指执行
            pc <= new_pc;
        end else if (stall[0] == `NoStop) begin // stall[0] 为 NoStop 时
            if (branch_flag_i == `Branch) begin
                pc <= branch_target_address_i;
            end else begin
                pc <= pc + 4'h4; // 指令存储器使能的时候，pc的值每时钟周期加 4（一条指令对应4个字节）
            end 
        end
    end 
end

endmodule
