`include "defines.v"

module id(
    input wire rst, // ��λ�ź�
    input wire[`InstAddrBus] pc_i, // ����׶ε�ָ���Ӧ��ַ 
    input wire[`InstBus] inst_i, // ����׶ε�ָ��

    //����ִ�н׶ε�ָ���һЩ��Ϣ�����ڽ��load���
    input wire[`AluOpBus] ex_aluop_i,

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

    // �ӳٲ�ָ��
    input wire is_in_delayslot_i, // ��ǰ��������׶ε�ָ���Ƿ�λ���ӳٲ� 

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
    output reg wreg_o,  // ����׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���

    // �ӳٲ�ָ��
    output reg next_inst_in_delayslot_o, // ��һ����������׶ε�ָ���Ƿ�λ���ӳٲ�

    output reg branch_flag_o, // �Ƿ���ת��
    output reg[`RegBus] branch_target_address_o, // ת�Ƶ���Ŀ���ַ
    output reg[`RegBus] link_addr_o, // ת��ָ��Ҫ����ķ��ص�ַ
    output reg is_in_delayslot_o, // ��ǰ��������׶ε�ָ���Ƿ�λ���ӳٲ�

    output wire[`RegBus] inst_o, // ��ǰ��������׶ε�ָ�� 
    output wire stallreq, // ��ˮ���Ƿ���Ҫ��ͣ

    output wire[31:0] excepttype_o, // �ռ����쳣��Ϣ
    output wire[`RegBus] current_inst_address_o // ����׶�ָ��ĵ�ַ
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

// ��ת��ָ��ʵ����صı���
wire[`RegBus] pc_plus_8;
wire[`RegBus] pc_plus_4;

wire[`RegBus] imm_sll2_signedext;

reg stallreq_for_reg1_loadrelate;
reg stallreq_for_reg2_loadrelate;
wire pre_inst_is_load;

assign pc_plus_8 = pc_i + 8; // ���浱ǰ����׶�ָ������ 2��ָ��ĵ�ַ
assign pc_plus_4 = pc_i + 4; // ���浱ǰ����׶�ָ���������ŵ�ָ��ĵ�ַ
// imm_sll2_signedext ��Ӧ��ָ֧�� offset ������λ���ٷ�����չ�� 32λ
assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00}; 

reg excepttype_is_syscall; // �Ƿ���ϵͳ�����쳣 syscall
reg excepttype_is_eret; // �Ƿ����쳣����ָ�� eret

assign excepttype_o = {19'b0, excepttype_is_eret, 2'b0,instvalid, excepttype_is_syscall, 8'b0};
assign current_inst_address_o = pc_i; // �����ź� pc_i ���ǵ�ǰ��������׶�ָ��ĵ�ַ


// ��ˮ���Ƿ���Ҫ��ͣ
assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
assign pre_inst_is_load = (
        (ex_aluop_i == `EXE_LB_OP) || 
  		(ex_aluop_i == `EXE_LBU_OP)||
  		(ex_aluop_i == `EXE_LH_OP) ||
  		(ex_aluop_i == `EXE_LHU_OP)||
  	    (ex_aluop_i == `EXE_LW_OP) ||
  		(ex_aluop_i == `EXE_LWR_OP)||
  		(ex_aluop_i == `EXE_LWL_OP)||
  		(ex_aluop_i == `EXE_LL_OP) ||
  		(ex_aluop_i == `EXE_SC_OP)) ? 1'b1 : 1'b0;

assign inst_o = inst_i;

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
        link_addr_o <= `ZeroWord;
        branch_target_address_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
        excepttype_is_syscall <= `False_v; // Ĭ��û��ϵͳ�����쳣
        excepttype_is_eret <= `False_v; // Ĭ�ϲ��� eret ָ�� 
    end else begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= rd; // rd
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvalid; // Ĭ������Чָ��
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= rs; // rs Ĭ��ͨ�� Regfile ���˿�1 ��ȡ�ļĴ�����ַ
        reg2_addr_o <= rt; // rt Ĭ��ͨ�� Regfile ���˿�2 ��ȡ�ļĴ�����ַ
        imm <= `ZeroWord;
        link_addr_o <= `ZeroWord;
        branch_target_address_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
        excepttype_is_syscall <= `False_v; // Ĭ��û��ϵͳ�����쳣
        excepttype_is_eret <= `False_v; // Ĭ�ϲ��� eret ָ�� 

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
                            `EXE_MFHI: begin // mfhi ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_MFHI_OP;
                                alusel_o <= `EXE_RES_MOVE;
                                reg1_read_o <= `ReadDisable;
                                reg2_read_o <= `ReadDisable;
                                instvalid <= `InstValid;
                            end
                            `EXE_MFLO: begin // mflo ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_MFLO_OP;
                                alusel_o <= `EXE_RES_MOVE;
                                reg1_read_o <= `ReadDisable;
                                reg1_read_o <= `ReadDisable;
                                instvalid <= `InstValid;
                            end
                            `EXE_MTHI: begin // mthi ָ��
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_MTHI_OP;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadDisable;
                                instvalid <= `InstValid;
                            end
                            `EXE_MTLO: begin // mtlo ָ��
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_MTLO_OP;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadDisable;
                                instvalid <= `InstValid;
                            end
                            `EXE_MOVN: begin // movn ָ��
                                aluop_o <= `EXE_MOVN_OP;
                                alusel_o <= `EXE_RES_MOVE;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                                // reg2_o ��ֵ���ǵ�ַΪ rt ��ͨ�üĴ�����ֵ
                                if (reg2_o != `ZeroWord) begin
                                    wreg_o <= `WriteEnable;
                                end else begin
                                    wreg_o <= `WriteDisable;
                                end
                            end
                            `EXE_MOVZ: begin // movz ָ��
                                aluop_o <= `EXE_MOVZ_OP;
                                alusel_o <= `EXE_RES_MOVE;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                                // reg2_o ��ֵ���ǵ�ַΪ rt ��ͨ�üĴ�����ֵ
                                if (reg2_o == `ZeroWord) begin
                                    wreg_o <= `WriteEnable;
                                end else begin
                                    wreg_o <= `WriteDisable;
                                end
                            end
                            `EXE_SLT: begin // slt ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SLT_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SLTU: begin // sltu ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SLTU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_ADD: begin // add ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_ADD_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_ADDU: begin // addu ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_ADDU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_SUB: begin // sub ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SUB_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end 
                            `EXE_SUBU: begin // subu ָ��
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SUBU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_MULT: begin // mult ָ��
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_MULT_OP;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_MULTU: begin // multu ָ��
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_MULTU_OP;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_DIV: begin // div ָ��
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_DIV_OP;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_DIVU: begin
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_DIVU_OP;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadEnable;
                                instvalid <= `InstValid;
                            end
                            `EXE_JR: begin // jr ָ��
                                wreg_o <= `WriteDisable;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadDisable;  
                                branch_target_address_o <= reg1_o;
                                branch_flag_o <= `Branch;
                                next_inst_in_delayslot_o <= `InDelaySlot;
                                instvalid <= `InstValid;                
                            end
                            `EXE_JALR: begin // jalr ָ��
                                wreg_o <= `WriteEnable;
                                alusel_o <= `EXE_RES_JUMP_BRANCH;
                                reg1_read_o <= `ReadEnable;
                                reg2_read_o <= `ReadDisable;
                                wd_o <= rd;
                                link_addr_o <= pc_plus_8;
                                branch_target_address_o <= reg1_o;
                                branch_flag_o <= `Branch;
                                next_inst_in_delayslot_o <= `InDelaySlot;
                                instvalid <= `InstValid;
                            end
                            default: begin 
                            end  
                        endcase
                    end
                    default: begin
                    end  
                endcase

                case (func)
                    `EXE_TEQ: begin // teq ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TEQ_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_TGE: begin // tge ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TGE_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_TGEU: begin // tgeu ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TGEU_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_TLT: begin // tlt ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TLT_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_TLTU: begin // tltu ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TLTU_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_TNE: begin // tne ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TNE_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_SYSCALL: begin // syscall ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_SYSCALL_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadDisable;
                        reg2_read_o <= `ReadDisable;
                        instvalid <= `InstValid;
                        excepttype_is_syscall <= `True_v;
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
            `EXE_SLTI: begin // slti ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SLT_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {{16{inst_i[15]}}, inst_i[15:0]}; // ������������չ
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_SLTIU: begin // sltiu ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SLTU_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {{16{inst_i[15]}}, inst_i[15:0]}; // ������������չ
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_ADDI: begin // addi ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_ADDI_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_ADDIU: begin // addiu ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_ADDIU_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_J: begin // j ָ��
                wreg_o <= `WriteDisable;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
                branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;
                instvalid <= `InstValid;
            end
            `EXE_JAL: begin // jal ָ��
                wreg_o <= `WriteEnable;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
                wd_o <= 5'b11111; // �Ĵ��� $31
                link_addr_o <= pc_plus_8;
                branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;
                instvalid <= `InstValid;
            end
            `EXE_BEQ: begin // beq ָ��
                wreg_o <= `WriteDisable;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instvalid <= `InstValid;
                if (reg1_o == reg2_o) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
            end
            `EXE_BGTZ: begin // bgtz ָ��
                wreg_o <= `WriteDisable;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                instvalid <= `InstValid;
                if ((!reg1_o[31]) && (reg1_o != `ZeroWord)) begin // rs ��ֵ���� 0
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
            end
            `EXE_BLEZ: begin // blez ָ��
                wreg_o <= `WriteDisable;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                instvalid <= `InstValid;
                if ((reg1_o[31]) || (reg1_o == `ZeroWord)) begin // rs ��ֵС�ڵ��� 0
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
            end
            `EXE_BNE: begin // bne ָ��
                wreg_o <= `WriteDisable;
                reg1_read_o  <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instvalid <= `InstValid;
                if (reg1_o != reg2_o) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
            end
            `EXE_REGIMM_INST: begin // op ���� regimm
                case (rt) 
                    `EXE_BGEZ: begin // bgez ָ��
                        wreg_o <= `WriteDisable;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instvalid <= `InstValid;
                        if (!reg1_o[31]) begin // rs ��ֵ���ڵ���0
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        end
                    end
                    `EXE_BGEZAL: begin // bgezal ָ��
                        wreg_o <= `WriteEnable;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        link_addr_o <= pc_plus_8;
                        wd_o <= 5'b11111; // �Ĵ��� $31
                        instvalid <= `InstValid;
                        if (!reg1_o[31]) begin // rs ��ֵ���ڵ��� 0
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        end
                    end
                    `EXE_BLTZ: begin // bltz ָ��
                        wreg_o <= `WriteDisable;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instvalid <= `InstValid;
                        if (reg1_o[31]) begin // rs ��ֵС��0
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        end
                    end
                    `EXE_BLTZAL: begin // bltzal ָ��
                        wreg_o <= `WriteEnable;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        link_addr_o <= pc_plus_8;
                        wd_o <= 5'b11111; // �Ĵ��� $31
                        instvalid <= `InstValid;
                        if (reg1_o[31]) begin // rs ��ֵС�� 0
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;
                        end
                    end
                    `EXE_TEQI: begin // teqi ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TEQI_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                        instvalid <= `InstValid;
                    end
                    `EXE_TGEI: begin // tgei ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TGEI_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                        instvalid <= `InstValid;
                    end
                    `EXE_TGEIU: begin // tgeiu ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TGEIU_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                        instvalid <= `InstValid;
                    end
                    `EXE_TLTI: begin // tlti ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TLTI_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                        instvalid <= `InstValid;
                    end
                    `EXE_TLTIU: begin // tltiu ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TLTIU_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                        instvalid <= `InstValid;
                    end
                    `EXE_TNEI: begin // tnei ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_TNEI_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                        instvalid <= `InstValid;
                    end
                endcase
            end
            `EXE_SPECIAL2_INST: begin // op ���� SPECIAL2
                case (func)
                    `EXE_CLZ: begin // clz ָ��
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_CLZ_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instvalid <= `InstValid;
                    end
                    `EXE_CLO: begin // clo ָ��
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_CLO_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instvalid <= `InstValid;
                    end
                    `EXE_MUL: begin // mul ָ��
                        wreg_o <= `WriteEnable;
                        aluop_o <= `EXE_MUL_OP;
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_MADD: begin // madd ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MADD_OP;
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_MADDU: begin // maddu ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MADDU_OP; 
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_MSUB: begin // msub ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MSUB_OP;
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    `EXE_MSUBU: begin // msubu ָ��
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_MSUBU_OP;
                        alusel_o <= `EXE_RES_MUL;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadEnable;
                        instvalid <= `InstValid;
                    end
                    default: begin
                    end  
                endcase 
            end
            `EXE_LB: begin // lb ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LB_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_LBU: begin // lbu ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LBU_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_LH: begin // lh ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LH_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_LHU: begin // lhu ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LHU_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_LW: begin // lw ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LW_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_LWL: begin // lwl ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LWL_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_LWR: begin // lwr ָ�� 
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LWR_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_SB: begin // sb ָ��
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SB_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instvalid <= `InstValid;
            end
            `EXE_SH: begin // sh ָ��
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SH_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instvalid <= `InstValid;
            end
            `EXE_SW: begin // sw ָ��
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SW_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instvalid <= `InstValid;
            end
            `EXE_SWL: begin // swl ָ��
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SWL_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instvalid <= `InstValid;
            end
            `EXE_SWR: begin // swr ָ��
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SWR_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                instvalid <= `InstValid;
            end
            `EXE_LL: begin // ll ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LL_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            `EXE_SC: begin // sc ָ��
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_SC_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
                wd_o <= rt;
                instvalid <= `InstValid;
            end
            default: begin
            end
        endcase

        if (inst_i == `EXE_ERET) begin // eret ָ��
            wreg_o <= `WriteDisable;
            aluop_o <= `EXE_ERET_OP;
            alusel_o <= `EXE_RES_NOP;
            reg1_read_o <= `ReadDisable;
            reg2_read_o <= `ReadDisable;
            instvalid <= `InstValid;
            excepttype_is_eret <= `True_v;
        end

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
        if (inst_i[31:21] == 11'b010_0000_0000 && inst_i[10:0] == 11'b000_0000_0000) begin // mfc0 ָ��
            wreg_o <= `WriteEnable;
            aluop_o <= `EXE_MFC0_OP;
            alusel_o <= `EXE_RES_MOVE;
            wd_o <= rt;
            reg1_read_o <= `ReadDisable;
            reg2_read_o <= `ReadDisable;
            instvalid <= `InstValid;
        end else if (inst_i[31:21] == 11'b010_0000_0100 && inst_i[10:0] == 11'b000_0000_0000) begin // mtc0 ָ��
            wreg_o <= `WriteDisable;
            aluop_o <= `EXE_MTC0_OP;
            alusel_o <= `EXE_RES_MOVE;
            reg1_read_o <= `ReadEnable;
            reg2_read_o <= `ReadDisable;
            reg1_addr_o <= rt;
            instvalid <= `InstValid;
        end
    end
end

// ******************* �ڶ��Σ�ȷ�����������Դ������ 1 *****************************
// �������������
always @( *) begin
    stallreq_for_reg1_loadrelate <= `NoStop;
    if (rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && reg1_read_o == `ReadEnable ) begin
		  stallreq_for_reg1_loadrelate <= `Stop;
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
    stallreq_for_reg2_loadrelate <= `NoStop;
    if (rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && reg2_read_o == `ReadEnable ) begin
		  stallreq_for_reg2_loadrelate <= `Stop;
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

// ������� is_in_delayslot_o ��ʾ��ǰ����׶�ָ���Ƿ����ӳٲ�ָ��
always @( *) begin
    if (rst == `RstEnable) begin
        is_in_delayslot_o <= `NotInDelaySlot;
    end else begin
        is_in_delayslot_o <= is_in_delayslot_i;
    end
end

endmodule