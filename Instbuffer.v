`timescale                              1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 16:25:38
// Design Name: 
// Module Name: Instbuffer
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

module Instbuffer(
    input   clk,
    input   rst,
    input   flush,
    //issue
    input   wire    issue_mode_i,   //issue mode of issue stage
    input   wire    issue_i,        //whether issue stage has issued inst    
    output  wire[`InstBus]  issue_inst1_o, 
    output  wire[`InstBus]  issue_inst2_o,
    output  wire[`InstAddrBus]  issue_inst1_addr_o,
    output  wire[`InstAddrBus]  issue_inst2_addr_o,
    
    //Fetch inst
    input   wire[`InstBus]  ICache_inst1_i,
    input   wire[`InstBus]  ICache_inst2_i,
    input   wire[`InstAddrBus]  ICache_inst1_addr_i,
    input   wire[`InstAddrBus]  ICache_inst2_addr_i, 
    input   wire                ICache_inst1_valid_o,
    input   wire                ICache_inst2_valid_o,
    output  wire                buffer_full_o
    
  
    );
    
    
    //队列本体
    reg [`InstBus]FIFO_data[`InstBufferSize-1:0];
    reg [`InstAddrBus]FIFO_addr[`InstBufferSize-1:0];
    reg [`SIZE_OF_CORR_PACK]FIFO_bpu_corr[`InstBufferSize-1:0];
	
    //头尾指针维护
    reg [`InstBufferSizeLog2-1:0]tail;//表征当前正在写入的数据位置
    reg [`InstBufferSizeLog2-1:0]head;//表征最后需要写入数据位置的后一位
    reg [`InstBufferSize-1:0]FIFO_valid;//表征buffer中的数据是否有效（高电平有效）
    always@(posedge clk)begin
        if(rst|flush)begin
            head <= `InstBufferSizeLog2'h0;
			FIFO_valid <= `InstBufferSize'h0;
        end
		//pop
        else if( issue_i == `Valid && issue_mode_i == `SingleIssue)begin//Issue one inst
            FIFO_valid[head] <= `Invalid;
			head <= head + 1;
            
		end
        else if( issue_i == `Valid && issue_mode_i == `DualIssue)begin//Issue two inst
			FIFO_valid[head] <= `Invalid;
			FIFO_valid[head+`InstBufferSizeLog2'h1] <= `Invalid;
            head <= head + 2;
		end
		
        if(rst|flush)begin
            tail <= `InstBufferSizeLog2'h0;
        end
		//push
        else if( ICache_inst1_valid_o == `Valid && ICache_inst2_valid_o == `Invalid)begin//ICache return one inst
			FIFO_valid[tail] <= (tail==head)? `Invalid:`Valid;
            tail <= tail + 1;
		end
        else if( ICache_inst1_valid_o == `Valid && ICache_inst2_valid_o == `Valid)begin//ICache return two inst
			FIFO_valid[tail] <= (tail==head)? `Invalid:`Valid;
			FIFO_valid[tail+`InstBufferSizeLog2'h1] <= (tail==head)? `Invalid:`Valid;
            tail <= tail + 2;
		end
    end
	
	
	//Write
    always@(posedge clk)begin
		FIFO_data[tail] <= ICache_inst1_i;
		FIFO_data[tail+`InstBufferSizeLog2'h1] <= ICache_inst2_i;
		FIFO_addr[tail] <= ICache_inst1_addr_i;
		FIFO_addr[tail+`InstBufferSizeLog2'h1] <= ICache_inst2_addr_i;
		//FIFO_bpu_corr[tail] <= bpu_corr1_i;
		//FIFO_bpu_corr[tail+`InstBufferSizeLog2'h1] <= bpu_corr2_i;
    end
	   
//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////Output//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
  /* always@(posedge clk) begin
	 issue_inst1_o <= FIFO_data[head];
	 issue_inst2_o <= FIFO_data[head+`InstBufferSizeLog2'h1];
	 issue_inst1_addr_o <= FIFO_addr[head];
	 issue_inst2_addr_o <= FIFO_addr[head+`InstBufferSizeLog2'h1];
	end
	*/
	reg [`InstBufferSizeLog2-1:0]head_o;//记录上一拍的head值，用于给inst_o赋值
	always@(posedge clk) begin
	   if(rst|flush)   head_o <= `InstBufferSizeLog2'h0;
	   else if(issue_mode_i == `SingleIssue)    head_o <= head_o + 1; 
	   else   head_o <= head;
	end
	
	assign issue_inst1_o = FIFO_data[head_o];
	assign issue_inst2_o = FIFO_data[head_o+`InstBufferSizeLog2'h1];
	//assign issue_inst2_o = (issue_mode_i)? FIFO_data[head_o+`InstBufferSizeLog2'h1]:issue_inst2_o;
	assign issue_inst1_addr_o = FIFO_addr[head_o];
	assign issue_inst2_addr_o = FIFO_addr[head_o+`InstBufferSizeLog2'h1];
	//assign issue_inst2_addr_o = (issue_mode_i)? FIFO_addr[head_o+`InstBufferSizeLog2'h1]:issue_inst2_addr_o;
	
	
    assign issue_bpu_corr1_o = FIFO_bpu_corr[head];
    assign issue_bpu_corr2_o = FIFO_bpu_corr[head+`InstBufferSizeLog2'h1];
	//assign issue_ok_o = FIFO_valid[head+`InstBufferSizeLog2'h2];
    //full
	assign buffer_full_o = FIFO_valid[tail+`InstBufferSizeLog2'h5];

    
    
    
    
endmodule
