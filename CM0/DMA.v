module DMA(
input			wire				HSEL,
input			wire				HCLK,
input			wire				HRESETn,
input			wire				HREADY,
input			wire	[31:0]	HADDR,
input			wire	[1:0]		HTRANS,
input			wire				HWRITE,
input			wire	[2:0]		HSIZE,
input			wire	[31:0]	HWDATA,
output		wire				HREADYOUT,
output		wire	[31:0]	HRDATA,
output		wire				HRESP,

output  		wire          	HSELM,
output  		wire 	[31:0]   HADDRM,
output  		wire  [1:0]   	HTRANSM,
output  		wire  [2:0]   	HSIZEM,
output  		wire          	HWRITEM,
output  		wire  [3:0]   	HPROTM,
output  		wire  [2:0]   	HBURSTM,
output  		wire          	HMASTLOCKM,
output  		wire 	[31:0] 	HWDATAM,
		
input 		wire          	HREADYM,
input 		wire          	HRESPM,
input 		wire 	[31:0] 	HRDATAM,
output		wire				IRQM
);

parameter
	STA_IDLE   = 3'b000,
	STA_STAGE0 = 3'b001,
	STA_STAGE1 = 3'b010,
	STA_STAGE2 = 3'b011,
	STA_STAGE3 = 3'b100,
	STA_STAGE4 = 3'b101,
	STA_STAGE5 = 3'b110;
	
reg 				we;
reg 	[31:0] 	hwdata_mask;
reg 	[31:0] 	buf_hwaddr;
reg 	[31:0] 	buf_hrdata;

reg				DMA_start_flag;
reg 				DMA_iten_flag;
reg	[31:0]	DMA_sourceaddr;
reg	[31:0]	DMA_targetaddr;
reg	[31:0]	DMA_datasize;

reg				DMA_transmite_flag;
reg				DMA_transmite_flag_r;
reg	[31:0]	cnt_addr;
reg	[31:0]	data_buf;

reg	[2:0]		STA;

reg 	[31:0]   HADDRM_buf;
reg  	[1:0]   	HTRANSM_buf;
reg  	[2:0]   	HSIZEM_buf;
reg          	HWRITEM_buf;
reg 	[31:0] 	HWDATAM_buf;

assign HRDATA = buf_hrdata;
assign HREADYOUT = 1'b1;
assign HRESP = 1'b0;

assign HSELM = 1'b1;
assign HMASTLOCKM = 1'b0;
assign HBURSTM = 3'b000;
assign HPROTM = 4'b0011;

assign HADDRM = HADDRM_buf;
assign HTRANSM = HTRANSM_buf;
assign HSIZEM = HSIZEM_buf;
assign HWRITEM = HWRITEM_buf;
assign HWDATAM = HWDATAM_buf;

assign IRQM = DMA_iten_flag ? (DMA_transmite_flag_r & !DMA_transmite_flag) : 1'b0;

always@(posedge HCLK or negedge HRESETn)	begin
	if(!HRESETn)	begin
		DMA_transmite_flag <= 1'b0;
		cnt_addr <= 'd0;
		STA <= STA_IDLE;
		HTRANSM_buf <= 2'b00;
		HSIZEM_buf <= 2'b00;
		HWRITEM_buf <= 1'b0;
		HWDATAM_buf <= 32'b0;
		HADDRM_buf <= 32'b0;
		we <= 1'b0;
		buf_hwaddr <= 32'h0;
		buf_hrdata <= 32'b0;
		DMA_sourceaddr <= 32'b0;
		DMA_targetaddr <= 32'b0;
		DMA_datasize <= 32'b0;
		DMA_start_flag <= 1'b0;
		DMA_iten_flag <= 1'b0;
	end
	else	begin
		
		we <= HSEL & HWRITE & HREADY & HTRANS[1];
		if(HSEL & HREADY & HTRANS[1])	begin
			buf_hwaddr <= HADDR;
			casez(HSIZE[1:0])
				2'b1? : hwdata_mask <= 32'hFFFFFFFF;
				2'b01 : hwdata_mask <= (32'h0000FFFF << (16 * HADDR[1]));
				2'b00 : hwdata_mask <= (32'h000000FF << (8 * HADDR[1:0]));
			endcase
		end
		if(we)	begin
			if(buf_hwaddr[7:0] == 8'h00)	begin
				DMA_start_flag <= (HWDATA & hwdata_mask) & 32'h00000001;
				DMA_iten_flag <= ((HWDATA & hwdata_mask) & 32'h00000002) >> 1;
			end
			if(buf_hwaddr[7:0] == 8'h04)	begin
				DMA_sourceaddr <= (HWDATA & hwdata_mask);
			end
			if(buf_hwaddr[7:0] == 8'h08)	begin
				DMA_targetaddr <= (HWDATA & hwdata_mask);
			end
			if(buf_hwaddr[7:0] == 8'h0C)	begin
				DMA_datasize <= (HWDATA & hwdata_mask);
			end
		end
		
		DMA_transmite_flag_r <= DMA_transmite_flag;

		case(STA)
			STA_IDLE	:	begin
				if(DMA_start_flag)	begin
					STA <= STA_STAGE0;
					DMA_transmite_flag <= 1'b1;
				end
				else	begin
					STA <= STA_IDLE;
					cnt_addr <= 'd0;
					HTRANSM_buf <= 2'b00;
					HSIZEM_buf <= 2'b00;
					HWRITEM_buf <= 1'b0;
					HWDATAM_buf <= 32'b0;
					HADDRM_buf <= 32'b0;
				end
			end
			STA_STAGE0	:	begin
				if(DMA_start_flag)	begin
					if(HREADYM)	begin
						HADDRM_buf <= DMA_sourceaddr + (cnt_addr << 2);
						HTRANSM_buf <= 2'b10;
						HSIZEM_buf <= 2'b10;
						HWRITEM_buf <= 1'b0;
						STA <= STA_STAGE1;
					end
					else	begin
						STA <= STA_STAGE0;
					end
				end
				else	begin
					STA <= STA_IDLE;
					DMA_transmite_flag <= 1'b0;
					DMA_start_flag <= 1'b0;
				end
			end
			STA_STAGE1	:	begin
				if(DMA_start_flag)	begin
					if(HREADYM)	begin
						HADDRM_buf <= 32'b0;
						HTRANSM_buf <= 2'b00;
						HSIZEM_buf <= 2'b00;
						HWRITEM_buf <= 1'b0;
						STA <= STA_STAGE2;
					end
					else	begin
						STA <= STA_STAGE1;
					end
				end
				else	begin
					STA <= STA_IDLE;
					DMA_transmite_flag <= 1'b0;
					DMA_start_flag <= 1'b0;
				end
			end
			STA_STAGE2	:	begin
				if(DMA_start_flag)	begin
					if(HREADYM)	begin
						data_buf <= HRDATAM;
						STA <= STA_STAGE3;
					end
					else	begin
						STA <= STA_STAGE2;
					end
				end
				else	begin
					STA <= STA_IDLE;
					DMA_transmite_flag <= 1'b0;
					DMA_start_flag <= 1'b0;
				end
			end
			STA_STAGE3	:	begin
				if(DMA_start_flag)	begin
					if(HREADYM)	begin
						HADDRM_buf <= DMA_targetaddr + (cnt_addr << 2);
						HTRANSM_buf <= 2'b10;
						HSIZEM_buf <= 2'b10;
						HWRITEM_buf <= 1'b1;
						STA <= STA_STAGE4;
					end
					else	begin
						STA <= STA_STAGE3;
					end
				end
				else	begin
					STA <= STA_IDLE;
					DMA_transmite_flag <= 1'b0;
					DMA_start_flag <= 1'b0;
				end
			end
			STA_STAGE4	:	begin
				if(DMA_start_flag)	begin
					if(HREADYM)	begin
						HWDATAM_buf <= data_buf;
						HADDRM_buf <= 32'b0;
						STA <= STA_STAGE5;
					end
					else	begin
						STA <= STA_STAGE4;
					end
				end
				else	begin
					STA <= STA_IDLE;
					DMA_transmite_flag <= 1'b0;
					DMA_start_flag <= 1'b0;
				end
			end
			STA_STAGE5	:	begin
				if(DMA_start_flag)	begin
					if(HREADYM)	begin
						HADDRM_buf <= 32'b0;
						HTRANSM_buf <= 2'b00;
						HSIZEM_buf <= 2'b00;
						HWRITEM_buf <= 1'b0;
						if(cnt_addr == DMA_datasize)	begin
							cnt_addr <= 'd0;
							DMA_transmite_flag <= 1'b0;
							DMA_start_flag <= 1'b0;
							STA <= STA_IDLE;
						end
						else	begin
							cnt_addr <= cnt_addr + 1'd1;
							STA <= STA_STAGE0;
						end
					end
					else	begin
						STA <= STA_STAGE5;
					end
				end
				else	begin
					STA <= STA_IDLE;
					DMA_transmite_flag <= 1'b0;
					DMA_start_flag <= 1'b0;
				end
			end
		endcase
	end
end

endmodule
