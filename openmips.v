`include "defines.v"

module openmips(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    input wire[5:0] int_i, // 6个外部硬件中断输入
    
    input wire[`InstBus] rom_data_i, // 从指令存储器取得的指令
    input wire[`DataBus] ram_data_i, // 从数据存储器读取的数据

    output wire[`InstAddrBus] rom_addr_o, // 输出到指令存储器的地址
    output wire rom_ce_o, // 指令存储器使能信号
    
    output wire[`DataAddrBus] ram_addr_o, // 要访问的数据存储器地址
    output wire[`DataBus] ram_data_o, // 要写入数据存储器的数据
    output wire ram_we_o, // 是否是对数据存储器的写操作，为 1表示写操作
    output wire[3:0] ram_sel_o, // 字节选择信号
    output wire ram_ce_o, // 数据存储器使能信号

    output wire timer_int_o // 是否有定时中断发生
);

// 连接 IF/ID 模块与译码阶段 ID 模块的变量
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;

// 连接译码阶段 ID 模块输出与 ID/EX 模块的输入的变量
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;
wire id_is_in_delayslot_o;
wire[`RegBus] id_link_address_o;
wire[`InstBus] id_inst_o;
wire[31:0] id_excepttype_o;
wire[`RegBus] id_current_inst_address_o;

// 连接 ID/EX 模块的输出与执行阶段 EX 模块的输入的变量
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_is_in_delayslot_i;	
wire[`RegBus] ex_link_address_i;
wire[`InstBus] ex_inst_i;
wire[31:0] ex_excepttype_i;	
wire[`RegBus] ex_current_inst_address_i;

// 连接执行阶段 EX 模块的输出与 EX/MEM 模块的输入的变量
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;
wire[`RegBus] ex_hi_o;
wire[`RegBus] ex_lo_o;
wire ex_whilo_o;
wire[`AluOpBus] ex_aluop_o;
wire[`InstAddrBus] ex_mem_addr_o;
wire[`RegBus] ex_reg1_o;
wire[`RegBus] ex_reg2_o;
wire ex_cp0_reg_we_o;
wire[4:0] ex_cp0_reg_write_addr_o;
wire[`RegBus] ex_cp0_reg_data_o;
wire[31:0] ex_excepttype_o;
wire[`RegBus] ex_current_inst_address_o;
wire ex_is_in_delayslot_o;

// 连接 EX/MEM 模块的输出与访存阶段 MEM 模块的输入的变量
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;
wire[`RegBus] mem_hi_i;
wire[`RegBus] mem_lo_i;
wire mem_whilo_i;
wire[`AluOpBus] mem_aluop_i;
wire[`InstAddrBus] mem_mem_addr_i;
wire[`RegBus] mem_reg1_i;
wire[`RegBus] mem_reg2_i;
wire mem_cp0_reg_we_i;
wire[4:0] mem_cp0_reg_write_addr_i;
wire[`RegBus] mem_cp0_reg_data_i;
wire[31:0] mem_excepttype_i;	
wire mem_is_in_delayslot_i;
wire[`RegBus] mem_current_inst_address_i;

// 连接访存阶段 MEM 模块的输出与 MEM/WB 模块的输入的变量
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;
wire[`RegBus] mem_hi_o;
wire[`RegBus] mem_lo_o;
wire mem_whilo_o;
wire mem_LLbit_value_o;
wire mem_LLbit_we_o;
wire mem_cp0_reg_we_o;
wire[4:0] mem_cp0_reg_write_addr_o;
wire[`RegBus] mem_cp0_reg_data_o;
wire[31:0] mem_excepttype_o;
wire mem_is_in_delayslot_o;
wire[`RegBus] mem_current_inst_address_o;

// 连接 MEM/WB 模块的输出与回写阶段的输入的变量
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;
wire[`RegBus] wb_hi_i;
wire[`RegBus] wb_lo_i;
wire wb_whilo_i;
wire wb_LLbit_value_i;
wire wb_LLbit_we_i;
wire wb_cp0_reg_we_i;
wire[4:0] wb_cp0_reg_write_addr_i;
wire[`RegBus] wb_cp0_reg_data_i;
wire[31:0] wb_excepttype_i;
wire wb_is_in_delayslot_i;
wire[`RegBus] wb_current_inst_address_i;

// 连接译码阶段 ID 模块与通用寄存器 Regfile 模块的变量
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

// 连接执行阶段与 HILO 模块的输出，读取 HI、LO寄存器
wire[`RegBus] hi;
wire[`RegBus] lo;


//连接执行阶段与 ex_mem 模块，用于多周期的 madd、maddu、msub、msubu 指令
wire[`DoubleRegBus] hilo_temp_o;
wire[1:0] cnt_o;

wire[`DoubleRegBus] hilo_temp_i;
wire[1:0] cnt_i;

// 连接执行阶段与 div 模块，用于除法运算
wire[`DoubleRegBus] div_result;
wire div_ready;
wire[`RegBus] div_opdata1;
wire[`RegBus] div_opdata2;
wire div_start;
wire div_annul;
wire signed_div;

// 与跳转指令相关
wire is_in_delayslot_i;
wire is_in_delayslot_o;
wire next_inst_in_delayslot_o;
wire id_branch_flag_o;
wire[`RegBus] branch_target_address;

// 与流水线暂停相关的变量
wire[`StallBus] stall;
wire stallreq_from_id;	
wire stallreq_from_ex;

// 与 LLbit 模块相关的变量
wire LLbit_o;

wire[`RegBus] cp0_data_o;
wire[4:0] cp0_raddr_i;
 
wire flush;
wire[`RegBus] new_pc;

wire[`RegBus] cp0_count;
wire[`RegBus] cp0_compare;
wire[`RegBus] cp0_status;
wire[`RegBus] cp0_cause;
wire[`RegBus] cp0_epc;
wire[`RegBus] cp0_config;
wire[`RegBus] cp0_prid; 

wire[`RegBus] latest_epc;

// pc_reg 例化
pc_reg pc_reg0(
    .clk(clk),
    .rst(rst),
    .stall(stall), 
    .flush(flush),
	.new_pc(new_pc),
    .branch_flag_i(id_branch_flag_o), 
    .branch_target_address_i(branch_target_address), 
    .pc(pc), 
    .ce(rom_ce_o)
); 

assign rom_addr_o = pc; // 指令存储器的输入地址就是 pc 的值

// IF/ID 模块例化
if_id if_id0(
    .clk(clk),
    .rst(rst),
    .stall(stall), 
    .flush(flush),
    .if_pc(pc),
    .if_inst(rom_data_i),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

// 译码阶段 ID 模块例化
id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i), 

    .ex_aluop_i(ex_aluop_o), 
    
    // 来自 Regfile 模块的输入
    .reg1_data_i(reg1_data), 
    .reg2_data_i(reg2_data), 

    
    // 处于执行阶段的指令的运算结果
    .ex_wreg_i(ex_wreg_o),
    .ex_wdata_i(ex_wdata_o), 
    .ex_wd_i(ex_wd_o),

    // 处于访存阶段的指令的运算结果
    .mem_wreg_i(mem_wreg_o), 
    .mem_wdata_i(mem_wdata_o), 
    .mem_wd_i(mem_wd_o), 

    // 
    .is_in_delayslot_i(is_in_delayslot_i),

    // 送到 Regfile 模块的信息
    .reg1_read_o(reg1_read), 
    .reg2_read_o(reg2_read), 
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),

    // 送到 ID/EX 模块的信息
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o), 
    .reg2_o(id_reg2_o), 
    .wd_o(id_wd_o), 
    .wreg_o(id_wreg_o),
    .inst_o(id_inst_o),

    .next_inst_in_delayslot_o(next_inst_in_delayslot_o),	
	.branch_flag_o(id_branch_flag_o),
	.branch_target_address_o(branch_target_address),       
	.link_addr_o(id_link_address_o),
	.is_in_delayslot_o(id_is_in_delayslot_o),

    .excepttype_o(id_excepttype_o),
    .current_inst_address_o(id_current_inst_address_o),

    // 送到 ctrl 模块的信息
    .stallreq(stallreq_from_id)
);

// 通用寄存器 Regfile 模块例化
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

// ID/EX 模块例化
id_ex id_ex0(
    .clk(clk), 
    .rst(rst), 
    .stall(stall),
    .flush(flush),

    // 从译码阶段 ID 模块传递过来的信息
    .id_aluop(id_aluop_o), 
    .id_alusel(id_alusel_o), 
    .id_reg1(id_reg1_o), 
    .id_reg2(id_reg2_o), 
    .id_wd(id_wd_o), 
    .id_wreg(id_wreg_o),
    .id_link_address(id_link_address_o),
	.id_is_in_delayslot(id_is_in_delayslot_o),
	.next_inst_in_delayslot_i(next_inst_in_delayslot_o),
    .id_inst(id_inst_o),
    .id_excepttype(id_excepttype_o),
	.id_current_inst_address(id_current_inst_address_o),

    // 传递到执行阶段 EX 模块的信息
    .ex_aluop(ex_aluop_i), 
    .ex_alusel(ex_alusel_i), 
    .ex_reg1(ex_reg1_i), 
    .ex_reg2(ex_reg2_i), 
    .ex_wd(ex_wd_i), 
    .ex_wreg(ex_wreg_i), 
    .ex_link_address(ex_link_address_i),
  	.ex_is_in_delayslot(ex_is_in_delayslot_i),
	.is_in_delayslot_o(is_in_delayslot_i), 
    .ex_inst(ex_inst_i), 
    .ex_excepttype(ex_excepttype_i),
	.ex_current_inst_address(ex_current_inst_address_i)
);

// EX 模块例化
ex ex0(
    .rst(rst), 

    // 从 ID/EX 模块传递过来的信息
    .aluop_i(ex_aluop_i), 
    .alusel_i(ex_alusel_i), 
    .reg1_i(ex_reg1_i), 
    .reg2_i(ex_reg2_i), 
    .wd_i(ex_wd_i), 
    .wreg_i(ex_wreg_i),
    
    .hi_i(hi), 
    .lo_i(lo),
    .inst_i(ex_inst_i),
    .mem_hi_i(mem_hi_o),
    .mem_lo_i(mem_lo_o), 
    .mem_whilo_i(mem_whilo_o), 
    .wb_hi_i(wb_hi_i), 
    .wb_lo_i(wb_lo_i), 
    .wb_whilo_i(wb_whilo_i), 

    .link_address_i(ex_link_address_i),
	.is_in_delayslot_i(ex_is_in_delayslot_i),

    .excepttype_i(ex_excepttype_i),
	.current_inst_address_i(ex_current_inst_address_i),

    // 从 EX/MEM 模块传递过来的信息
    .hilo_temp_i(hilo_temp_i), 
    .cnt_i(cnt_i), 

    // 从 DIV 模块传递过来的信息
    .div_result_i(div_result),
	.div_ready_i(div_ready), 

    //访存阶段的指令是否要写 CP0，用来检测数据相关
  	.mem_cp0_reg_we(mem_cp0_reg_we_o),
	.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
	.mem_cp0_reg_data(mem_cp0_reg_data_o),
	
	//回写阶段的指令是否要写CP0，用来检测数据相关
  	.wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i),

	.cp0_reg_data_i(cp0_data_o),
	.cp0_reg_read_addr_o(cp0_raddr_i),
		
	//向下一流水级传递，用于写CP0中的寄存器
	.cp0_reg_we_o(ex_cp0_reg_we_o),
	.cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
	.cp0_reg_data_o(ex_cp0_reg_data_o),	

    // 输出到 EX/MEM 模块的信息
    .wd_o(ex_wd_o), 
    .wreg_o(ex_wreg_o), 
    .wdata_o(ex_wdata_o),

    .hi_o(ex_hi_o), 
    .lo_o(ex_lo_o), 
    .whilo_o(ex_whilo_o), 

    .hilo_temp_o(hilo_temp_o), 
    .cnt_o(cnt_o), 

    .aluop_o(ex_aluop_o),
	.mem_addr_o(ex_mem_addr_o),
	.reg2_o(ex_reg2_o),

    .excepttype_o(ex_excepttype_o),
	.is_in_delayslot_o(ex_is_in_delayslot_o),
	.current_inst_address_o(ex_current_inst_address_o),

    // 输出到 DIV 模块的信息
    .div_opdata1_o(div_opdata1),
	.div_opdata2_o(div_opdata2),
	.div_start_o(div_start),
	.signed_div_o(signed_div),

    // 送到 ctrl 模块的信息
    .stallreq(stallreq_from_ex)
);
// EX/MEM 模块例化
ex_mem ex_mem0(
    .clk(clk), 
    .rst(rst), 
    .stall(stall), 
    .flush(flush),

    // 来自执行阶段 EX 模块的信息
    .ex_wd(ex_wd_o), 
    .ex_wreg(ex_wreg_o), 
    .ex_wdata(ex_wdata_o), 
    .ex_hi(ex_hi_o), 
    .ex_lo(ex_lo_o),
    .ex_whilo(ex_whilo_o),

    .hilo_i(hilo_temp_o),
	.cnt_i(cnt_o),

    .ex_aluop(ex_aluop_o),
	.ex_mem_addr(ex_mem_addr_o),
	.ex_reg2(ex_reg2_o),

    .ex_cp0_reg_we(ex_cp0_reg_we_o),
	.ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
	.ex_cp0_reg_data(ex_cp0_reg_data_o),

    .ex_excepttype(ex_excepttype_o),
	.ex_is_in_delayslot(ex_is_in_delayslot_o),
	.ex_current_inst_address(ex_current_inst_address_o),

    // 送到访存阶段 MEM 模块的信息
    .mem_wd(mem_wd_i), 
    .mem_wreg(mem_wreg_i), 
    .mem_wdata(mem_wdata_i), 
    .mem_hi(mem_hi_i), 
    .mem_lo(mem_lo_i), 
    .mem_whilo(mem_whilo_i),

    .mem_aluop(mem_aluop_i),
	.mem_mem_addr(mem_mem_addr_i),
	.mem_reg2(mem_reg2_i),

    .mem_cp0_reg_we(mem_cp0_reg_we_i),
	.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
	.mem_cp0_reg_data(mem_cp0_reg_data_i),

    .mem_excepttype(mem_excepttype_i),
  	.mem_is_in_delayslot(mem_is_in_delayslot_i),
	.mem_current_inst_address(mem_current_inst_address_i),
    
    // 送到 EX 模块的信息
    .hilo_o(hilo_temp_i),
	.cnt_o(cnt_i)
);

// MEM 模块例化
mem mem0(
    .rst(rst), 
    
    // 来自 EX/MEM 模块的信息
    .wd_i(mem_wd_i), 
    .wreg_i(mem_wreg_i), 
    .wdata_i(mem_wdata_i), 
    .hi_i(mem_hi_i), 
    .lo_i(mem_lo_i), 
    .whilo_i(mem_whilo_i), 

    .aluop_i(mem_aluop_i),
	.mem_addr_i(mem_mem_addr_i),
	.reg2_i(mem_reg2_i),

    .cp0_reg_we_i(mem_cp0_reg_we_i),
	.cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
	.cp0_reg_data_i(mem_cp0_reg_data_i),


    // 来自数据存储器的信息
    .mem_data_i(ram_data_i), 

    //LLbit_i是LLbit寄存器的值
	.LLbit_i(LLbit_o),
	//但不一定是最新值，回写阶段可能要写LLbit，所以还要进一步判断
	.wb_LLbit_we_i(wb_LLbit_we_i),
	.wb_LLbit_value_i(wb_LLbit_value_i),

    .excepttype_i(mem_excepttype_i),
	.is_in_delayslot_i(mem_is_in_delayslot_i),
	.current_inst_address_i(mem_current_inst_address_i),	
		
	.cp0_status_i(cp0_status),
	.cp0_cause_i(cp0_cause),
	.cp0_epc_i(cp0_epc),
		
	//回写阶段的指令是否要写CP0，用来检测数据相关
  	.wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i),

    .LLbit_we_o(mem_LLbit_we_o),
	.LLbit_value_o(mem_LLbit_value_o),

    // 送到 MEM/WB 模块的信息
    .wd_o(mem_wd_o), 
    .wreg_o(mem_wreg_o), 
    .wdata_o(mem_wdata_o), 
    .hi_o(mem_hi_o), 
    .lo_o(mem_lo_o), 
    .whilo_o(mem_whilo_o), 

    .cp0_reg_we_o(mem_cp0_reg_we_o),
	.cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
	.cp0_reg_data_o(mem_cp0_reg_data_o),

    // 送到数据存储器的信息
    .mem_addr_o(ram_addr_o), 
    .mem_we_o(ram_we_o), 
    .mem_sel_o(ram_sel_o), 
    .mem_data_o(ram_data_o), 
    .mem_ce_o(ram_ce_o),

    // 送到 CP0 和 ctrl 模块的信息
    .excepttype_o(mem_excepttype_o),
	.cp0_epc_o(latest_epc),
	.is_in_delayslot_o(mem_is_in_delayslot_o),
	.current_inst_address_o(mem_current_inst_address_o)
);

// MEM/WB 模块例化
mem_wb mem_wb0(
    .clk(clk), 
    .rst(rst), 
    .stall(stall), 
    .flush(flush),

    // 来自访存阶段 MEM 模块的信息
    .mem_wd(mem_wd_o), 
    .mem_wreg(mem_wreg_o), 
    .mem_wdata(mem_wdata_o), 
    .mem_hi(mem_hi_o), 
    .mem_lo(mem_lo_o), 
    .mem_whilo(mem_whilo_o), 
    .mem_LLbit_we(mem_LLbit_we_o),
	.mem_LLbit_value(mem_LLbit_value_o),

    .mem_cp0_reg_we(mem_cp0_reg_we_o),
	.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
	.mem_cp0_reg_data(mem_cp0_reg_data_o),

    // 送到回写阶段的信息
    .wb_wd(wb_wd_i), 
    .wb_wreg(wb_wreg_i), 
    .wb_wdata(wb_wdata_i), 
    .wb_hi(wb_hi_i), 
    .wb_lo(wb_lo_i), 
    .wb_whilo(wb_whilo_i), 
    .wb_LLbit_we(wb_LLbit_we_i),
	.wb_LLbit_value(wb_LLbit_value_i),

    .wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i)
);

hilo_reg hilo_reg0(
    .clk(clk), 
    .rst(rst), 

    // 写端口
    .we(wb_whilo_i), 
    .hi_i(wb_hi_i), 
    .lo_i(wb_lo_i), 

    // 读端口
    .hi_o(hi), 
    .lo_o(lo)
);

ctrl ctrl0(
    .rst(rst), 

    .excepttype_i(mem_excepttype_o),
	.cp0_epc_i(latest_epc),

    .stallreq_from_id(stallreq_from_id), 
    .stallreq_from_ex(stallreq_from_ex), 
    .stall(stall), 
    .new_pc(new_pc),
	.flush(flush)
);

div div0(
    .clk(clk), 
    .rst(rst), 

    .signed_div_i(signed_div),
	.opdata1_i(div_opdata1),
	.opdata2_i(div_opdata2),
	.start_i(div_start),
	.annul_i(flush), // 异常处理

    .result_o(div_result),
	.ready_o(div_ready)
);

LLbit_reg LLbit_reg0(
	.clk(clk),
	.rst(rst),
	.flush(flush),
	  
	//写端口
	.LLbit_i(wb_LLbit_value_i),
	.we(wb_LLbit_we_i),
	
	//读端口
	.LLbit_o(LLbit_o)
	);

cp0_reg cp0_reg0(
	.clk(clk),
	.rst(rst),
		
	.we_i(wb_cp0_reg_we_i),
	.waddr_i(wb_cp0_reg_write_addr_i),
	.raddr_i(cp0_raddr_i),
	.data_i(wb_cp0_reg_data_i),		

    .int_i(int_i),
    .excepttype_i(mem_excepttype_o),
    .current_inst_addr_i(mem_current_inst_address_o),
	.is_in_delayslot_i(mem_is_in_delayslot_o),

	.data_o(cp0_data_o),
    .count_o(cp0_count),
	.compare_o(cp0_compare),
	.status_o(cp0_status),
	.cause_o(cp0_cause),
	.epc_o(cp0_epc),
	.config_o(cp0_config),
	.prid_o(cp0_prid),
	.timer_int_o(timer_int_o)  			
	);


endmodule