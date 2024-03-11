
module m0_sram(
    input           clk         ,
    output [31:0]   SRAMRDATA   ,
    input  [13:0]   SRAMADDR    ,
    input  [ 3:0]   SRAMWEN     ,
    input  [31:0]   SRAMWDATA   ,
    input           SRAMCS
);

    fpga_ram    u_sram_0
    (
    .SRAM_CLK    ( clk                  ),
    .SRAMCS      ( SRAMCS               ),
    .SRAMWEN     ( SRAMWEN[0]           ),
    .SRAMADDR    ( SRAMADDR             ),
    .SRAMWDATA   ( SRAMWDATA[0*8+7:0*8] ),
    .SRAMRDATA   ( SRAMRDATA[0*8+7:0*8] )
    );

    fpga_ram    u_sram_1
    (
    .SRAM_CLK    ( clk                  ),
    .SRAMCS      ( SRAMCS               ),
    .SRAMWEN     ( SRAMWEN[1]           ),
    .SRAMADDR    ( SRAMADDR             ),
    .SRAMWDATA   ( SRAMWDATA[1*8+7:1*8] ),
    .SRAMRDATA   ( SRAMRDATA[1*8+7:1*8] )
    );

    fpga_ram    u_sram_2
    (
    .SRAM_CLK    ( clk                  ),
    .SRAMCS      ( SRAMCS               ),
    .SRAMWEN     ( SRAMWEN[2]           ),
    .SRAMADDR    ( SRAMADDR             ),
    .SRAMWDATA   ( SRAMWDATA[2*8+7:2*8] ),
    .SRAMRDATA   ( SRAMRDATA[2*8+7:2*8] )
    );

    fpga_ram    u_sram_3
    (
    .SRAM_CLK    ( clk                  ),
    .SRAMCS      ( SRAMCS               ),
    .SRAMWEN     ( SRAMWEN[3]           ),
    .SRAMADDR    ( SRAMADDR             ),
    .SRAMWDATA   ( SRAMWDATA[3*8+7:3*8] ),
    .SRAMRDATA   ( SRAMRDATA[3*8+7:3*8] )
    );

endmodule



