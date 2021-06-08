`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/01 20:45:31
// Design Name: 
// Module Name: my_cpu_spoc
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


module openmips_min_spoc (
    input wire clk,
    input wire rst
);
    //����inst_rom��cpu
    wire [`InstAddrBus] inst_addr;  //虚地址
    wire [`InstBus] inst1 ;
    wire [`InstBus] inst2 ;
    wire [`InstAddrBus] inst1_addr;
    wire [`InstAddrBus] inst2_addr;
    wire rom_ce;
    
    mycpu mycpu0(
        .clk(clk),
        .rst(rst),
        .inst1_from_icache(inst1),
        .inst2_from_icache(inst2),
        .inst1_addr_from_icache(inst1_addr),
        .inst2_addr_from_icache(inst2_addr),
        
        .raddr_to_icache(inst_addr),
        .rreq_to_icache(rom_ce)    
    
    );
    
    
    
    inst_rom inst_rom0(
        //.clk(clk),
    	.ce   (rom_ce   ),
        .addr (inst_addr ),
        .inst1 (inst1 ),
        .inst2 (inst2),
        .inst1_addr(inst1_addr),
        .inst2_addr(inst2_addr)
    );
    
    
    
endmodule
