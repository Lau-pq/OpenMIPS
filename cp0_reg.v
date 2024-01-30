`include "defines.v"

module cp0_reg(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    input wire we_i, // 是否要写 CP0 中寄存器的地址
    input wire[4:0] waddr_i, // 要写的 CP0 中寄存器的地址
    input wire[4:0] raddr_i, // 要读取的 CP0 中寄存器的地址
    input wire[`RegBus] data_i, // 要写入 CP0 中寄存器的数据

    input wire[5:0] int_i, // 6 个外部硬件中断输入

    output reg[`RegBus] data_o, // 读出的 CP0 中某个寄存器的值
    output reg[`RegBus] count_o, // Count 寄存器的值
    output reg[`RegBus] compare_o, // Compare 寄存器的值
    output reg[`RegBus] status_o, // Status 寄存器的值
    output reg[`RegBus] cause_o, // Cause 寄存器的值
    output reg[`RegBus] epc_o, // EPC 寄存器的值
    output reg[`RegBus] config_o, // Config 寄存器的值
    output reg[`RegBus] prid_o, // PRId 寄存器的值

    output reg timer_int_o // 是否有定时中断发生

);

// ********************对 CP0 中寄存器的写操作 *****************
always @(posedge clk) begin
    if (rst == `RstEnable) begin
        count_o <= `ZeroWord; // Count 寄存器的初始值，为 0
        compare_o <= `ZeroWord; // Compare 寄存器的初始值，为 0
        status_o <= 32'h10000000; // CU 字段为 4'b0001，表示协处理器 CP0 存在
        cause_o <= `ZeroWord; // Cause 寄存器的初始值，为 0
        epc_o <= `ZeroWord; // EPC 寄存器的初始值，为 0
        config_o <= 32'h00008000; // BE 字段为 1，表示工作在大端模式(MSB)
        prid_o <= 32'h00480102; // 制作者 L，对于 0x48，类型 0x1(基本类型)，版本号1.0
        timer_int_o <= `InterruptNotAssert;
    end else begin
        count_o <= count_o + 1; // Count 寄存器的值在每个时钟周期加 1
        cause_o[15:10] <= int_i; // Cause 的第 10~15 bit 保存外部中断声明
        if (compare_o != `ZeroWord && count_o == compare_o) begin // 当 Compare 寄存器不为 0，且 Count 寄存器的值等于 Compare 寄存器的值
            timer_int_o <= `InterruptAssert; // 时钟中断发生
        end
        if (we_i == `WriteEnable) begin
            case (waddr_i)
                `CP0_REG_COUNT: begin // 写 Count 寄存器
                    count_o <= data_i;
                end
                `CP0_REG_COMPARE: begin // 写 Compare 寄存器
                    compare_o <= data_i;
                    timer_int_o <= `InterruptNotAssert;
                end
                `CP0_REG_STATUS: begin // 写 Status 寄存器
                    status_o <= data_i;
                end
                `CP0_REG_EPC: begin // 写 EPC 寄存器
                    epc_o <= data_i;                    
                end
                `CP0_REG_CAUSE: begin // 写 Cause 寄存器
                    // Cause 寄存器只有 IP[1:0]、IV、WP 字段是可写的
                    cause_o[9:8] <= data_i[9:8];
                    cause_o[23] <= data_i[23];
                    cause_o[22] <= data_i[22];
                end
            endcase
        end
    end
end

// ********************对 CP0 中寄存器的读操作 *****************
always @( *) begin
    if (rst == `RstEnable) begin
        data_o <= `ZeroWord;
    end else begin
        case (raddr_i)
            `CP0_REG_COUNT: begin // 读 Count 寄存器
                data_o <= count_o;
            end
            `CP0_REG_COMPARE: begin // 读 Compare 寄存器
                data_o <= compare_o;
            end 
            `CP0_REG_STATUS: begin // 读 Status 寄存器
                data_o <= status_o;
            end
            `CP0_REG_CAUSE: begin // 读 Cause 寄存器
                data_o <= cause_o;
            end
            `CP0_REG_EPC: begin // 读 EPC 寄存器
                data_o <= epc_o;
            end
            `CP0_REG_PRId: begin // 读 PRId 寄存器
                data_o <= prid_o;
            end
            `CP0_REG_CONFIG: begin // 读 Config 寄存器
                data_o <= config_o;
            end
            default: begin
            end
        endcase
    end
end


endmodule