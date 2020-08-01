// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//		"header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : yongchan jeon (Kris) poucotm@gmail.com
// File   : spi_sdo.v
// Create : 2020-07-14 20:51:02
// Revise : 2020-07-16 09:43:32
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

module spi_sdo(
	input wire 			clk,  //25MHZ
	input wire 			rst,  //上按�?
	input wire 			flag_sdo, //启动配置标志,右按�?
	input wire  		sdo,
	input wire	[7:0]	Addr1,
	input wire	[7:0]	Addr2,
	input wire			ins1_RW,
	input wire			ins2_RW,
	input wire	[7:0]	DATA_cmd1,
	input wire	[7:0]	DATA_cmd2,

	output wire			flag_end,
	output reg  [7:0]	sdo_data1,
	output reg  [7:0]	sdo_data2,
	output wire 		sdi,
	output wire 		cs_n,
	output wire 		sck //


	);


//state定义
parameter   	IDLE				= 5'b00001;
parameter		STATE_cmd 	 		= 5'b00010;
parameter		STATE_read 	 		= 5'b00100;
parameter		STATE_delay 		= 5'b01000;
parameter		STATE_delay2 		= 5'b10000;

//计数�?大�??
parameter		DIV_END_NUM = 4-1;
parameter		BIT_END_NUM = 16;
parameter		DELAY_END_NUM = 17 ;



//读写指令

//各个状�?�命令寄存器
reg		[15:0]	cmd_inst_shift;
reg		[15:0]	read_inst_shift;

reg 	[15:0]	sdo_data_shift1;
reg 	[15:0]	sdo_data_shift2;

reg		[4:0]	state;
reg		[2:0] 	div_cnt;
reg		[4:0]	bit_cnt;
reg		[4:0]	delay_cnt;
reg		[4:0]	delay2_cnt;
reg				cs_n_r;
reg				sck_r;
reg				sdi_r;
reg				flag_end_r;
reg 	[6:0]	Addr1_r;
reg 	[6:0]	Addr2_r;







//sck  cs_n sdi
assign sck = sck_r;
assign cs_n = cs_n_r;
assign sdi = sdi_r;
assign flag_end = flag_end_r;

//Addr_r
always @* begin
	Addr1_r <= Addr1[6:0];
end
//Addr2_r
always @* begin
	Addr2_r <= Addr2[6:0];
end

//可用 状�?�跳�?
always@(posedge clk or posedge rst) begin
	if(rst == 1'b1 )
		state<=IDLE;
	else case(state)
		IDLE:
			begin
				if(flag_sdo == 1) begin
					state<=STATE_cmd;
				end	
				else 
					state<=IDLE;
			end
		
		STATE_cmd:
			begin
				if(div_cnt == DIV_END_NUM && bit_cnt == BIT_END_NUM) begin
					state<=STATE_delay;
				end					
				else 
					state<=STATE_cmd;
			end

		STATE_delay:
			begin
				if(delay_cnt == DELAY_END_NUM) begin
					state<=STATE_read;
				end	
				else 
					state<=STATE_delay;
			end

		STATE_read:
			begin
				if(bit_cnt == BIT_END_NUM && div_cnt==DIV_END_NUM)
					state<=STATE_delay2;
				else 
					state<=STATE_read;
			end
		STATE_delay2:
			begin
				if(delay2_cnt == DELAY_END_NUM) begin
					state<=IDLE;
				end	
				else 
					state<=STATE_delay2;
			end
		default : state <= IDLE;
	endcase
end

//可用 div_cnt生成
always @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		// reset
		div_cnt <= 'd0;
	end
	else if (div_cnt == DIV_END_NUM) begin
		div_cnt <= 'd0;
	end
	else if ( state == STATE_cmd || state == STATE_read) begin  
		div_cnt <= div_cnt + 1'b1;
	end
end
//可用 bit_cnt
always @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		// reset
		bit_cnt <= 'd0;
	end
	else if (bit_cnt ==BIT_END_NUM && div_cnt == DIV_END_NUM ) begin 
		bit_cnt <= 'd0;
	end
	else if (div_cnt == DIV_END_NUM && (state == STATE_cmd || state == STATE_read) ) begin  
		bit_cnt <= bit_cnt + 1'b1;
	end
end
//可用 delay_cnt
always @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		// reset
		delay_cnt <= 'd0;
	end
	else if (delay_cnt == DELAY_END_NUM ) begin
		delay_cnt <= 'd0;
	end
	else if (state == STATE_delay) begin
		delay_cnt <= delay_cnt + 1'b1;
	end
end

//可用 delay2_cnt
always @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		// reset
		delay2_cnt <= 'd0;
	end
	else if (delay2_cnt == DELAY_END_NUM ) begin
		delay2_cnt <= 'd0;
	end
	else if (state == STATE_delay2) begin
		delay2_cnt <= delay2_cnt + 1'b1;
	end
end
//可用 cs_n_r
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		cs_n_r <= 1'b1;
	end
	else if (div_cnt == DIV_END_NUM && bit_cnt == BIT_END_NUM && (state == STATE_cmd || state == STATE_read) ) begin
		cs_n_r <= 1'b1;
	end
	else if (state == IDLE && flag_sdo == 1'b1) begin
		cs_n_r <= 1'b0;
	end
	else if (state == STATE_delay && delay_cnt == DELAY_END_NUM) begin
		cs_n_r <= 1'b0;
	end
end
//可用 sck_r
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		sck_r <= 1'b0;
	end
	else if (div_cnt == (DIV_END_NUM >> 1) && bit_cnt != BIT_END_NUM && (state == STATE_cmd || state == STATE_read) ) begin
		sck_r <= 1'b1;
	end
	else if (div_cnt == (DIV_END_NUM ) && bit_cnt != BIT_END_NUM && (state == STATE_cmd || state == STATE_read) ) begin
		sck_r <= 1'b0;
	end
end

//flag_end_r
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		flag_end_r <= 1'b0;
	end
	else if (state == STATE_delay2 && delay2_cnt == DELAY_END_NUM ) begin
		flag_end_r <= 1'b1;
	end
	else begin
		flag_end_r <= 1'b0;
	end
end

//cmd_inst_shift
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		cmd_inst_shift <= 'd0;
	end
	else if (flag_sdo == 1'b1 && state == IDLE) begin
		cmd_inst_shift <= {ins1_RW,Addr1_r,DATA_cmd1};
	end
	else if (state == STATE_cmd && div_cnt == DIV_END_NUM ) begin
		cmd_inst_shift <= {cmd_inst_shift[14:0],1'b0};
	end
end

//read_inst_shift;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		read_inst_shift <= 'd0;
	end
	else if (flag_sdo == 1'b1 && state == IDLE) begin
		read_inst_shift <= {ins2_RW,Addr2_r,DATA_cmd2};
	end
	else if (state == STATE_read && div_cnt == DIV_END_NUM ) begin
		read_inst_shift <= {read_inst_shift[14:0],1'b0};
	end
end


//sdi_r
always @* begin
	if (state == STATE_cmd) begin
		sdi_r <= cmd_inst_shift[15];
	end
	else if (state == STATE_read) begin
		sdi_r <= read_inst_shift[15];
	end
	else begin
		sdi_r <= 1'b0;
	end
end

//sdo_data_shift1
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		sdo_data_shift1 <= 'd0;
	end
	else if (state == STATE_cmd && div_cnt == (DIV_END_NUM >> 1) && bit_cnt != BIT_END_NUM ) begin
		sdo_data_shift1 <= {sdo_data_shift1[14:0],sdo};
	end
end
//sdo_data1
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		sdo_data1 <= 8'd0;
	end
	else if (state == STATE_cmd && div_cnt == DIV_END_NUM && bit_cnt == BIT_END_NUM) begin
		sdo_data1 <= sdo_data_shift1[7:0];
	end
end

//sdo_data_shift2
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		sdo_data_shift2 <= 'd0;
	end
	else if (state == STATE_read && div_cnt == (DIV_END_NUM >> 1) && bit_cnt != BIT_END_NUM ) begin
		sdo_data_shift2 <= {sdo_data_shift2[14:0],sdo};
	end
end
//sdo_data2
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		sdo_data2 <= 8'd0;
	end
	else if (state == STATE_read && div_cnt == DIV_END_NUM && bit_cnt == BIT_END_NUM) begin
		sdo_data2 <= sdo_data_shift2[7:0];
	end
end



endmodule