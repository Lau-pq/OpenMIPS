`include "defines.v"

module ex(
    input wire rst, // ��λ�ź�
    input wire[`AluOpBus] aluop_i, // ִ�н׶�Ҫ���е������������
    input wire[`AluSelBus] alusel_i, // ִ�н׶�Ҫ���е����������
    input wire[`RegBus] reg1_i, // ���������Դ������1
    input wire[`RegBus] reg2_i, // ���������Դ������2
    input wire[`RegAddrBus] wd_i, // ָ��ִ��Ҫд���Ŀ�ļĴ�����ַ
    input wire wreg_i,  // �Ƿ���Ҫд���Ŀ�ļĴ���

    // HILO ģ������� HI��LO �Ĵ�����ֵ
    input wire[`RegBus] hi_i, // HILO ģ������� HI �Ĵ�����ֵ
    input wire[`RegBus] lo_i, // HILO ģ������� LO �Ĵ�����ֵ

    // �ô�׶ε�ָ���Ƿ�Ҫд HI��LO�����ڼ�� HI��LO�Ĵ�������������������� 
    input wire[`RegBus] mem_hi_i, // ���ڷô�׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    input wire[`RegBus] mem_lo_i, // ���ڷô�׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    input wire mem_whilo_i, // ���ڷô�׶ε�ָ���Ƿ�Ҫд HI��LO�Ĵ���

    // ��д�׶ε�ָ���Ƿ�Ҫд HI��LO�����ڼ�� HI��LO�Ĵ��������������������
    input wire[`RegBus] wb_hi_i, // ���ڻ�д�׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    input wire[`RegBus] wb_lo_i, // ���ڻ�д�׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    input wire wb_whilo_i, // ���ڻ�д�׶ε�ָ���Ƿ�Ҫд HI��LO�Ĵ���

    // ����ִ�н׶ε�ָ��� HI��LO�Ĵ�����д��������
    output reg[`RegBus] hi_o, // ִ�н׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    output reg[`RegBus] lo_o, // ִ�н׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    output reg whilo_o, // ִ�н׶ε�ָ���Ƿ�Ҫд HI��LO�Ĵ���

    // ִ�еĽ��
    output reg[`RegAddrBus] wd_o, // ִ�н׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ
    output reg wreg_o, // ִ�н׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] wdata_o // ִ�н׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ
);

reg[`RegBus] logicout; // �����߼�����Ľ��
reg[`RegBus] shiftres; // ������λ����Ľ��
reg[`RegBus] moveres; // �����ƶ������Ľ��
reg[`RegBus] HI; // ���� HI �Ĵ���������ֵ
reg[`RegBus] LO; // ���� LO�Ĵ���������ֵ

// ********** �õ����µ� HI��LO�Ĵ�����ֵ���������������� ***********
always @( *) begin
    if (rst == `RstEnable) begin
        {HI, LO} <= {`ZeroWord, `ZeroWord}; 
    end else if (mem_whilo_i == `WriteEnable) begin
        {HI, LO} <= {mem_hi_i, mem_lo_i}; // �ô�׶ε�ָ��Ҫд HI��LO�Ĵ���
    end else if (wb_whilo_i == `WriteEnable) begin
        {HI, LO} <= {wb_hi_i, wb_lo_i}; // ��д�׶ε�ָ��Ҫд HI��LO�Ĵ���
    end else begin
        {HI, LO} <= {hi_i, lo_i};
    end
end

// ********** ���� aluop_i ָʾ�����������ͽ������� *************
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

// �����ƶ�����
always @( *) begin
    if (rst == `RstEnable) begin
        moveres <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_MFHI_OP: begin // mfhi ָ��� HI ��ֵ��Ϊ�ƶ������Ľ��
                moveres <= HI;
            end
            `EXE_MFLO_OP: begin // mflo ָ��� LO ��ֵ��Ϊ�ƶ������Ľ��
                moveres <= LO;
            end
            `EXE_MOVZ_OP: begin // movz ָ��� reg1_i ��ֵ(rs)��Ϊ�ƶ������Ľ��
                moveres <= reg1_i;
            end
            `EXE_MOVN_OP: begin // movn ָ��� reg1_i ��ֵ(rs)��Ϊ�ƶ������Ľ��
                moveres <= reg1_i;
            end
            default: begin
                moveres <= `ZeroWord;
            end
        endcase
    end
end

//mthi, mtlo ָ���Ҫ���� whilo_o��hi_o��lo_o ��ֵ
always @( *) begin
    if (rst == `RstEnable) begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end else if (aluop_i == `EXE_MTHI_OP) begin
        whilo_o <= `WriteEnable;
        hi_o <= reg1_i; // д HI �Ĵ���
        lo_o <= LO; // LO ���ֲ���
    end else if (aluop_i == `EXE_MTLO_OP) begin
        whilo_o <= `WriteEnable;
        hi_o <= HI; // HI ���ֲ���
        lo_o <= reg1_i; // д LO �Ĵ���
    end else begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end
end

// ***************** ���� alusel_i ָʾ���������ͣ�ѡ��һ����������Ϊ���ս�� ****************
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
        `EXE_RES_MOVE: begin // ѡ���ƶ�������Ϊ����������
            wdata_o <= moveres;
        end
        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end



endmodule