`include "defines.v"

module if_id(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    // ����ȡָ�׶ε��źţ�InstBus ��ʾָ���� Ϊ32
    input wire[`InstAddrBus] if_pc, // ȡָ�׶�ȡ�õ�ָ���Ӧ�ĵ�ַ
    input wire[`InstBus] if_inst, // ȡָ�׶�ȡ�õ�ָ��

    // ���Կ���ģ�� ctrl ����Ϣ
    input wire[`StallBus] stall,

    input wire flush, // ��ˮ������ź� 

    // ��Ӧ����׶ε��ź�
    output reg[`InstAddrBus] id_pc, // ����׶ε�ָ���Ӧ�ĵ�ַ
    output reg[`InstBus] id_inst // ����׶ε�ָ��
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc <= `ZeroWord; // ��λ��ʱ�� pc Ϊ 0
        id_inst <= `ZeroWord; // ��λ��ʱ��ָ��ҲΪ 0��ʵ�ʾ��ǿ�ָ��
    end else if (flush == 1'b1) begin
        // �쳣���� �����ˮ�� ��λ
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
    end else if ((stall[1] == `Stop) && (stall[2] == `NoStop)) begin // ȡָ��ͣ ������� ��ָ��
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
    end else if (stall[1] == `NoStop) begin // ȡָ���� 
        id_pc <= if_pc; // ����ʱ�����´���ȡָ�׶ε�ֵ
        id_inst <= if_inst;
    end
end
endmodule