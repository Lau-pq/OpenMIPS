`include "defines.v"

module ex_mem(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    // ����ִ�н׶ε���Ϣ
    input wire[`RegAddrBus] ex_wd, // ִ�н׶ε�ָ��ִ�к�Ҫд���Ŀ�ļĴ�����ַ
    input wire ex_wreg, // ִ�н׶ε�ָ��ִ�к��Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[`RegBus] ex_wdata, // ִ�н׶ε�ָ��ִ�к�Ҫд��Ŀ�ļĴ�����ֵ

    // �͵��ô�׶ε���Ϣ
    output reg[`RegAddrBus] mem_wd, // �ô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
    output reg mem_wreg, // �ô�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] mem_wdata // �ô�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
    end else begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
    end
end

endmodule