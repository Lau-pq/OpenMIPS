`include "defines.v"

module hilo_reg(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    // д�˿�
    input wire we, // HI��LO �Ĵ���дʹ���ź�
    input wire[`RegBus] hi_i, // Ҫд�� HI �Ĵ�����ֵ
    input wire[`RegBus] lo_i, // Ҫд�� LO �Ĵ�����ֵ

    // ���˿�
    output reg[`RegBus] hi_o, // HI �Ĵ�����ֵ
    output reg[`RegBus] lo_o  // LO �Ĵ�����ֵ     
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end else if ((we == `WriteEnable)) begin
        hi_o <= hi_i;
        lo_o <= lo_i;
    end
end

endmodule