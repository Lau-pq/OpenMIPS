`include "defines.v"

module if_id(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    // ����ȡָ�׶ε��źţ�InstBus ��ʾָ���� Ϊ32
    input wire[`InstAddrBus] if_pc, // ȡָ�׶�ȡ�õ�ָ���Ӧ�ĵ�ַ
    input wire[`InstBus] if_inst, // ȡָ�׶�ȡ�õ�ָ��

    // ��Ӧ����׶ε��ź�
    output reg[`InstAddrBus] id_pc, // ����׶ε�ָ���Ӧ�ĵ�ַ
    output reg[`InstBus] id_inst // ����׶ε�ָ��
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc <= `ZeroWord; // ��λ��ʱ�� pc Ϊ 0
        id_inst <= `ZeroWord; // ��λ��ʱ��ָ��ҲΪ 0��ʵ�ʾ��ǿ�ָ��
    end else begin
        id_pc <= if_pc; // ����ʱ�����´���ȡָ�׶ε�ֵ
        id_inst <= if_inst;
    end
end
endmodule