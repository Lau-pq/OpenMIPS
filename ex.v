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
    output reg[`RegBus] wdata_o, // ִ�н׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ

    output reg stallreg // ��ʵ���Ƿ���ͣ
);

reg[`RegBus] logicout; // �����߼�����Ľ��
reg[`RegBus] shiftres; // ������λ����Ľ��
reg[`RegBus] moveres; // �����ƶ������Ľ��
reg[`RegBus] arithmeticres; // ������������Ľ��
reg[`DoubleRegBus] mulres; // ����˷���������Ϊ 64λ
reg[`RegBus] HI; // ���� HI �Ĵ���������ֵ
reg[`RegBus] LO; // ���� LO�Ĵ���������ֵ

wire ov_sum; // ����������
wire reg1_eq_reg2; // ��һ���������Ƿ���ڵڶ���������
wire reg1_lt_reg2; // ��һ���������Ƿ�С�ڵڶ���������
wire[`RegBus] reg2_i_mux; // ��������ĵڶ��������� reg2_i �Ĳ���
wire[`RegBus] reg1_i_not; // ��������ĵ�һ�������� reg1_i ȡ�����ֵ
wire[`RegBus] result_sum; // ����ӷ����
wire[`RegBus] opdata1_mult; // �˷������еı�����
wire[`RegBus] opdata2_mult; // �˷������еĳ���
wire[`DoubleRegBus] hilo_temp; // ��ʱ����˷���������Ϊ 64λ

// ******************** ���������ֵ ***********************
// ���� �� �з��űȽ� reg2_i_mux Ϊ reg2_i ���룬����Ϊ reg2_i
assign reg2_i_mux = (
    (aluop_i == `EXE_SUB_OP) || 
    (aluop_i == `EXE_SUBU_OP) || 
    (aluop_i == `EXE_SLT_OP)) ? 
    (~reg2_i)+1 : reg2_i;  

// �ӷ� result_sum Ϊ�ӷ�������
// ���� result_sum Ϊ����������
// �з��űȽ����� result_sum ���������� �ж��Ƿ�С�� 0 

assign result_sum = reg1_i + reg2_i_mux;

// �����Ƿ����
assign ov_sum = 
    ((!reg1_i[31] && !reg2_i_mux[31]) && // reg1_i ��, reg2_i_mux ��
    result_sum[31]) || // ����֮��Ϊ����
    ((reg1_i[31] && reg2_i_mux[31]) && // reg1_i ��, reg2_i_mux ��
    (!result_sum[31])); // ����֮��Ϊ����

// ��������� 1�Ƿ�С�ڲ����� 2
assign reg1_lt_reg2 = 
    ((aluop_i == `EXE_SLT_OP)) ? // �з��űȽ�����
    ((reg1_i[31] && !reg2_i[31]) || // reg1_i��, reg2_i��, reg1_i < reg2_i
    (!reg1_i[31] && !reg2_i[31] && result_sum[31]) || // reg1_i��, reg2_i��, �� < 0
    (reg1_i[31] && reg2_i[31] && result_sum[31])) // reg1_i��, reg2_i��, �� < 0
    : (reg1_i < reg2_i); // �޷������Ƚ�

// �Բ����� 1 ��λȡ�������� reg1_i_not
assign reg1_i_not = ~reg1_i;

// ȡ�ó˷�����ı�������������з��ų˷��ұ������Ǹ�����ȡ����
assign opdata1_mult = 
    (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) &&
    (reg1_i[31])) ? (~reg1_i + 1) : reg1_i;

// ȡ�ó˷�����ĳ�����������з��ų˷��ҳ����Ǹ�����ȡ����
assign opdata2_mult = 
    (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) &&
    (reg2_i[31])) ? (~reg2_i + 1) : reg2_i;

// �õ���ʱ�˷�����������ڱ��� hilo_temp ��
assign hilo_temp = opdata1_mult * opdata2_mult;

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

// ������������
always @( *) begin
    if (rst == `RstEnable) begin
        arithmeticres <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_SLT_OP, `EXE_SLTU_OP: begin
                arithmeticres <= reg1_lt_reg2; // �Ƚ�����
            end
            `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
                arithmeticres <= result_sum; // �ӷ�����
            end
            `EXE_SUB_OP, `EXE_SUBU_OP: begin 
                arithmeticres <= result_sum; // ��������
            end
            `EXE_CLZ_OP: begin // �������� clz
                arithmeticres <= reg1_i[31] ? 0 : reg1_i[30] ? 1 :
                                reg1_i[29] ? 2 : reg1_i[28] ? 3 :
                                reg1_i[27] ? 4 : reg1_i[26] ? 5 :
                                reg1_i[25] ? 6 : reg1_i[24] ? 7 :
                                reg1_i[23] ? 8 : reg1_i[22] ? 9 :
                                reg1_i[21] ? 10 : reg1_i[20] ? 11 :
                                reg1_i[19] ? 12 : reg1_i[18] ? 13 :
                                reg1_i[17] ? 14 : reg1_i[16] ? 15 :
                                reg1_i[15] ? 16 : reg1_i[14] ? 17 :
                                reg1_i[13] ? 18 : reg1_i[12] ? 19 :
                                reg1_i[11] ? 20 : reg1_i[10] ? 21 :
                                reg1_i[9] ? 22 : reg1_i[8] ? 23 :
                                reg1_i[7] ? 24 : reg1_i[6] ? 25 :
                                reg1_i[5] ? 26 : reg1_i[4] ? 27 :
                                reg1_i[3] ? 28 : reg1_i[2] ? 29 :
                                reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32;
            end
            `EXE_CLO_OP: begin // �������� clo
                arithmeticres <= reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 :
                                reg1_i_not[29] ? 2 : reg1_i_not[28] ? 3 :
                                reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
                                reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 :
                                reg1_i_not[23] ? 8 : reg1_i_not[22] ? 9 :
                                reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
                                reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 :
                                reg1_i_not[17] ? 14 : reg1_i_not[16] ? 15 :
                                reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 :
                                reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 :
                                reg1_i_not[11] ? 20 : reg1_i_not[10] ? 21 :
                                reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 :
                                reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 :
                                reg1_i_not[5] ? 26 : reg1_i_not[4] ? 27 :
                                reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 :
                                reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32;
            end
            default: begin
                arithmeticres <= `ZeroWord;
            end
        endcase
    end
end

// ���г˷�����
always @( *) begin
    if (rst == `RstEnable) begin
        mulres <= {`ZeroWord, `ZeroWord};
    end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP)) begin // �з��ų˷�
        if (reg1_i[31] ^ reg2_i[31]) begin // ���
            mulres <= ~hilo_temp + 1; // ����
        end else begin
            mulres <= hilo_temp;
        end
    end else begin
        mulres <= hilo_temp; // �޷��ų˷�
    end
end

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

//mthi, mtlo ָ���Ҫ���� whilo_o��hi_o��lo_o ��ֵ
always @( *) begin
    if (rst == `RstEnable) begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin // mult��multu ָ��
        whilo_o <= `WriteEnable;
        hi_o <= mulres[63:32];
        lo_o <= mulres[31:0];
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
    if (((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) && (ov_sum)) begin
        wreg_o <= `WriteDisable; // add��addi��sub ָ������, ��дĿ�ļĴ��� 
    end else begin
        wreg_o <= wreg_i; // wreg_o ���� wreg_i����ʾ�Ƿ�ҪдĿ�ļĴ���        
    end
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
        `EXE_RES_ARITHMETIC: begin
            wdata_o <= arithmeticres; // ���˷���ļ���������ָ��
        end
        `EXE_RES_MUL: begin
            wdata_o <= mulres[31:0]; // �˷�ָ�� mul
        end
        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end



endmodule