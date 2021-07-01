`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/21 22:10:47
// Design Name: 
// Module Name: ex_top
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

module ex_top(
        input   rst,
        
        input[`InstAddrBus]     inst1_addr_i,
        input[`InstAddrBus]     inst2_addr_i,
        input[`SIZE_OF_CORR_PACK] inst1_bpu_corr_i,
        input[`SIZE_OF_CORR_PACK] inst2_bpu_corr_i,
        input[`AluOpBus]     aluop1_i,
        input[`AluSelBus]     alusel1_i,
        input[`AluOpBus]     aluop2_i,
        input[`AluSelBus]     alusel2_i,
        input[`RegBus]          reg1_i,
        input[`RegBus]          reg2_i,
        input[`RegBus]          reg3_i,
        input[`RegBus]          reg4_i,
        input[`RegAddrBus]      waddr1_i,
        input[`RegAddrBus]      waddr2_i,
        input                                   we1_i,
        input                                   we2_i,
        
 
        input[`DoubleRegBus]    div_result_i,
        input                                     div_ready_i,
        
        input[`RegBus]                  hi_i,
        input[`RegBus]                  lo_i,
        
        //jump and branch
            
        input[`RegBus]                  imm_fnl1_i,
        input                   issue_i,
        
        input                   is_in_delayslot1_i,
        input                   is_in_delayslot2_i,
        
        
       output[`InstAddrBus]     inst1_addr_o,
       output[`InstAddrBus]     inst2_addr_o,
       output[`SIZE_OF_CORR_PACK] inst1_bpu_corr_o,
       output[`SIZE_OF_CORR_PACK] inst2_bpu_corr_o,
       output[`RegAddrBus]     waddr1_o,
       output[`RegAddrBus]     waddr2_o,
       output                                 we1_o,
       output                                 we2_o,
       output[`RegBus]              wdata1_o,
       output[`RegBus]              wdata2_o,
       
       //output                               mul_req_o,
//       output                               mul_s_o,

      output  reg[`RegBus]    hi_o,
      output  reg[`RegBus]    lo_o,
      output  reg                       whilo_o,
      
      output[`InstAddrBus]          npc_actual,
      output                        branch_flag_actual,
      output                        predict_flag,
      output[`SIZE_OF_BRANCH_INFO]                        branch_info,
      
      output                        issue_mode,
      output                        is_in_delayslot1_o,
      output                        is_in_delayslot2_o,
      
      
      //div
      output[`RegBus]               div_opdata1_o,
      output[`RegBus]               div_opdata2_o,
      output                        div_start_o,
      output                        signed_div_o,
      
      output[`AluOpBus]             aluop1_o,
      output[`RegBus]               mem_addr_o,
      output[`RegBus]               reg2_o,
      
      output[`RegBus]               mem_raddr_o,
      output[`RegBus]               mem_waddr_o,
      output                        mem_we_o,
      output[3:0]                   mem_sel_o,
      output[`RegBus]               mem_data_o,
      output                        mem_re_o,
      
      output                                 stallreq               
            
    );
    
    
    wire[`RegBus]   ex_sub_1_hi_o;
    wire[`RegBus]   ex_sub_1_lo_o;
    wire    ex_sub_1_whilo_o;    
    wire[`RegBus]   ex_sub_2_hi_o;
    wire[`RegBus]   ex_sub_2_lo_o;
    wire    ex_sub_2_whilo_o;
    
    assign issue_mode = issue_i;
    assign is_in_delayslot1_o = is_in_delayslot1_i;
    assign is_in_delayslot2_o = is_in_delayslot2_i;
    assign inst1_addr_o = inst1_addr_i;
    assign inst2_addr_o = inst2_addr_i;
    assign inst1_bpu_corr_o = inst1_bpu_corr_i;
    assign inst2_bpu_corr_o = inst2_bpu_corr_i;
    
    ex  u_ex1(
            .rst(rst),

            .aluop_i(aluop1_i),            
            .alusel_i(alusel1_i),           
            .reg1_i(reg1_i),          
            .reg2_i(reg2_i),          
            .waddr_i(waddr1_i),              
            .we_i (we1_i), 
             .hi_i(hi_i),
             .lo_i(lo_i),       
            .mul_ready_i(mul_ready_i),                  
            .mul_i(mul_i),
            .div_result_i(div_result_i),            
            .div_ready_i(div_ready_i),
            .imm_i(imm_fnl1_i),
            .pc_i(inst1_addr_i),
            
            .waddr_o(waddr1_o),                     
            . we_o(we1_o),         
            .wdata_o(wdata1_o),                
            .hi_o(ex_sub_1_hi_o),                   
            .lo_o(ex_sub_1_lo_o),                   
            .whilo_o(ex_sub_1_whilo_o),                           
            .div_opdata1_o(div_opdata1_o),            
            .div_opdata2_o(div_opdata2_o),            
            .div_start_o(div_start_o),    
            .signed_div_o(signed_div_o),
                    
            .mem_addr_o(mem_addr_o),                                                
            .mem_raddr_o(mem_raddr_o),              
            .mem_waddr_o(mem_waddr_o),              
            .mem_we_o(mem_we_o),                 
            .mem_sel_o(mem_sel_o),                
            .mem_data_o(mem_data_o),               
            .mem_re_o(mem_re_o),                 
                                      
            . stallreq(stallreq)                  

            );          
                    
    ex_sub  u_ex2(
            .rst(rst),

            .aluop_i(aluop2_i),            
            .alusel_i(alusel2_i),           
            .reg1_i(reg3_i),          
            .reg2_i(reg4_i),          
            .waddr_i(waddr2_i),              
            .we_i (we2_i), 
            .hi_i(hi_i),
            .lo_i(lo_i),
            .waddr_o(waddr2_o),                     
            . we_o(we2_o),         
            .wdata_o(wdata2_o),                
            .hi_o(ex_sub_2_hi_o),                   
            .lo_o(ex_sub_2_lo_o),                   
            .whilo_o(ex_sub_2_whilo_o)
            
    
    
    );             
 
 always @(*)    begin
        if(rst == `RstEnable)   begin
                whilo_o = `WriteDisable;
                hi_o = `ZeroWord;
                lo_o = `ZeroWord;
        end else if(ex_sub_2_whilo_o == `WriteEnable) begin
                whilo_o = `WriteEnable;
                hi_o = ex_sub_2_hi_o;
                lo_o = ex_sub_2_lo_o;
        end else if(ex_sub_1_whilo_o == `WriteEnable) begin
                whilo_o = `WriteEnable;
                hi_o = ex_sub_1_hi_o;
                lo_o = ex_sub_1_lo_o;                              
        end else begin
                whilo_o = `WriteDisable;
                hi_o = `ZeroWord;
                lo_o = `ZeroWord;   
                end                                               
    end
    
assign reg2_o = reg2_i;
assign aluop1_o = aluop1_i;    
    
    
endmodule
