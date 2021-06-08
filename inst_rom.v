`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/01 20:30:58
// Design Name: 
// Module Name: inst_rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

//InstMemNum��InstMemNumLog2�໥��Ӧ
//ͨ������ʹ���ź�ce����Ӧ��ָ�����ڵ�ַ  �ɵõ� ��Ӧ��32λָ����Ϣ 
module inst_rom (
    //input clk,
    input wire ce,
    input wire[`InstAddrBus] addr,                 //InstAddrBus=31:0        
    output reg[`InstBus] inst1,
    output reg[`InstBus] inst2,
    output reg[`InstAddrBus]    inst1_addr,
    output reg[`InstAddrBus]    inst2_addr
);
    //����һ�����飬��СΪinstmemnum��Ԫ�ؿ��Ϊinstbus��32��
    reg [`InstBus] inst_mem[0:`InstMemNum-1] ;          //InstMemNum = 131071

    //ʹ���ļ�inst_rom.data��ʼ��ָ��洢��
    initial $readmemh ("1_test_ori_big.data",inst_mem);

    //����λ�ź���Чʱ��ȡ����Ӧ��ֵַ�е�ָ��
    always @(*) begin  //改成时序电路？
        if(ce == `ChipDisable) begin
            inst1 <= `ZeroWord;     inst2 <= `ZeroWord;
        end else begin      //debug
            inst1 <= inst_mem[addr[`InstMemNumLog2+1:2]]; //���ִ洢��������Ҫ��4��������λ��InstMemNumLog2=17
            inst2 <= inst_mem[addr[`InstMemNumLog2+1:2]+1];
            inst1_addr <= addr[`InstMemNumLog2+1:2];
            inst2_addr <= addr[`InstMemNumLog2+1:2]+1;
            //inst1 <= inst_mem[addr[`InstMemNumLog2+1:2]];
            //inst2 <= inst_mem[addr[`InstMemNumLog2+3:4]];
            
        end
    end

endmodule