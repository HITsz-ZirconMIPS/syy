`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/24 20:47:49
// Design Name: 
// Module Name: commit
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

module commit(
        
        input   clk,
        input   rst,
        input   flush,
        input   flush_cause,
        input[4:0]   stall,
        
        //from mem
        input[`InstAddrBus] pc_i,
        input[`RegAddrBus]  waddr1_i,
        input[`RegAddrBus]  waddr2_i,
        input                              we1_i,
        input                              we2_i,
        input[`RegBus]          wdata1_i,
        input[`RegBus]          wdata2_i,
        input[`RegBus]          hi_i,
        input[`RegBus]          lo_i,
        input                             whilo_i,
        
        //to regfiles
        output  reg[`InstAddrBus]   pc_o,
        output  reg[`RegAddrBus]    waddr1_o,
        output  reg[`RegAddrBus]    waddr2_o,
        output  reg                               we1_o,
        output  reg                               we2_o,
        output  reg[`RegBus]            wdata1_o,
        output  reg[`RegBus]            wdata2_o,
        output  reg[`RegBus]            hi_o,
        output  reg[`RegBus]            lo_o,
        output  reg                               whilo_o
       
        );
        
    always @(posedge clk) begin
        if(rst == `RstEnable)   begin
            pc_o <= `ZeroWord;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            wdata1_o <= `ZeroWord;
            wdata2_o <= `ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;
            
        //end else if(flush == `Flush && flush_cause == `Exception && exception_first_inst_i == 1'b1)    
        end else if(stall[2] == `Stop && stall[3] == `NoStop) begin
            pc_o <= `ZeroWord;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            wdata1_o <= `ZeroWord;
            wdata2_o <= `ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;                       
        end else if(stall[2] == `NoStop)    begin
            pc_o <= pc_i;
            waddr1_o <= waddr1_i;                                                         
            waddr2_o <= waddr2_i;
            we1_o <= we1_i;
            we2_o <= we2_i;
            wdata1_o <= wdata1_i;
            wdata2_o <= wdata2_i;
            hi_o <= hi_i; 
            lo_o <= lo_i;
            whilo_o <= whilo_i;    
            end 
    end
    
endmodule
