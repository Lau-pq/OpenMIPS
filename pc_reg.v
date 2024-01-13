`include "defines.v"

module pc_reg (
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�
    output reg[`InstAddrBus] pc, // Ҫ��ȡ��ָ���ַ
    output reg ce // ָ��洢��ʹ���ź�
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        ce <= `ChipDisable; // ��λ��ʱ��ָ��洢������
    end else begin
        ce <= `ChipEnable; // ��λ������ָ��洢��ʹ��
    end
end

always @(posedge clk) begin
    if (ce == `ChipDisable) begin
        pc <= 32'h0000_0000; // ָ��洢�����õ�ʱ��pcΪ 0 
    end else begin
        pc <= pc + 4'h4; // ָ��洢�����ܵ�ʱ��pc��ֵÿʱ�����ڼ� 4��һ��ָ���Ӧ4���ֽڣ�
    end
end

endmodule
