`include "defines.v"

module ex(
    input wire rst, // ��λ�ź�
    input wire[`AluOpBus] aluop_i, // ִ�н׶�Ҫ���е������������
    input wire[`AluSelBus] alusel_i, // ִ�н׶�Ҫ���е����������
    input wire[`RegBus] reg1_i, // ���������Դ������1
    input wire[`RegBus] reg2_i, // ���������Դ������2
    input wire[`RegAddrBus] wd_i, // ָ��ִ��Ҫд���Ŀ�ļĴ�����ַ
    input wire wreg_i,  // �Ƿ���Ҫд���Ŀ�ļĴ���

    // ִ�еĽ��
    output reg[`RegAddrBus] wd_o, // ִ�н׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ
    output reg wreg_o, // ִ�н׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] wdata_o // ִ�н׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ
);

reg[`RegBus] logicout; // �����߼�����Ľ��
reg[`RegBus] shiftres; // ������λ����Ľ��

// ********** ��һ�Σ����� aluop_i ָʾ�����������ͽ������� *************
// �����߼�����
always @( *) begin
    if (rst == `RstEnable) begin
        logicout <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_OR_OP: begin // �߼�������
                logicout <= reg1_i | reg2_i;
            end
            `EXE_AND_OP: begin // �߼�������
                logicout <= reg1_i & reg2_i;
            end
            `EXE_NOR_OP: begin // �߼��������
               logicout <= ~(reg1_i | reg2_i);
            end
            `EXE_XOR_OP: begin // �߼��������
                logicout <= reg1_i ^ reg2_i;
            end
            default: begin
                logicout <= `ZeroWord;
            end
        endcase
    end
end

// ������λ����
always @( *) begin
    if (rst == `RstEnable) begin
        shiftres <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_SLL_OP: begin // �߼�����
                shiftres <= reg2_i << reg1_i[4:0];
            end
            `EXE_SRL_OP: begin // �߼�����
                shiftres <= reg2_i >> reg1_i[4:0];
            end
            `EXE_SRA_OP: begin // ��������
                shiftres <= ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
            end
            default: begin
                shiftres <= `ZeroWord;
            end   
        endcase
    end
end

// ***************** �ڶ��Σ����� alusel_i ָʾ���������ͣ�ѡ��һ����������Ϊ���ս�� ****************
always @( *) begin
    wd_o <= wd_i; // wd_o ���� wd_i��Ҫд��Ŀ�ļĴ�����ַ
    wreg_o <= wreg_i; // wreg_o ���� wreg_i����ʾ�Ƿ�ҪдĿ�ļĴ���
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout; // ѡ���߼�������Ϊ����������
        end
        `EXE_RES_SHIFT: begin
            wdata_o <= shiftres; // ѡ����λ������Ϊ����������
        end
        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end

endmodule