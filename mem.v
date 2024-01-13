`include "defines.v"

module mem(
    input wire rst, // ��λ�ź�

    // ����ִ�н׶ε���Ϣ
    input wire[`RegAddrBus] wd_i, // �ô�׶ε�ָ��Ҫд���Ŀ�ļĴ����ĵ�ַ 
    input wire wreg_i, // �ô�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[`RegBus] wdata_i, // �ô�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ

    // �ô�׶εĽ��
    output reg[`RegAddrBus] wd_o, // �ô�׶ε�ָ������Ҫд���Ŀ�ļĴ����ĵ�ַ
    output reg wreg_o, // �ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] wdata_o // �ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ
);

always @( *) begin
    if (rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
    end
end

endmodule