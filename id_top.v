`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 17:05:06
// Design Name: 
// Module Name: id_top
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

module id_top(
        
        input rst,
        
        input[`InstBus]     inst1_i,
        input[`InstBus]     inst2_i,
        input[`InstAddrBus]     inst1_addr_i,
        input[`InstAddrBus]     inst2_addr_i,
        
        input[`RegBus]      reg1_data_i, 
        input[`RegBus]      reg2_data_i, 
        input[`RegBus]      reg3_data_i, 
        input[`RegBus]      reg4_data_i, 
        

        
        input[`RegAddrBus]      ex_waddr1_i,
        input[`RegAddrBus]      ex_waddr2_i,
        input                   ex_we1_i,
        input                   ex_we2_i,
        input[`RegBus]          ex_wdata1_i,
        input[`RegBus]          ex_wdata2_i,
        input[`RegAddrBus]      mem_waddr1_i,
        input[`RegAddrBus]      mem_waddr2_i,
        input                   mem_we1_i,
        input                   mem_we2_i,
        input[`RegBus]          mem_wdata1_i,
        input[`RegBus]          mem_wdata2_i,
        input[`RegAddrBus]          commit_waddr1_i,
        input[`RegAddrBus]          commit_waddr2_i,
        input                       commit_we1_i,
        input                       commit_we2_i,
        input[`RegBus]               commit_wdata1_i,
        input[`RegBus]               commit_wdata2_i,
        
        input[`AluOpBus]        ex_aluop1_i,
        
        input[`RegBus]          hi_i,
        input[`RegBus]          lo_i,
        
        input[`RegBus]          ex_hi_i,
        input[`RegBus]          ex_lo_i,
        input                   ex_whilo_i,
              
        input[`RegBus]          mem_hi_i,
        input[`RegBus]          mem_lo_i,
        input                   mem_whilo_i,
        
        input[`RegBus]          commit_hi_i,
        input[`RegBus]          commit_lo_i,
        input                   commit_whilo_i,
        
        output[`InstAddrBus]    inst1_addr_o,
        output[`InstAddrBus]    inst2_addr_o,
        
        
        output[`RegAddrBus]     reg1_raddr_o,
        output[`RegAddrBus]     reg2_raddr_o,
        output[`RegAddrBus]     reg3_raddr_o,
        output[`RegAddrBus]     reg4_raddr_o,
        
        
        output[`AluOpBus]           aluop1_o,
        output[`AluOpBus]           alusel1_o,
        output[`AluOpBus]           aluop2_o,
        output[`AluOpBus]           alusel2_o,
        output[`RegBus]                reg1_o, 
        output[`RegBus]                reg2_o,
        output[`RegBus]                reg3_o,
        output[`RegBus]                reg4_o,
        output[`RegAddrBus]       waddr1_o,
        output[`RegAddrBus]       waddr2_o,
        output                                   we1_o,
        output                                   we2_o,
        
        output  [`RegBus]               imm_ex_o,
        
        output  reg[`RegBus]            hi_o,
        output  reg[`RegBus]            lo_o,
       
        output reg                             issue_o,
        output  reg                             issued_o,
        output  reg                     stallreq_from_id
    );
    
    wire[`AluOpBus]    id_sub_2_aluop_o;
    wire[`AluSelBus]    id_sub_2_alusel_o;    
    wire[`RegAddrBus]   id_sub_2_waddr_o;
    wire    id_sub_2_we_o;
    wire[31:0]  id_sub_2_exception_type;
    wire[`RegBus]   id_sub_2_reg1_o;
    wire[`RegBus]   id_sub_2_reg2_o;
    reg[`AluOpBus]  id_aluop2_o;
    reg[`AluOpBus]  id_alusel2_o;
    reg[`RegAddrBus]    id_waddr2_o;
    reg     id_we2_o;
    reg[31:0]   id_exception_type2_o;
    reg[`RegBus]    id_reg3_o;
    reg[`RegBus]    id_reg4_o;
    
    reg reg3_raw_dependency;
    reg reg4_raw_dependency;
    reg hilo_raw_dependency;
    wire  reg12_load_dependency;
    wire  reg34_load_dependency;
    wire  load_dependency;
    
    wire hilo_re1,hilo_re2,hilo_we1,hilo_we2;
    wire reg3_read_o;
    wire reg4_read_o;
    
    assign reg1_raddr_o = (rst==`RstEnable) ? `NOPRegAddr : inst1_i[25:21];
    assign reg2_raddr_o = (rst==`RstEnable) ? `NOPRegAddr : inst1_i[20:16];
    assign reg3_raddr_o = (rst==`RstEnable) ? `NOPRegAddr : inst2_i[25:21];
    assign reg4_raddr_o = (rst==`RstEnable) ? `NOPRegAddr : inst2_i[20:16]; 
    
    id  u_id1(
        .rst(rst),
        .pc_i(inst1_addr_i),
        .inst_i(inst1_i),
        
        .reg1_data_i(reg1_data_i),
        .reg2_data_i(reg2_data_i),
        
        .ex_waddr1_i(ex_waddr1_i),
        .ex_waddr2_i(ex_waddr2_i),
        .ex_we1_i(ex_we1_i),
        .ex_we2_i(ex_we2_i),
        .ex_wdata1_i(ex_wdata1_i),
        .ex_wdata2_i(ex_wdata2_i),
        .mem_waddr1_i(mem_waddr1_i),
        .mem_waddr2_i(mem_waddr2_i),
        .mem_we1_i(mem_we1_i),
        .mem_we2_i(mem_we2_i),
        .mem_wdata1_i(mem_wdata1_i),
        .mem_wdata2_i(mem_wdata2_i),
        
        
        .aluop_o(aluop1_o),
        .alusel_o(alusel1_o),
        .reg1_o(reg1_o),
        .reg2_o(reg2_o),
        .reg1_read_o(),
        .reg2_read_o(),
        .waddr_o(waddr1_o),
        .we_o(we1_o),
        
        
        .imm_fnl_o(imm_ex_o)      //  ??
        
        );    
        
    id   u_id2(
    
        .rst(rst),
        .pc_i(inst2_addr_i),
        .inst_i(inst2_i),
        
        .reg1_data_i(reg3_data_i),
        .reg2_data_i(reg4_data_i),
        
        .ex_waddr1_i(ex_waddr1_i),
        .ex_waddr2_i(ex_waddr2_i),
        .ex_we1_i(ex_we1_i),
        .ex_we2_i(ex_we2_i),
        .ex_wdata1_i(ex_wdata1_i),
        .ex_wdata2_i(ex_wdata2_i),
        .mem_waddr1_i(mem_waddr1_i),
        .mem_waddr2_i(mem_waddr2_i),
        .mem_we1_i(mem_we1_i),
        .mem_we2_i(mem_we2_i),
        .mem_wdata1_i(mem_wdata1_i),
        .mem_wdata2_i(mem_wdata2_i),
        
        
        .aluop_o(id_sub_2_aluop_o),
        .alusel_o(id_sub_2_alusel_o),
        .reg1_o(id_sub_2_reg1_o),
        .reg2_o(id_sub_2_reg2_o),
        .reg1_read_o(reg3_read_o),
        .reg2_read_o(reg4_read_o),
        .waddr_o(id_sub_2_waddr_o),
        .we_o(id_sub_2_we_o),
        
        .imm_fnl_o()
        
        );
           
always @(*) begin
    if( issue_o == `SingleIssue)    begin
        id_aluop2_o = `EXE_NOP_OP;
        id_alusel2_o = `EXE_RES_NOP;
        id_reg3_o = `ZeroWord;
        id_reg4_o = `ZeroWord;
        id_waddr2_o = `NOPRegAddr;
        id_we2_o = `WriteDisable;
        id_exception_type2_o = `ZeroWord;
    end else begin
        id_aluop2_o = id_sub_2_aluop_o;
        id_alusel2_o = id_sub_2_alusel_o;
        id_reg3_o = id_sub_2_reg1_o;
        id_reg4_o = id_sub_2_reg2_o;
        id_waddr2_o =  id_sub_2_waddr_o;
        id_we2_o = id_sub_2_we_o;
        id_exception_type2_o = id_sub_2_exception_type;
       end     
 end
 
 assign aluop2_o = id_aluop2_o;
 assign alusel2_o = id_alusel2_o;
 assign reg3_o = id_reg3_o;
 assign reg4_o = id_reg4_o;
 assign waddr2_o = id_waddr2_o;
 assign we2_o = id_we2_o;
 
 assign inst1_addr_o = inst1_addr_i;
 assign inst2_addr_o = (issue_o==`SingleIssue) ? `ZeroWord : inst2_addr_i;
 
 
 always @(*) begin
    if(rst == `RstEnable)  {hi_o,lo_o} = {`ZeroWord,`ZeroWord};
    else if(ex_whilo_i == `WriteEnable) {hi_o,lo_o} = {ex_hi_i,ex_lo_i};
    else if(mem_whilo_i == `WriteEnable) {hi_o,lo_o} = {mem_hi_i,mem_lo_i};
    else if(commit_whilo_i == `WriteEnable) {hi_o,lo_o} = {commit_hi_i,commit_lo_i};
    else    {hi_o,lo_o} = {hi_i,lo_i};
end    
 
 //当第二条指令读rs寄存器同时第一条指令要写入rs寄存器时，产生RAW数据相关，改为单发射
 always @(*) begin
    if(rst == `RstEnable)   reg3_raw_dependency = `RAWIndependent;
    else if(reg3_read_o == `ReadEnable && we1_o == `WriteEnable && waddr1_o == inst2_i[25:21]) reg3_raw_dependency = `RAWDependent; 
    else reg3_raw_dependency = `RAWIndependent;
end
//当第二条指令读rt寄存器同时第一条指令要写入rt寄存器时，产生RAW数据相关，改为单发射   增加了对初始情况的判断。。？
 always @(*) begin
    if(rst == `RstEnable)   reg4_raw_dependency = `RAWIndependent;
    else if(reg4_read_o == `ReadEnable && we1_o == `WriteEnable && waddr1_o == inst2_i[20:16] && inst2_i != 0) reg4_raw_dependency = `RAWDependent;
    else reg4_raw_dependency = `RAWIndependent;
end
 
 always @(*) begin
    if(rst == `RstEnable)   hilo_raw_dependency = `RAWIndependent;
    else if(hilo_we1 == `WriteEnable && hilo_re2 == `ReadEnable) hilo_raw_dependency = `RAWDependent;
    else hilo_raw_dependency = `RAWIndependent;
end
 //对双发还是单发的逻辑判断
 always @(*) begin      //load??
    if(rst == `RstEnable)   issue_o = `DualIssue;
    else if(reg3_raw_dependency == `RAWDependent || reg4_raw_dependency == `RAWDependent|| hilo_raw_dependency == `RAWDependent) issue_o = `SingleIssue;
    else    issue_o = `DualIssue;
end
 
always @(*) begin   //缺少其他逻辑判断，比如延迟槽
    if(rst == `RstEnable)  begin
        issued_o = 1'b0;
        stallreq_from_id = `NoStop;
    end else begin      //！！！改过了！！需要改回来
        issued_o = 1'b1;
        stallreq_from_id = `NoStop;
        end     
end 
 
    
endmodule
