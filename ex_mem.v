`include "defines.v"

module ex_mem(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    // ����ִ�н׶ε���Ϣ
    input wire[`RegAddrBus] ex_wd, // ִ�н׶ε�ָ��ִ�к�Ҫд���Ŀ�ļĴ�����ַ
    input wire ex_wreg, // ִ�н׶ε�ָ��ִ�к��Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[`RegBus] ex_wdata, // ִ�н׶ε�ָ��ִ�к�Ҫд��Ŀ�ļĴ�����ֵ
    input wire[`RegBus] ex_hi, // ִ�н׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    input wire[`RegBus] ex_lo, // ִ�н׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    input wire ex_whilo, // ִ�н׶ε�ָ���Ƿ�Ҫд HI��LO �Ĵ���

    // �͵��ô�׶ε���Ϣ
    output reg[`RegAddrBus] mem_wd, // �ô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
    output reg mem_wreg, // �ô�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] mem_wdata, // �ô�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
    output reg[`RegBus] mem_hi, // �ô�׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    output reg[`RegBus] mem_lo, // �ô�׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    output reg mem_whilo // �ô�׶ε�ָ���Ƿ�Ҫд HI��LO�Ĵ���
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
    end else begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;
    end
end

endmodule