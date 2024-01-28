`include "defines.v"

module LLbit_reg(
    input wire clk, 
    input wire rst, 

    // 异常是否发生，为 1 表示异常发生，为 0 表示没有异常
    input wire flush, 

    // 写操作
    input wire LLbit_i, 
    input wire we, 

    // LLbit 寄存器的值
    output reg LLbit_o
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        LLbit_o <= 1'b0;
    end else if (flush) begin // 异常发生
        LLbit_o <= 1'b0;
    end else if (we == `WriteEnable) begin
        LLbit_o <= LLbit_i;
    end
end

endmodule