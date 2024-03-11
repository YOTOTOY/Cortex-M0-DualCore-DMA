module cpu2_ctrl
(
input			wire			HSEL,
input			wire			HCLK,
input			wire			HRESETn,
input			wire			HREADY,
input			wire	[31:0]HADDR,
input			wire	[1:0]	HTRANS,
input			wire			HWRITE,
input			wire	[2:0]	HSIZE,
input			wire	[31:0]HWDATA,
output		wire			HREADYOUT,
output		wire	[31:0]HRDATA,
output		wire			HRESP,
output		wire			cpu2_en,
input			wire 	[1:0] HMASTER
);

assign HREADYOUT = 1'b1;
assign HRESP = 1'b0;
assign cpu2_en = cpu2_en_buf[0];

reg [31:0] hwdata_mask;
reg we;
reg [31:0] buf_hwaddr;
reg [31:0] buf_hrdata;
reg [31:0] cpu2_en_buf;

assign HRDATA = buf_hrdata;

always@(posedge HCLK or negedge HRESETn)	begin
	if(!HRESETn)	begin
		we <= 1'b0;
		buf_hwaddr <= 32'h0;
		buf_hrdata <= 32'b0;
		cpu2_en_buf <= 1'b0;
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
			if(buf_hwaddr == 32'h50000000)	begin
				cpu2_en_buf <= (HWDATA & hwdata_mask);
			end
		end
		if(HSEL & !HWRITE & HREADY & HTRANS[1])	begin
			if(HADDR == 32'h50000004)	begin
				buf_hrdata <= {30'h0, HMASTER};
			end
		end
	end
end

//always@(posedge HCLK or negedge HRESETn)	begin
//	if(!HRESETn)	begin
//		cpu2_en <= 1'b0;
//	end
//	else	begin
//		if(we)	begin
//			if(buf_hwaddr == 32'h50000000)	begin
//				cpu2_en <= (HWDATA & hwdata_mask);
//			end
//		end
//	end
//end
//
//always@(posedge HCLK or negedge HRESETn)	begin
//	if(!HRESETn)	begin
//		buf_hrdata <= 32'b0;
//	end
//	else	begin
//		if(HSEL & !HWRITE & HTRANS[1])	begin
//			if(HADDR == 32'h50000004)	begin
//				buf_hrdata <= {30'h0, HMASTER};
//			end
//		end
//	end
//end


endmodule
