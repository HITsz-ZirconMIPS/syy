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
    
   // output [15:0] led,
   // output [1:0]  led_rg0,
   // output [1:0]  led_rg1
    
    
    
);
    //����inst_rom��cpu
    wire [`InstAddrBus] inst_addr;  //虚地址
    wire [`InstBus] inst1 ;
    wire [`InstBus] inst2 ;
    wire [`InstAddrBus] inst1_addr;
    wire [`InstAddrBus] inst2_addr;
    wire rom_ce;
    
    wire [`DataAddrBus] mem_to_ram_raddr;
    wire [`DataAddrBus] mem_to_ram_waddr;
    wire [`DataBus] mem_to_ram_data;
    wire [3:0] mem_to_ram_sel;
    wire mem_to_ram_we;
    wire mem_to_ram_ce;

    wire [`DataBus] ram_mem_data;
    wire[5:0] int;
    wire timer_int;
    
    
    
    mycpu mycpu0(
        .clk(clk),
        .rst(rst),
        .inst1_from_icache(inst1),
        .inst2_from_icache(inst2),
        .inst1_addr_from_icache(inst1_addr),
        .inst2_addr_from_icache(inst2_addr),
        
        .raddr_to_icache(inst_addr),
        .rreq_to_icache(rom_ce)    ,
        //input
        .rdata_from_dcache(ram_mem_data),
        .stallreq_from_dcache(),
        //output
        .rreq_to_dcache(mem_to_ram_ce),
        .raddr_to_dcache(mem_to_ram_raddr),
        .wreq_to_dcache(mem_to_ram_we),
        .waddr_to_dcache(mem_to_ram_waddr),
        .wdata_to_dcache(mem_to_ram_data),
        .wsel_to_dcache(mem_to_ram_sel) 
        
    
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
    
    data_ram data_ram0(
    	.clk    (clk    ),
        .ce     (mem_to_ram_ce     ),
        .we     (mem_to_ram_we     ),
        .raddr   (mem_to_ram_raddr   ),
        .waddr  (mem_to_ram_waddr),
        .sel    (mem_to_ram_sel    ),
        .data_i (mem_to_ram_data ),
        .data_o (ram_mem_data )
    );
    
    
endmodule
