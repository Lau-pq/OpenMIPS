`include "defines.v"

module ex_mem(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    input wire flush, // ��ˮ������ź� 

    // ����ִ�н׶ε���Ϣ
    input wire[`RegAddrBus] ex_wd, // ִ�н׶ε�ָ��ִ�к�Ҫд���Ŀ�ļĴ�����ַ
    input wire ex_wreg, // ִ�н׶ε�ָ��ִ�к��Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[`RegBus] ex_wdata, // ִ�н׶ε�ָ��ִ�к�Ҫд��Ŀ�ļĴ�����ֵ
    input wire[`RegBus] ex_hi, // ִ�н׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    input wire[`RegBus] ex_lo, // ִ�н׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    input wire ex_whilo, // ִ�н׶ε�ָ���Ƿ�Ҫд HI��LO �Ĵ���

    input wire ex_cp0_reg_we, // ִ�н׶ε�ָ���Ƿ�Ҫд CP0 �еļĴ���
    input wire[4:0] ex_cp0_reg_write_addr, // ִ�н׶ε�ָ��Ҫд�� CP0 �мĴ����ĵ�ַ
    input wire[`RegBus] ex_cp0_reg_data, // ִ�н׶ε�ָ��Ҫд�� CP0 �мĴ���������

    input wire[31:0] ex_excepttype, // ���롢ִ�н׶��ռ������쳣��Ϣ
    input wire ex_is_in_delayslot, // ִ�н׶ε�ָ���Ƿ����ӳٲ�ָ��
    input wire[`RegBus] ex_current_inst_address, // ִ�н׶�ָ��ĵ�ַ

    // ���Կ���ģ�����Ϣ
    input wire[`StallBus] stall,

    input wire[`DoubleRegBus] hilo_i, // ����ĳ˷����
    input wire[1:0] cnt_i, // ��һ��ʱ��������ִ�н׶εĵڼ���ʱ������

    // Ϊʵ�ּ��ء��洢ָ�����ӵ�����ӿ�
    input wire[`AluOpBus] ex_aluop, // ִ�н׶ε�ָ��Ҫ���е�����������
    input wire[`RegBus] ex_mem_addr, // ִ�н׶εļ��ء��洢ָ���Ӧ�Ĵ洢����ַ
    input wire[`RegBus] ex_reg2, // ִ�н׶εĴ洢ָ��Ҫ�洢�����ݣ����� lwl��lwr ָ��Ҫд���Ŀ�ļĴ�����ԭʼֵ

    // �͵��ô�׶ε���Ϣ
    output reg[`RegAddrBus] mem_wd, // �ô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
    output reg mem_wreg, // �ô�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] mem_wdata, // �ô�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
    output reg[`RegBus] mem_hi, // �ô�׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    output reg[`RegBus] mem_lo, // �ô�׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    output reg mem_whilo,  // �ô�׶ε�ָ���Ƿ�Ҫд HI��LO�Ĵ���

    output reg mem_cp0_reg_we, // �ô�׶ε�ָ���Ƿ�Ҫд CP0 �еļĴ���
    output reg[4:0] mem_cp0_reg_write_addr, // �ô�׶ε�ָ���Ƿ�Ҫд�� CP0 �мĴ����ĵ�ַ
    output reg[`RegBus] mem_cp0_reg_data, // �ô�׶ε�ָ��Ҫд�� CP0 �мĴ���������

    output reg[`DoubleRegBus] hilo_o, // ����ĳ˷����
    output reg[1:0] cnt_o, // ��ǰ����ִ�н׶εĵڼ���ʱ������ 

    output reg[31:0] mem_excepttype, // ���롢ִ�н׶��ռ������쳣��Ϣ
    output reg mem_is_in_delayslot, // �ô�׶ε�ָ���Ƿ����ӳٲ�ָ��
    output reg[`RegBus] mem_current_inst_address, // �ô�׶�ָ��ĵ�ַ

    // Ϊʵ�ּ��ء��洢ָ�����ӵ�����˿�
    output reg[`AluOpBus] mem_aluop, // �ô�׶ε�ָ��Ҫ���е������������
    output reg[`RegBus] mem_mem_addr, // �ô�׶εļ��ء��洢ָ���Ӧ�Ĵ洢����ַ
    output reg[`RegBus] mem_reg2 // �ô�׶εĴ洢ָ��Ҫ�洢�����ݣ����� lwl��lwr ָ��Ҫд���Ŀ�ļĴ�����ԭʼֵ
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin // ��λ
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= {`ZeroWord, `ZeroWord};
        cnt_o <= 2'b00;
        mem_aluop <= `EXE_NOP_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2 <= `ZeroWord;
        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= 5'b00000; 
        mem_cp0_reg_data <= `ZeroWord; 
        mem_excepttype <= `ZeroWord;
        mem_is_in_delayslot <= `NotInDelaySlot;
        mem_current_inst_address <= `ZeroWord;
    end else if (flush == 1'b1) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= {`ZeroWord, `ZeroWord};
        cnt_o <= 2'b00;
        mem_aluop <= `EXE_NOP_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2 <= `ZeroWord;
        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= 5'b00000; 
        mem_cp0_reg_data <= `ZeroWord; 
        mem_excepttype <= `ZeroWord;
        mem_is_in_delayslot <= `NotInDelaySlot;
        mem_current_inst_address <= `ZeroWord;
    end else if ((stall[3] == `Stop) && (stall[4] == `NoStop)) begin // ִ����ͣ �ô���� ��ָ��
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= hilo_i; 
        cnt_o <= cnt_i;
        mem_aluop <= `EXE_NOP_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2 <= `ZeroWord;
        mem_cp0_reg_we <= `WriteDisable;
        mem_cp0_reg_write_addr <= 5'b00000; 
        mem_cp0_reg_data <= `ZeroWord; 
        mem_excepttype <= `ZeroWord;
        mem_is_in_delayslot <= `NotInDelaySlot;
        mem_current_inst_address <= `ZeroWord;
    end else if (stall[3] == `NoStop) begin // ִ�м���
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;
        hilo_o <= {`ZeroWord, `ZeroWord}; 
        cnt_o <= 2'b00;
        mem_aluop <= ex_aluop;
        mem_mem_addr <= ex_mem_addr;
        mem_reg2 <= ex_reg2;
        
        // ��ִ�н׶�û����ͣ��ʱ�򣬽��� CP0 �мĴ�����д��Ϣ���ݵ��ô�׶�
        mem_cp0_reg_we <= ex_cp0_reg_we;
        mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr; 
        mem_cp0_reg_data <= ex_cp0_reg_data; 

        mem_excepttype <= ex_excepttype;
        mem_is_in_delayslot <= ex_is_in_delayslot;
        mem_current_inst_address <= ex_current_inst_address;
    end else begin
        hilo_o <= hilo_i;
        cnt_o <= cnt_i;
    end
end

endmodule