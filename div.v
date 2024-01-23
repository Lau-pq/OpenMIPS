`include "defines.v"

// 本模块主要采用状态机方式实现

module div(
    input wire clk, // 时钟信号
    input wire rst, // 复位信号

    input wire signed_div_i, // 是否为有符号除法，为 1表示有符号除法
    input wire[`RegBus] opdata1_i, // 被除数
    input wire[`RegBus] opdata2_i, // 除数
    input wire start_i, // 是否开始除法运算
    input wire annul_i, // 是否取消除法运算，为 1表示取消除法运算

    output reg[`DoubleRegBus] result_o, // 除法运算结果
    output reg ready_o // 除法运算是否结束 
);

wire[32:0] div_temp; // 保存被减数 minuend - 除数 n 的结果
reg[5:0] cnt; // 记录试商法进行了几轮，当等于 32时，表示试商法结束
reg[64:0] dividend; // [63:32]为minuend, 第k次迭代结束，[k:0]为中间结果，[31:k+1] 为被除数还没参与运算的数据
reg[1:0] state; // 状态
reg[`RegBus] divisor; // 除数 n
reg[`RegBus] temp_op1;
reg[`RegBus] temp_op2;

assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor}; // 计算 minuend - n

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        state <= `DivFree;
        ready_o <= `DivResultNotReady;
        result_o <= {`ZeroWord, `ZeroWord};
    end else begin
        case (state)
            `DivFree: begin // DivFree 状态
                if (start_i == `DivStart && !annul_i) begin
                    if (opdata2_i == `ZeroWord) begin // 除数为 0
                        state <= `DivByZero;
                    end else begin // 除数不为 0
                        state <= `DivOn;
                        cnt <= 6'b000000;
                        if (signed_div_i && opdata1_i[31]) begin // 有符号除法且被除数为负数
                            temp_op1 = ~opdata1_i + 1; // 被除数取补码
                        end else begin
                            temp_op1 = opdata1_i;
                        end
                        if (signed_div_i && opdata2_i[31]) begin // 有符号除法且除数为负数
                            temp_op2 = ~opdata2_i + 1; // 除数取补码
                        end else begin
                            temp_op2 = opdata2_i;
                        end
                        dividend <= {`ZeroWord, `ZeroWord};
                        dividend[32:1] <= temp_op1;
                        divisor <= temp_op2;
                    end
                end else begin // 没有开始除法运算
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord, `ZeroWord};
                end
            end
            `DivByZero: begin // DivByZero 状态
                dividend <= {`ZeroWord, `ZeroWord};
                state <= `DivEnd;
            end
            `DivOn: begin // DivOn 状态
                if (!annul_i) begin
                    if (cnt != 6'b100000) begin // cnt 不为 32，试商法还没结束
                        if (div_temp[32]) begin // minuend-n 结果 < 0
                            // 将被除数还没有运算的最高位加入下一次迭代的被减数，同时将 0加入中间结果
                            dividend <= {dividend[63:0], 1'b0}; 
                        end else begin // miniend-n 结果 > 0
                            // 将减法的结果与被除数还没有运算的最高位加入到下一次迭代的被减数，将 1加入中间结果
                            dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
                        end
                        cnt <= cnt + 1;
                    end else begin // 试商法结束
                        if ((signed_div_i) && (opdata1_i[31] ^ opdata2_i[31])) begin // 有符号除法 异号
                            dividend[31:0] <= ~dividend[31:0] + 1; // 求补码 
                        end
                        if ((signed_div_i) && (opdata1_i[31] ^ dividend[64])) begin // 有符号除法 余数跟被除数同号
                            dividend[64:33] <= ~dividend[64:33] + 1; // 求补码
                        end
                        state <= `DivEnd; // 进入 DivEnd 状态
                        cnt <= 6'b000000; // cnt 清零
                    end
                end else begin
                    state <= `DivFree; //annul_i 为 1
                end
            end
            `DivEnd: begin // DivEnd 状态
                result_o <= {dividend[64:33], dividend[31:0]};
                ready_o <= `DivResultReady;
                if (start_i == `DivStop) begin
                    state <= `DivFree;
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord, `ZeroWord};
                end
            end
        endcase
    end
end



endmodule