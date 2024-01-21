`include "defines.v"

module openmips(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�
    
    input wire[`InstBus] rom_data_i, // ��ָ��洢��ȡ�õ�ָ��
    output wire[`InstAddrBus] rom_addr_o, // �����ָ��洢���ĵ�ַ
    output wire rom_ce_o // ָ��洢��ʹ���ź�
);

// ���� IF/ID ģ��������׶� ID ģ��ı���
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstAddrBus] id_inst_i;

// ��������׶� ID ģ������� ID/EX ģ�������ı���
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;

// ���� ID/EX ģ��������ִ�н׶� EX ģ�������ı���
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;

// ����ִ�н׶� EX ģ�������� EX/MEM ģ�������ı���
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;
wire[`RegBus] ex_hi_o;
wire[`RegBus] ex_lo_o;
wire ex_whilo_o;

// ���� EX/MEM ģ��������ô�׶� MEM ģ�������ı���
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;
wire[`RegBus] mem_hi_i;
wire[`RegBus] mem_lo_i;
wire mem_whilo_i;

// ���ӷô�׶� MEM ģ�������� MEM/WB ģ�������ı���
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;
wire[`RegBus] mem_hi_o;
wire[`RegBus] mem_lo_o;
wire mem_whilo_o;

// ���� MEM/WB ģ���������д�׶ε�����ı���
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;
wire[`RegBus] wb_hi_i;
wire[`RegBus] wb_lo_i;
wire wb_whilo_i;

// ��������׶� ID ģ����ͨ�üĴ��� Regfile ģ��ı���
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

// ����ִ�н׶��� HILO ģ����������ȡ HI��LO�Ĵ���
wire[`RegBus] hi;
wire[`RegBus] lo;

// ����ˮ����ͣ��صı���
wire[`StallBus] stall;
wire stallreq_from_id;	
wire stallreq_from_ex;

// pc_reg ����
pc_reg pc_reg0(
    .clk(clk),
    .rst(rst),
    .stall(stall), 
    .pc(pc), 
    .ce(rom_ce_o)
); 

assign rom_addr_o = pc; // ָ��洢���������ַ���� pc ��ֵ

// IF/ID ģ������
if_id if_id0(
    .clk(clk),
    .rst(rst),
    .stall(stall), 
    .if_pc(pc),
    .if_inst(rom_data_i),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

// ����׶� ID ģ������
id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i), 

    // ���� Regfile ģ�������
    .reg1_data_i(reg1_data), 
    .reg2_data_i(reg2_data), 

    // ����ִ�н׶ε�ָ���������
    .ex_wreg_i(ex_wreg_o),
    .ex_wdata_i(ex_wdata_o), 
    .ex_wd_i(ex_wd_o),

    // ���ڷô�׶ε�ָ���������
    .mem_wreg_i(mem_wreg_o), 
    .mem_wdata_i(mem_wdata_o), 
    .mem_wd_i(mem_wd_o), 

    // �͵� Regfile ģ�����Ϣ
    .reg1_read_o(reg1_read), 
    .reg2_read_o(reg2_read), 
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),

    // �͵� ID/EX ģ�����Ϣ
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o), 
    .reg2_o(id_reg2_o), 
    .wd_o(id_wd_o), 
    .wreg_o(id_wreg_o),

    // �͵� ctrl ģ�����Ϣ
    .stallreq(stallreq_from_id)
);

// ͨ�üĴ��� Regfile ģ������
regfile regfile1(
    .clk(clk),
    .rst(rst),
    .we(wb_wreg_i), 
    .waddr(wb_wd_i),
    .wdata(wb_wdata_i), 
    .re1(reg1_read), 
    .raddr1(reg1_addr), 
    .rdata1(reg1_data), 
    .re2(reg2_read), 
    .raddr2(reg2_addr), 
    .rdata2(reg2_data)
);

// ID/EX ģ������
id_ex id_ex0(
    .clk(clk), 
    .rst(rst), 
    .stall(stall),

    // ������׶� ID ģ�鴫�ݹ�������Ϣ
    .id_aluop(id_aluop_o), 
    .id_alusel(id_alusel_o), 
    .id_reg1(id_reg1_o), 
    .id_reg2(id_reg2_o), 
    .id_wd(id_wd_o), 
    .id_wreg(id_wreg_o),

    // ���ݵ�ִ�н׶� EX ģ�����Ϣ
    .ex_aluop(ex_aluop_i), 
    .ex_alusel(ex_alusel_i), 
    .ex_reg1(ex_reg1_i), 
    .ex_reg2(ex_reg2_i), 
    .ex_wd(ex_wd_i), 
    .ex_wreg(ex_wreg_i)
);

// EX ģ������
ex ex0(
    .rst(rst), 

    // �� ID/EX ģ�鴫�ݹ�������Ϣ
    .aluop_i(ex_aluop_i), 
    .alusel_i(ex_alusel_i), 
    .reg1_i(ex_reg1_i), 
    .reg2_i(ex_reg2_i), 
    .wd_i(ex_wd_i), 
    .wreg_i(ex_wreg_i),
    
    .hi_i(hi), 
    .lo_i(lo),
    .mem_hi_i(mem_hi_o),
    .mem_lo_i(mem_lo_o), 
    .mem_whilo_i(mem_whilo_o), 
    .wb_hi_i(wb_hi_i), 
    .wb_lo_i(wb_lo_i), 
    .wb_whilo_i(wb_whilo_i), 

    // ����� EX/MEM ģ�����Ϣ
    .wd_o(ex_wd_o), 
    .wreg_o(ex_wreg_o), 
    .wdata_o(ex_wdata_o),

    .hi_o(ex_hi_o), 
    .lo_o(ex_lo_o), 
    .whilo_o(ex_whilo_o), 

    // �͵� ctrl ģ�����Ϣ
    .stallreq(stallreq_from_ex)
);

// EX/MEM ģ������
ex_mem ex_mem0(
    .clk(clk), 
    .rst(rst), 
    .stall(stall), 

    // ����ִ�н׶� EX ģ�����Ϣ
    .ex_wd(ex_wd_o), 
    .ex_wreg(ex_wreg_o), 
    .ex_wdata(ex_wdata_o), 
    .ex_hi(ex_hi_o), 
    .ex_lo(ex_lo_o),
    .ex_whilo(ex_whilo_o),

    // �͵��ô�׶� MEM ģ�����Ϣ
    .mem_wd(mem_wd_i), 
    .mem_wreg(mem_wreg_i), 
    .mem_wdata(mem_wdata_i), 
    .mem_hi(mem_hi_i), 
    .mem_lo(mem_lo_i), 
    .mem_whilo(mem_whilo_i)
);

// MEM ģ������
mem mem0(
    .rst(rst), 
    
    // ���� EX/MEM ģ�����Ϣ
    .wd_i(mem_wd_i), 
    .wreg_i(mem_wreg_i), 
    .wdata_i(mem_wdata_i), 
    .hi_i(mem_hi_i), 
    .lo_i(mem_lo_i), 
    .whilo_i(mem_whilo_i), 

    // �͵� MEM/WB ģ�����Ϣ
    .wd_o(mem_wd_o), 
    .wreg_o(mem_wreg_o), 
    .wdata_o(mem_wdata_o), 
    .hi_o(mem_hi_o), 
    .lo_o(mem_lo_o), 
    .whilo_o(mem_whilo_o)
);

// MEM/WB ģ������
mem_wb mem_wb0(
    .clk(clk), 
    .rst(rst), 
    .stall(stall), 

    // ���Էô�׶� MEM ģ�����Ϣ
    .mem_wd(mem_wd_o), 
    .mem_wreg(mem_wreg_o), 
    .mem_wdata(mem_wdata_o), 
    .mem_hi(mem_hi_o), 
    .mem_lo(mem_lo_o), 
    .mem_whilo(mem_whilo_o), 

    // �͵���д�׶ε���Ϣ
    .wb_wd(wb_wd_i), 
    .wb_wreg(wb_wreg_i), 
    .wb_wdata(wb_wdata_i), 
    .wb_hi(wb_hi_i), 
    .wb_lo(wb_lo_i), 
    .wb_whilo(wb_whilo_i)
);

hilo_reg hilo_reg0(
    .clk(clk), 
    .rst(rst), 

    // д�˿�
    .we(wb_whilo_i), 
    .hi_i(wb_hi_i), 
    .lo_i(wb_lo_i), 

    // ���˿�
    .hi_o(hi), 
    .lo_o(lo)
);

ctrl ctrl0(
    .rst(rst), 
    .stallreq_from_id(stallreq_from_id), 
    .stallreq_from_ex(stallreq_from_ex), 
    .stall(stall)
);

endmodule