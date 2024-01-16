`include "defines.v"

module inst_rom(
    input wire ce, // 使能信号
    input wire[`InstAddrBus] addr, // 要读取的指令地址
    output reg[`InstBus] inst // 读出的指令
);

// 定义一个数组，大小是 InstMemNum，元素宽度是 InstBus
reg[`InstBus] inst_mem[0:`InstMemNum-1];

// 使用文件 inst_rom.data 初始化指令存储器
initial begin
    // 给出绝对路径 注意 “/” 
    $readmemh ("E:/competition/Loongson/OpenMIPS/data/inst_rom6.data", inst_mem); 
end

// 当复位信号无效时，依据输入的地址，给出指令存储器 ROM 中对应的元素
always @( *) begin
    if (ce == `ChipDisable) begin
        inst <= `ZeroWord;
    end else begin
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]]; // 右移2位
    end
end

endmodule