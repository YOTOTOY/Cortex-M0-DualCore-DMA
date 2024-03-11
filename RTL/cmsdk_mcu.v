//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2017 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//  Version and Release Control Information:
//
//  File Revision       : $Revision: 368442 $
//  File Date           : $Date: 2017-07-25 15:07:59 +0100 (Tue, 25 Jul 2017) $
//
//  Release Information : Cortex-M0 DesignStart-r2p0-00rel0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
// Abstract : Top level for Cortex-M0 DesignStart Eval RTL example
//-----------------------------------------------------------------------------
//


module cmsdk_mcu
 (
  input  wire          sysclk, // input
  input	wire			  sysclkp,
  input  wire          sysrst,  // active low reset
  
  input  wire          nTRST,
  inout  wire          SWDIO,
  input  wire          SWCLK,

  output  wire         CKE,
  output  wire         CSn,
  output  wire         RASn,
  output  wire         CASn,
  output  wire         WEn,
  output  wire [12:0]  ADDR,
  output  wire [1:0]   BA,
  inout   wire [31:0]  DQ,
  output  wire [3:0]   DQM,
  
  input	 wire			  RXD,
  output  wire			  TXD
  
  );

wire				CDBGPWRUP;
wire				CDBGPWRUP2;
wire				SYSRESETREQ;
wire				HRESETn1;
reg 				cpu2_rstn;

wire				HCLK;
wire				PCLK;
wire 	[31:0] 	HADDR;
wire 	[ 2:0] 	HBURST;
wire 	       	HMASTLOCK;
wire 	[ 3:0] 	HPROT;
wire 	[ 2:0] 	HSIZE;
wire 	[ 1:0] 	HTRANS;
wire 	[31:0] 	HWDATA;
wire        	HWRITE;
wire 	[31:0] 	HRDATA;
wire        	HREADY;
wire				HREADYOUT;
wire        	HRESP;
wire  [1:0]   	HMASTER;
wire				HRESETn;
reg				HRESETn_buf;

wire          	HSELS0;
wire 	[31:0]   HADDRS0;
wire  [1:0]   	HTRANSS0;
wire  [2:0]   	HSIZES0;
wire          	HWRITES0;
wire          	HREADYS0;
wire  [3:0]   	HPROTS0;
wire  [2:0]   	HBURSTS0;
wire          	HMASTLOCKS0;
wire 	[31:0] 	HWDATAS0;

wire          	HREADYOUTS0;
wire          	HRESPS0;
wire 	[31:0] 	HRDATAS0;

wire          	HSELS1;
wire 	[31:0]   HADDRS1;
wire  [1:0]   	HTRANSS1;
wire  [2:0]   	HSIZES1;
wire          	HWRITES1;
wire          	HREADYS1;
wire  [3:0]   	HPROTS1;
wire  [2:0]   	HBURSTS1;
wire          	HMASTLOCKS1;
wire 	[31:0] 	HWDATAS1;

wire          	HREADYOUTS1;
wire          	HRESPS1;
wire 	[31:0] 	HRDATAS1;
  
wire 	[15:0] 	PADDR;
wire           PENABLE;
wire 				PWRITE;
wire	[3:0] 	PSTRB;
wire	[2:0] 	PPROT;
wire	[31:0] 	PWDATA;
wire  			PSEL;
wire        	PCLKG;
wire        	PRESETn;

wire	[31:0] 	PRDATA;
wire 				PREADY;
wire 				PSLVERR;
  
wire				sdram_hsel;
wire				sdram_hreadyout;
wire	[31:0]	sdram_hrdata;
wire				sdram_hresp;

wire				flash_hsel;
wire				flash_hreadyout;
wire	[31:0]	flash_hrdata;
wire				flash_hresp;

wire				apbbus_hsel;
wire				apbbus_hreadyout;
wire	[31:0]	apbbus_hrdata;
wire				apbbus_hresp;

wire				defslv_hsel;
wire				defslv_hreadyout;
wire				defslv_hresp;

wire				cpu2_hsel;
wire				cpu2_hreadyout;
wire	[31:0]	cpu2_hrdata;
wire				cpu2_hresp;

wire				cpu2_en;

wire				dma_hsel;
wire				dma_hreadyout;
wire	[31:0]	dma_hrdata;
wire				dma_hresp;

wire          	DMA_HSEL;
wire 	[31:0]   DMA_HADDR;
wire 	[1:0]   	DMA_HTRANS;
wire 	[2:0]   	DMA_HSIZE;
wire          	DMA_HWRITE;
wire  [3:0]   	DMA_HPROT;
wire  [2:0]   	DMA_HBURST;
wire          	DMA_HMASTLOCK;
wire 	[31:0] 	DMA_HWDATA;

wire          	DMA_HREADY;
wire          	DMA_HRESP;
wire 	[31:0] 	DMA_HRDATA;
wire				DMA_IRQ;

wire         	uart_psel;
wire         	uart_pready;
wire 	[31:0]  	uart_prdata;
wire         	uart_pslverr;
  
wire         	timer_psel;
wire         	timer_pready;
wire 	[31:0]  	timer_prdata;
wire         	timer_pslverr;

wire           SRAM1_CS;
wire [ 3:0]    SRAM1_WEN;
wire [29:0]    SRAM1_ADDR;
wire [31:0]    SRAM1_WDATA;
wire [31:0]    SRAM1_RDATA;
  
wire				TIMERINT;

wire				TXINT;
wire				RXINT;

wire	[31:0]	IRQ;

wire				SWCLKTCK;
wire				SWDITMS;
wire				SWDO;
wire				SWDOEN;

assign IRQ = {16'b0,DMA_IRQ,6'b0,TIMERINT,6'b0,TXINT,RXINT};
assign SWDIO = SWDOEN ? SWDO : 1'bz;
assign SWDITMS = SWDIO;
assign SWCLKTCK = SWCLK;

 sysclkout sysclkout_HCLK(
		.inclk				(sysclk),  //  altclkctrl_input.inclk
		.outclk				(HCLK) // altclkctrl_output.outclk
	);
	
 sysclkout sysclkout_PCLK(
		.inclk				(sysclkp),  //  altclkctrl_input.inclk
		.outclk				(PCLK) // altclkctrl_output.outclk
	);

 sysclkout sysclkout_PCLKG(
		.inclk				(sysclkp),  //  altclkctrl_input.inclk
		.outclk				(PCLKG) // altclkctrl_output.outclk
	);

 sysclkout sysclkout_HRESETn(
		.inclk				(HRESETn_buf),  //  altclkctrl_input.inclk
		.outclk				(HRESETn) // altclkctrl_output.outclk
	);

 sysclkout sysclkout_HRESETn2(
		.inclk				(cpu2_rstn),  //  altclkctrl_input.inclk
		.outclk				(HRESETn1) // altclkctrl_output.outclk
	);
	
//assign HCLK = sysclk;
//assign PCLK = sysclk;
//assign PCLKG = sysclk;
assign PRESETn = HRESETn;

always@(posedge HCLK or negedge sysrst)	begin
	if(!sysrst)
		HRESETn_buf <= 1'b0;
	else if(SYSRESETREQ)
		HRESETn_buf <= 1'b0;
	else
		HRESETn_buf <= 1'b1;
end

always@(posedge HCLK or negedge sysrst)	begin
	if(!sysrst)
		cpu2_rstn <= 1'b0;
	else if(SYSRESETREQ)
		cpu2_rstn <= 1'b0;
	else
		cpu2_rstn <= cpu2_en;
end

//assign HRESETn1 = cpu2_rstn;

//instantiate the DesignStart Cortex M0 Integration Layer
CORTEXM0INTEGRATION
u_cortexm0integration
(
  // CLOCK AND RESETS
  .FCLK          (HCLK),
  .SCLK          (HCLK),
  .HCLK          (HCLK),
  .DCLK          (HCLK),
  .PORESETn      (sysrst),
  .DBGRESETn     (sysrst),
  .HRESETn       (HRESETn),
  .SWCLKTCK      (SWCLKTCK),
  .nTRST         (nTRST),
//  .SWCLKTCK      (1'b1),
//  .nTRST         (1'b0),

  // AHB-LITE MASTER PORT
  .HADDR         (HADDRS0),
  .HBURST        (HBURSTS0),
  .HMASTLOCK     (HMASTLOCKS0),
  .HPROT         (HPROTS0),
  .HSIZE         (HSIZES0),
  .HTRANS        (HTRANSS0),
  .HWDATA		  (HWDATAS0),
  .HWRITE        (HWRITES0),
  .HRDATA        (HRDATAS0),
  .HREADY        (HREADYS0),
  .HRESP         (HRESPS0),
  .HMASTER       (HMASTERS0),

  // CODE SEQUENTIALITY AND SPECULATION
  .CODENSEQ      (),
  .CODEHINTDE    (),
  .SPECHTRANS    (),

  // DEBUG
  .SWDITMS       (SWDITMS),
//	.SWDITMS       (1'b1),
  .TDI           (1'b0),
  .SWDO          (SWDO),
  .SWDOEN        (SWDOEN),
  .TDO           (),
  .nTDOEN        (),
  .DBGRESTART    (1'b0),
  .DBGRESTARTED  (),
  .EDBGRQ        (1'b0),
  .HALTED        (),

  // MISC
  .NMI            (1'b0),        // Non-maskable interrupt input
  .IRQ            (IRQ),        // Interrupt request inputs
  .TXEV           (),              // Event output (SEV executed)
  .RXEV           (1'b0),              // Event input
  .LOCKUP         (),            // Core is locked-up
  .SYSRESETREQ    (SYSRESETREQ),       // System reset request
  .STCALIB        ({26{1'b0}}),           // SysTick calibration register value
  .STCLKEN        (1'b0),           // SysTick SCLK clock enable
  .IRQLATENCY     (8'h00),
  .ECOREVNUM      ({28{1'b0}}),

  // POWER MANAGEMENT
  .GATEHCLK      (),
  .SLEEPING      (),           // Core and NVIC sleeping
  .SLEEPDEEP     (),
  .WAKEUP        (),
  .WICSENSE      (),
  .SLEEPHOLDREQn (1'b1),
  .SLEEPHOLDACKn (),
  .WICENREQ      (1'b0),
  .WICENACK      (),
  .CDBGPWRUPREQ  (CDBGPWRUP),
  .CDBGPWRUPACK  (CDBGPWRUP),

  // SCAN IO
  .SE            (1'b0),
  .RSTBYPASS     (1'b0)
);

CORTEXM0INTEGRATION
u_cortexm0integration2
(
  // CLOCK AND RESETS
  .FCLK          (HCLK),
  .SCLK          (HCLK),
  .HCLK          (HCLK),
  .DCLK          (HCLK),
  .PORESETn      (sysrst),
  .DBGRESETn     (sysrst),
  .HRESETn       (HRESETn1),
//  .SWCLKTCK      (SWCLKTCK),
//  .nTRST         (nTRST),
  .SWCLKTCK      (1'b1),
  .nTRST         (1'b0),

  // AHB-LITE MASTER PORT
  .HADDR         (HADDRS1),
  .HBURST        (HBURSTS1),
  .HMASTLOCK     (HMASTLOCKS1),
  .HPROT         (HPROTS1),
  .HSIZE         (HSIZES1),
  .HTRANS        (HTRANSS1),
  .HWDATA		  (HWDATAS1),
  .HWRITE        (HWRITES1),
  .HRDATA        (HRDATAS1),
  .HREADY        (HREADYS1),
  .HRESP         (HRESPS1),
  .HMASTER       (HMASTERS1),

  // CODE SEQUENTIALITY AND SPECULATION
  .CODENSEQ      (),
  .CODEHINTDE    (),
  .SPECHTRANS    (),

  // DEBUG
//  .SWDITMS       (SWDITMS),
  .SWDITMS       (1'b1),
  .TDI           (1'b0),
//  .SWDO          (SWDO),
//  .SWDOEN        (SWDOEN),
  .SWDO          (),
  .SWDOEN        (),
  .TDO           (),
  .nTDOEN        (),
  .DBGRESTART    (1'b0),
  .DBGRESTARTED  (),
  .EDBGRQ        (1'b0),
  .HALTED        (),

  // MISC
  .NMI            (1'b0),        // Non-maskable interrupt input
  .IRQ            (32'b0),        // Interrupt request inputs
  .TXEV           (),              // Event output (SEV executed)
  .RXEV           (1'b0),              // Event input
  .LOCKUP         (),            // Core is locked-up
  .SYSRESETREQ    (),       // System reset request
  .STCALIB        ({26{1'b0}}),           // SysTick calibration register value
  .STCLKEN        (1'b0),           // SysTick SCLK clock enable
  .IRQLATENCY     (8'h00),
  .ECOREVNUM      ({28{1'b0}}),

  // POWER MANAGEMENT
  .GATEHCLK      (),
  .SLEEPING      (),           // Core and NVIC sleeping
  .SLEEPDEEP     (),
  .WAKEUP        (),
  .WICSENSE      (),
  .SLEEPHOLDREQn (1'b1),
  .SLEEPHOLDACKn (),
  .WICENREQ      (1'b0),
  .WICENACK      (),
  .CDBGPWRUPREQ  (CDBGPWRUP2),
  .CDBGPWRUPACK  (CDBGPWRUP2),

  // SCAN IO
  .SE            (1'b0),
  .RSTBYPASS     (1'b0)
);

 cmsdk_ahb_master_mux #(
  .PORT0_ENABLE		(1),
  .PORT1_ENABLE		(1),
  .PORT2_ENABLE		(1),
  .DW						(32)
  )
  cmsdk_ahb_master_mux_inst
 (
  .HCLK					(HCLK),
  .HRESETn				(HRESETn),
		
  .HSELS0				(1'b1),
  .HADDRS0				(HADDRS0),
  .HTRANSS0				(HTRANSS0),
  .HSIZES0				(HSIZES0),
  .HWRITES0				(HWRITES0),
  .HREADYS0				(HREADYS0),
  .HPROTS0				(HPROTS0),
  .HBURSTS0				(HBURSTS0),
  .HMASTLOCKS0			(HMASTLOCKS0),
  .HWDATAS0				(HWDATAS0),
		
  .HREADYOUTS0			(HREADYS0),
  .HRESPS0				(HRESPS0),
  .HRDATAS0				(HRDATAS0),
		
  .HSELS1				(1'b1),
  .HADDRS1				(HADDRS1),
  .HTRANSS1				(HTRANSS1),
  .HSIZES1				(HSIZES1),
  .HWRITES1				(HWRITES1),
  .HREADYS1				(HREADYS1),
  .HPROTS1				(HPROTS1),
  .HBURSTS1				(HBURSTS1),
  .HMASTLOCKS1			(HMASTLOCKS1),
  .HWDATAS1				(HWDATAS1),
		
  .HREADYOUTS1			(HREADYS1),
  .HRESPS1				(HRESPS1),
  .HRDATAS1				(HRDATAS1),
		
  .HSELS2				(DMA_HSEL),
  .HADDRS2				(DMA_HADDR),
  .HTRANSS2				(DMA_HTRANS),
  .HSIZES2				(DMA_HSIZE),
  .HWRITES2				(DMA_HWRITE),
  .HREADYS2				(DMA_HREADY),
  .HPROTS2				(DMA_HPORT),
  .HBURSTS2				(DMA_HBURST),
  .HMASTLOCKS2			(DMA_HMASTLOCK),
  .HWDATAS2				(DMA_HWDATA),
		
  .HREADYOUTS2			(DMA_HREADY),
  .HRESPS2				(DMA_HRESP),
  .HRDATAS2				(DMA_HRDATA),
		
  .HSELM					(HSEL),
  .HADDRM				(HADDR),
  .HTRANSM				(HTRANS),
  .HSIZEM				(HSIZE),
  .HWRITEM				(HWRITE),
  .HREADYM				(HREADY),
  .HPROTM				(HPROT),
  .HBURSTM				(HBURST),
  .HMASTLOCKM			(HMASTLOCK),
  .HWDATAM				(HWDATA),
		
  .HREADYOUTM			(HREADYOUT),
  .HRESPM				(HRESP),
  .HRDATAM				(HRDATA),
		
  .HMASTERM				(HMASTER)
  );
  
  cpu2_ctrl	cpu2_ctrl_inst
(
	.HSEL					(cpu2_hsel),
	.HCLK					(HCLK),
	.HRESETn				(HRESETn),
	.HREADY				(HREADY),
	.HADDR				(HADDR),
	.HTRANS				(HTRANS),
	.HWRITE				(HWRITE),
	.HSIZE				(HSIZE),
	.HWDATA				(HWDATA),
	.HREADYOUT			(cpu2_hreadyout),
	.HRDATA				(cpu2_hrdata),
	.HRESP				(cpu2_hresp),
	.cpu2_en				(cpu2_en),
	.HMASTER				(HMASTER)
);
	 
	DMA	DMA_inst
	(
	.HSEL					(dma_hsel),
	.HCLK					(HCLK),
	.HRESETn				(HRESETn),
	.HREADY				(HREADY),
	.HADDR				(HADDR),
	.HTRANS				(HTRANS),
	.HWRITE				(HWRITE),
	.HSIZE				(HSIZE),
	.HWDATA				(HWDATA),
	.HREADYOUT			(dma_hreadyout),
	.HRDATA				(dma_hrdata),
	.HRESP				(dma_hresp),
			
	.HSELM				(DMA_HSEL),
	.HADDRM				(DMA_HADDR),
	.HTRANSM				(DMA_HTRANS),
	.HSIZEM				(DMA_HSIZE),
	.HWRITEM				(DMA_HWRITE),
	.HPROTM				(DMA_HPROT),
	.HBURSTM				(DMA_HBURST),
	.HMASTLOCKM			(DMA_HMASTLOCK),
	.HWDATAM				(DMA_HWDATA),
			
	.HREADYM				(DMA_HREADY),
	.HRESPM				(DMA_HRESP),
	.HRDATAM				(DMA_HRDATA),
	.IRQM					(DMA_IRQ)
);

 cmsdk_ahb_slave_mux #(
    .PORT0_ENABLE  (1),
    .PORT1_ENABLE  (1),
    .PORT2_ENABLE  (1),
    .PORT3_ENABLE  (1),
    .PORT4_ENABLE  (1),
    .PORT5_ENABLE  (1),
    .PORT6_ENABLE  (0),
    .PORT7_ENABLE  (0),
    .PORT8_ENABLE  (0),
    .PORT9_ENABLE  (0),
    .DW            (32)
    )
	 cmsdk_ahb_slave_mux_inst
 (
	.HCLK				(HCLK),   
	.HRESETn			(HRESETn),
	.HREADY			(HREADY), 
	.HSEL0			(defslv_hsel),  
	.HREADYOUT0		(defslv_hreadyout),
	.HRESP0			(defslv_hresp), 
	.HRDATA0			(32'd0),
	.HSEL1			(sdram_hsel),  
	.HREADYOUT1		(sdram_hreadyout),
	.HRESP1			(sdram_hresp), 
	.HRDATA1			(sdram_hrdata),
	.HSEL2			(flash_hsel),  
	.HREADYOUT2		(flash_hreadyout),
	.HRESP2			(flash_hresp), 
	.HRDATA2			(flash_hrdata),
	.HSEL3			(apbbus_hsel),  
	.HREADYOUT3		(apbbus_hreadyout),
	.HRESP3			(apbbus_hresp), 
	.HRDATA3			(apbbus_hrdata),
	.HSEL4			(cpu2_hsel),  
	.HREADYOUT4		(cpu2_hreadyout),
	.HRESP4			(cpu2_hresp), 
	.HRDATA4			(cpu2_hrdata),
	.HSEL5			(dma_hsel),  
	.HREADYOUT5		(dma_hreadyout),
	.HRESP5			(dma_hresp), 
	.HRDATA5			(dma_hrdata),
	.HSEL6			(1'b0),  
	.HREADYOUT6		(1'b1),
	.HRESP6			(1'b0), 
	.HRDATA6			(32'b0),
	.HSEL7			(1'b0),  
	.HREADYOUT7		(1'b1),
	.HRESP7			(1'b0), 
	.HRDATA7			(32'b0),
	.HSEL8			(1'b0),  
	.HREADYOUT8		(1'b1),
	.HRESP8			(1'b0), 
	.HRDATA8			(32'b0),
	.HSEL9			(1'b0),  
	.HREADYOUT9		(1'b1),
	.HRESP9			(1'b0), 
	.HRDATA9			(32'b0),
	.HREADYOUT		(HREADYOUT),
	.HRESP			(HRESP),  
	.HRDATA 			(HRDATA)
  );
  
   cmsdk_mcu_addr_decode	cmsdk_mcu_addr_decode_inst
 (
    // System Address
    .haddr			(HADDR),

    .flash_hsel	(flash_hsel),
	 .sdram_hsel	(sdram_hsel),
	 .apbbus_hsel	(apbbus_hsel),
	 .cpu2_hsel		(cpu2_hsel),
	 .dma_hsel		(dma_hsel),
	 
	 .defslv_hsel	(defslv_hsel)

    );
	 
  cmsdk_ahb_default_slave     u_cmsdk_ahb_default_slave
    (
    .HCLK                       (HCLK           ),
    .HRESETn                    (HRESETn        ),
    .HSEL                       (defslv_hsel    ),

    .HTRANS                     (HTRANS         ),
    .HREADY                     (HREADY         ),
    .HREADYOUT                  (defslv_hreadyout),
    .HRESP                      (defslv_hresp    )
    );
	 
	 AHB2SDRAM	AHB2SDRAM_inst(
	 .HSEL				(sdram_hsel),
	 .HCLK				(HCLK),
	 .HRESETn			(HRESETn),
	 .HREADY				(HREADY),
	 .HADDR				(HADDR),
	 .HTRANS				(HTRANS),
	 .HWRITE				(HWRITE),
	 .HSIZE				(HSIZE),
	 .HWDATA		  		(HWDATA),
	 .HREADYOUT			(sdram_hreadyout),
	 .HRDATA				(sdram_hrdata),
	 .HRESP				(sdram_hresp),
			
	 .CKE					(CKE),
	 .CSn					(CSn),
	 .RASn				(RASn),
	 .CASn				(CASn),
	 .WEn					(WEn),
	 .ADDR				(ADDR),
	 .BA					(BA),
	 .DQ					(DQ),
	 .DQM					(DQM)
	 );

    cmsdk_ahb_to_sram #(.AW(32))    u_cmsdk_ahb_to_sram_1
    (
    .HCLK                   (HCLK           ),
    .HRESETn                (HRESETn        ),
    .HSEL                   (flash_hsel     ),
    .HREADY                 (HREADY         ),
    .HTRANS                 (HTRANS         ),
    .HSIZE                  (HSIZE          ),
    .HWRITE                 (HWRITE         ),
    .HADDR                  (HADDR          ),
    
    .HREADYOUT              (flash_hreadyout),
    .HRESP                  (flash_hresp    ),
    .HRDATA                 (flash_hrdata   ),
	 .HWDATA		  				 (HWDATA),
    .SRAMRDATA              (SRAM1_RDATA    ),
    .SRAMADDR               (SRAM1_ADDR     ),
    .SRAMWEN                (SRAM1_WEN      ),
    .SRAMWDATA              (SRAM1_WDATA    ),
    .SRAMCS                 (SRAM1_CS       )
    );

    m0_sram                 u_ram_1
    (
    .clk                    (HCLK           ),
    .SRAMCS                 (SRAM1_CS       ),
    .SRAMWEN                (SRAM1_WEN      ),
    .SRAMADDR               (SRAM1_ADDR[13:0]),
    .SRAMWDATA              (SRAM1_WDATA    ),
    .SRAMRDATA              (SRAM1_RDATA    )
    );

 cmsdk_ahb_to_apb #(
  // Parameter to define address width
  // 16 = 2^16 = 64KB APB address space
  .ADDRWIDTH			(16),
  .REGISTER_RDATA		(1),
  .REGISTER_WDATA		(0)
  )
  cmsdk_ahb_to_apb_inst
 (
  .HCLK					(HCLK),
  .HRESETn				(HRESETn),
  .PCLKEN				(1),
			
  .HSEL					(apbbus_hsel),
  .HADDR					(HADDR),
  .HTRANS				(HTRANS),
  .HSIZE					(HSIZE),
  .HPROT					(4'b0011),
  .HWRITE				(HWRITE),
  .HREADY				(HREADY),
  .HWDATA				(HWDATA),
			
  .HREADYOUT			(apbbus_hreadyout),
  .HRDATA				(apbbus_hrdata),
  .HRESP					(apbbus_hresp),
			
  .PADDR					(PADDR),
  .PENABLE				(PENABLE),
  .PWRITE				(PWRITE),
  .PSTRB					(PSTRB),
  .PPROT					(PPROT),
  .PWDATA				(PWDATA),
  .PSEL					(PSEL),
			
  .APBACTIVE			(),
			
  .PRDATA				(PRDATA),
  .PREADY				(PREADY),
  .PSLVERR				(PSLVERR)
  );
  
  cmsdk_apb_slave_mux #(
  .PORT0_ENABLE  		(1),
  .PORT1_ENABLE  		(1),
  .PORT2_ENABLE  		(0),
  .PORT3_ENABLE  		(0),
  .PORT4_ENABLE  		(0),
  .PORT5_ENABLE  		(0),
  .PORT6_ENABLE  		(0),
  .PORT7_ENABLE  		(0),
  .PORT8_ENABLE  		(0),
  .PORT9_ENABLE  		(0),
  .PORT10_ENABLE 		(0),
  .PORT11_ENABLE 		(0),
  .PORT12_ENABLE 		(0),
  .PORT13_ENABLE 		(0),
  .PORT14_ENABLE 		(0),
  .PORT15_ENABLE 		(0)
  )
  cmsdk_apb_slave_mux_inst
 (
  .DECODE4BIT			(PADDR[15:12]),
  .PSEL					(PSEL),
		
  .PSEL0					(uart_psel),
  .PREADY0				(uart_pready),
  .PRDATA0				(uart_prdata),
  .PSLVERR0				(uart_pslverr),
		
  .PSEL1					(timer_psel),
  .PREADY1				(timer_pready),
  .PRDATA1				(timer_prdata),
  .PSLVERR1				(timer_pslverr),
		
  .PSEL2					(),
  .PREADY2				(),
  .PRDATA2				(),
  .PSLVERR2				(),
		
  .PSEL3					(),
  .PREADY3				(),
  .PRDATA3				(),
  .PSLVERR3				(),
		
  .PSEL4					(),
  .PREADY4				(),
  .PRDATA4				(),
  .PSLVERR4				(),
		
  .PSEL5					(),
  .PREADY5				(),
  .PRDATA5				(),
  .PSLVERR5				(),
		
  .PSEL6					(),
  .PREADY6				(),
  .PRDATA6				(),
  .PSLVERR6				(),
		
  .PSEL7					(),
  .PREADY7				(),
  .PRDATA7				(),
  .PSLVERR7				(),
		
  .PSEL8					(),
  .PREADY8				(),
  .PRDATA8				(),
  .PSLVERR8				(),
		
  .PSEL9					(),
  .PREADY9				(),
  .PRDATA9				(),
  .PSLVERR9				(),
		
  .PSEL10				(),
  .PREADY10				(),
  .PRDATA10				(),
  .PSLVERR10			(),
		
  .PSEL11				(),
  .PREADY11				(),
  .PRDATA11				(),
  .PSLVERR11			(),
		
  .PSEL12				(),
  .PREADY12				(),
  .PRDATA12				(),
  .PSLVERR12			(),
		
  .PSEL13				(),
  .PREADY13				(),
  .PRDATA13				(),
  .PSLVERR13			(),
		
  .PSEL14				(),
  .PREADY14				(),
  .PRDATA14				(),
  .PSLVERR14			(),
		
  .PSEL15				(),
  .PREADY15				(),
  .PRDATA15				(),
  .PSLVERR15			(),
		
  .PREADY				(PREADY),
  .PRDATA				(PRDATA),
  .PSLVERR				(PSLVERR)
  );
    
  cmsdk_apb_uart 	cmsdk_apb_uart_inst(
	.PCLK					(PCLK),
	.PCLKG				(PCLKG),
	.PRESETn				(PRESETn),
			
	.PSEL					(uart_psel),
	.PADDR				(PADDR[11:2]),
	.PENABLE				(PENABLE),
	.PWRITE				(PWRITE),
	.PWDATA				(PWDATA),
			
	.ECOREVNUM			(4'b0000),
			
	.PRDATA				(uart_prdata),
	.PREADY				(uart_pready),
	.PSLVERR				(uart_pslverr),
			
	.RXD					(RXD),
	.TXD					(TXD),
	.TXEN					(),
	.BAUDTICK			(),
			
	.TXINT				(TXINT),
	.RXINT				(RXINT),
	.TXOVRINT			(),
	.RXOVRINT			(),
	.UARTINT				()
  );
  
  
  cmsdk_apb_timer 	cmsdk_apb_timer_inst(
	.PCLK					(PCLK),
	.PCLKG				(PCLKG),
	.PRESETn				(PRESETn),
			
	.PSEL					(timer_psel),
	.PADDR				(PADDR[11:2]),
	.PENABLE				(PENABLE),
	.PWRITE				(PWRITE),
	.PWDATA				(PWDATA),
			
	.ECOREVNUM			(4'b0000),

	.PRDATA				(timer_prdata),
	.PREADY				(timer_pready),
	.PSLVERR				(timer_pslverr),
	
	.EXTIN				(),
	
	.TIMERINT			(TIMERINT)
  );
  
endmodule



