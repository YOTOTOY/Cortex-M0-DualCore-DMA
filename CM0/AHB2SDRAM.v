module AHB2SDRAM(
input			wire				HSEL,
input			wire				HCLK,
input			wire				HRESETn,
input			wire				HREADY,
input			wire	[31:0]	HADDR,
input			wire	[1:0]		HTRANS,
input			wire				HWRITE,
input			wire	[2:0]		HSIZE,
input			wire	[31:0]	HWDATA,
output		reg				HREADYOUT,
output		reg	[31:0]	HRDATA,
output		wire				HRESP,

output  		wire      	  	CKE,
output  		wire      	  	CSn,
output  		wire     	   RASn,
output  		wire     	   CASn,
output  		wire     	   WEn,
output  		wire 	[12:0] 	ADDR,
output  		wire 	[1:0] 	BA,
inout   		wire 	[31:0] 	DQ,
output  		wire 	[3:0]  	DQM
);


parameter
//50MHz 20ns
	t0					 = 20,
	tDelay 			 = 200*1000/t0,	//200us
	tFresh			 = 7*1000/t0,		//7us
	tRP				 = 42/t0,			//tRP/t0
	tRC				 = 60/t0,			//tRC/t0
	tMRO				 = 2,					//2clk
	tRCD				 = 15/20,			//tRCD/t0
	nCAS 				 = 3;					//nRAS
	
parameter
//CSn RASn CASn WEn
	CMD_NOP         = 4'b0111,
	CMD_LoadModeReg = 4'b0000,
	CMD_Precharge	 = 4'b0010,
	CMD_Refresh     = 4'b0001,
	CMD_BankActive  = 4'b0011,
	CMD_Write       = 4'b0100,
	CMD_Read        = 4'b0101;
	
parameter
	STA_IDLE        = 4'b0000,
	STA_Precharge   = 4'b0001,
	STA_AutoRefresh = 4'b0010,
	STA_SelfRefresh = 4'b0011,
	STA_ModeRegSet  = 4'b0100,
	STA_RowAct      = 4'b0101,
	STA_WriteIDLE   = 4'b0110,
	STA_Write       = 4'b0111,
	STA_ReadIDLE    = 4'b1000,
	STA_Read        = 4'b1001;

parameter
	ALL_BANK 			 = (1 << 10),
	AUTO_PRECHARGE_ON  = (1 << 10),
	AUTO_PRECHARGE_OFF = (0 << 10),
	OP_CODE 				 = 0,
	CASLatency			 = 3'b011,
	BurstType 			 = 0,
	BurstLength			 = 3'b001;		

reg	[13:0]	delay_cnt;
reg 	[0:0]		precharge_cnt;
reg	[2:0]		autorefresh_cnt;
reg 	[1:0]		modreg_cnt;
reg 	[8:0]		fresh_cnt;
reg	[0:0]		write_cnt;
reg	[0:0]		read_cnt;
reg	[2:0]		CASLatency_cnt;

reg				autorefresh_finished;
reg				init_finished;
reg 				fresh_flag;
reg 				fresh_req;

reg	[3:0]		STA;
reg 	[3:0]		cmd;

reg	[12:0]	ADDR_reg;
reg	[1:0]		BA_reg;
reg	[31:0]	DQ_reg;
reg	[3:0]		DQM_reg;

reg 	[3:0] 	hwdata_mask;
reg 	[31:0] 	hwaddr_buf;
reg	[31:0]	hwdata_buf;

reg				write;
reg				read;
reg 				write_finished;
reg				read_finished;

assign HRESP = 1'b0;
assign CKE = 1;
assign {CSn,RASn,CASn,WEn} = cmd;
assign BA = BA_reg;
assign ADDR = ADDR_reg;
assign DQ = (STA == STA_Write) ? DQ_reg : 32'bz;
assign DQM = DQM_reg;

always@(posedge HCLK or negedge HRESETn)	begin
	if(!HRESETn)	begin
		HREADYOUT <= 1;
		hwaddr_buf <= 32'h0;
		write <= 0;
		read <= 0;
	end
	else	begin
		write <= HSEL & HWRITE & HTRANS[1] & HREADY;
		read <= HSEL & !HWRITE & HTRANS[1] & HREADY;
		HREADYOUT <= ((HREADY & HSEL & HTRANS[1]) | write | read) ? 0 : ~(write_finished^read_finished);
		if(HREADY & HSEL & HTRANS[1])	begin
			hwaddr_buf <= HADDR;
			casez(HSIZE[1:0])
				2'b1? : hwdata_mask <= 4'b1111;
				2'b01 : hwdata_mask <= (4'b0011 << (2 * HADDR[1]));
				2'b00 : hwdata_mask <= (4'b0001 << (HADDR[1:0]));
			endcase
		end
	end
end

always@(posedge HCLK)	begin
	if(write)	begin
		hwdata_buf <= HWDATA;
	end
end

always@(posedge HCLK or negedge HRESETn)	begin
	if(!HRESETn)	begin
		fresh_cnt <= 'd0;
		fresh_flag <= 0;
	end
	else	begin
		if(init_finished)	begin
			if(fresh_cnt == tFresh)	begin
				fresh_flag <= 1;
				fresh_cnt <= 'd0;
			end
			else	begin
				fresh_flag <= 0;
				fresh_cnt <= fresh_cnt + 1;
			end
		end
	end
end

always@(posedge HCLK or negedge HRESETn)	begin
	if(!HRESETn)	begin
		delay_cnt <= 'd0;
		precharge_cnt <= 'd0;
		autorefresh_cnt <= 'd0;
		modreg_cnt <= 'd0;
		write_cnt <= 'd0;
		read_cnt <= 'd0;
		CASLatency_cnt <= 'd0;
		autorefresh_finished <= 'd0;
		init_finished <= 'd0;
		fresh_req <= 'd0;
		write_finished <= 1;
		read_finished <= 1;
		cmd <= CMD_NOP;
		STA <= STA_IDLE;
	end
	else	begin
		if(delay_cnt == tDelay)	begin	//200us
			STA <= STA_Precharge;
		end
		else	begin
			cmd <= CMD_NOP;
			delay_cnt <= delay_cnt + 1;
		end
			
		case(STA)
			STA_Precharge	:	begin
										if(write)	begin
											STA <= STA_WriteIDLE;
											write_finished <= 0;
										end
										else if(read)	begin
											STA <= STA_ReadIDLE;
											read_finished <= 0;
										end
										else if(precharge_cnt == 0)	begin
											cmd <= CMD_Precharge;
											ADDR_reg <= ALL_BANK;
											STA <= STA_Precharge;
										end
										else if(precharge_cnt == tRP)	begin
											if(init_finished)	begin
												STA <= STA_RowAct;
												fresh_req <= 0;
											end
											else	begin
												STA <= STA_AutoRefresh;
											end
										end
										else	begin
											STA <= STA_Precharge;
										end
										if(precharge_cnt == tRP)	begin
											precharge_cnt <= 0;
										end
										else	begin
											precharge_cnt <= precharge_cnt + 1;
										end
									end
			STA_AutoRefresh:	begin
										if(autorefresh_cnt == 0)	begin
											cmd <= CMD_Refresh;
											STA <= STA_AutoRefresh;
										end
										else if(autorefresh_cnt == tRC)	begin
											if(!autorefresh_finished)	begin
												autorefresh_finished <= 1;
												STA <= STA_AutoRefresh;
											end
											else	begin
												if(init_finished)	begin
													STA <= STA_RowAct;
												end
												else	begin
													STA <= STA_ModeRegSet;
												end
											end
										end
										else	begin
											STA <= STA_AutoRefresh;
											cmd <= CMD_NOP;
										end
										if(autorefresh_cnt == tRC)	begin
											autorefresh_cnt <= 0;
										end
										else	begin
											autorefresh_cnt <= autorefresh_cnt + 1;
										end
									end
			STA_ModeRegSet	:	begin
										if(modreg_cnt == 0)	begin
											cmd <= CMD_LoadModeReg;
											BA_reg <= 2'b00;
											ADDR_reg <= {3'b0,OP_CODE,2'b0,CASLatency,BurstType,BurstLength};
											STA <= STA_ModeRegSet;
										end
										else if(modreg_cnt == tMRO)	begin
											STA <= STA_RowAct;
											init_finished <= 1;
										end
										else	begin
											STA <= STA_ModeRegSet;
											cmd <= CMD_NOP;
										end
										if(modreg_cnt == tMRO)	begin
											modreg_cnt <= 0;
										end
										else	begin
											modreg_cnt <= modreg_cnt + 1;
										end
									end
			STA_RowAct		:	begin
										cmd <= CMD_NOP;
										if(fresh_flag)	begin
											fresh_req <= 1;
										end
										else	begin
											fresh_req <= fresh_req;
										end
										if(write)	begin
											STA <= STA_WriteIDLE;
											write_finished <= 0;
										end
										else if(read)	begin
											STA <= STA_ReadIDLE;
											read_finished <= 0;
										end
										else if(fresh_req)	begin
											STA <= STA_Precharge;
										end
										else	begin
											STA <= STA_RowAct;
										end
									end
			STA_WriteIDLE	:	begin
										if(write_cnt == tRCD)	begin
											cmd <= CMD_BankActive;
											BA_reg <= hwaddr_buf[28:27];
											ADDR_reg <= hwaddr_buf[14:2]; 
											STA <= STA_Write;
											DQ_reg <= hwdata_buf;
										end
										else	begin
											STA <= STA_WriteIDLE;
											cmd <= CMD_NOP;
										end
										if(write_cnt == tRCD)	begin
											write_cnt <= 0;
										end
										else begin
											write_cnt <= write_cnt + 1;
										end
									end
			STA_Write		:	begin
											cmd <= CMD_Write;
											BA_reg <= hwaddr_buf[28:27];
											ADDR_reg <= {hwaddr_buf[26:25],AUTO_PRECHARGE_OFF,hwaddr_buf[24:15]};
											DQM_reg <= ~hwdata_mask;
											write_finished <= 1;
											STA <= STA_Precharge;
									end
			STA_ReadIDLE	:	begin
										if(read_cnt == tRCD)	begin
											cmd <= CMD_BankActive;
											BA_reg <= hwaddr_buf[28:27];
											ADDR_reg <= hwaddr_buf[14:2];
											STA <= STA_Read;
										end
										else	begin
											STA <= STA_ReadIDLE;
											cmd <= CMD_NOP;
										end
										if(read_cnt == tRCD)	begin
											read_cnt <= 0;
										end
										else begin
											read_cnt <= read_cnt + 1;
										end
									end
			STA_Read			:	begin
										if(CASLatency_cnt == 0)	begin
											cmd <= CMD_Read;
											BA_reg <= hwaddr_buf[28:27];
											ADDR_reg <= {hwaddr_buf[26:25],AUTO_PRECHARGE_OFF,hwaddr_buf[24:15]};
											DQM_reg <= ~hwdata_mask;
											STA <= STA_Read;
										end
										else if(CASLatency_cnt == (nCAS+1))	begin
											HRDATA <= DQ;
											STA <= STA_Precharge;
											read_finished <= 1;
										end
										else	begin
											STA <= STA_Read;
											cmd <= CMD_NOP;
										end
										if(CASLatency_cnt == (nCAS+1))	begin
											CASLatency_cnt <= 0;
										end
										else	begin
											CASLatency_cnt <= CASLatency_cnt + 1;
										end
									end
		endcase	
	end
end



endmodule
