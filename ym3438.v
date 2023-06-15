module ym3438(
	MCLK, PHI, DATA_i, DATA_o, DATA_o_z, TEST_i, TEST_o, IC, IRQ, CS, WR, RD, ADDRESS, MOL, MOR
	,
	d_c1, d_c2
	);
	input MCLK;
	input PHI;
	
	input [7:0] DATA_i;
	output [7:0] DATA_o;
	output DATA_o_z;
	
	input TEST_i;
	output TEST_o;
	
	input IC, IRQ, CS, WR, RD;
	
	input [1:0] ADDRESS;
	
	output [8:0] MOL, MOR;
	
	// temp
	assign MOL = 9'b0;
	assign MOR = 9'b0;
	assign DATA_o = 8'b0;
	assign DATA_o_z = 1'b0;
	assign TEST_o = 1'b0;
	
	wire c1, c2;
	wire reset_fsm;
	
	wire [2:0] connect = 0;
	
	ym3438_prescaler prescaler(
		.MCLK(MCLK),
		.PHI(PHI),
		.IC(IC),
		.c1(c1),
		.c2(c2),
		.reset_fsm(reset_fsm)
		);
		
	wire fsm_sel0;
	wire fsm_sel1;
	wire fsm_sel2;
	wire fsm_sel23;
	wire fsm_timer_ed;
	wire fsm_op1_sel;
	wire fsm_op2_sel;
	wire alg_fb_sel;
	wire alg_op2;
	wire alg_cur1;
	wire alg_cur2;
	wire alg_op1_0;
	wire alg_out;
	
	ym3438_fsm fsm(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.fsm_reset(reset_fsm),
		.connect(connect),
		.fsm_sel0_o(fsm_sel0),
		.fsm_sel1_o(fsm_sel1),
		.fsm_sel2_o(fsm_sel2),
		.fsm_sel23_o(fsm_sel23),
		.fsm_timer_ed_o(fsm_timer_ed),
		.fsm_op1_sel_o(fsm_op1_sel),
		.fsm_op2_sel_o(fsm_op2_sel),
		.alg_fb_sel_o(alg_fb_sel),
		.alg_op2_o(alg_op2),
		.alg_cur1_o(alg_cur1),
		.alg_cur2_o(alg_cur2),
		.alg_op1_0_o(alg_op1_0),
		.alg_out_o(alg_out)
		);
	
	
	ym3438_io io(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.address(ADDRESS),
		.data(DATA_i),
		.CS(CS),
		.WR(WR),
		.RD(RD),
		.IC(IC),
		.data_bus(),
		.write_addr_en(),
		.write_data_en(),
		.io_IC()
		);
	

	output d_c1;
	output d_c2;
	
	assign d_c1 = c1;
	assign d_c2 = c2;
	
endmodule
