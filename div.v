`include "defines.v"

// ��ģ����Ҫ����״̬����ʽʵ��

module div(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    input wire signed_div_i, // �Ƿ�Ϊ�з��ų�����Ϊ 1��ʾ�з��ų���
    input wire[`RegBus] opdata1_i, // ������
    input wire[`RegBus] opdata2_i, // ����
    input wire start_i, // �Ƿ�ʼ��������
    input wire annul_i, // �Ƿ�ȡ���������㣬Ϊ 1��ʾȡ����������

    output reg[`DoubleRegBus] result_o, // ����������
    output reg ready_o // ���������Ƿ���� 
);

wire[32:0] div_temp; // ���汻���� minuend - ���� n �Ľ��
reg[5:0] cnt; // ��¼���̷������˼��֣������� 32ʱ����ʾ���̷�����
reg[64:0] dividend; // [63:32]Ϊminuend, ��k�ε���������[k:0]Ϊ�м�����[31:k+1] Ϊ��������û�������������
reg[1:0] state; // ״̬
reg[`RegBus] divisor; // ���� n
reg[`RegBus] temp_op1;
reg[`RegBus] temp_op2;

assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor}; // ���� minuend - n

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        state <= `DivFree;
        ready_o <= `DivResultNotReady;
        result_o <= {`ZeroWord, `ZeroWord};
    end else begin
        case (state)
            `DivFree: begin // DivFree ״̬
                if (start_i == `DivStart && !annul_i) begin
                    if (opdata2_i == `ZeroWord) begin // ����Ϊ 0
                        state <= `DivByZero;
                    end else begin // ������Ϊ 0
                        state <= `DivOn;
                        cnt <= 6'b000000;
                        if (signed_div_i && opdata1_i[31]) begin // �з��ų����ұ�����Ϊ����
                            temp_op1 = ~opdata1_i + 1; // ������ȡ����
                        end else begin
                            temp_op1 = opdata1_i;
                        end
                        if (signed_div_i && opdata2_i[31]) begin // �з��ų����ҳ���Ϊ����
                            temp_op2 = ~opdata2_i + 1; // ����ȡ����
                        end else begin
                            temp_op2 = opdata2_i;
                        end
                        dividend <= {`ZeroWord, `ZeroWord};
                        dividend[32:1] <= temp_op1;
                        divisor <= temp_op2;
                    end
                end else begin // û�п�ʼ��������
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord, `ZeroWord};
                end
            end
            `DivByZero: begin // DivByZero ״̬
                dividend <= {`ZeroWord, `ZeroWord};
                state <= `DivEnd;
            end
            `DivOn: begin // DivOn ״̬
                if (!annul_i) begin
                    if (cnt != 6'b100000) begin // cnt ��Ϊ 32�����̷���û����
                        if (div_temp[32]) begin // minuend-n ��� < 0
                            // ����������û����������λ������һ�ε����ı�������ͬʱ�� 0�����м���
                            dividend <= {dividend[63:0], 1'b0}; 
                        end else begin // miniend-n ��� > 0
                            // �������Ľ���뱻������û����������λ���뵽��һ�ε����ı��������� 1�����м���
                            dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
                        end
                        cnt <= cnt + 1;
                    end else begin // ���̷�����
                        if ((signed_div_i) && (opdata1_i[31] ^ opdata2_i[31])) begin // �з��ų��� ���
                            dividend[31:0] <= ~dividend[31:0] + 1; // ���� 
                        end
                        if ((signed_div_i) && (opdata1_i[31] ^ dividend[64])) begin // �з��ų��� ������������ͬ��
                            dividend[64:33] <= ~dividend[64:33] + 1; // ����
                        end
                        state <= `DivEnd; // ���� DivEnd ״̬
                        cnt <= 6'b000000; // cnt ����
                    end
                end else begin
                    state <= `DivFree; //annul_i Ϊ 1
                end
            end
            `DivEnd: begin // DivEnd ״̬
                result_o <= {dividend[64:33], dividend[31:0]};
                ready_o <= `DivResultReady;
                if (start_i == `DivStop) begin
                    state <= `DivFree;
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord, `ZeroWord};
                end
            end
        endcase
    end
end



endmodule