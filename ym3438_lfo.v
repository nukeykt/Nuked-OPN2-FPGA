module ym3438_lfo
	(
	input MCLK,
	input c1,
	input c2,
	input [3:0] lfo,
	input fsm_sel23,
	input [7:0] reg_21,
	input IC
	);
	
	wire [6:0] lfo_subcnt_sr_in;
	wire [6:0] lfo_subcnt_sr_out;
	
	ym3438_sr_bit_array #(.DATA_WIDTH(7)) lfo_subcnt_sr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(lfo_subcnt_sr_in),
		.data_out(lfo_subcnt_sr_out)
		);
	
	wire lfo_subcnt_inc = reg_21[1] | fsm_sel23;
	
	wire lfo_subcnt_of;
	
	wire lfo_subcnt_res = ~(lfo_subcnt_of | ~IC);
	
	wire [6:0] lfo_subcnt_sum = lfo_subcnt_sr_out + lfo_subcnt_inc;
	
	assign lfo_subcnt_sr_in = lfo_subcnt_res ? lfo_subcnt_sum : 7'h00;
	
	wire [7:0] lfo_sel;
	
	genvar i;
		
	generate
		for (i = 0; i < 8; i=i+1)
		begin : l1
			assign lfo_sel[i] = lfo[2:0] == i;
		end
	endgenerate
	
	wire [7:0] lfo_of_check;
	
	assign lfo_of_check[0] = lfo_sel[0] & lfo_subcnt_sr_out[6] & lfo_subcnt_sr_out[5]
		& lfo_subcnt_sr_out[3] & lfo_subcnt_sr_out[2];
	assign lfo_of_check[1] = lfo_sel[1] & lfo_subcnt_sr_out[6] & lfo_subcnt_sr_out[3]
		& lfo_subcnt_sr_out[2] & lfo_subcnt_sr_out[0];
	assign lfo_of_check[2] = lfo_sel[2] & lfo_subcnt_sr_out[6] & lfo_subcnt_sr_out[2]
		& lfo_subcnt_sr_out[1] & lfo_subcnt_sr_out[0];
	assign lfo_of_check[3] = lfo_sel[3] & lfo_subcnt_sr_out[6] & lfo_subcnt_sr_out[1] & lfo_subcnt_sr_out[0];
	assign lfo_of_check[4] = lfo_sel[4] & lfo_subcnt_sr_out[5] & lfo_subcnt_sr_out[4]
		& lfo_subcnt_sr_out[3] & lfo_subcnt_sr_out[2] & lfo_subcnt_sr_out[1];
	assign lfo_of_check[5] = lfo_sel[5] & lfo_subcnt_sr_out[5] & lfo_subcnt_sr_out[3] & lfo_subcnt_sr_out[2];
	assign lfo_of_check[6] = lfo_sel[6] & lfo_subcnt_sr_out[3];
	assign lfo_of_check[7] = lfo_sel[7] & lfo_subcnt_sr_out[2] & lfo_subcnt_sr_out[0];
	
	assign lfo_subcnt_of = lfo_of_check != 8'h00;
	
	wire [6:0] lfo_cnt_sr_in;
	wire [6:0] lfo_cnt_sr_out;
	
	ym3438_sr_bit_array #(.DATA_WIDTH(7)) lfo_cnt_sr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(lfo_cnt_sr_in),
		.data_out(lfo_cnt_sr_out)
		);
	
	wire [6:0] lfo_cnt_sum = lfo_cnt_sr_out + lfo_subcnt_of;
	
	assign lfo_cnt_sr_in = lfo[3] ? lfo_cnt_sum : 7'h00;

endmodule
