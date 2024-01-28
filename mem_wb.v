`include "defines.v"

module mem_wb(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    // �ô�׶εĽ��
    input wire[`RegAddrBus] mem_wd, // �ô�׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ
    input wire mem_wreg, // �ô�׶ε�ָ�������Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[`RegBus] mem_wdata, // �ô�׶ε�ָ������Ҫд��Ŀ�ļĴ�����ֵ
    input wire[`RegBus] mem_hi, // �ô�׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    input wire[`RegBus] mem_lo, // �ô�׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    input wire mem_whilo, // �ô�׶ε�ָ���Ƿ�Ҫд HI��LO�Ĵ���    

    // ���Կ���ģ�����Ϣ
    input wire[`StallBus] stall, 

    // �� LLbit ģ���йص���Ϣ
    input wire mem_LLbit_we, // �ô�׶ε�ָ���Ƿ�Ҫд LLbit �Ĵ���
    input wire mem_LLbit_value, // �ô�׶ε�ָ��Ҫд�� LLbit �Ĵ�����ֵ  

    // �͵���д�׶ε���Ϣ
    output reg[`RegAddrBus] wb_wd, // ��д�׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
    output reg wb_wreg, // ��д�׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���
    output reg[`RegBus] wb_wdata, // ��д�׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
    output reg[`RegBus] wb_hi, // ��д�׶ε�ָ��Ҫд�� HI �Ĵ�����ֵ
    output reg[`RegBus] wb_lo, // ��д�׶ε�ָ��Ҫд�� LO �Ĵ�����ֵ
    output reg wb_whilo, // ��д�׶ε�ָ���Ƿ�Ҫд HI��LO�Ĵ��� 

    // �� LLbit ģ���йص���Ϣ
    output reg wb_LLbit_we, // ��д�׶ε�ָ���Ƿ�Ҫд LLbit �Ĵ���
    output reg wb_LLbit_value // ��д�׶ε�ָ��Ҫд�� LLbit �Ĵ�����ֵ
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
        wb_hi <= `ZeroWord;
        wb_lo <= `ZeroWord;
        wb_whilo <= `WriteDisable;
        wb_LLbit_we <= 1'b0;
        wb_LLbit_value <= 1'b0;
    end else if ((stall[4] == `Stop) && (stall[5] == `NoStop)) begin // �ô���ͣ ��д���� ��ָ��
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteDisable;
        wb_wdata <= `ZeroWord;
        wb_hi <= `ZeroWord;
        wb_lo <= `ZeroWord;
        wb_whilo <= `WriteDisable;
        wb_LLbit_we <= 1'b0;
        wb_LLbit_value <= 1'b0;
    end else if (stall[4] == `NoStop) begin // �ô����
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
        wb_hi <= mem_hi;
        wb_lo <= mem_lo;
        wb_whilo <= mem_whilo;
        wb_LLbit_we <= mem_LLbit_we;
        wb_LLbit_value <= mem_LLbit_value;
    end
end

endmodule