`include "defines.v"

module mem(
    input wire rst, // 复位信号

    // 来自执行阶段的信息
    input wire[`RegAddrBus] wd_i, // 访存阶段的指令要写入的目的寄存器的地址 
    input wire wreg_i, // 访存阶段的指令是否有要写入的目的寄存器
    input wire[`RegBus] wdata_i, // 访存阶段的指令要写入目的寄存器的值
    input wire[`RegBus] hi_i, // 访存阶段的指令要写入 LO 寄存器的值
    input wire[`RegBus] lo_i, // 访存阶段的指令要写入 HI 寄存器的值
    input wire[`RegBus] whilo_i, // 访存阶段的指令是否要写 HI、LO 寄存器

    input wire[`AluOpBus] aluop_i, // 访存阶段的指令要进行的运算的子类型
    input wire[`RegBus] mem_addr_i, // 访存阶段的加载、存储指令对应的存储器地址
    input wire[`RegBus] reg2_i, // 访存阶段的存储指令要存储的数据，或者 lwl、lwr 指令要写入的目的寄存器的原始值

    input wire cp0_reg_we_i, // 访存阶段的指令是否要写 CP0 中的寄存器
    input wire[4:0] cp0_reg_write_addr_i, // 访存阶段的指令最终要写的 CP0 中寄存器的地址
    input wire[`RegBus] cp0_reg_data_i, // 访存阶段的指令最终要写入 CP0 中寄存器的数据

    input wire[31:0] excepttype_i, // 译码、执行阶段收集到的异常信息
    input wire is_in_delayslot_i, // 访存阶段的指令是否是延迟槽指令
    input wire[`RegBus] current_inst_address_i, // 访存阶段指令的地址

    // 来自外部数据存储器 RAM 的信息
    input wire[`RegBus] mem_data_i, // 从数据存储器读取的数据

    // 与 LLbit 模块有关的信息
    input wire LLbit_i, // LLbit 模块给出的 LLbit 寄存器的值
    input wire wb_LLbit_we_i, // 回写阶段的指令是否要写 LLbit 寄存器
    input wire wb_LLbit_value_i, // 回写阶段要写入 LLbit 的值

    // 来自 CP0 模块的信息
    input wire[`RegBus] cp0_status_i, // CP0 中 Status 寄存器的值
    input wire[`RegBus] cp0_cause_i, // CP0 中 Cause 寄存器的值
    input wire[`RegBus] cp0_epc_i, // CP0 中 EPC 寄存器的值

    // 来自回写阶段 用来检测数据相关
    input wire wb_cp0_reg_we, // 回写阶段的指令是否要写 CP0 中的寄存器
    input wire[4:0] wb_cp0_reg_write_addr, // 回写阶段的指令要写的 CP0 中寄存器的地址
    input wire[`RegBus] wb_cp0_reg_data, // 回写阶段的指令要写入 CP0 中寄存器的值

    // 访存阶段的结果
    output reg[`RegAddrBus] wd_o, // 访存阶段的指令最终要写入的目的寄存器的地址
    output reg wreg_o, // 访存阶段的指令最终是否有要写入的目的寄存器
    output reg[`RegBus] wdata_o, // 访存阶段的指令最终要写入目的寄存器的值
    output reg[`RegBus] hi_o, // 访存阶段的指令最终要写入 HI 寄存器的值
    output reg[`RegBus] lo_o, // 访存阶段的指令最终要写入 LO 寄存器的值
    output reg[`RegBus] whilo_o, // 访存阶段的指令最终是否要写 HI、LO 寄存器

    output reg cp0_reg_we_o , // 访存阶段的指令最终是否要写 CP0 中的寄存器
    output reg[4:0] cp0_reg_write_addr_o, // 访存阶段的指令最终要写入 CP0 中寄存器的数据
    output reg[`RegBus] cp0_reg_data_o, // 访存阶段的指令最终要写的 CP0 寄存器的地址
    
    // 送到外部数据存储器 RAM 的信息
    output reg[`RegBus] mem_addr_o, // 要访问的数据存储器的地址
    output wire mem_we_o, // 是否是写操作 为 1表示写操作
    output reg[3:0] mem_sel_o, // 字节选择信号
    output reg[`RegBus] mem_data_o, // 要写入数据存储器的数据
    output reg mem_ce_o, // 数据存储器使能信号

    // 与 LLbit 模块有关的信息
    output reg LLbit_we_o, // 访存阶段的指令是否要写 LLbit 寄存器 
    output reg LLbit_value_o,  

    // 关于异常
    output reg[31:0] excepttype_o, // 最终的异常类型
    output wire[`RegBus] cp0_epc_o, // CP0 中 EPC 寄存器的最新值

    output wire is_in_delayslot_o, // 访存阶段的指令是否是延迟槽指令
    output wire[`RegBus] current_inst_address_o // 访存阶段指令的地址
);

wire[`RegBus] zero32; 
reg mem_we;

reg LLbit; // 保存 LLbit 寄存器的最新值

reg[`RegBus] cp0_status; // 保存 CP0 中 Status 寄存器的最新值
reg[`RegBus] cp0_cause; // 保存 CP0 中 Cause 寄存器的最新值
reg[`RegBus] cp0_epc; // 保存 CP0 中 EPC 寄存器的最新值

assign zero32 = `ZeroWord;

assign is_in_delayslot_o = is_in_delayslot_i;
assign current_inst_address_o = current_inst_address_i;

always @( *) begin
    if (rst == `RstEnable) begin
        LLbit <= 1'b0;
    end else begin
        if (wb_LLbit_we_i) begin
            LLbit <= wb_LLbit_value_i; // 回写阶段的指令要写 LLbit
        end else begin
            LLbit <= LLbit_i;
        end
    end
end

always @( *) begin
    if (rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
        whilo_o <= `WriteDisable;
        mem_addr_o <= `ZeroWord;
        mem_we <= `WriteDisable;
        mem_sel_o <= 4'b0000;
        mem_data_o <= `ZeroWord;
        mem_ce_o <= `ChipDisable;
        LLbit_we_o <= 1'b0;
        LLbit_value_o <= 1'b0;
        cp0_reg_we_o <= `WriteDisable;
        cp0_reg_write_addr_o <= 5'b00000;
        cp0_reg_data_o <= `ZeroWord;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        hi_o <= hi_i;
        lo_o <= lo_i;
        whilo_o <= whilo_i;
        mem_we <= `WriteDisable;
        mem_addr_o <= `ZeroWord;
        mem_sel_o <= 4'b1111;
        mem_ce_o <= `ChipDisable; 
        LLbit_we_o <= 1'b0;
        LLbit_value_o <= 1'b0;
        
        // 将对 CP0 中寄存器的写信息传递到流水线下一级
        cp0_reg_we_o <= cp0_reg_we_i;
        cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
        cp0_reg_data_o <= cp0_reg_data_i;
        case (aluop_i)
            `EXE_LB_OP: begin // lb 指令
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o <= {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                        mem_sel_o <= 4'b1000;
                    end
                    2'b01: begin
                        wdata_o <= {{24{mem_data_i[23]}}, mem_data_i[23:16]};
                        mem_sel_o <= 4'b0100;
                    end
                    2'b10: begin
                        wdata_o <= {{24{mem_data_i[15]}}, mem_data_i[15:8]};
                        mem_sel_o <= 4'b0010;
                    end
                    2'b11: begin
                        wdata_o <= {{24{mem_data_i[7]}}, mem_data_i[7:0]};
                        mem_sel_o <= 4'b0001;
                    end
                    default: begin
                        wdata_o <= `ZeroWord;
                    end
                endcase
            end
            `EXE_LBU_OP: begin // lbu 指令
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o <= {{24{1'b0}}, mem_data_i[31:24]};
                        mem_sel_o <= 4'b1000;
                    end
                    2'b01: begin
                        wdata_o <= {{24{1'b0}}, mem_data_i[23:16]};
                        mem_sel_o <= 4'b0100;
                    end
                    2'b10: begin
                        wdata_o <= {{24{1'b0}}, mem_data_i[15:8]};
                        mem_sel_o <= 4'b0010;
                    end 
                    2'b11: begin
                        wdata_o <= {{24{1'b0}}, mem_data_i[7:0]};
                        mem_sel_o <= 4'b0001;
                    end
                    default: begin
                        wdata_o <= `ZeroWord;
                    end  
                endcase
            end
            `EXE_LH_OP: begin // lh 指令
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o <= {{16{mem_data_i[31]}}, mem_data_i[31:16]};
                        mem_sel_o <= 4'b1100;
                    end
                    2'b10: begin
                        wdata_o <= {{16{mem_data_i[15]}}, mem_data_i[15:0]};
                        mem_sel_o <= 4'b0011;
                    end
                    default: begin
                        wdata_o <= `ZeroWord;
                    end  
                endcase
            end
            `EXE_LHU_OP: begin // lhu 指令
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o <= {{16{1'b0}}, mem_data_i[31:16]};
                        mem_sel_o <= 4'b1100;
                    end
                    2'b10: begin
                        wdata_o <= {{16{1'b0}}, mem_data_i[15:0]};
                        mem_sel_o <= 4'b0011;
                    end
                    default: begin
                        wdata_o <= `ZeroWord;
                    end
                endcase
            end
            `EXE_LW_OP: begin // lw 指令
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                wdata_o <= mem_data_i;
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;
            end
            `EXE_LWL_OP: begin // lwl 指令
                mem_addr_o <= {mem_addr_i[31:2], 2'b00};
                mem_we <= `WriteDisable;
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o <= mem_data_i;
                    end
                    2'b01: begin
                        wdata_o <= {mem_data_i[23:0], reg2_i[7:0]};
                    end
                    2'b10: begin
                        wdata_o <= {mem_data_i[15:0], reg2_i[15:0]};
                    end
                    2'b11: begin
                        wdata_o <= {mem_data_i[7:0], reg2_i[23:0]};
                    end
                    default: begin
                        wdata_o <= `ZeroWord;
                    end
                endcase
            end
            `EXE_LWR_OP: begin // lwr 指令
                mem_addr_o <= {mem_addr_i[31:2], 2'b00};
                mem_we <= `WriteDisable;
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        wdata_o <= {reg2_i[31:8], mem_data_i[31:24]};
                    end
                    2'b01: begin
                        wdata_o <= {reg2_i[31:16], mem_data_i[31:16]};
                    end
                    2'b10: begin
                        wdata_o <= {reg2_i[31:24], mem_data_i[31:8]};
                    end
                    2'b11: begin
                        wdata_o <= mem_data_i;
                    end
                    default: begin
                        wdata_o <= `ZeroWord;
                    end  
                endcase
            end
            `EXE_SB_OP: begin // sb 指令
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteEnable;
                mem_data_o <= {4{reg2_i[7:0]}};
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o <= 4'b1000;
                    end
                    2'b01: begin
                        mem_sel_o <= 4'b0100;
                    end
                    2'b10: begin
                        mem_sel_o <= 4'b0010;
                    end
                    2'b11: begin
                        mem_sel_o <= 4'b0001;
                    end
                    default: begin
                        mem_sel_o <= 4'b0000;
                    end
                endcase
            end
            `EXE_SH_OP: begin // sh 指令
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteEnable;
                mem_data_o <= {2{reg2_i[15:0]}};
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o <= 4'b1100;
                    end
                    2'b10: begin
                        mem_sel_o <= 4'b0011;
                    end
                    default: begin
                        mem_sel_o <= 4'b0000;
                    end
                endcase
            end
            `EXE_SW_OP: begin // sw 指令
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteEnable;
                mem_data_o <= reg2_i;
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;
            end
            `EXE_SWL_OP: begin // swl 指令
                mem_addr_o <= {mem_addr_i[31:2], 2'b00};
                mem_we <= `WriteEnable;
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o <= 4'b1111;
                        mem_data_o <= reg2_i;
                    end
                    2'b01: begin
                        mem_sel_o <= 4'b0111;
                        mem_data_o <= {zero32[7:0], reg2_i[31:8]};
                    end
                    2'b10: begin
                        mem_sel_o <= 4'b0011;
                        mem_data_o <= {zero32[15:0], reg2_i[31:16]};
                    end
                    2'b11: begin
                        mem_sel_o <= 4'b0001;
                        mem_data_o <= {zero32[23:0], reg2_i[31:24]};
                    end
                    default: begin
                        mem_sel_o <= 4'b0000;
                    end
                endcase
            end
            `EXE_SWR_OP: begin // swr 指令
                mem_addr_o <= {mem_addr_i[31:2], 2'b00};
                mem_we <= `WriteEnable;
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o <= 4'b1000;
                        mem_data_o <= {reg2_i[7:0], zero32[23:0]};
                    end
                    2'b01: begin
                        mem_sel_o <= 4'b1100;
                        mem_data_o <= {reg2_i[15:0], zero32[15:0]};
                    end
                    2'b10: begin
                        mem_sel_o <= 4'b1110;
                        mem_data_o <= {reg2_i[23:0], zero32[7:0]};
                    end
                    2'b11: begin
                        mem_sel_o <= 4'b1111;
                        mem_data_o <= reg2_i;
                    end
                    default: begin
                        mem_sel_o <= 4'b0000;
                    end
                endcase
            end
            `EXE_LL_OP: begin // ll 指令的访存输出
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                wdata_o <= mem_data_i;
                LLbit_we_o <= 1'b1;
                LLbit_value_o <= 1'b1;
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;
            end
            `EXE_SC_OP: begin // sc 指令的访存输出
                if (LLbit) begin
                    LLbit_we_o <= 1'b1;
                    LLbit_value_o <= 1'b0;
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_data_o <= reg2_i;
                    wdata_o <= 32'b1;
                    mem_sel_o <= 4'b1111;
                    mem_ce_o <= `ChipEnable;
                end else begin
                    wdata_o <= 32'b0;
                end
            end
            default: begin
            end  
        endcase
    end
end

// **************** 得到 CP0 中寄存器的最新值 **********************
always @( *) begin
    if (rst == `RstEnable) begin
        cp0_status <= `ZeroWord;
    end else if ((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_STATUS)) begin
        cp0_status <= wb_cp0_reg_data;
    end else begin
        cp0_status <= cp0_status_i;
    end
end

always @( *) begin
    if (rst == `RstEnable) begin
        cp0_epc <= `ZeroWord;
    end else if ((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_EPC)) begin
        cp0_epc <= wb_cp0_reg_data;
    end else begin
        cp0_epc <= cp0_epc_i;
    end
end

assign cp0_epc_o = cp0_epc;

always @( *) begin
    if (rst == `RstEnable) begin
        cp0_cause <= `ZeroWord;
    end else if ((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_CAUSE)) begin
        cp0_cause[9:8] <= wb_cp0_reg_data[9:8]; // IP[1:0] 字段是可写的
        cp0_cause[22] <= wb_cp0_reg_data[22]; // WP 字段是可写的
        cp0_cause[23] <= wb_cp0_reg_data[23]; // IV 字段是可写的
    end else begin
        cp0_cause <= cp0_cause_i;
    end
end

// ********************** 给出最终的异常类型 *******************88
always @( *) begin
    if (rst == `RstEnable) begin
        excepttype_o <= `ZeroWord;
    end else begin
        excepttype_o <= `ZeroWord;
        if (current_inst_address_i != `ZeroWord) begin
            if (((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) &&
                (cp0_status[1] == 1'b0) && 
                (cp0_status[0] == 1'b1)) begin
                    excepttype_o <= 32'h00000001; // interrupt
            end else if (excepttype_i[8] == 1'b1) begin
                excepttype_o <= 32'h00000008; // syscall
            end else if (excepttype_i[9] == 1'b1) begin
                excepttype_o <= 32'h0000000a; // inst_invalid
            end else if (excepttype_i[10] == 1'b1) begin
                excepttype_o <= 32'h0000000d; // trap
            end else if (excepttype_i[11] == 1'b1) begin
                excepttype_o <= 32'h0000000c; // ov
            end else if (excepttype_i[12] == 1'b1) begin
                excepttype_o <= 32'h0000000e; // eret
            end
        end
    end
end

// ****************** 对数据存储器的写操作 *********************
assign mem_we_o = mem_we & (~(|excepttype_o));

endmodule