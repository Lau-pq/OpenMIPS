`include "defines.v"

module mem(
    input wire rst, // ��λ�ź�

    // ����ִ�н׶ε���Ϣ
    input wire[`RegAddrBus] wd_i, // �ô�׶ε�ָ��Ҫд���Ŀ�ļĴ����ĵ�ַ 
    input wire wreg_i, // �ô�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[`RegBus] wdata_i, // �ô�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
    input wire[`RegBus] hi_i, // �ô�׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    input wire[`RegBus] lo_i, // �ô�׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    input wire[`RegBus] whilo_i, // �ô�׶ε�ָ���Ƿ�Ҫд HI��LO �Ĵ���

    // �ô�׶εĽ��
    output reg[`RegAddrBus] wd_o, // �ô�׶ε�ָ������Ҫд���Ŀ�ļĴ����ĵ�ַ
    output reg wreg_o, // �ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] wdata_o, // �ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ
    output reg[`RegBus] hi_o, // �ô�׶ε�ָ������Ҫд�� HI �Ĵ�����ֵ
    output reg[`RegBus] lo_o, // �ô�׶ε�ָ������Ҫд�� LO �Ĵ�����ֵ
    output reg[`RegBus] whilo_o // �ô�׶ε�ָ�������Ƿ�Ҫд HI��LO �Ĵ���
);

always @( *) begin
    if (rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
        whilo_o <= `WriteDisable;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        hi_o <= hi_i;
        lo_o <= lo_i;
        whilo_o <= whilo_i;
    end
end

endmodule