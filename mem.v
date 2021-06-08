`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 16:29:04
// Design Name: 
// Module Name: mem
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

module mem(
        input   rst,
        input[`RegBus]  mem_data_i,
        //massage from ex
        input[`InstAddrBus]     inst1_addr_i,
        input[`InstAddrBus]     inst2_addr_i,
        input[`RegAddrBus]      waddr1_i,
        input[`RegAddrBus]      waddr2_i,
        input                                  we1_i,
        input                                  we2_i,
        input[`RegBus]               wdata1_i,
        input[`RegBus]               wdata2_i,
        input[`RegBus]               hi_i,
        input[`RegBus]               lo_i,
        input                                  whilo_i,    
        input[`AluOpBus]           aluop1_i,
        input[`RegBus]              mem_addr_i,
        input[`RegBus]              reg2_i,
        
        //massage to writeback
        output[`InstAddrBus]    inst1_addr_o,
        output[`InstAddrBus]    inst2_addr_o,
        
        output reg[`RegAddrBus]     waddr1_o,
        output reg[`RegAddrBus]     waddr2_o,
        output  reg                         we1_o,
        output  reg                         we2_o,
        output  reg[`RegBus]            wdata1_o,
        output  reg[`RegBus]            wdata2_o,
        output  reg[`RegBus]            hi_o,
        output  reg[`RegBus]            lo_o,
        output  reg                               whilo_o,
        
        output[`RegBus]                 mem_addr_o
      

    );
    
    assign mem_addr_o = mem_addr_i;
    
    always @(*) begin
        if(rst == `RstEnable)   begin
            waddr1_o = `NOPRegAddr;
            waddr2_o = `NOPRegAddr;
            we1_o = `WriteDisable;
            we2_o = `WriteDisable;
            wdata1_o = `ZeroWord;
            wdata2_o = `ZeroWord;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
            whilo_o = `WriteDisable;
        end else begin
            waddr1_o = waddr1_i;
            waddr2_o = waddr2_i;
            we1_o = we1_i;
            we2_o = we2_i;
            wdata1_o = wdata1_i;
            wdata2_o = wdata2_i;
            hi_o = hi_i;
            lo_o = lo_i;
            whilo_o = whilo_i;
               
        case(aluop1_i)
            `EXE_LB_OP: begin
                    case(mem_addr_i[1:0])
                        2'b00:  wdata1_o = {{24{mem_data_i[7]}},mem_data_i[7:0]};
                        2'b01:  wdata1_o = {{24{mem_data_i[15]}},mem_data_i[15:8]};
                        2'b10:  wdata1_o = {{24{mem_data_i[23]}},mem_data_i[23:16]};
                        2'b11:  wdata1_o = {{24{mem_data_i[31]}},mem_data_i[31:24]};
                        default: ;      //??? wdata1_o = `ZeroWord;
                        endcase
            end
            `EXE_LBU_OP:    begin
                    case(mem_addr_i[1:0])
                        2'b00:  wdata1_o = {24'b0,mem_data_i[7:0]};
                        2'b01:  wdata1_o = {24'b0,mem_data_i[15:8]};
                        2'b10:  wdata1_o = {24'b0,mem_data_i[23:16]};
                        2'b11:  wdata1_o = {24'b0,mem_data_i[31:24]};
                        default: ;
                        endcase
            end                
            `EXE_LH_OP:    begin
                    case(mem_addr_i[1:0])
                        2'b00:  wdata1_o = {{16{mem_data_i[15]}},mem_data_i[15:0]};
                        2'b10:  wdata1_o = {{16{mem_data_i[31]}},mem_data_i[31:16]};
                        default: ;
                        endcase
            end       
            `EXE_LHU_OP:    begin
                    case(mem_addr_i[1:0])
                        2'b00:  wdata1_o = {16'b0,mem_data_i[15:0]};
                        2'b10:  wdata1_o = {16'b0,mem_data_i[31:16]};
                        default: ;
                        endcase
            end       
            `EXE_LW_OP:     wdata1_o = mem_data_i;
            `EXE_LWL_OP:     begin
                    case(mem_addr_i[1:0])   
                        2'b00:  wdata1_o = {mem_data_i[7:0],reg2_i[23:0]};
                        2'b01:  wdata1_o = {mem_data_i[15:0],reg2_i[15:0]};
                        2'b10:  wdata1_o = {mem_data_i[23:0],reg2_i[7:0]};
                        2'b11:  wdata1_o = mem_data_i;
                        default: ;
                        endcase
            end     
             `EXE_LWR_OP:     begin
                    case(mem_addr_i[1:0])   
                        2'b00:  wdata1_o = mem_data_i;
                        2'b01:  wdata1_o = {reg2_i[31:24],mem_data_i[31:8]};
                        2'b10:  wdata1_o = {reg2_i[31:16],mem_data_i[31:16]};
                        2'b11:  wdata1_o = {reg2_i[31:8],mem_data_i[31:24]};
                        default: ;
                        endcase
            end 
            `EXE_LL_OP:     wdata1_o = mem_data_i;
                default:    ;
                    endcase
            end        
end                            
    
endmodule
