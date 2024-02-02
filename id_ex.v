`include "defines.v"

module id_ex(
    input wire clk, 
    input wire rst, 

    input wire flush, // 流水线清除信号

    // 从译码阶段传递过来的信息
    input wire[`AluOpBus] id_aluop, 
    input wire[`AluSelBus] id_alusel,
    input wire[`RegBus] id_reg1, 
    input wire[`RegBus] id_reg2, 
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,

    input wire[`RegBus] id_link_address, // 处于译码阶段的转移指令要保存的返回地址
    input wire id_is_in_delayslot, // 当前处于译码阶段的指令是否位于延迟槽
    input wire next_inst_in_delayslot_i, // 下一条进入译码阶段的指令是否位于延迟槽

    input wire[`RegBus] id_inst, 

    input wire[`RegBus] id_current_inst_address, // 译码阶段指令的地址
    input wire[31:0] id_excepttype, // 译码阶段收集到的异常信息

    // 来自控制模块的信息
    input wire[`StallBus] stall,  

    // 传递到执行阶段的信息
    output reg[`AluOpBus] ex_aluop, 
    output reg[`AluSelBus] ex_alusel, 
    output reg[`RegBus] ex_reg1, 
    output reg[`RegBus] ex_reg2,
    output reg[`RegAddrBus] ex_wd, 
    output reg ex_wreg,

    output reg[`RegBus] ex_link_address, // 处于执行阶段的转移指令要保存的返回地址
    output reg ex_is_in_delayslot, // 当前处于执行阶段的指令是否位于延迟槽
    output reg is_in_delayslot_o, // 当前处于译码阶段的指令是否位于延迟槽

    output reg[`RegBus] ex_inst, 

    output reg[`RegBus] ex_current_inst_address, // 译码阶段收集到的异常信息
    output reg[31:0] ex_excepttype // 执行阶段指令的地址
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin // 复位
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_link_address <= `ZeroWord;
        ex_is_in_delayslot <= `NotInDelaySlot;
        is_in_delayslot_o <= `NotInDelaySlot;
        ex_inst <= `ZeroWord;
        ex_excepttype <= `ZeroWord;
        ex_current_inst_address <= `ZeroWord;
    end else if (flush == 1'b1) begin // 清楚流水线
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_link_address <= `ZeroWord;
        ex_is_in_delayslot <= `NotInDelaySlot;
        is_in_delayslot_o <= `NotInDelaySlot;
        ex_inst <= `ZeroWord;
        ex_excepttype <= `ZeroWord;
        ex_current_inst_address <= `ZeroWord;
    end else if ((stall[2] == `Stop) && (stall[3] == `NoStop)) begin // 译码暂停 执行继续 空指令
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_link_address <= `ZeroWord;
        ex_is_in_delayslot <= `NotInDelaySlot;
        is_in_delayslot_o <= `NotInDelaySlot;
        ex_inst <= `ZeroWord;
        ex_excepttype <= `ZeroWord;
        ex_current_inst_address <= `ZeroWord;
    end else if (stall[2] == `NoStop) begin // 译码继续
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
        ex_link_address <= id_link_address;
        ex_is_in_delayslot <= id_is_in_delayslot;
        is_in_delayslot_o <= next_inst_in_delayslot_i;
        ex_inst <= id_inst;
        ex_excepttype <= id_excepttype;
        ex_current_inst_address <= id_current_inst_address;
    end
end

endmodule