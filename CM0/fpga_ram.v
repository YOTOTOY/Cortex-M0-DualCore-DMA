
module fpga_ram(
    input           SRAM_CLK    ,
    input           SRAMCS      ,
    input           SRAMWEN     ,
    input  [13:0]   SRAMADDR    ,
    input  [ 7:0]   SRAMWDATA   ,
    output [ 7:0]   SRAMRDATA
);

    fpga_ram_16k    u_fpga_ram_16k
    (
    .clock          ( SRAM_CLK      ),
    .clken          ( SRAMCS        ),
    .wren           ( SRAMWEN       ),
    .address        ( SRAMADDR      ),
    .data           ( SRAMWDATA     ),
    .q              ( SRAMRDATA     )
    );

endmodule
