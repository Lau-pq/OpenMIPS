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

    // �����ⲿ���ݴ洢�� RAM ����Ϣ
    input wire[`RegBus] mem_data_i, // �����ݴ洢����ȡ������

    // �ô�׶εĽ��
    output reg[`RegAddrBus] wd_o, // �ô�׶ε�ָ������Ҫд���Ŀ�ļĴ����ĵ�ַ
    output reg wreg_o, // �ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] wdata_o, // �ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ
    output reg[`RegBus] hi_o, // �ô�׶ε�ָ������Ҫд�� HI �Ĵ�����ֵ
    output reg[`RegBus] lo_o, // �ô�׶ε�ָ������Ҫд�� LO �Ĵ�����ֵ
    output reg[`RegBus] whilo_o, // �ô�׶ε�ָ�������Ƿ�Ҫд HI��LO �Ĵ���

    // �͵��ⲿ���ݴ洢�� RAM ����Ϣ
    output reg[`RegBus] mem_addr_o, // Ҫ���ʵ����ݴ洢���ĵ�ַ
    output wire mem_we_o, // �Ƿ���д���� Ϊ 1��ʾд����
    output reg[3:0] mem_sel_o, // �ֽ�ѡ���ź�
    output reg[`RegBus] mem_data_o, // Ҫд�����ݴ洢��������
    output reg mem_ce_o // ���ݴ洢��ʹ���ź�
);

wire[`RegBus] zero32; 
reg mem_we;

assign mem_we_o = mem_we; // �ⲿ���ݴ洢�� RAM �Ķȡ�д�ź�
assign zero32 = `ZeroWord;


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
            default: begin
            end  
        endcase
    end
end

endmodule