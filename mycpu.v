`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 16:30:26
// Design Name: 
// Module Name: mycpu
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

module mycpu(
        input   clk,
        input   rst,
        //input[5:0]  int,      //?
        output  flush,
        //output  timer_int_o,   //??
        
        
        //与I-Cache交流
        input   stallreq_from_icache,
        input[`InstBus] inst1_from_icache,  //
        input[`InstBus] inst2_from_icache,
        input[`InstAddrBus] inst1_addr_from_icache,
        input[`InstAddrBus] inst2_addr_from_icache,  //
        input[`SIZE_OF_CORR_PACK] corr_pack0_from_cache_o,
        input[`SIZE_OF_CORR_PACK] corr_pack1_from_cache_o,
        input inst1_valid_from_icache,
        input inst2_valid_from_icache,
        output rreq_to_icache,
        output[`InstAddrBus]    raddr_to_icache,
        
        //Cache Pc Control
        input[`InstAddrBus] npc_from_cache_i,
        
        //与D-Cache交流
        input[`RegBus]  rdata_from_dcache,
        input   stallreq_from_dcache,
        output  rreq_to_dcache,
        output[`DataAddrBus]    raddr_to_dcache,
        output  wreq_to_dcache,
        output[`DataAddrBus]    waddr_to_dcache,
        output[`RegBus] wdata_to_dcache,
        output[3:0] wsel_to_dcache
             
        
          
    );
    
    wire[3:0]   stall;
    wire flush_cause;
    wire flush_to_ibuffer;
    wire stallreq_from_ex;
    wire stallreq_from_id;
    wire ibuffer_full;
    
    wire rf_we1;
    wire rf_we2;
    wire[`RegAddrBus]   rf_waddr1;
    wire[`RegAddrBus]   rf_waddr2;
    wire[`RegAddrBus]   rf_raddr1;
    wire[`RegAddrBus]   rf_raddr2;
    wire[`RegAddrBus]   rf_raddr3;
    wire[`RegAddrBus]   rf_raddr4;
    wire[`RegBus]   rf_wdata1;
    wire[`RegBus]   rf_wdata2;
    wire[`RegBus]   rf_rdata1;
    wire[`RegBus]   rf_rdata2;
    wire[`RegBus]   rf_rdata3;
    wire[`RegBus]   rf_rdata4;
    
    wire[`RegBus]   hi_i;
    wire[`RegBus]   lo_i;
    wire    we_hilo;
    wire[`RegBus]   hi_o;
    wire[`RegBus]   lo_o;
    
    wire[`SIZE_OF_CORR_PACK] inst1_bpu_corr_i;
    wire[`SIZE_OF_CORR_PACK] inst2_bpu_corr_i;
    wire[`SIZE_OF_BRANCH_INFO] branch_info_i;
    
    wire id_issue_en_i;
    wire[`InstBus] id_inst1_i;
    wire[`InstBus] id_inst2_i;
    wire[`InstAddrBus]  id_inst1_addr_i;
    wire[`InstAddrBus]  id_inst2_addr_i;
    wire[`SIZE_OF_CORR_PACK] id_inst1_bpu_corr_i;
    wire[`SIZE_OF_CORR_PACK] id_inst2_bpu_corr_i;
    wire[`RegBus]   reg31;
    
    wire is_in_delayslot_i;
    
    wire[`InstAddrBus]  id_inst1_addr_o;
    wire[`InstAddrBus]  id_inst2_addr_o;
    wire[`SIZE_OF_CORR_PACK] id_inst1_bpu_corr_o;
    wire[`SIZE_OF_CORR_PACK] id_inst2_bpu_corr_o;
    wire[`AluOpBus]          id_aluop1_o;              
    wire [`AluOpBus]         id_aluop2_o; 
    wire [`AluSelBus]         id_alusel1_o;                   
    wire [`AluSelBus]         id_alusel2_o;               
    wire  [`RegBus]            id_reg1_o;                 
    wire  [`RegBus]            id_reg2_o;                 
    wire  [`RegBus]            id_reg3_o;                 
    wire  [`RegBus]            id_reg4_o;                 
    wire [`RegAddrBus]    id_waddr1_o;                    
    wire [`RegAddrBus]    id_waddr2_o;                    
    wire                            id_we1_o;        
    wire                            id_we2_o; 
    wire[`RegBus]                   id_hi_o;
    wire[`RegBus]                   id_lo_o;       
    wire                            id_imm_fnl1_o;    
    
    wire                            id_issue_mode_o;
    wire                            id_issued_o;
    wire                            id_is_in_delayslot;
    wire                            next_inst_in_delayslot;
    
    
           
    
    // div                
    wire    signed_div;
    wire[`RegBus]   div_opdata1;
    wire[`RegBus]   div_opdata2;
    wire    div_start;
    wire[`DoubleRegBus]   div_result;
    wire    div_ready;
    
    wire[`InstAddrBus]  ex_inst1_addr_i;
    wire[`InstAddrBus]  ex_inst2_addr_i;
    wire[`SIZE_OF_CORR_PACK]  ex_inst1_bpu_corr_i;
    wire[`SIZE_OF_CORR_PACK]  ex_inst2_bpu_corr_i;
    wire[`AluOpBus]         ex_aluop1_i;     
    wire [`AluOpBus]         ex_aluop2_i; 
    wire [`AluSelBus]         ex_alusel1_i;                   
    wire [`AluSelBus]         ex_alusel2_i;               
    wire  [`RegBus]            ex_reg1_i;                 
    wire  [`RegBus]            ex_reg2_i;                 
    wire  [`RegBus]            ex_reg3_i;                 
    wire  [`RegBus]            ex_reg4_i;                 
    wire [`RegAddrBus]    ex_waddr1_i;                    
    wire [`RegAddrBus]    ex_waddr2_i;                    
    wire                            ex_we1_i;        
    wire                            ex_we2_i;       
    wire[`RegBus]           ex_hi_i;
    wire[`RegBus]           ex_lo_i;
    wire[`RegBus]           ex_imm_fnl1_i;
    wire                            ex_issue_i;
    
    wire[`InstAddrBus]  ex_inst1_addr_o;
    wire[`InstAddrBus]  ex_inst2_addr_o;
    wire[`SIZE_OF_CORR_PACK]  ex_inst1_bpu_corr_o;
    wire[`SIZE_OF_CORR_PACK]  ex_inst2_bpu_corr_o;
    
    wire [`RegAddrBus]    ex_waddr1_o;                    
    wire [`RegAddrBus]    ex_waddr2_o;  
    wire    ex_we1_o;
    wire    ex_we2_o;
    wire[`RegBus]   ex_wdata1_o;
    wire[`RegBus]   ex_wdata2_o;
    wire[`RegBus]   ex_hi_o;
    wire[`RegBus]   ex_lo_o;
    wire    ex_whilo_o;
    wire[`AluOpBus] ex_aluop1_o;
    wire[`RegBus]   ex_mem_addr_o;
    wire[`RegBus]   ex_reg2_o;
    
    wire[`InstAddrBus]  ex_npc_actual_o;
    wire ex_branch_flag_o;
    wire ex_predict_flag_o;
    wire[`SIZE_OF_BRANCH_INFO] ex_branch_info_o;
    wire ex_issue_mode_o;
    wire ex_is_in_delayslot1_o;
    wire ex_is_in_delayslot2_o;
    
    wire[`InstAddrBus]  mem_inst1_addr_i;
    wire[`InstAddrBus]  mem_inst2_addr_i;
    wire[`RegAddrBus]   mem_waddr1_i;
    wire[`RegAddrBus]   mem_waddr2_i;
    wire    mem_we1_i;
    wire    mem_we2_i;
    wire[`RegBus]   mem_wdata1_i;
    wire[`RegBus]   mem_wdata2_i;
    wire [`RegBus]  mem_hi_i;
    wire[`RegBus]   mem_lo_i;
    wire    mem_whilo_i;
    wire[`AluOpBus] mem_aluop1_i;
    wire[`RegBus]   mem_mem_addr_i;
    wire[`RegBus]   mem_reg2_i;
    
    wire[`InstAddrBus]  mem_inst1_addr_o;
    wire[`InstAddrBus]  mem_inst2_addr_o;
    wire[`RegAddrBus]   mem_waddr1_o;
    wire[`RegAddrBus]   mem_waddr2_o;
    wire    mem_we1_o;
    wire    mem_we2_o;
    wire[`RegBus]   mem_wdata1_o;
    wire[`RegBus]   mem_wdata2_o;
    wire[`RegBus]   mem_hi_o;
    wire[`RegBus]   mem_lo_o;
    wire    mem_whilo_o;
    wire[`RegBus]   mem_mem_addr_o;      
    wire mem_is_in_delayslot1_o;
    wire mem_is_in_delayslot2_o;
    
    
    wire[`RegAddrBus]        commit_waddr1_o;
    wire[`RegAddrBus]        commit_waddr2_o;  
    wire                     commit_we1_o;
    wire                     commit_we2_o;
    wire[`RegBus]           commit_wdata1_o;
    wire[`RegBus]           commit_wdata2_o;
    
    ctrl u_ctrl(
        .rst(rst),
        .stallreq_from_ex(stallreq_from_ex),
        .stallreq_from_id(stallreq_from_id),
        .predict_flag(ex_predict_flag_o),
        .stall(stall),
        .flush(flush),
        .flush_cause(flush_cause),
       // .epc_o(epc_o),
        .flush_to_ibuffer(flush_to_ibuffer)
        );
        
              
           
    pc_reg  u_pc_reg(       //need to be fixed
        .clk(clk),       
        .rst(rst),
        .stall(stall),
        .flush(flush),
        .flush_cause(flush_cause),
        .stallreq_from_icache(stallreq_from_icache),
        .branch_flag(ex_branch_flag_o),
        .ibuffer_full(ibuffer_full),
        .pc(raddr_to_icache),
        .rreq_to_icache(rreq_to_icache)
        //.issue(id_issue_mode_o)
        
        );   
           
    regfile  u_regfile(
        .clk(clk),
        .rst(rst),
        .we1(rf_we1),
        .waddr1(rf_waddr1),
        .wdata1(rf_wdata1),
         .we2(rf_we2),
        .waddr2(rf_waddr2),
        .wdata2(rf_wdata2),
        .raddr1(rf_raddr1),
        .rdata1(rf_rdata1),
        .raddr2(rf_raddr2),
        .rdata2(rf_rdata2),
         .raddr3(rf_raddr3),
        .rdata3(rf_rdata3),                      
        .raddr4(rf_raddr4),
        .rdata4(rf_rdata4),
        .reg31(reg31)
            
     );
     
     hilo_reg  u_hiloreg(
        .clk(clk),
        .rst(rst),
        .we(we_hilo),
        .hi_i(hi_i),
        .lo_i(lo_i),
        .hi_o(hi_o),
        .lo_o(lo_o)
        );
     
     
 
    Instbuffer  u_buffer(
        .clk(clk),
        .rst(rst),             //??????????????????????/
        .flush(flush_to_ibuffer),
        .issue_mode_i(id_issue_mode_o),
        .issue_i(id_issued_o),
        .issue_inst1_o(id_inst1_i),
        .issue_inst2_o(id_inst2_i),
        .issue_inst1_addr_o(id_inst1_addr_i),
        .issue_inst2_addr_o(id_inst2_addr_i),
        //.issue_bpu_corr1_o(id_inst1_bpu_corr_i),
        //.issue_bpu_corr2_o(id_inst2_bpu_corr_i),
        //.issue_ok_o(id_issue_en_i),
        .ICache_inst1_i(inst1_from_icache),
        .ICache_inst2_i(inst2_from_icache),
        .ICache_inst1_addr_i(inst1_addr_from_icache),
        .ICache_inst2_addr_i(inst2_addr_from_icache),
        //.bpu_corr1_i(corr_pack0_from_cache_o),
        //.bpu_corr2_i(corr_pack1_from_cache_o),
        .ICache_inst1_valid_o(1),//(inst1_valid_from_icache), //!!!!!!!!!!!!改了
        .ICache_inst2_valid_o(1),//(inst2_valid_from_icache),
	    .buffer_full_o(ibuffer_full) 
            
             
        );
 
 
    id_top  u_id_top(
        .rst(rst),
        .stallreq_from_ex(stallreq_from_ex),
        .stallreq_from_dcache(stallreq_from_dcache),
        .inst1_i(id_inst1_i),
        .inst2_i(id_inst2_i),
        .inst1_addr_i(id_inst1_addr_i),
        .inst2_addr_i(id_inst2_addr_i), 
        .inst1_bpu_corr_i(id_inst1_bpu_corr_i),
        .inst2_bpu_corr_i(id_inst2_bpu_corr_i),   
        .issue_en_i(id_issue_en_i),
        .is_in_delayslot_i(id_issue_en_i),
        .reg1_data_i(rf_rdata1),
        .reg2_data_i(rf_rdata2),
        .reg3_data_i(rf_rdata3),
        .reg4_data_i(rf_rdata4),
        .ex_waddr1_i(ex_waddr1_o),
        .ex_waddr2_i(ex_waddr2_o),
        .ex_we1_i(ex_we1_o),
        .ex_we2_i(ex_we2_o),        
        .ex_wdata1_i(ex_wdata1_o),
        .ex_wdata2_i(ex_wdata2_o),
        .mem_waddr1_i(mem_waddr1_o),
        .mem_waddr2_i(mem_waddr2_o),
        .mem_we1_i(mem_we1_o),
        .mem_we2_i(mem_we2_o),        
        .mem_wdata1_i(mem_wdata1_o),
        .mem_wdata2_i(mem_wdata2_o),
        .commit_waddr1_i(rf_waddr1),
        .commit_waddr2_i(rf_waddr2),
        .commit_we1_i(rf_we1),
        .commit_we2_i(rf_we2),
        .commit_wdata1_i(rf_wdata1),
        .commit_wdata2_i(rf_wdata2),

        .ex_aluop1_i(ex_aluop1_o),
        .hi_i(hi_o),
        .lo_i(lo_o),
        .ex_hi_i(ex_hi_o),
        .ex_lo_i(ex_lo_o),
        .ex_whilo_i(ex_whilo_o), 
        .mem_hi_i(mem_hi_o),
        .mem_lo_i(mem_lo_o),
        .mem_whilo_i(mem_whilo_o),        
        .commit_hi_i(hi_i),
        .commit_lo_i(lo_i),
        .commit_whilo_i(we_hilo),  
        .inst1_addr_o(id_inst1_addr_o),
        .inst2_addr_o(id_inst2_addr_o),
        .inst1_bpu_corr_o(id_inst1_bpu_corr_o),
        .inst2_bpu_corr_o(id_inst2_bpu_corr_o), 
        .reg1_raddr_o(rf_raddr1),                   
        .reg2_raddr_o(rf_raddr2),                   
        .reg3_raddr_o(rf_raddr3),                   
        .reg4_raddr_o(rf_raddr4),                                          
        .aluop1_o(id_aluop1_o),                   
        .alusel1_o(id_alusel1_o),                  
        .aluop2_o(id_aluop2_o),                   
        .alusel2_o(id_alusel2_o),                  
        .reg1_o(id_reg1_o),                  
        .reg2_o(id_reg2_o),                  
        .reg3_o(id_reg3_o),                  
        .reg4_o(id_reg4_o),                  
        .waddr1_o(id_waddr1_o),                     
        .waddr2_o(id_waddr2_o),                     
        .we1_o(id_we1_o),         
        .we2_o(id_we2_o),  
        .hi_o(id_hi_o),
        .lo_o(id_lo_o),       
        .is_in_delayslot1_o(id_is_in_delayslot1_o),
        .is_in_delayslot2_o(id_is_in_delayslot2_o),
        .imm_ex_o(id_imm_fnl1_o),
        .ninst_in_delayslot(next_inst_in_delayslot),
                                              
                                
        .issue_o(id_issue_mode_o),
        .issued_o(id_issued_o),
        .stallreq_from_id(stallreq_from_id)
        );          
        
        
        id_ex u_id_ex(
            .clk(clk),
            .rst(rst),
            .flush(flush),
            .flush_cause(flush_cause),
            .stall(stall),
            . inst1_addr_i(id_inst1_addr_o),                    
            . inst2_addr_i(id_inst2_addr_o),  
            . inst1_bpu_corr_i(id_inst1_bpu_corr_o),
            . inst2_bpu_corr_i(id_inst2_bpu_corr_o),                     
            . aluop1_i(id_aluop1_o),                      
            . alusel1_i(id_alusel1_o),                    
            . aluop2_i(id_aluop2_o),                      
            . alusel2_i(id_alusel2_o),                    
            . reg1_i(id_reg1_o),                      
            . reg2_i(id_reg2_o),                      
            . reg3_i(id_reg3_o),                      
            . reg4_i(id_reg4_o),                      
            . waddr1_i(id_waddr1_o),                         
            . waddr2_i(id_waddr2_o),                         
            . we1_i(id_we1_o),             
            . we2_i(id_we2_o),    
            . hi_i(id_hi_o),
            . lo_i(id_lo_o),
                     
            . imm_fnl1_i(id_imm_fnl1_o),         
            . issue_i(id_issue_mode_o),           
            . ex_issue_mode_i(ex_issue_mode_o),
            . next_inst_in_delayslot_i(next_inst_in_delayslot),
            . is_in_delayslot1_i(id_is_in_delayslot1_o),
            . is_in_delayslot2_i(id_is_in_delayslot2_o),
            . inst1_addr_o(ex_inst1_addr_i),                    
            . inst2_addr_o(ex_inst2_addr_i),                         
            .  aluop1_o(ex_aluop1_i),                       
            .   alusel1_o(ex_alusel1_i),                     
            .  aluop2_o(ex_aluop2_i),                       
            .   alusel2_o(ex_alusel2_i),                     
            .     reg1_o(ex_reg1_i),                      
            .     reg2_o(ex_reg2_i),                      
            .     reg3_o(ex_reg3_i),                      
            .     reg4_o(ex_reg4_i),                      
            .    waddr1_o(ex_waddr1_i),                            
            .    waddr2_o(ex_waddr2_i),                            
            .     we1_o(ex_we1_i),               
            .     we2_o(ex_we2_i),               
            .   hi_o(ex_hi_i),
            .   lo_o(ex_lo_i),
            .     imm_fnl1_o(ex_imm_fnl1_i),          
            .     issue_o(ex_issue_i),
            .   next_inst_in_delayslot_o(ex_is_in_delayslot_i),      //??  
            .   is_in_delayslot1_o(ex_is_in_delayslot1_i),         
            .   is_in_delayslot2_o(ex_is_in_delayslot2_i)         
                 
                 );              
                
        div  u_div(
            .clk(clk),
            .rst(rst),
            .signed_div_i(signed_div),
            .opdata1_i(div_opdata1),
            .opdata2_i(div_opdata2),
            .start_i(div_start),
            .annul_i(flush==`Flush && flush_cause == `Exception),            
            .result_o(div_result),
            .ready_o(div_ready)
            
            );
        
        
ex_top  u_ex_top(
            .rst(rst),
            . inst1_addr_i(ex_inst1_addr_i),                    
            . inst2_addr_i(ex_inst2_addr_i),  
            . inst1_bpu_corr_i(ex_inst1_bpu_corr_i),
            . inst2_bpu_corr_i(ex_inst2_bpu_corr_i),                               
            . aluop1_i(ex_aluop1_i),                      
            . alusel1_i(ex_alusel1_i),                    
            . aluop2_i(ex_aluop2_i),                      
            . alusel2_i(ex_alusel2_i),                    
            . reg1_i(ex_reg1_i),                      
            . reg2_i(ex_reg2_i),                      
            . reg3_i(ex_reg3_i),                      
            . reg4_i(ex_reg4_i),                      
            . waddr1_i(ex_waddr1_i),                         
            . waddr2_i(ex_waddr2_i),                         
            . we1_i(ex_we1_i),             
            . we2_i(ex_we2_i),             
            
            .div_result_i(div_result),
            .div_ready_i(div_ready),
            .hi_i(ex_hi_i),
            .lo_i(ex_lo_i),
            
            . imm_fnl1_i(ex_imm_fnl1_i),         
            . issue_i(ex_issue_i),    
            . is_in_delayslot1_i(ex_is_in_delayslot1_i),
            . is_in_delayslot2_i(ex_is_in_delayslot2_i),       
            . inst1_addr_o(ex_inst1_addr_o),                    
            . inst2_addr_o(ex_inst2_addr_o),        
            . inst1_bpu_corr_o(ex_inst1_bpu_corr_o),
            . inst2_bpu_corr_o(ex_inst2_bpu_corr_o),                                
            .    waddr1_o(ex_waddr1_o),                            
            .    waddr2_o(ex_waddr2_o),                            
            .     we1_o(ex_we1_o),               
            .     we2_o(ex_we2_o),
            .wdata1_o(ex_wdata1_o),
            .wdata2_o(ex_wdata2_o),
            .hi_o(ex_hi_o),
            .lo_o(ex_lo_o),
            .whilo_o(ex_whilo_o),
            .issue_mode(ex_issue_mode_o),
            
            .div_opdata1_o(div_opdata1),
            .div_opdata2_o(div_opdata2),
            .div_start_o(div_start),
            .signed_div_o(signed_div),
            .aluop1_o(ex_aluop1_o),
            .mem_addr_o(ex_mem_addr_o),
            .reg2_o(ex_reg2_o),
           // .mem_raddr_o(raddr_to_dcache),
            .stallreq(stallreq_from_ex)            
            
    );                    
        
        ex_mem  u_ex_mem(
            .clk(clk),
            .rst(rst),
            .flush(flush),
            .flush_cause(flush_cause),
            .stall(stall),
            .inst1_addr_i(ex_inst1_addr_o),
            .inst2_addr_i(ex_inst2_addr_o),
            . inst1_bpu_corr_i(ex_inst1_bpu_corr_o),
            . inst2_bpu_corr_i(ex_inst2_bpu_corr_o),                 
            
            .waddr1_i(ex_waddr1_i),
            .waddr2_i(ex_waddr2_i),
            .we1_i(ex_we1_o),
            .we2_i(ex_we2_o),
            .wdata1_i(ex_wdata1_o),
            .wdata2_i(ex_wdata2_o),
            .hi_i(ex_hi_o),
            .lo_i(ex_lo_o),
            .whilo_i(ex_whilo_o),            
            .aluop1_i(ex_aluop1_o),
            .mem_addr_i(ex_mem_addr_o),
            .reg2_i(ex_reg2_o),
            .is_in_delayslot1_i(ex_is_in_delayslot1_o),
            .is_in_delayslot2_i(ex_is_in_delayslot2_o),
            . inst1_addr_o(mem_inst1_addr_i),
            . inst2_addr_o(mem_inst2_addr_i),
            . inst1_bpu_corr_o(mem_inst1_bpu_corr_i),
            . inst2_bpu_corr_o(mem_inst2_bpu_corr_i), 
            .branch_info_o(branch_info_i),
            .waddr1_o(mem_waddr1_i),
            .waddr2_o(mem_waddr2_i),
            .we1_o(mem_we1_i),
            .we2_o(mem_we2_i),
            .wdata1_o(mem_wdata1_i),
            .wdata2_o(mem_wdata2_i),
            .hi_o(mem_hi_i),
            .lo_o(mem_lo_i),
            .whilo_o(mem_whilo_i),
            .aluop1_o(mem_aluop1_i),
            .mem_addr_o(mem_mem_addr_i),
            .reg2_o(mem_reg2_i),        
            .is_in_delayslot1_o(mem_is_in_delayslot1_i),
            .is_in_delayslot2_o(mem_is_in_delayslot2_i)
               
        
    );
 
    mem  u_mem(
        .rst(rst),
        .mem_data_i(rdata_from_dcache),
        .inst1_addr_i(mem_inst1_addr_i),
        .inst2_addr_i(mem_inst2_addr_i),
        .waddr1_i(mem_waddr1_i),
        .waddr2_i(mem_waddr2_i),
        .we1_i(mem_we1_i),
        .we2_i(mem_we2_i),
        .wdata1_i(mem_wdata1_i),
        .wdata2_i(mem_wdata2_i),
        .hi_i(mem_hi_i),
        .lo_i(mem_lo_i),
        .whilo_i(mem_whilo_i),
        .aluop1_i(mem_aluop1_i),
        .mem_addr_i(mem_mem_addr_i),
        .reg2_i(mem_reg2_i),
        
        .is_in_delayslot1_i(mem_is_in_delayslot1_i),
        .is_in_delayslot2_i(mem_is_in_delayslot2_i),
        
        .inst1_addr_o(mem_inst1_addr_o),
        .inst2_addr_o(mem_inst2_addr_o),
        .waddr1_o(mem_waddr1_o),
        .waddr2_o(mem_waddr2_o),
        .we1_o(mem_we1_o),
        .we2_o(mem_we2_o),
        .wdata1_o(mem_wdata1_o),
        .wdata2_o(mem_wdata2_o),
        .hi_o(mem_hi_o),
        .lo_o(mem_lo_o),
        .whilo_o(mem_whilo_o),

        .mem_addr_o(mem_mem_addr_o),
 
        .is_in_delayslot1_o(mem_is_in_delayslot1_o),
        .is_in_delayslot2_o(mem_is_in_delayslot2_o)
 );
 
    commit  u_commit(
        .clk(clk),
        .rst(rst),
        .flush(flush),
        .flush_cause(flush_cause),
        .stall(stall),
        .pc_i(mem_inst1_addr_o),
        .waddr1_i(mem_waddr1_o),
        .waddr2_i(mem_waddr2_o),
        .we1_i(mem_we1_o),
        .we2_i(mem_we2_o),
        .wdata1_i(mem_wdata1_o),
        .wdata2_i(mem_wdata2_o),
        .hi_i(mem_hi_o),
        .lo_i(mem_lo_o),
        .whilo_i(mem_whilo_o),
        
        .pc_o(commit_pc_o),
        .waddr1_o(rf_waddr1),
        .waddr2_o(rf_waddr2),
        .we1_o(rf_we1),
        .we2_o(rf_we2),
        .wdata1_o(rf_wdata1),
        .wdata2_o(rf_wdata2),
        .hi_o(hi_i),
        .lo_o(lo_i),
        .whilo_o(we_hilo)
        
        
        );
        
 
 
    
endmodule
