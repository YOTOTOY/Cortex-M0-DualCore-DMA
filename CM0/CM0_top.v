module CM0_top(
input			wire				clk,
input			wire				reset,

input			wire				nTRST,
inout 		wire 				SWDIOTMS,
input			wire				SWCLKTCK,

output  		wire				SDRAMCLK,
output  		wire        	CKE,
output  		wire        	CSn,
output  		wire        	RASn,
output  		wire        	CASn,
output  		wire        	WEn,
output  		wire	[12:0] 	ADDR,
output  		wire 	[1:0]  	BA,
inout   		wire 	[31:0] 	DQ,
output  		wire 	[3:0]  	DQM,

input			wire				RXD,
output		wire				TXD
);

wire					sysclk;
wire					sysclkp;
wire					sysrst;

 PLL 	PLL_inst(
	.areset		(!reset),
	.inclk0		(clk),
	.c0			(sysclk),
	.c1			(SDRAMCLK),
	.c2			(sysclkp),
	.locked		(sysrst)
	);



 cmsdk_mcu	cmsdk_mcu_inst(
	.sysclk		(sysclk),
	.sysclkp		(sysclkp),
	.sysrst		(sysrst),
	
	.nTRST		(nTRST),
	.SWDIO		(SWDIOTMS),
	.SWCLK		(SWCLKTCK),
	
	.CKE			(CKE),
	.CSn			(CSn),
	.RASn			(RASn),
	.CASn			(CASn),
	.WEn			(WEn),
	.ADDR			(ADDR),
	.BA			(BA),
	.DQ			(DQ),
	.DQM			(DQM),
	
	.TXD			(TXD),
	.RXD			(RXD)
  
  );

endmodule
