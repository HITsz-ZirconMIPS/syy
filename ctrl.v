`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/01 23:16:13
// Design Name: 
// Module Name: ctrl
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


module ctrl(
    input rst,
    input stallreq_from_ex,
    input stallreq_from_id,
    //input stallreq_from_dcache,
    //input pred_flag,
    //input exception_flag,
    //input[4:0] exception_type,
    //input[`InstAddrBus] cp0_epc_i,
    //input[`InstAddrBus]  ebase_i,
    
    output reg[3:0]   stall,
    output reg flush,
    output reg flush_cause,
    output reg[`InstAddrBus]    epc_o,
    
    output flush_to_ibuffer
    
    
    );
    
    
    assign flush_to_ibuffer = (rst == `RstEnable || flush == `Flush) ? `Flush : `Noflush;
    
    always @(*) begin   //缺少部分逻辑判断 比如例外
        if(rst == `RstEnable) begin
            stall = 4'b0000;
            flush = `Noflush;
            flush_cause = `Exception;
            epc_o = `ZeroWord;
        end else if(stallreq_from_id == `Stop)begin
            stall = 4'b0001;
            flush = `Noflush;
            flush_cause = `Exception;
            epc_o = `ZeroWord;    
        end else begin
            stall = 4'b0000;
            flush = `Noflush;
            flush_cause = `Exception;
            epc_o = `ZeroWord;
            end
       end
            
    
    
    
   
    
endmodule