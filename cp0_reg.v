`include "defines.v"

module cp0_reg(
    input wire clk, // ʱ���ź�
    input wire rst, // ��λ�ź�

    input wire we_i, // �Ƿ�Ҫд CP0 �мĴ����ĵ�ַ
    input wire[4:0] waddr_i, // Ҫд�� CP0 �мĴ����ĵ�ַ
    input wire[4:0] raddr_i, // Ҫ��ȡ�� CP0 �мĴ����ĵ�ַ
    input wire[`RegBus] data_i, // Ҫд�� CP0 �мĴ���������

    input wire[5:0] int_i, // 6 ���ⲿӲ���ж�����

    output reg[`RegBus] data_o, // ������ CP0 ��ĳ���Ĵ�����ֵ
    output reg[`RegBus] count_o, // Count �Ĵ�����ֵ
    output reg[`RegBus] compare_o, // Compare �Ĵ�����ֵ
    output reg[`RegBus] status_o, // Status �Ĵ�����ֵ
    output reg[`RegBus] cause_o, // Cause �Ĵ�����ֵ
    output reg[`RegBus] epc_o, // EPC �Ĵ�����ֵ
    output reg[`RegBus] config_o, // Config �Ĵ�����ֵ
    output reg[`RegBus] prid_o, // PRId �Ĵ�����ֵ

    output reg timer_int_o // �Ƿ��ж�ʱ�жϷ���

);

// ********************�� CP0 �мĴ�����д���� *****************
always @(posedge clk) begin
    if (rst == `RstEnable) begin
        count_o <= `ZeroWord; // Count �Ĵ����ĳ�ʼֵ��Ϊ 0
        compare_o <= `ZeroWord; // Compare �Ĵ����ĳ�ʼֵ��Ϊ 0
        status_o <= 32'h10000000; // CU �ֶ�Ϊ 4'b0001����ʾЭ������ CP0 ����
        cause_o <= `ZeroWord; // Cause �Ĵ����ĳ�ʼֵ��Ϊ 0
        epc_o <= `ZeroWord; // EPC �Ĵ����ĳ�ʼֵ��Ϊ 0
        config_o <= 32'h00008000; // BE �ֶ�Ϊ 1����ʾ�����ڴ��ģʽ(MSB)
        prid_o <= 32'h00480102; // ������ L������ 0x48������ 0x1(��������)���汾��1.0
        timer_int_o <= `InterruptNotAssert;
    end else begin
        count_o <= count_o + 1; // Count �Ĵ�����ֵ��ÿ��ʱ�����ڼ� 1
        cause_o[15:10] <= int_i; // Cause �ĵ� 10~15 bit �����ⲿ�ж�����
        if (compare_o != `ZeroWord && count_o == compare_o) begin // �� Compare �Ĵ�����Ϊ 0���� Count �Ĵ�����ֵ���� Compare �Ĵ�����ֵ
            timer_int_o <= `InterruptAssert; // ʱ���жϷ���
        end
        if (we_i == `WriteEnable) begin
            case (waddr_i)
                `CP0_REG_COUNT: begin // д Count �Ĵ���
                    count_o <= data_i;
                end
                `CP0_REG_COMPARE: begin // д Compare �Ĵ���
                    compare_o <= data_i;
                    timer_int_o <= `InterruptNotAssert;
                end
                `CP0_REG_STATUS: begin // д Status �Ĵ���
                    status_o <= data_i;
                end
                `CP0_REG_EPC: begin // д EPC �Ĵ���
                    epc_o <= data_i;                    
                end
                `CP0_REG_CAUSE: begin // д Cause �Ĵ���
                    // Cause �Ĵ���ֻ�� IP[1:0]��IV��WP �ֶ��ǿ�д��
                    cause_o[9:8] <= data_i[9:8];
                    cause_o[23] <= data_i[23];
                    cause_o[22] <= data_i[22];
                end
            endcase
        end
    end
end

// ********************�� CP0 �мĴ����Ķ����� *****************
always @( *) begin
    if (rst == `RstEnable) begin
        data_o <= `ZeroWord;
    end else begin
        case (raddr_i)
            `CP0_REG_COUNT: begin // �� Count �Ĵ���
                data_o <= count_o;
            end
            `CP0_REG_COMPARE: begin // �� Compare �Ĵ���
                data_o <= compare_o;
            end 
            `CP0_REG_STATUS: begin // �� Status �Ĵ���
                data_o <= status_o;
            end
            `CP0_REG_CAUSE: begin // �� Cause �Ĵ���
                data_o <= cause_o;
            end
            `CP0_REG_EPC: begin // �� EPC �Ĵ���
                data_o <= epc_o;
            end
            `CP0_REG_PRId: begin // �� PRId �Ĵ���
                data_o <= prid_o;
            end
            `CP0_REG_CONFIG: begin // �� Config �Ĵ���
                data_o <= config_o;
            end
            default: begin
            end
        endcase
    end
end


endmodule