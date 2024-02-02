`include "defines.v"

module mem(
    input wire rst, // ��λ�ź�

    // ����ִ�н׶ε���Ϣ
    input wire[`RegAddrBus] wd_i, // �ô�׶ε�ָ��Ҫд���Ŀ�ļĴ����ĵ�ַ 
    input wire wreg_i, // �ô�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[`RegBus] wdata_i, // �ô�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
    input wire[`RegBus] hi_i, // �ô�׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    input wire[`RegBus] lo_i, // �ô�׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    input wire[`RegBus] whilo_i, // �ô�׶ε�ָ���Ƿ�Ҫд HI��LO �Ĵ���

    input wire[`AluOpBus] aluop_i, // �ô�׶ε�ָ��Ҫ���е������������
    input wire[`RegBus] mem_addr_i, // �ô�׶εļ��ء��洢ָ���Ӧ�Ĵ洢����ַ
    input wire[`RegBus] reg2_i, // �ô�׶εĴ洢ָ��Ҫ�洢�����ݣ����� lwl��lwr ָ��Ҫд���Ŀ�ļĴ�����ԭʼֵ

    input wire cp0_reg_we_i, // �ô�׶ε�ָ���Ƿ�Ҫд CP0 �еļĴ���
    input wire[4:0] cp0_reg_write_addr_i, // �ô�׶ε�ָ������Ҫд�� CP0 �мĴ����ĵ�ַ
    input wire[`RegBus] cp0_reg_data_i, // �ô�׶ε�ָ������Ҫд�� CP0 �мĴ���������

    input wire[31:0] excepttype_i, // ���롢ִ�н׶��ռ������쳣��Ϣ
    input wire is_in_delayslot_i, // �ô�׶ε�ָ���Ƿ����ӳٲ�ָ��
    input wire[`RegBus] current_inst_address_i, // �ô�׶�ָ��ĵ�ַ

    // �����ⲿ���ݴ洢�� RAM ����Ϣ
    input wire[`RegBus] mem_data_i, // �����ݴ洢����ȡ������

    // �� LLbit ģ���йص���Ϣ
    input wire LLbit_i, // LLbit ģ������� LLbit �Ĵ�����ֵ
    input wire wb_LLbit_we_i, // ��д�׶ε�ָ���Ƿ�Ҫд LLbit �Ĵ���
    input wire wb_LLbit_value_i, // ��д�׶�Ҫд�� LLbit ��ֵ

    // ���� CP0 ģ�����Ϣ
    input wire[`RegBus] cp0_status_i, // CP0 �� Status �Ĵ�����ֵ
    input wire[`RegBus] cp0_cause_i, // CP0 �� Cause �Ĵ�����ֵ
    input wire[`RegBus] cp0_epc_i, // CP0 �� EPC �Ĵ�����ֵ

    // ���Ի�д�׶� ��������������
    input wire wb_cp0_reg_we, // ��д�׶ε�ָ���Ƿ�Ҫд CP0 �еļĴ���
    input wire[4:0] wb_cp0_reg_write_addr, // ��д�׶ε�ָ��Ҫд�� CP0 �мĴ����ĵ�ַ
    input wire[`RegBus] wb_cp0_reg_data, // ��д�׶ε�ָ��Ҫд�� CP0 �мĴ�����ֵ

    // �ô�׶εĽ��
    output reg[`RegAddrBus] wd_o, // �ô�׶ε�ָ������Ҫд���Ŀ�ļĴ����ĵ�ַ
    output reg wreg_o, // �ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] wdata_o, // �ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ
    output reg[`RegBus] hi_o, // �ô�׶ε�ָ������Ҫд�� HI �Ĵ�����ֵ
    output reg[`RegBus] lo_o, // �ô�׶ε�ָ������Ҫд�� LO �Ĵ�����ֵ
    output reg[`RegBus] whilo_o, // �ô�׶ε�ָ�������Ƿ�Ҫд HI��LO �Ĵ���

    output reg cp0_reg_we_o , // �ô�׶ε�ָ�������Ƿ�Ҫд CP0 �еļĴ���
    output reg[4:0] cp0_reg_write_addr_o, // �ô�׶ε�ָ������Ҫд�� CP0 �мĴ���������
    output reg[`RegBus] cp0_reg_data_o, // �ô�׶ε�ָ������Ҫд�� CP0 �Ĵ����ĵ�ַ
    
    // �͵��ⲿ���ݴ洢�� RAM ����Ϣ
    output reg[`RegBus] mem_addr_o, // Ҫ���ʵ����ݴ洢���ĵ�ַ
    output wire mem_we_o, // �Ƿ���д���� Ϊ 1��ʾд����
    output reg[3:0] mem_sel_o, // �ֽ�ѡ���ź�
    output reg[`RegBus] mem_data_o, // Ҫд�����ݴ洢��������
    output reg mem_ce_o, // ���ݴ洢��ʹ���ź�

    // �� LLbit ģ���йص���Ϣ
    output reg LLbit_we_o, // �ô�׶ε�ָ���Ƿ�Ҫд LLbit �Ĵ��� 
    output reg LLbit_value_o,  

    // �����쳣
    output reg[31:0] excepttype_o, // ���յ��쳣����
    output wire[`RegBus] cp0_epc_o, // CP0 �� EPC �Ĵ���������ֵ

    output wire is_in_delayslot_o, // �ô�׶ε�ָ���Ƿ����ӳٲ�ָ��
    output wire[`RegBus] current_inst_address_o // �ô�׶�ָ��ĵ�ַ
);

wire[`RegBus] zero32; 
reg mem_we;

reg LLbit; // ���� LLbit �Ĵ���������ֵ

reg[`RegBus] cp0_status; // ���� CP0 �� Status �Ĵ���������ֵ
reg[`RegBus] cp0_cause; // ���� CP0 �� Cause �Ĵ���������ֵ
reg[`RegBus] cp0_epc; // ���� CP0 �� EPC �Ĵ���������ֵ

assign zero32 = `ZeroWord;

assign is_in_delayslot_o = is_in_delayslot_i;
assign current_inst_address_o = current_inst_address_i;

always @( *) begin
    if (rst == `RstEnable) begin
        LLbit <= 1'b0;
    end else begin
        if (wb_LLbit_we_i) begin
            LLbit <= wb_LLbit_value_i; // ��д�׶ε�ָ��Ҫд LLbit
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
        
        // ���� CP0 �мĴ�����д��Ϣ���ݵ���ˮ����һ��
        cp0_reg_we_o <= cp0_reg_we_i;
        cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
        cp0_reg_data_o <= cp0_reg_data_i;
        case (aluop_i)
            `EXE_LB_OP: begin // lb ָ��
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
            `EXE_LBU_OP: begin // lbu ָ��
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
            `EXE_LH_OP: begin // lh ָ��
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
            `EXE_LHU_OP: begin // lhu ָ��
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
            `EXE_LW_OP: begin // lw ָ��
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                wdata_o <= mem_data_i;
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;
            end
            `EXE_LWL_OP: begin // lwl ָ��
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
            `EXE_LWR_OP: begin // lwr ָ��
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
            `EXE_SB_OP: begin // sb ָ��
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
            `EXE_SH_OP: begin // sh ָ��
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
            `EXE_SW_OP: begin // sw ָ��
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteEnable;
                mem_data_o <= reg2_i;
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;
            end
            `EXE_SWL_OP: begin // swl ָ��
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
            `EXE_SWR_OP: begin // swr ָ��
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
            `EXE_LL_OP: begin // ll ָ��ķô����
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                wdata_o <= mem_data_i;
                LLbit_we_o <= 1'b1;
                LLbit_value_o <= 1'b1;
                mem_sel_o <= 4'b1111;
                mem_ce_o <= `ChipEnable;
            end
            `EXE_SC_OP: begin // sc ָ��ķô����
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

// **************** �õ� CP0 �мĴ���������ֵ **********************
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
        cp0_cause[9:8] <= wb_cp0_reg_data[9:8]; // IP[1:0] �ֶ��ǿ�д��
        cp0_cause[22] <= wb_cp0_reg_data[22]; // WP �ֶ��ǿ�д��
        cp0_cause[23] <= wb_cp0_reg_data[23]; // IV �ֶ��ǿ�д��
    end else begin
        cp0_cause <= cp0_cause_i;
    end
end

// ********************** �������յ��쳣���� *******************88
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

// ****************** �����ݴ洢����д���� *********************
assign mem_we_o = mem_we & (~(|excepttype_o));

endmodule