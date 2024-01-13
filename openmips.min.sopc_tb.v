// 时间单位是 1ns，精度是 1ps
`timescale 1ns/1ps
`include "defines.v"

module openmips_min_sopc_tb();

reg CLOCK_50;
reg rst;

// 每隔 10ns，CLOCK_50 信号翻转一次，所以一个周期是 20ns，对应 50MHz
initial begin
    CLOCK_50 = 1'b0;
    forever begin
        #10 CLOCK_50 = ~CLOCK_50;
    end
end

// 最初时刻，复位信号有效，在第 195ns 时，复位信号无效，最小 SOPC 开始运行
// 运行 1000ns后，暂停仿真
initial begin
    rst = `RstEnable;
    #195 rst = `RstDisable;
    #1000 $stop;
end

// 例化最小 SOPC
openmips_min_sopc openmips_min_sopc0(
    .clk(CLOCK_50), 
    .rst(rst)
);

endmodule