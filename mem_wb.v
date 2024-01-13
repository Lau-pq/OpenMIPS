`include "defines.v"

module mem_wb(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    // �ô�׶εĽ��
    input wire[`RegAddrBus] mem_wd, // �ô�׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ
    input wire mem_wreg, // �ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[`RegBus] mem_wdata, // �ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ

    // �͵���д�׶ε���Ϣ
    output reg[`RegAddrBus] wb_wd, // ��д�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
    output reg wb_wreg, // ��д�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] wb_wdata // ��д�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
    end else begin
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
    end
end

endmodule