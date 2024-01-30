// **************************** ȫ�ֵĺ궨�� ****************************

`define RstEnable 1'b1 // ��λ�ź���Ч
`define RstDisable 1'b0 // ��λ�ź���Ч
`define ZeroWord 32'h0000_0000 // 32λ����ֵ0
`define WriteEnable 1'b1 // ʹ��д
`define WriteDisable 1'b0 // ��ֹд
`define ReadEnable 1'b1 // ʹ�ܶ�
`define ReadDisable 1'b0 // ��ֹ��
`define AluOpBus 7:0 // ����׶ε���� aluop_o �Ŀ��
`define AluSelBus 2:0 // ����׶ε���� alusel_o �Ŀ��
`define InstValid 1'b0 // ָ����Ч
`define InstInvalid 1'b1 // ָ����Ч
`define True_v 1'b1 // �߼����桯
`define False_v 1'b0 // �߼����١�
`define ChipEnable 1'b1 // оƬʹ��
`define ChipDisable 1'b0 // оƬ��ֹ
`define InterruptAssert 1'b1 // �����ж�
`define InterruptNotAssert 1'b0 // δ�����ж�

// **************************** �����ָ���йصĺ궨�� ****************************
`define EXE_AND 6'b100100 // ָ�� and �Ĺ�����
`define EXE_OR 6'b100101 // ָ�� or �Ĺ�����
`define EXE_XOR 6'b100110 // ָ�� xor �Ĺ�����
`define EXE_NOR 6'b100111 // ָ�� nor �Ĺ�����

`define EXE_ANDI 6'b001100 // ָ�� andi ��ָ����
`define EXE_ORI 6'b001101 // ָ�� ori ��ָ����
`define EXE_XORI 6'b001110 // ָ�� xori ��ָ����
`define EXE_LUI 6'b001111 // ָ�� lui ��ָ����

`define EXE_SLL 6'b000000 // ָ�� sll �Ĺ����� (nop��ssnop �ɵ�������� sll)
`define EXE_SLLV 6'b000100 // ָ�� sllv �Ĺ�����
`define EXE_SRL 6'b000010 // ָ�� srl �Ĺ�����
`define EXE_SRLV 6'b000110 // ָ�� srlv �Ĺ�����
`define EXE_SRA 6'b000011 // ָ�� sra �Ĺ�����
`define EXE_SRAV 6'b000111 // ָ�� srav �Ĺ�����

`define EXE_MOVZ 6'b001010 // ָ�� movz �Ĺ�����
`define EXE_MOVN 6'b001011 // ָ�� movn �Ĺ�����
`define EXE_MFHI 6'b010000 // ָ�� mfhi �Ĺ�����
`define EXE_MTHI 6'b010001 // ָ�� mthi �Ĺ�����
`define EXE_MFLO 6'b010010 // ָ�� mflo �Ĺ�����
`define EXE_MTLO 6'b010011 // ָ�� mtlo �Ĺ�����

`define EXE_ADD 6'b100000 // ָ�� add �Ĺ�����
`define EXE_ADDU 6'b100001 // ָ�� addu �Ĺ�����
`define EXE_SUB 6'b100010 // ָ�� sub �Ĺ�����
`define EXE_SUBU 6'b100011 // ָ�� subu �Ĺ�����
`define EXE_SLT 6'b101010 // ָ�� slt �Ĺ�����
`define EXE_SLTU 6'b101011 // ָ�� sltu �Ĺ�����

`define EXE_ADDI 6'b001000 // ָ�� addi ��ָ����
`define EXE_ADDIU 6'b001001 // ָ�� addiu ��ָ����
`define EXE_SLTI 6'b001010 // ָ�� slti ��ָ����
`define EXE_SLTIU 6'b001011 // ָ�� sltiu ��ָ����

`define EXE_CLO 6'b100001 // ָ�� clo �Ĺ�����
`define EXE_CLZ 6'b100000 // ָ�� clz �Ĺ�����

`define EXE_MUL 6'b000010 // ָ�� mul �Ĺ�����
`define EXE_MULT 6'b011000 // ָ���� mult �Ĺ�����
`define EXE_MULTU 6'b011001 // ָ�� multu �Ĺ�����

`define EXE_MADD 6'b000000 // ָ�� madd �Ĺ�����
`define EXE_MADDU 6'b000001 // ָ�� maddu �Ĺ�����
`define EXE_MSUB 6'b000100 // ָ�� msub �Ĺ�����
`define EXE_MSUBU 6'b000101 // ָ�� msubu �Ĺ�����

`define EXE_DIV  6'b011010 // ָ�� div �Ĺ�����
`define EXE_DIVU  6'b011011 // ָ�� div �Ĺ�����

`define EXE_J  6'b000010 // ָ�� j ��ָ����
`define EXE_JAL  6'b000011 // ָ�� jal ��ָ���� 
`define EXE_JALR  6'b001001 // ָ�� jalr �Ĺ�����
`define EXE_JR  6'b001000 // ָ�� jr �Ĺ�����
`define EXE_BEQ  6'b000100 // ָ�� beq ��ָ����
`define EXE_BGTZ  6'b000111 // ָ�� bgtz ��ָ����
`define EXE_BLEZ  6'b000110 // ָ�� blez ��ָ����
`define EXE_BNE  6'b000101 // ָ�� bne ��ָ����
`define EXE_BLTZ  5'b00000 // ָ�� bltz �Ĺ�����
`define EXE_BLTZAL  5'b10000 // ָ�� bltzal �Ĺ�����
`define EXE_BGEZ  5'b00001 // ָ�� bgez �Ĺ�����
`define EXE_BGEZAL  5'b10001 // ָ�� bgezal �Ĺ�����

`define EXE_LB  6'b100000 // ָ�� lb ��ָ����
`define EXE_LBU  6'b100100 // ָ�� lbu ��ָ����
`define EXE_LH  6'b100001 // ָ�� lh ��ָ����
`define EXE_LHU  6'b100101 // ָ�� lhu ��ָ����
`define EXE_LL  6'b110000
`define EXE_LW  6'b100011 // ָ�� lw ��ָ����
`define EXE_LWL  6'b100010 // ָ�� lwl ��ָ����
`define EXE_LWR  6'b100110 // ָ�� lwr ��ָ����
`define EXE_SB  6'b101000 // ָ�� sb ��ָ����
`define EXE_SC  6'b111000
`define EXE_SH  6'b101001 // ָ�� sh ��ָ����
`define EXE_SW  6'b101011 // ָ�� sw ��ָ����
`define EXE_SWL  6'b101010 // ָ�� swl ��ָ����
`define EXE_SWR  6'b101110 // ָ�� swr ��ָ����

`define EXE_LL 6'b110000 // ָ�� ll ��ָ����
`define EXE_SC 6'b111000 // ָ�� sc ��ָ����  

`define EXE_SYNC 6'b001111 // ָ�� sync �Ĺ�����
`define EXE_PREF 6'b110011 // ָ�� pref ��ָ����

`define EXE_SPECIAL_INST 6'b000000 // SPECIAL ָ���ָ����
`define EXE_SPECIAL2_INST 6'b011100 // SPECIAL2 ָ���ָ����
`define EXE_REGIMM_INST 6'b000001 // REGIMM ָ���ָ����


// AluOp
`define EXE_AND_OP 8'b0010_0100
`define EXE_OR_OP 8'b0010_0101
`define EXE_XOR_OP 8'b0010_0110
`define EXE_NOR_OP 8'b0010_0111

`define EXE_SLL_OP 8'b0111_1100
`define EXE_SRL_OP 8'b0000_0010
`define EXE_SRA_OP 8'b0000_0011

`define EXE_MOVZ_OP  8'b0000_1010
`define EXE_MOVN_OP  8'b0000_1011
`define EXE_MFHI_OP  8'b0001_0000
`define EXE_MTHI_OP  8'b0001_0001
`define EXE_MFLO_OP  8'b0001_0010
`define EXE_MTLO_OP  8'b0001_0011

`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_ADD_OP  8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP  8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP  8'b01010110
`define EXE_CLZ_OP  8'b10110000
`define EXE_CLO_OP  8'b10110001

`define EXE_MULT_OP  8'b00011000
`define EXE_MULTU_OP  8'b00011001
`define EXE_MUL_OP  8'b10101001

`define EXE_MADD_OP  8'b10100110
`define EXE_MADDU_OP  8'b10101000
`define EXE_MSUB_OP  8'b10101010
`define EXE_MSUBU_OP  8'b10101011

`define EXE_DIV_OP  8'b00011010
`define EXE_DIVU_OP  8'b00011011

`define EXE_J_OP  8'b01001111
`define EXE_JAL_OP  8'b01010000
`define EXE_JALR_OP  8'b00001001
`define EXE_JR_OP  8'b00001000
`define EXE_BEQ_OP  8'b01010001
`define EXE_BGEZ_OP  8'b01000001
`define EXE_BGEZAL_OP  8'b01001011
`define EXE_BGTZ_OP  8'b01010100
`define EXE_BLEZ_OP  8'b01010011
`define EXE_BLTZ_OP  8'b01000000
`define EXE_BLTZAL_OP  8'b01001010
`define EXE_BNE_OP  8'b01010010

`define EXE_LB_OP  8'b11100000
`define EXE_LBU_OP  8'b11100100
`define EXE_LH_OP  8'b11100001
`define EXE_LHU_OP  8'b11100101
`define EXE_LL_OP  8'b11110000
`define EXE_LW_OP  8'b11100011
`define EXE_LWL_OP  8'b11100010
`define EXE_LWR_OP  8'b11100110
`define EXE_SB_OP  8'b11101000
`define EXE_SC_OP  8'b11111000
`define EXE_SH_OP  8'b11101001
`define EXE_SW_OP  8'b11101011
`define EXE_SWL_OP  8'b11101010
`define EXE_SWR_OP  8'b11101110

`define EXE_MFC0_OP 8'b01011101
`define EXE_MTC0_OP 8'b01100000

`define EXE_NOP_OP 8'b0000_0000

// AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_MOVE 3'b011	
`define EXE_RES_ARITHMETIC 3'b100	
`define EXE_RES_MUL 3'b101
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE 3'b111

`define EXE_RES_NOP 3'b000

// ************************** ��ָ��洢�� ROM �йصĺ궨�� *************************

`define InstAddrBus 31:0 // ROM �ĵ�ַ���߿��
`define InstBus 31:0 // ROM ���������߿��
`define InstMemNum 131017 // ROM ��ʵ�ʴ�СΪ 128KB
`define InstMemNumLog2 17 // ROM ʵ��ʹ�õĵ�ַ�߿��

// ************************** �����ݴ洢�� DATA_RAM �йصĺ궨�� *************************

`define DataAddrBus 31:0 // ��ַ���߿��
`define DataBus 31:0 // �������߿��
`define DataMemNum 131017 // RAM ��ʵ�ʴ�СΪ 128KB
`define DataMemNumLog2 17 // RAM ʵ��ʹ�õĵ�ַ�߿��
`define ByteWidth 7:0 // һ���ֽڵĿ�ȣ�8bit

// *********************** ��ͨ�üĴ��� Regfile �йصĺ궨�� ***********************

`define RegAddrBus 4:0 // Regfile ģ��ĵ�ַ�߿��
`define RegBus 31:0 // Regfile ģ��������߿��
`define RegWidth 32 // ͨ�üĴ����Ŀ��
`define DoubleRegWidth 64 // ������ͨ�üĴ����Ŀ��
`define DoubleRegBus 63:0 // ������ͨ�üĴ����������߿��
`define RegNum 32 // ͨ�üĴ���������
`define RegNumLog2 5 // Ѱַͨ�üĴ���ʹ�õĵ�ַλ��
`define NOPRegAddr 5'b00000

// *********************** ����ˮ����ͣ�йصĺ궨�� ***********************
`define Stop 1'b1 // ��ˮ����ͣ
`define NoStop 1'b0 // ��ˮ�߼���
`define StallBus 5:0 // �����źſ��

//����div
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0

// ת��ָ��
`define Branch 1'b1 // ת��
`define NotBranch 1'b0 // ��ת��
`define InDelaySlot 1'b1 // ���ӳٲ���
`define NotInDelaySlot 1'b0 // �����ӳٲ���

// ���� CP0 �и����Ĵ����ĵ�ַ
`define CP0_REG_COUNT 5'b01001 //�ɶ�д
`define CP0_REG_COMPARE 5'b01011 //�ɶ�д
`define CP0_REG_STATUS 5'b01100 //�ɶ�д
`define CP0_REG_CAUSE 5'b01101 //ֻ��
`define CP0_REG_EPC 5'b01110 //�ɶ�д
`define CP0_REG_PRId 5'b01111 //ֻ��
`define CP0_REG_CONFIG 5'b10000 //ֻ��

