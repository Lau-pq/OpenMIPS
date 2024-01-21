`include "defines.v"

module ctrl(
    input wire rst, // ��λ�ź�
    input wire stallreq_from_id, // ��������׶ε�ָ���Ƿ�������ˮ����ͣ 
    input wire stallreq_from_ex, // ����ִ�н׶ε�ָ���Ƿ�������ˮ����ͣ
    output reg[`StallBus] stall // ��ͣ��ˮ�߿����ź�
    // stall[0]Ϊ 1��ʾȡֵ��ַ PC���ֲ���
    // stall[1]Ϊ 1��ʾȡָ�׶���ͣ 
    // stall[2]Ϊ 1��ʾ����׶���ͣ 
    // stall[3]Ϊ 1��ʾִ�н׶���ͣ 
    // stall[4]Ϊ 1��ʾ�ô�׶���ͣ 
    // stall[5]Ϊ 1��ʾд�ؽ׶���ͣ 
);

always @( *) begin
    if (rst == `RstEnable) begin
        stall <= 6'b000000;
    end else if (stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;
    end else if (stallreq_from_id == `Stop) begin
        stall <= 6'b000111;
    end else begin
        stall <= 6'b000000;
    end
end

endmodule