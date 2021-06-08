`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 16:28:19
// Design Name: 
// Module Name: id_ex
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

module id_ex(
        input   clk,
        input   rst,
        input   flush,
        input   flush_cause,
        input[3:0]  stall,
        
        input[`InstAddrBus]     inst1_addr_i,
        input[`InstAddrBus]     inst2_addr_i,
        input[`AluOpBus]          aluop1_i,
        input[`AluSelBus]          alusel1_i,
        input[`AluOpBus]          aluop2_i,
        input[`AluSelBus]          alusel2_i,
        input [`RegBus]             reg1_i,
        input [`RegBus]             reg2_i,
        input [`RegBus]             reg3_i,
        input [`RegBus]             reg4_i,
        input[`RegAddrBus]     waddr1_i,
        input[`RegAddrBus]     waddr2_i,
        input                                 we1_i,
        input                                 we2_i,
        input[`RegBus]                        hi_i,
        input[`RegBus]                        lo_i,
        input                                 imm_fnl_i,
        input                                 issue_i,
        input                                 ex_issue_mode_i,
        output  reg[`InstAddrBus]       inst1_addr_o,
        output  reg[`InstAddrBus]       inst2_addr_o,
        
        output  reg[`AluOpBus]           aluop1_o,
        output  reg[`AluSelBus]           alusel1_o,
        output  reg[`AluOpBus]           aluop2_o,
        output  reg[`AluSelBus]           alusel2_o,
        output  reg[`RegBus]                reg1_o,
        output  reg[`RegBus]                reg2_o,
        output  reg[`RegBus]                reg3_o,
        output  reg[`RegBus]                reg4_o,
        output  reg[`RegAddrBus]    waddr1_o,
        output reg[`RegAddrBus]     waddr2_o,
        output reg                                  we1_o,
        output reg                                  we2_o,
        output  reg[`RegBus]                        hi_o,
        output  reg[`RegBus]                        lo_o,
        
        output  reg                                 imm_fnl1_o,
        output  reg                                 issue_o
        
        
       
              
   
       
    );
    
    always@ (posedge clk)   begin
        if (rst == `RstEnable) begin
            inst1_addr_o <= `ZeroWord;
            inst2_addr_o <= `ZeroWord;
            aluop1_o <= `EXE_NOP_OP;
            alusel1_o <= `EXE_RES_NOP;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            reg1_o <= `ZeroWord;
            reg2_o <= `ZeroWord;
            reg3_o <= `ZeroWord;
            reg4_o <= `ZeroWord;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            imm_fnl1_o <= `ZeroWord;
            issue_o <= `DualIssue;
            
            
            
        end else if (stall[0] == `Stop && stall[1] == `NoStop)  begin
            inst1_addr_o <= `ZeroWord;
            inst2_addr_o <= `ZeroWord;
            aluop1_o <= `EXE_NOP_OP;
            alusel1_o <= `EXE_RES_NOP;
            aluop2_o <= `EXE_NOP_OP;
            alusel2_o <= `EXE_RES_NOP;
            reg1_o <= `ZeroWord;
            reg2_o <= `ZeroWord;
            reg3_o <= `ZeroWord;
            reg4_o <= `ZeroWord;
            waddr1_o <= `NOPRegAddr;
            waddr2_o <= `NOPRegAddr;
            we1_o <= `WriteDisable;
            we2_o <= `WriteDisable;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            imm_fnl1_o <= `ZeroWord;
            issue_o <= `DualIssue;
    
               
                
    end else if (stall[0] == `NoStop) begin
            inst1_addr_o <= inst1_addr_i;
            inst2_addr_o <= inst2_addr_i;
            aluop1_o <= aluop1_i;
            alusel1_o <= alusel1_i;
            aluop2_o <= aluop2_i;
            alusel2_o <= alusel2_i;
            reg1_o <= reg1_i;
            reg2_o <= reg2_i;
            reg3_o <= reg3_i;
            reg4_o <= reg4_i;
            waddr1_o <= waddr1_i;
            waddr2_o <= waddr2_i;
            we1_o <= we1_i;
            we2_o <= we2_i;     
            hi_o <= hi_i;
            lo_o <= lo_i;
            imm_fnl1_o <= imm_fnl_i;
            issue_o <= issue_i;    
    end
     end
endmodule
    