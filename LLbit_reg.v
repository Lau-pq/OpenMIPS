`include "defines.v"

module LLbit_reg(
    input wire clk, 
    input wire rst, 

    // �쳣�Ƿ�����Ϊ 1 ��ʾ�쳣������Ϊ 0 ��ʾû���쳣
    input wire flush, 

    // д����
    input wire LLbit_i, 
    input wire we, 

    // LLbit �Ĵ�����ֵ
    output reg LLbit_o
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        LLbit_o <= 1'b0;
    end else if (flush) begin // �쳣����
        LLbit_o <= 1'b0;
    end else if (we == `WriteEnable) begin
        LLbit_o <= LLbit_i;
    end
end

endmodule