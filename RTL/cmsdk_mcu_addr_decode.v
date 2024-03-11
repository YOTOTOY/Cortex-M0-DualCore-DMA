//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2015 ARM Limited or its affiliates.
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
// Abstract : This module performs the address decode of the HADDR from the
//            CPU and generates the HSELs for each of the target peripherals.
//            Also performs address decode for MTB
//-----------------------------------------------------------------------------
//


module cmsdk_mcu_addr_decode
 (
    // System Address
    input wire [31:0]       haddr,

    output wire             flash_hsel,
	 output wire				 sdram_hsel,
	 output wire				 apbbus_hsel,
	 output wire				 cpu2_hsel,
	 output wire				 dma_hsel,
	 
    output wire             defslv_hsel
);   

    assign sdram_hsel    = haddr[31:28] == 4'h2;
    assign flash_hsel 	 = haddr[31:28] == 4'h0;
	 assign apbbus_hsel   = haddr[31:28] == 4'h4;
	 assign cpu2_hsel 	 = haddr[31:28] == 4'h5;
	 assign dma_hsel 		 = haddr[31:28] == 4'h1;
	 
    assign defslv_hsel   = ~(sdram_hsel | flash_hsel | apbbus_hsel | cpu2_hsel | dma_hsel);


endmodule
