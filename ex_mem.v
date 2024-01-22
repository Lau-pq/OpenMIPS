`include "defines.v"

module ex_mem(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    // ����ִ�н׶ε���Ϣ
    input wire[`RegAddrBus] ex_wd, // ִ�н׶ε�ָ��ִ�к�Ҫд���Ŀ�ļĴ�����ַ
    input wire ex_wreg, // ִ�н׶ε�ָ��ִ�к��Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[`RegBus] ex_wdata, // ִ�н׶ε�ָ��ִ�к�Ҫд��Ŀ�ļĴ�����ֵ
    input wire[`RegBus] ex_hi, // ִ�н׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    input wire[`RegBus] ex_lo, // ִ�н׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    input wire ex_whilo, // ִ�н׶ε�ָ���Ƿ�Ҫд HI��LO �Ĵ���

    // ���Կ���ģ�����Ϣ
    input wire[`StallBus] stall,

    input wire[`DoubleRegBus] hilo_i, // ����ĳ˷����
    input wire[1:0] cnt_i, // ��һ��ʱ��������ִ�н׶εĵڼ���ʱ������

    // �͵��ô�׶ε���Ϣ
    output reg[`RegAddrBus] mem_wd, // �ô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
    output reg mem_wreg, // �ô�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] mem_wdata, // �ô�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
    output reg[`RegBus] mem_hi, // �ô�׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    output reg[`RegBus] mem_lo, // �ô�׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    output reg mem_whilo,  // �ô�׶ε�ָ���Ƿ�Ҫд HI��LO�Ĵ���

    output reg[`DoubleRegBus] hilo_o, // ����ĳ˷����
    output reg[1:0] cnt_o // ��ǰ����ִ�н׶εĵڼ���ʱ������ 
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= {`ZeroWord, `ZeroWord};
        cnt_o <= 2'b00;
    end else if ((stall[3] == `Stop) && (stall[4] == `NoStop)) begin // ִ����ͣ �ô���� ��ָ��
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;
        hilo_o <= hilo_i; 
        cnt_o <= cnt_i; 
    end else if (stall[3] == `NoStop) begin // ִ�м���
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;
        hilo_o <= {`ZeroWord, `ZeroWord}; 
        cnt_o <= 2'b00;
    end else begin
        hilo_o <= hilo_i;
        cnt_o <= cnt_i;
    end
end

endmodule