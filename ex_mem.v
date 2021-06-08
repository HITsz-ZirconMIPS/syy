`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 16:28:53
// Design Name: 
// Module Name: ex_mem
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

module ex_mem(
        
        input   clk,
        input   rst,
        input   flush,
        input   flush_cause,
        input[3:0]  stall,
        
        //massages from ex
        input[`InstAddrBus] inst1_addr_i,
        input[`InstAddrBus] inst2_addr_i,
        
        input[`RegAddrBus]  waddr1_i,
        input[`RegAddrBus]  waddr2_i,
        input                              we1_i,
        input                              we2_i,
        input[`RegBus]           wdata1_i,
        input[`RegBus]           wdata2_i,
        input[`RegBus]           hi_i,
        input[`RegBus]           lo_i,
        input                              whilo_i,
        input[`AluOpBus]       aluop1_i,
        input[`RegBus]          mem_addr_i,
        input[`RegBus]          reg2_i,
        
        output  reg[`InstAddrBus]   inst1_addr_o,
        output  reg[`InstAddrBus]   inst2_addr_o,
        
        output  reg[`RegAddrBus]    waddr1_o,
        output  reg[`RegAddrBus]    waddr2_o,
        output  reg                               we1_o,
        output  reg                                we2_o,
        output  reg[`RegBus]            wdata1_o,
        output  reg[`RegBus]            wdata2_o,
        output  reg[`RegBus]            hi_o,
        output  reg[`RegBus]            lo_o,
        output  reg                              whilo_o,
        output  reg[`AluOpBus]       aluop1_o,
        output  reg[`RegBus]            mem_addr_o,
        output  reg[`RegBus]            reg2_o
        
            
        );
        
        always@(posedge clk) begin
            if(rst == `RstEnable)   begin
                inst1_addr_o <= `ZeroWord;
                inst2_addr_o <= `ZeroWord;
                
                waddr1_o <= `NOPRegAddr;
                waddr2_o <= `NOPRegAddr;
                we1_o <= `WriteDisable;
                we2_o <= `WriteDisable;
                wdata1_o <= `ZeroWord;
                wdata2_o <= `ZeroWord;
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
                whilo_o <= `WriteDisable;
                aluop1_o <= `WriteDisable;
                mem_addr_o <= `ZeroWord;
                reg2_o <= `ZeroWord;
                
           // end else if (flush == `Flush && flush_cause == `Exception) begin    
            end else if(stall[1] == `Stop && stall[2] == `NoStop) begin
                inst1_addr_o <= `ZeroWord;
                inst2_addr_o <= `ZeroWord;
                
                waddr1_o <= `NOPRegAddr;
                waddr2_o <= `NOPRegAddr;
                we1_o <= `WriteDisable;
                we2_o <= `WriteDisable;
                wdata1_o <= `ZeroWord;
                wdata2_o <= `ZeroWord;
                hi_o <= `ZeroWord;
                lo_o <= `ZeroWord;
                whilo_o <= `WriteDisable;
                aluop1_o <= `EXE_NOP_OP;
                mem_addr_o <= `ZeroWord;
                reg2_o <= `ZeroWord;
            end else if(stall[1] == `NoStop)    begin
                
                inst1_addr_o <= inst1_addr_i ;
                inst2_addr_o <= inst2_addr_i; 
              
                waddr1_o <= waddr1_i;
                waddr2_o <= waddr2_i;
                we1_o <= we1_i;
                we2_o <= we2_i;
                wdata1_o <= wdata1_i;
                wdata2_o <= wdata2_i;
                hi_o <= hi_i; 
                lo_o <= lo_i;
                whilo_o <= whilo_i;
                aluop1_o <= aluop1_i; 
                mem_addr_o <= mem_addr_i; 
                reg2_o <= reg2_i;
                            
            end
       end
   
       
            
endmodule