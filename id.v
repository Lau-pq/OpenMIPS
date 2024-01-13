`include "defines.v"

module id(
    input wire rst, // ��λ�ź�
    input wire[`InstAddrBus] pc_i, // ����׶ε�ָ���Ӧ��ַ 
    input wire[`InstBus] inst_i, // ����׶ε�ָ��

    // ��ȡ�� Regfile ��ֵ 
    input wire[`RegBus] reg1_data_i, // �� Regfile ����ĵ�һ�����Ĵ����˿ڵ�����
    input wire[`RegBus] reg2_data_i, // �� Regfile ����ĵڶ������Ĵ����˿ڵ�����

    // ����� Regfile ����Ϣ
    output reg reg1_read_o, // Regfile ģ��ĵ�һ�����Ĵ����˿ڵĶ�ʹ���ź�
    output reg reg2_read_o, // Regfile ģ��ĵڶ������Ĵ����˿ڵĶ�ʹ���ź�
    output reg[`RegAddrBus] reg1_addr_o, // Regfile ģ��ĵ�һ�����Ĵ����˿ڵĶ���ַ�ź�
    output reg[`RegAddrBus] reg2_addr_o, // Regfile ģ��ĵڶ������Ĵ����˿ڵĶ���ַ�ź�

    // �͵�ִ�н׶ε���Ϣ
    output reg[`AluOpBus] aluop_o, // ����׶ε�ָ��Ҫ���е������������
    output reg[`AluSelBus] alusel_o, // ����׶ε�ָ��Ҫ���е����������
    output reg[`RegBus] reg1_o,// ����׶ε�ָ��Ҫ���е������Դ������ 1
    output reg[`RegBus] reg2_o, // ����׶ε�ָ��Ҫ���е������Դ������ 2
    output reg[`RegAddrBus] wd_o, // ����׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
    output reg wreg_o // ����׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
);

// ȡ��ָ���ָ���룬������
// ���� ori ָ��ֻ��ͨ���жϵ� 26-31 bit��ֵ�������ж��Ƿ��� ori ָ��
wire[5:0] op = inst_i[31:26]; // op
wire[4:0] op2 = inst_i[10:6]; // R shamt
wire[5:0] op3 = inst_i[5:0]; // R func
wire[4:0] op4 = inst_i[20:16]; // rt

// ����ָ��ִ����Ҫ��������
reg[`RegBus] imm;

// ָʾָ���Ƿ���Ч
reg instvalid;

// *************** ��һ�Σ���ָ��������� ***********************
always @( *) begin
    if (rst == `RstEnable) begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= `ZeroWord;
    end else begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= inst_i[15:11]; // rd
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvalid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21]; // rs Ĭ��ͨ�� Regfile ���˿�1 ��ȡ�ļĴ�����ַ
        reg2_addr_o <= inst_i[20:16]; // rt Ĭ��ͨ�� Regfile ���˿�2 ��ȡ�ļĴ�����ַ
        imm <= `ZeroWord;

        case (op)
            `EXE_ORI: begin // ���� op ֵ�ж��Ƿ��� ori ָ��
                // ori ָ����Ҫ�����д��Ŀ�ļĴ��������� wreg_o Ϊ WriteEnable
                wreg_o <= `WriteEnable;

                // ��������������߼� ���� ����
                aluop_o <= `EXE_OR_OP;

                // �����������߼�����
                alusel_o <= `EXE_RES_LOGIC;

                // ��Ҫͨ�� Regfile �Ķ��˿�1 ��ȡ�Ĵ���
                reg1_read_o <= 1'b1;

                // ����Ҫͨ�� Regfile �Ķ��˿�2 ��ȡ�Ĵ���
                reg2_read_o <= 1'b0;

                // ָ��ִ����Ҫ��������
                imm <= {16'h0, inst_i[15:0]}; // �������޷�����չ

                // ָ��ִ��Ҫд��Ŀ�ļĴ�����ַ
                wd_o <= inst_i[20:16]; // rt

                // ori ָ������Чָ��
                instvalid <= `InstValid;
            end
            default: begin
            end
        endcase
    end
end

// ******************* �ڶ��Σ�ȷ�����������Դ������ 1 *****************************8
always @( *) begin
    if (rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if (reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i; // Regfile ���˿�1�����ֵ
    end else if (reg1_read_o == 1'b0) begin
        reg1_o <= imm; // ������
    end else begin
        reg1_o <= `ZeroWord;
    end
end

// ******************* �����Σ�ȷ�����������Դ������ 2 *****************************8
always @( *) begin
    if (rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if (reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i; // Regfile ���˿�2�����ֵ
    end else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm; // ������
    end else begin
        reg2_o <= `ZeroWord;
    end
end

endmodule