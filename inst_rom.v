`include "defines.v"

module inst_rom(
    input wire ce, // ʹ���ź�
    input wire[`InstAddrBus] addr, // Ҫ��ȡ��ָ���ַ
    output reg[`InstBus] inst // ������ָ��
);

// ����һ�����飬��С�� InstMemNum��Ԫ�ؿ���� InstBus
reg[`InstBus] inst_mem[0:`InstMemNum-1];

// ʹ���ļ� inst_rom.data ��ʼ��ָ��洢��
initial begin
    // ��������·�� ע�� ��/�� 
    $readmemh ("E:/competition/Loongson/OpenMIPS/data/inst_rom6.data", inst_mem); 
end

// ����λ�ź���Чʱ����������ĵ�ַ������ָ��洢�� ROM �ж�Ӧ��Ԫ��
always @( *) begin
    if (ce == `ChipDisable) begin
        inst <= `ZeroWord;
    end else begin
        inst <= inst_mem[addr[`InstMemNumLog2+1:2]]; // ����2λ
    end
end

endmodule