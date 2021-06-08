`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 16:20:05
// Design Name: 
// Module Name: pc_reg
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
`include  "defines.v" 

module pc_reg(
    input clk,
    input rst,
    input[3:0]  stall,
    input   flush,
    input   flush_cause,
    
    input   stallreq_from_icache,
    input[`InstAddrBus] ex_pc,
    input[`InstAddrBus] npc_actual,
    input[`InstAddrBus] epc,
    //input issue,
    
    input   ibuffer_full,
    
    output   reg [`InstAddrBus] pc,
    output   reg    rreq_to_icache
    //output   reg    issue    
    
    );
    
    reg[`InstAddrBus]   npc;
    
always@(posedge clk) begin   //组合逻辑？
        if(rst == `RstEnable || flush == `Flush || ibuffer_full)begin
            rreq_to_icache = `ChipDisable;
        end else begin
            rreq_to_icache =`ChipEnable ;
        end
end

always @(posedge clk)   pc<=npc;
    
//逻辑要改一下    组合逻辑？  使用npc的意义是什么？
always@(*) begin
    if(rreq_to_icache==  `ChipDisable) begin
        npc = 32'hbfc00000;
    end else if(stall[0]==`Stop)begin
         npc = pc;    
    //end else if(issue == `SingleIssue) begin
      //  npc <= pc + 4'h4;    
    end else 
        npc <= pc + 4'h8;
              
end    
    
    
    
    
endmodule
