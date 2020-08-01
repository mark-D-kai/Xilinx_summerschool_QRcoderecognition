`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/31 09:35:37
// Design Name: 
// Module Name: ad7768_one
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


`timescale 1ns/100ps

module ad7768_one (

  // device-interface

  input wire        DCLK,
  input wire        DRDY_in,
  input	wire		reset, 
  input wire [7:0]	data_in,
  input	wire		read_flag,
  

  output		sync_n,
  output	reg	[23:0]		adc_data0_out,
  output	reg	[23:0]		adc_data1_out,
  output	reg	[23:0]		adc_data2_out,
  output	reg	[23:0]		adc_data3_out,
  output	reg	[23:0]		adc_data4_out,
  output	reg	[23:0]		adc_data5_out,
  output	reg	[23:0]		adc_data6_out,
  output	reg	[23:0]		adc_data7_out,
  output 	reg 			read_end_flag
	);


  parameter   	IDLE			= 2'b01;
  parameter		READ	 		= 2'b10;

  parameter		idle_int_END	= 8'd32;



  //

  reg		[1:0]	state;

  reg 				sync_n_r;


  
  
  reg		[7:0]	shift_counter = 8'd0;
  
  reg		[31:0]		data0_shift_reg; //寄存器缓存
  reg		[31:0]		data1_shift_reg;
  reg		[31:0]		data2_shift_reg;
  reg		[31:0]		data3_shift_reg;
  reg		[31:0]		data4_shift_reg;
  reg		[31:0]		data5_shift_reg;
  reg		[31:0]		data6_shift_reg;
  reg		[31:0]		data7_shift_reg;

  reg		read_flag_s;
  wire		read_flag_start;

assign sync_n = ~sync_n_r;

always @(posedge DCLK ) begin
	read_flag_s <= read_flag;
end

assign read_flag_start = (read_flag & ~read_flag_s);


//state
always@(posedge DCLK or posedge reset) begin
	if(reset == 1'b1 )
		state<=IDLE;
	else case(state)
		IDLE:
			begin
				if(read_flag_start == 1'b1) begin
					state<=READ;
				end	
				else 
					state<=IDLE;
			end
		
		READ:
			begin
				if(read_flag == 1'b0) begin
					state<=IDLE;
				end					
				else 
					state<=READ;
			end

		default : state <= IDLE;
	endcase
end



//sync_n_r
always @(posedge DCLK or posedge reset) begin
	if (reset) begin
		// reset
		sync_n_r <= 1'b0;
	end
	else if (read_flag_start == 1'b1) begin
		sync_n_r <= 1'b1;
	end
	else begin
		sync_n_r <= 1'b0;
	end
end


//data0_shift_reg
always @(negedge DCLK or negedge reset) begin
	if((reset)||(shift_counter > 8'd31))begin  //复位或计数达到32 清零
		data0_shift_reg <= 32'b0;
		data1_shift_reg <= 32'b0;
		data2_shift_reg <= 32'b0;
		data3_shift_reg <= 32'b0;
		data4_shift_reg <= 32'b0;
		data5_shift_reg <= 32'b0;
		data6_shift_reg <= 32'b0;
		data7_shift_reg <= 32'b0;	
	end	
	else if((DRDY_in)&&(shift_counter <= 8'd31))begin 		
			data0_shift_reg <= {data0_shift_reg[30:0],data_in[0]};
			data1_shift_reg <= {data1_shift_reg[30:0],data_in[1]};		
			data2_shift_reg <= {data2_shift_reg[30:0],data_in[2]};
			data3_shift_reg <= {data3_shift_reg[30:0],data_in[3]};			
			data4_shift_reg <= {data4_shift_reg[30:0],data_in[4]};
			data5_shift_reg <= {data5_shift_reg[30:0],data_in[5]};		
			data6_shift_reg <= {data6_shift_reg[30:0],data_in[6]};
			data7_shift_reg <= {data7_shift_reg[30:0],data_in[7]};
	end		
end




//shift_counter
always @(negedge DCLK or negedge reset) begin
	if(reset )begin                    	//复位重置
		shift_counter <= 8'd0;
		end
	else if((DRDY_in)&&(shift_counter < 8'd31))  //开始计数 
		shift_counter <= shift_counter + 8'd1;
	else 	
		shift_counter <= 8'd0;			   //计数达到32个 清0 
end

//read_end_flag
always @(posedge DCLK or posedge reset) begin
	if (reset) begin
		// reset
		read_end_flag <= 1'b0;
	end
	else if (shift_counter == 8'd31) begin
		read_end_flag <= 1'b1;
	end
	// else begin
	// 	read_end_flag <= 1'b0;
	// end
	else if (read_flag == 1'b0) begin
		read_end_flag <= 1'b0;
	end
end



//有效数据传出
always @(posedge DCLK) begin	
	if(shift_counter == 8'd31)begin		
		adc_data0_out <= data0_shift_reg[23:0];
		adc_data1_out <= data1_shift_reg[23:0];
		adc_data2_out <= data2_shift_reg[23:0];
		adc_data3_out <= data3_shift_reg[23:0];		
		adc_data4_out <= data4_shift_reg[23:0];
		adc_data5_out <= data5_shift_reg[23:0];
		adc_data6_out <= data6_shift_reg[23:0];
		adc_data7_out <= data7_shift_reg[23:0];		
	end	
end

endmodule