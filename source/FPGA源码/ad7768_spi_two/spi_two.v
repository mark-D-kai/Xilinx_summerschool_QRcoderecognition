`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/31 10:28:26
// Design Name: 
// Module Name: ad7768_spi
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


module spi_two(
	input wire 			sclk,  //100MHZ
	input wire 			srst,  //ÃƒÂ¤Ã‚Â¸Ã�?�Â ÃƒÂ¦Ã�?�â€™Ã¢â�?�¬Â°ÃƒÂ©Ã�????
	input wire  		sdo,
	
	output wire 			sdi,
	output wire 			cs_n,
	output wire 			sck,//ÃƒÂ¥Ã‚Â¯Ã�?�Â¹clkÃƒÂ§Ã…Â�??4ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ©Ã�?�Â¢Ã�??ËœÃƒÂ¯Ã‚Â¼Ã�?�â€™clkÃƒÂ§Ã…Â�??1/4MHZ


	output wire 		reset_n,  //ad7768ÃƒÂ§Ã‚Â¡Ã�?�Â¬ÃƒÂ¥Ã�?�Â¤Ã�?�ÂÃƒÂ¤Ã�?�Â�??	
	output wire 		START_n,		//ad7768ÃƒÂ¤Ã‚Â¸Ã�?�ÂÃƒÂ¤Ã�?�Â½Ã�?�Â¿ÃƒÂ§Ã¢â�?�¬ÂÃ�?�Â¨STARTÃƒÂ¥Ã¢â‚¬â�?�¢Ã�?�â€™SYNC_OUTÃƒÂ¦Ã…Â½Ã�?�Â¥ÃƒÂ¥Ã�?�ÂÃ�?�Â�?
	output   wire       mclk
 	);
wire    rst;
assign rst = srst;
//25MHzç›²æ½žæ�?�èŽ½éˆ¥æ¾Ÿè¯¥â�?�¢æ�?�îŸ�?�ãƒ�?�å�?��???
(*mark_debug = "true"*)
wire 		clk;
reg [1:0] cnt1 = 0; //
reg btnclk = 0; //å¿™éˆ¥æ�?��?�ç¹â�????æ«¯è¯¥ãƒ‹å�?�¡æ¾ãƒ�?�Ñ€?å§‘ãƒ�????
parameter cnt1value ='d1; 
always @ (posedge sclk)
begin
	if(cnt1 == cnt1value) //çŒ«åºéš†å¿™éˆ¥â’™æ‡ŠîŸŠî�?�™âˆ¶Î²å®¦âˆ¶ãƒ‚æƒ»çŸ«îž æŸ¯å¹»î�????
	begin
		btnclk = ~btnclk;
		cnt1 = 1'd0;
	end
	else
	begin
		cnt1 = cnt1 + 1'd1;
	end
end
assign clk = btnclk;
//enddebug



//
wire [7:0]	Addr1;
wire [7:0]	Addr2;
wire [7:0]	DATA1_cmd;
wire [7:0]	DATA2_cmd;
wire 		ins1_RW; //1read,0write
wire 		ins2_RW;

wire		flag_end1;

wire [7:0]	sdo_data1;

wire [7:0]	sdo_data2;

wire		sck1;

wire		cs_1_n;

wire		sdi1;

//
wire [7:0]	Addr3;
wire [7:0]	Addr4;
wire [7:0]	DATA3_cmd;
wire [7:0]	DATA4_cmd;
wire 		ins3_RW;
wire 		ins4_RW;

wire		flag_end2;

wire [7:0]	sdo_data3;

wire [7:0]	sdo_data4;

wire		sck2;

wire		cs_2_n;

wire		sdi2;
//






//
parameter		idle_int_END	= 20'd500000;

reg [19:0]		idle_cnt;
reg				idle_flag;

wire 			flag_sdo;
reg 			flag_sdo_r;
//idle_cnt
always @(posedge clk or posedge rst) begin
		if (rst) begin
			// reset
			idle_cnt <= 20'd0;
		end
		else if (idle_cnt == idle_int_END) begin
			idle_cnt <= 20'd0;
		end
		else if ( (idle_cnt < idle_int_END) && idle_flag == 1'b1) begin
			idle_cnt <= idle_cnt + 1'b1;
		end
	end	
//idle_flag
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		idle_flag <= 1'b1;
	end
	else if (idle_cnt == idle_int_END) begin
		idle_flag <= 1'b0;
	end
end
//flag_sdo_r
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// reset
		flag_sdo_r <= 1'b0;
	end
	else if (idle_cnt == idle_int_END) begin
		flag_sdo_r <= 1'b1;
	end
	else begin
		flag_sdo_r <= 1'b0;
	end
end

assign flag_sdo = flag_sdo_r;
//

//
assign mclk = 1'b0;  //AD7768ÃƒÂ©Ã¢â‚¬Â¡�???Â¡ÃƒÂ§Ã¢?ÂÃ‚Â¨CMOSÃƒÂ¦Ã¢â‚¬�??Ã‚Â¶ÃƒÂ©�???â„¢�???
assign reset_n = ~rst;
assign START_n = 1'b1;
//

//
assign Addr1= 8'h04;
assign Addr2= 8'h06;
assign DATA1_cmd= 8'b0011_0011;
assign DATA2_cmd= 8'b1001_0000;
assign ins1_RW = 1'b0;
assign ins2_RW = 1'b0;

//
assign Addr3= 8'h01;
assign Addr4= 8'h03;
assign DATA3_cmd= 8'b0000_0011;
assign DATA4_cmd= 8'b0000_0000;
assign ins3_RW = 1'b0;
assign ins4_RW = 1'b0;


//
assign cs_n = cs_1_n & cs_2_n ;
assign sck = sck1 | sck2 ;
assign sdi = sdi1 | sdi2 ;



	spi_sdo inst_spi_sdo1 (
			.clk       (clk),
			.rst       (rst),
			.flag_sdo  (flag_sdo),
			.sdo       (sdo),
			.Addr1     (Addr1),
			.Addr2     (Addr2),
			.ins1_RW   (ins1_RW),
			.ins2_RW   (ins2_RW),
			.DATA_cmd1 (DATA1_cmd),
			.DATA_cmd2 (DATA2_cmd),
			.flag_end  (flag_end1),
			.sdo_data1 (sdo_data1),
			.sdo_data2 (sdo_data2),
			.sdi       (sdi1),
			.cs_n      (cs_1_n),
			.sck       (sck1)
		);

	spi_sdo inst_spi_sdo2 (
			.clk       (clk),
			.rst       (rst),
			.flag_sdo  (flag_end1),
			.sdo       (sdo),
			.Addr1     (Addr3),
			.Addr2     (Addr4),
			.ins1_RW   (ins3_RW),
			.ins2_RW   (ins4_RW),
			.DATA_cmd1 (DATA3_cmd),
			.DATA_cmd2 (DATA4_cmd),
			.flag_end  (flag_end2),
			.sdo_data1 (sdo_data3),
			.sdo_data2 (sdo_data4),
			.sdi       (sdi2),
			.cs_n      (cs_2_n),
			.sck       (sck2)
		);

endmodule
