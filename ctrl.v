`include "defines.v"

module ctrl(
    input wire rst, // ��λ�ź�
    input wire stallreq_from_id, // ��������׶ε�ָ���Ƿ�������ˮ����ͣ 
    input wire stallreq_from_ex, // ����ִ�н׶ε�ָ���Ƿ�������ˮ����ͣ

    // ���� MEM ģ��
    input wire[31:0] excepttype_i, // ���յ��쳣���� 
    input wire[`RegBus] cp0_epc_i, // EPC �Ĵ���������ֵ

    output reg[`RegBus] new_pc, // �쳣������ڵ�ַ
    output reg flush, // �Ƿ������ˮ��

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
        flush <= 1'b0;
		new_pc <= `ZeroWord;
    end else if (excepttype_i != `ZeroWord) begin // �����쳣
        flush <= 1'b1;
        stall <= 6'b000000;
        case (excepttype_i)
            32'h00000001: begin // �ж�
                new_pc <= 32'h00000020;
            end
            32'h00000008: begin // ϵͳ�����쳣 syscall
                new_pc <= 32'h00000040;
            end
            32'h0000000a: begin // ��Чָ���쳣
                new_pc <= 32'h00000040;
            end
            32'h0000000d: begin // �����쳣
                new_pc <= 32'h00000040;
            end
            32'h0000000c: begin // ����쳣
                new_pc <= 32'h00000040;
            end
            32'h0000000e: begin // �쳣����ָ�� eret
                new_pc <= cp0_epc_i;
            end
            default: begin
            end
        endcase
    end else if (stallreq_from_ex == `Stop) begin
        stall <= 6'b001111;
        flush <= 1'b0;
    end else if (stallreq_from_id == `Stop) begin
        stall <= 6'b000111;
        flush <= 1'b0;
    end else begin
        stall <= 6'b000000;
        flush <= 1'b0;
        new_pc <= `ZeroWord;
    end
end

endmodule