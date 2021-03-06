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
    input stallreq_from_dcache,
    input predict_flag,
    input exception_flag,
    input[4:0] exception_type,
    input[`InstAddrBus] cp0_epc_i,
    input[`InstAddrBus]  ebase_i,
    
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
            
        end else if(exception_flag == `ExceptionInduced) begin
            stall = 4'b0000;    
            flush = `Flush;
            flush_cause = `Exception;
            case(exception_type)
                `EXCEPTION_INT,`EXCEPTION_ADEL,`EXCEPTION_ADES,`EXCEPTION_SYS,`EXCEPTION_BP,`EXCEPTION_RI,
                    `EXCEPTION_OV,`EXCEPTION_TR:    epc_o = ebase_i;
                `EXCEPTION_ERET:    epc_o = cp0_epc_i;
                default:    epc_o = `ZeroWord;
                endcase
        end else if(stallreq_from_dcache == `Stop) begin
            stall = 4'b0011;
            flush = `Noflush;
            flush_cause = `Exception;
            epc_o = `ZeroWord;
        end else if(predict_flag == `InValidPrediction) begin
            stall = 4'b0000;
            flush = `Flush;
            flush_cause = `FailedBranchPrediction;
            epc_o = `ZeroWord;           
        end else if(stallreq_from_ex == `Stop) begin
            stall = 4'b0011;
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
