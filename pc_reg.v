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
    input branch_flag,
    input[`InstAddrBus] ex_pc,
    input[`InstAddrBus] npc_actual,
    input[`InstAddrBus] epc,
    input[`InstAddrBus] npc_from_cache,
   
    
    input   ibuffer_full,
    
    output   reg [`InstAddrBus] pc,
    output   reg    rreq_to_icache
   
    
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
    
//逻辑要改一下    组合逻辑？  使用npc的意义是什么？ 次态 next_pc 
always@(*) begin
    if(rreq_to_icache==  `ChipDisable) begin
        npc = 32'hbfc00000;
    end else if(flush == `Flush && flush_cause == `Exception)begin
         npc = epc;    
    end else if(flush == `Flush && flush_cause == `FailedBranchPrediction && branch_flag == `Branch) begin
         npc = npc_actual;  
    end else if(flush == `Flush && flush_cause == `FailedBranchPrediction && branch_flag == `NotBranch) begin
         npc = ex_pc + 32'h8;
    end else if(ibuffer_full) npc = pc;        
    else 
         npc = pc + 4'h8;
              
end    
    
    
    
    
endmodule
