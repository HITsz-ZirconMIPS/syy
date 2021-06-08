`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 16:28:03
// Design Name: 
// Module Name: id
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

module id(
    input rst,
    input [`InstAddrBus]    pc_i,
    input [`InstBus]              inst_i,
    
    input[`RegBus]              reg1_data_i,
    input[`RegBus]              reg2_data_i,
    //shu ju xiang guan
    
    input[`RegAddrBus]      ex_waddr1_i,
    input[`RegAddrBus]      ex_waddr2_i,
    input                                  ex_we1_i,
    input                                  ex_we2_i,
    input[`RegBus]               ex_wdata1_i,
    input[`RegBus]               ex_wdata2_i,
    input[`RegAddrBus]      mem_waddr1_i,
    input[`RegAddrBus]      mem_waddr2_i,
    input                                  mem_we1_i,
    input                                  mem_we2_i,
    input[`RegBus]               mem_wdata1_i,
    input[`RegBus]               mem_wdata2_i,
    input[`RegAddrBus]          commit_waddr1_i,
    input[`RegAddrBus]          commit_waddr2_i,
    input                       commit_we1_i,
    input                       commit_we2_i,
    input[`RegBus]               commit_wdata1_i,
    input[`RegBus]               commit_wdata2_i,
    
    
    //fang cun xiang guan   
       
    //output reg[`RegAddrBus] reg1_addr_o,
    //output reg[`RegAddrBus] reg2_addr_o,

   
    output reg[`AluOpBus]   aluop_o, 
    output reg[`AluSelBus]  alusel_o,
    output reg[`RegBus]     reg1_o,
    output reg[`RegBus]     reg2_o,
    output reg                       reg1_read_o,
    output reg                       reg2_read_o,
    output reg[`RegAddrBus]     waddr_o,
    output reg                      we_o,
    
    output  reg             hilo_re,
    output  reg             hilo_we,
    //生成的最终立即数    
    output[`RegBus]         imm_fnl_o 
        
    );
    
    
    reg[`RegAddrBus]    reg1_raddr_o;
    reg[`RegAddrBus]    reg2_raddr_o;
    wire [5:0]   op = inst_i[31:26];
    wire [5:0]   rs = inst_i[25:21];
    wire [5:0]   rt = inst_i[20:16];
    wire [4:0]   rd = inst_i[15:11];
    wire [4:0]   shamt = inst_i[10:6];
    wire [5:0]   funct = inst_i[5:0];
    wire [15:0]  imm = inst_i[15:0];
    
    
    reg[`RegBus]    imm_ex;
    
    reg instvalid;
    
    always@(*) begin
        if(rst == `RstEnable)   begin
            aluop_o = `EXE_NOP_OP;
            alusel_o = `EXE_RES_NOP;
            waddr_o = `NOPRegAddr;
            we_o = `WriteDisable;
            instvalid = `InstValid;
            reg1_read_o = `ReadDisable;
            reg2_read_o = `ReadDisable;
            reg1_raddr_o = `NOPRegAddr;
            reg2_raddr_o = `NOPRegAddr;
            imm_ex = 32'h0;
            hilo_re = `ReadDisable;
            hilo_we = `ReadDisable;
            
        end else begin    
            aluop_o = `EXE_NOP_OP;
            alusel_o = `EXE_RES_NOP;
            waddr_o = rd;
            we_o = `WriteDisable;
            instvalid = `InstValid;
            reg1_read_o = `ReadDisable;
            reg2_read_o = `ReadDisable;
            reg1_raddr_o = rs;
            reg2_raddr_o = rt;
            imm_ex = `ZeroWord;
            hilo_re = `ReadDisable;
            hilo_we = `ReadDisable;
            
            
        case(op)
            `EXE_SPECIAL_INST:  begin
                if(shamt == 5'b00000)begin
                    case(funct)
                        `EXE_OR:begin      //orָ��
                                we_o = `WriteEnable;
                                aluop_o = `EXE_OR_OP;
                                alusel_o = `EXE_RES_LOGIC;
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                                instvalid = `InstValid;
                            end 
                            `EXE_AND:begin     //ANDָ��
                                we_o = `WriteEnable;
                                aluop_o = `EXE_AND_OP;
                                alusel_o = `EXE_RES_LOGIC;
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                                instvalid =`InstValid; 
                            end
                            `EXE_XOR:begin
                                we_o = `WriteEnable;
                                aluop_o =`EXE_XOR_OP;
                                alusel_o =`EXE_RES_LOGIC;
                                reg1_read_o =1'b1;
                                reg2_read_o =1'b1;
                                instvalid =`InstValid;
                            end
                            `EXE_NOR:begin              //norָ��������
                                we_o =`WriteEnable;
                                aluop_o =`EXE_NOR_OP;
                                alusel_o =`EXE_RES_LOGIC;
                                reg1_read_o =1'b1;
                                reg2_read_o =1'b1;
                                instvalid =`InstValid;
                            end
                            `EXE_SLLV:begin         //�߼�����
                                we_o =`WriteEnable;
                                aluop_o =`EXE_SLL_OP;
                                alusel_o =`EXE_RES_SHIFT;
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                                instvalid =`InstValid;
                            end
                            `EXE_SRLV:begin
                                we_o =`WriteEnable;
                                aluop_o =`EXE_SRL_OP;
                                alusel_o =`EXE_RES_SHIFT;
                                reg1_read_o =1'b1;
                                reg2_read_o =1'b1;
                                instvalid =`InstValid;
                            end
                            `EXE_SRAV:begin
                                we_o =`WriteEnable;
                                aluop_o =`EXE_SRA_OP;
                                alusel_o =`EXE_RES_SHIFT;
                                reg1_read_o =1'b1;
                                reg2_read_o =1'b1;
                                instvalid =`InstValid;
                            end
                            /*`EXE_SYNC:begin             //keep it  or not ?
                                we_o =`WriteDisable;
                                aluop_o =`EXE_NOP_OP;
                                alusel_o =`EXE_RES_NOP;
                                reg1_read_o =1'b0;
                                reg2_read_o =1'b1;
                                instvalid =`InstValid;
                            end
                            */
                            `EXE_MFHI: begin
                                we_o = `WriteEnable;
                                aluop_o = `EXE_MFHI_OP;
                                alusel_o = `EXE_RES_MOVE;
                                reg1_read_o = 1'b0;
                                reg2_read_o = 1'b0;
                                instvalid = `InstValid;
                                hilo_re = `ReadEnable;
                             end
                             
                            `EXE_MFLO: begin
                                we_o = `WriteEnable;
                                aluop_o = `EXE_MFLO_OP;
                                alusel_o = `EXE_RES_MOVE;
                                reg1_read_o = 1'b0;
                                reg2_read_o = 1'b0;
                                instvalid = `InstValid;
                                hilo_re = `ReadEnable;
                             end
                             
                             `EXE_MTHI: begin
                                we_o = `WriteDisable;
                                aluop_o = `EXE_MTHI_OP;
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b0;
                                instvalid = `InstValid;
                                hilo_we = `ReadEnable;
                             end
                             
                             `EXE_MTLO: begin
                                we_o = `WriteEnable;
                                aluop_o = `EXE_MTLO_OP;
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b0;
                                instvalid = `InstValid;
                                hilo_we = `ReadEnable;
                             end
                             
                            
                            `EXE_SLT:begin
                                we_o = `WriteEnable;
                                aluop_o = `EXE_SLT_OP;
                                alusel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                                instvalid = `InstValid;
                            end
                            `EXE_SLTU:begin
                                we_o = `WriteEnable;
                                aluop_o = `EXE_SLTU_OP;
                                alusel_o = `EXE_RES_ARITHMETIC;
                                reg1_read_o = 1'b1;
                                reg2_read_o = 1'b1;
                                instvalid = `InstValid;
                            end
                            `EXE_ADD:begin
                                we_o = `WriteEnable;
                                aluop_o =`EXE_ADD_OP;
                                alusel_o =`EXE_RES_ARITHMETIC;
                                reg1_read_o =1'b1;
                                reg2_read_o =1'b1;
                                instvalid =`InstValid;
                            end
                            `EXE_ADDU:begin
                                we_o = `WriteEnable;
                                aluop_o =`EXE_ADDU_OP;
                                alusel_o =`EXE_RES_ARITHMETIC;
                                reg1_read_o =1'b1;
                                reg2_read_o =1'b1;
                                instvalid =`InstValid;
                            end
                            `EXE_SUB:begin
                                we_o = `WriteEnable;
                                aluop_o =`EXE_SUB_OP;
                                alusel_o =`EXE_RES_ARITHMETIC;
                                reg1_read_o =1'b1;
                                reg2_read_o =1'b1;
                                instvalid =`InstValid;
                            end
                            `EXE_SUBU:begin
                                we_o = `WriteEnable;
                                aluop_o =`EXE_SUBU_OP;
                                alusel_o =`EXE_RES_ARITHMETIC;
                                reg1_read_o =1'b1;
                                reg2_read_o =1'b1;
                                instvalid =`InstValid;
                            end
            
                            
                            default:    ;
                        endcase
                   end
                   
                   
          
          if(rs == 5'b00000)  begin
                case(funct)
                    `EXE_SLL:   begin
                        we_o = `WriteEnable;
                        aluop_o = `EXE_SLL_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        reg1_read_o = `ReadDisable;
                        reg2_read_o = `ReadEnable;
                        imm_ex = shamt;
                        instvalid = `InstValid;
                        end 
                    `EXE_SRL:   begin
                        we_o = `WriteEnable;
                        aluop_o = `EXE_SRL_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        reg1_read_o = `ReadDisable;
                        reg2_read_o = `ReadEnable;
                        imm_ex = shamt;
                        instvalid = `InstValid;
                        end    
                    `EXE_SRA:   begin
                        we_o = `WriteEnable;
                        aluop_o = `EXE_SRA_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        reg1_read_o = `ReadDisable;
                        reg2_read_o = `ReadEnable;
                        imm_ex = shamt;
                        instvalid = `InstValid;
                        end    
                        default:    ;
                        endcase
                  end
               end
                        
            `EXE_ORI:   begin
                   aluop_o = `EXE_OR_OP;
                   alusel_o = `EXE_RES_LOGIC;
                   waddr_o = rt;
                   we_o =`WriteEnable;
                   instvalid = `InstValid; 
                   reg1_read_o = `ReadEnable;
                   reg2_read_o = `ReadDisable;
           
                   imm_ex = {16'h0,inst_i[15:0]};

            end                        
            
            `EXE_ANDI:begin
                aluop_o =`EXE_AND_OP;
                alusel_o =`EXE_RES_LOGIC;
                waddr_o = rt;
                we_o =`WriteEnable;
                instvalid <=`InstValid;
                reg1_read_o =1'b1;
                reg2_read_o =1'b0;
                
                imm_ex ={16'h0,inst_i[15:0]};
                
            end 
            `EXE_XORI:begin
                aluop_o =`EXE_XOR_OP;
                alusel_o =`EXE_RES_LOGIC;
                waddr_o = rt;
                we_o =`WriteEnable;
                instvalid <=`InstValid;
                reg1_read_o =1'b1;
                reg2_read_o =1'b0;
                
                imm_ex ={16'h0,inst_i[15:0]};
            
            end
            `EXE_LUI:begin
                we_o =`WriteEnable;
                aluop_o =`EXE_OR_OP;
                alusel_o =`EXE_RES_LOGIC;
                reg1_read_o =1'b1;
                reg2_read_o =1'b0;
                
                imm_ex ={inst_i[15:0],16'h0};
                waddr_o = rt;
                instvalid <=`InstValid;
            end
           /* `EXE_PREF:begin                         //keep or not?
                we_o =`WriteDisable;
                aluop_o =`EXE_NOP_OP;
                alusel_o =`EXE_RES_NOP;
                reg1_read_o =1'b0;
                reg2_read_o =1'b0;
                instvalid =`InstValid;
            end*/
            
    
            default:    begin
                end
                
                endcase
            end
            
                  
           
end            
      
// need to solve correlation problems      
always@(*)  begin
        reg1_o = `ZeroWord;
    if(rst == `RstEnable)   begin
        reg1_o = `ZeroWord;    
        
     // solve the problem of data correlation   
    end else if(reg1_read_o == `ReadEnable && ex_we2_i == `WriteEnable && ex_waddr2_i == reg1_raddr_o)  begin
        reg1_o = ex_wdata2_i;
    end else if(reg1_read_o == `ReadEnable && ex_we1_i == `WriteEnable && ex_waddr1_i == reg1_raddr_o) begin
        reg1_o = ex_wdata1_i;
    end else if(reg1_read_o ==  `ReadEnable && mem_we2_i == `WriteEnable && mem_waddr2_i == reg1_raddr_o)   begin
        reg1_o = mem_wdata2_i;
    end else if(reg1_read_o == `ReadEnable && mem_we1_i == `WriteEnable && mem_waddr1_i == reg1_raddr_o)    begin
        reg1_o = mem_wdata1_i;            
       
    end else if(reg1_read_o == `ReadEnable) begin
        reg1_o = reg1_data_i;           //regfile 
    end else if(reg1_read_o == `ReadDisable) begin
        reg1_o = imm_ex;                //imm number
    end else begin
        reg1_o = `ZeroWord;
        end
end          

      
always@(*)  begin
        reg2_o = `ZeroWord;
    if(rst == `RstEnable)   begin
        reg2_o = `ZeroWord;
     
      // solve the problem of data correlation   
    end else if(reg2_read_o == `ReadEnable && ex_we2_i == `WriteEnable && ex_waddr2_i == reg2_raddr_o)  begin
        reg2_o = ex_wdata2_i;
    end else if(reg2_read_o == `ReadEnable && ex_we1_i == `WriteEnable && ex_waddr1_i == reg2_raddr_o) begin
        reg2_o = ex_wdata1_i;
    end else if(reg2_read_o ==  `ReadEnable && mem_we2_i == `WriteEnable && mem_waddr2_i == reg2_raddr_o)   begin
        reg2_o = mem_wdata2_i;
    end else if(reg2_read_o == `ReadEnable && mem_we1_i == `WriteEnable && mem_waddr1_i == reg2_raddr_o)    begin
        reg2_o = mem_wdata1_i;               
        
    end else if(reg2_read_o == `ReadEnable) begin
        reg2_o = reg2_data_i;
    end else if(reg2_read_o == `ReadDisable) begin
        reg2_o = imm_ex;  
    end else begin
        reg2_o = `ZeroWord;
        end
end   

assign imm_fnl = imm_ex;
                
endmodule