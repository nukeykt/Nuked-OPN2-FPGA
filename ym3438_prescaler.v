module ym3438_prescaler(
	input MCLK,
	input PHI,
	input IC,
	output c1, c2,
	output reset_fsm
	);
	
	
	wire nIC = ~IC;
	
	wire pc1 = ~PHI;
	wire pc2 = PHI;
	
	wire [11:0] ic_latch_out;
	
	ym3438_sr_bit #(.SR_LENGTH(12)) ic_latch(
		.MCLK(MCLK),
		.bit_in(nIC),
		.sr_out(ic_latch_out),
		.c1(pc1),
		.c2(pc2)
		);
	
	wire fsm_reset_and = nIC & ~ic_latch_out[11];
	
	wire [3:0] fsm_res_latch_out;
	
	ym3438_sr_bit #(.SR_LENGTH(4)) fsm_res_latch(
		.MCLK(MCLK),
		.bit_in(fsm_reset_and),
		.sr_out(fsm_res_latch_out),
		.c1(pc1),
		.c2(pc2)
		);
	
	assign reset_fsm = fsm_res_latch_out[3];
	
	wire [5:0] clkgen_sr_out;
	
	wire clkgen_bit = ~(fsm_reset_and | (clkgen_sr_out[4:0] != 4'b0));
	
	ym3438_sr_bit #(.SR_LENGTH(6)) clkgen_sr(
		.MCLK(MCLK),
		.bit_in(clkgen_bit),
		.sr_out(clkgen_sr_out),
		.c1(pc1),
		.c2(pc2)
		);
	
	wire c1_in = clkgen_sr_out[0] | clkgen_sr_out[5];
	wire c2_in = clkgen_sr_out[2] | clkgen_sr_out[3];
	
	ym3438_sr_bit c1_sr(
		.MCLK(MCLK),
		.bit_in(c1_in),
		.sr_out(c1),
		.c1(pc1),
		.c2(pc2)
		);
	
	ym3438_sr_bit c2_sr(
		.MCLK(MCLK),
		.bit_in(c2_in),
		.sr_out(c2),
		.c1(pc1),
		.c2(pc2)
		);

endmodule
