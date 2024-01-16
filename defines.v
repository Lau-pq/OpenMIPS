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

`define EXE_SYNC 6'b001111 // ָ�� syne �Ĺ�����
`define EXE_PREF 6'b110011 // ָ�� pref ��ָ����
`define EXE_SPECIAL_INST 6'b000000 // SPECIAL ָ���ָ����

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

`define EXE_NOP_OP 8'b0000_0000

// AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010
`define EXE_RES_MOVE 3'b011	

`define EXE_RES_NOP 3'b000

// ************************** ��ָ��洢�� ROM �йصĺ궨�� *************************

`define InstAddrBus 31:0 // ROM �ĵ�ַ���߿��
`define InstBus 31:0 // ROM ���������߿��
`define InstMemNum 131017 // ROM ��ʵ�ʴ�СΪ 128KB
`define InstMemNumLog2 17 // ROM ʵ��ʹ�õĵ�ַ�߿��

// *********************** ��ͨ�üĴ��� Regfile �йصĺ궨�� ***********************

`define RegAddrBus 4:0 // Regfile ģ��ĵ�ַ�߿��
`define RegBus 31:0 // Regfile ģ��������߿��
`define RegWidth 32 // ͨ�üĴ����Ŀ��
`define DoubleRegWidth 64 // ������ͨ�üĴ����Ŀ��
`define DoubleRegBus 63:0 // ������ͨ�üĴ����������߿��
`define RegNum 32 // ͨ�üĴ���������
`define RegNumLog2 5 // Ѱַͨ�üĴ���ʹ�õĵ�ַλ��
`define NOPRegAddr 5'b00000
