// ʱ�䵥λ�� 1ns�������� 1ps
`timescale 1ns/1ps
`include "defines.v"

module openmips_min_sopc_tb();

reg CLOCK_50;
reg rst;

// ÿ�� 10ns��CLOCK_50 �źŷ�תһ�Σ�����һ�������� 20ns����Ӧ 50MHz
initial begin
    CLOCK_50 = 1'b0;
    forever begin
        #10 CLOCK_50 = ~CLOCK_50;
    end
end

// ���ʱ�̣���λ�ź���Ч���ڵ� 195ns ʱ����λ�ź���Ч����С SOPC ��ʼ����
// ���� 1000ns����ͣ����
initial begin
    rst = `RstEnable;
    #195 rst = `RstDisable;
    #1000 $stop;
end

// ������С SOPC
openmips_min_sopc openmips_min_sopc0(
    .clk(CLOCK_50), 
    .rst(rst)
);

endmodule