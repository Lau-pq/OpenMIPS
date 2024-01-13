`include "defines.v"

module pc_reg (
    input wire clk, // 时钟信号
    input wire rst, // 复位信号
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
        pc <= pc + 4'h4; // 指令存储器是能的时候，pc的值每时钟周期加 4（一条指令对应4个字节）
    end
end

endmodule
