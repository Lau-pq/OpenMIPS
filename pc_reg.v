`include "defines.v"

module pc_reg (
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    input wire[`StallBus] stall, // ���Կ���ģ�� ctrl ����Ϣ

    // �����쳣����
    input wire flush, // ��ˮ������ź�
    input wire[`RegBus] new_pc, // �쳣����������ڵ�ַ

    // ��������׶� ID ģ�����Ϣ
    input wire branch_flag_i, // �Ƿ���ת��
    input wire[`RegBus] branch_target_address_i, // ת�Ƶ���Ŀ���ַ   

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
        if (flush == 1'b1) begin 
            // �쳣���� �� ctrl ģ��������쳣����������ڵ�ַ new_pc ��ȡִָ��
            pc <= new_pc;
        end else if (stall[0] == `NoStop) begin // stall[0] Ϊ NoStop ʱ
            if (branch_flag_i == `Branch) begin
                pc <= branch_target_address_i;
            end else begin
                pc <= pc + 4'h4; // ָ��洢��ʹ�ܵ�ʱ��pc��ֵÿʱ�����ڼ� 4��һ��ָ���Ӧ4���ֽڣ�
            end 
        end
    end 
end

endmodule
