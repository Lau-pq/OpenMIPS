`include "defines.v"

module id(
    input wire rst, // ��λ�ź�
    input wire[`InstAddrBus] pc_i, // ����׶ε�ָ���Ӧ��ַ 
    input wire[`InstBus] inst_i, // ����׶ε�ָ��

    // ��ȡ�� Regfile ��ֵ 
    input wire[`RegBus] reg1_data_i, // �� Regfile ����ĵ�һ�����Ĵ����˿ڵ�����
    input wire[`RegBus] reg2_data_i, // �� Regfile ����ĵڶ������Ĵ����˿ڵ�����

    // ����ִ�н׶ε�ָ���������
    input wire ex_wreg_i, // ����ִ�н׶ε�ָ���Ƿ�ҪдĿ�ļĴ���
    input wire[`RegBus] ex_wdata_i, // ����ִ�н׶ε�ָ��Ҫд��Ŀ�ļĴ����ĵ�ַ
    input wire[`RegAddrBus] ex_wd_i, // ����ִ�н׶ε�ָ��Ҫд��Ŀ�ļĴ���������

    // ���ڷô�׶ε�ָ���������
    input wire mem_wreg_i, // ���ڷô�׶ε�ָ���Ƿ���Ҫд��Ŀ�ļĴ���
    input wire[`RegBus] mem_wdata_i, // ���ڷô�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ַ
    input wire[`RegAddrBus] mem_wd_i, // ���ڷô�׶ε�ָ��Ҫд��Ŀ�ļĴ���������

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
wire[4:0] shamt = inst_i[10:6]; // R shamt
wire[5:0] func = inst_i[5:0]; // R func
wire[4:0] rs = inst_i[25:21]; // rs
wire[4:0] rt = inst_i[20:16]; // rt
wire[4:0] rd = inst_i[15:11]; // rd

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
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= `ZeroWord;
    end else begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= rd; // rd
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvalid;
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= rs; // rs Ĭ��ͨ�� Regfile ���˿�1 ��ȡ�ļĴ�����ַ
        reg2_addr_o <= rt; // rt Ĭ��ͨ�� Regfile ���˿�2 ��ȡ�ļĴ�����ַ
        imm <= `ZeroWord;

        case (op)
            `EXE_SPECIAL_INST: begin
                case (shamt)
                    5'b00000: begin
                        case (func)
                            `EXE_OR: begin // or ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_OR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_AND: begin // and ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_AND_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= `ReadEnable; 
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_XOR: begin // xor ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_XOR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_NOR: begin // nor ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_NOR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SLLV: begin // sllv ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SLL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SRLV: begin // srlv ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SRAV: begin // srav ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRA_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SYNC: begin // sync ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_NOP_OP;
                                alusel_o <= `EXE_RES_NOP;
                                reg1_read_o <= `ReadDisable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            default: begin
                            end  
                        endcase
                    end
                    default: begin
                    end  
                endcase
            end
            `EXE_ORI: begin // ori ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {16'h0, inst_i[15:0]};
                wd_o <= rt;
                instvalid <= `InstValid; 
            end
            `EXE_ANDI: begin // andi ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_AND_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {16'h0, inst_i[15:0]};
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_XORI: begin // xori ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_XOR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {16'h0, inst_i[15:0]};
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_LUI: begin // lui ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {inst_i[15:0], 16'h0};
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_PREF: begin // pref ָ��
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_NOP_OP;
                alusel_o <= `EXE_RES_NOP;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
                instvalid <= `InstValid;
            end
            default: begin
            end
        endcase

        if (inst_i[31:21] == 11'b000_0000_0000) begin
            if (func == `EXE_SLL) begin // sll ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SLL_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadEnable;
                imm[4:0] <= shamt;
                wd_o <= rd;
                instvalid <= `InstValid;
            end else if (func == `EXE_SRL) begin // srl ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SRL_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadEnable;
                imm[4:0] <= shamt;
                wd_o <= rd;
                instvalid <= `InstValid;
            end else if (func == `EXE_SRA) begin // sra ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SRA_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadEnable;
                imm[4:0] <= shamt;
                wd_o <= rd;
                instvalid <= `InstValid;
            end
        end
    end
end

// ******************* �ڶ��Σ�ȷ�����������Դ������ 1 *****************************
// �������������
always @( *) begin
    if (rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if ((reg1_read_o == `ReadEnable) && (ex_wreg_i == `WriteEnable) && (ex_wd_i == reg1_addr_o)) begin
        // ��� Regfile ģ����˿�1Ҫ��ȡ�ļĴ�������ִ�н׶�Ҫд��Ŀ�ļĴ�����ֱ�Ӱ�ִ�н׶εĽ�� ex_wdata_i ��Ϊ reg1_o ��ֵ
        reg1_o <= ex_wdata_i; 
    end else if ((reg1_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_wd_i == reg1_addr_o)) begin
        // ��� Regfile ģ����˿�1Ҫ��ȡ�ļĴ������Ƿô�׶�Ҫд��Ŀ�ļĴ�����ֱ�Ӱѷô�׶εĽ�� mem_wdata_i ��Ϊ reg1_o ��ֵ
        reg1_o <= mem_wdata_i;
    end else if (reg1_read_o == `ReadEnable) begin
        reg1_o <= reg1_data_i; // Regfile ���˿�1�����ֵ
    end else if (reg1_read_o == `ReadDisable) begin
        reg1_o <= imm; // ������
    end else begin
        reg1_o <= `ZeroWord;
    end
end

// ******************* �����Σ�ȷ�����������Դ������ 2 *****************************
// �������������
always @( *) begin
    if (rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if ((reg2_read_o == `ReadEnable) && (ex_wreg_i == `WriteEnable) && (ex_wd_i == reg2_addr_o)) begin
        // ��� Regfile ģ����˿�2Ҫ��ȡ�ļĴ�������ִ�н׶�Ҫд��Ŀ�ļĴ�����ֱ�Ӱ�ִ�н׶εĽ�� ex_wdata_i ��Ϊ reg2_o ��ֵ
        reg2_o <= ex_wdata_i; 
    end else if ((reg2_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_wd_i == reg2_addr_o)) begin
        // ��� Regfile ģ����˿�2Ҫ��ȡ�ļĴ������Ƿô�׶�Ҫд��Ŀ�ļĴ�����ֱ�Ӱѷô�׶εĽ�� mem_wdata_i ��Ϊ reg2_o ��ֵ
        reg2_o <= mem_wdata_i;
    end else if (reg2_read_o == `ReadEnable) begin
        reg2_o <= reg2_data_i; // Regfile ���˿�2�����ֵ
    end else if (reg2_read_o == `ReadDisable) begin
        reg2_o <= imm; // ������
    end else begin
        reg2_o <= `ZeroWord;
    end
end

endmodule