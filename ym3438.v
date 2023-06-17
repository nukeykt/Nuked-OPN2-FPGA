module ym3438(
	input MCLK,
	input PHI,
	input [7:0] DATA_i,
	output [7:0] DATA_o,
	output DATA_o_z,
	input TEST_i,
	output TEST_o,
	input IC, IRQ, CS, WR, RD,
	input [1:0] ADDRESS,
	output [8:0] MOL, MOR
	);
	
	
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
	wire fsm_ch3_sel;
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
		.fsm_ch3_sel_o(fsm_ch3_sel),
		.alg_fb_sel_o(alg_fb_sel),
		.alg_op2_o(alg_op2),
		.alg_cur1_o(alg_cur1),
		.alg_cur2_o(alg_cur2),
		.alg_op1_0_o(alg_op1_0),
		.alg_out_o(alg_out)
		);
	
	wire [7:0] data_bus;
	wire bank;
	wire write_addr_en;
	wire write_data_en;
	
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
		.timer_a(0),
		.timer_b(0),
		.read_mode(0),
		.write_addr_en(write_addr_en),
		.write_data_en(write_data_en),
		.io_IC(),
		.data_bus(data_bus),
		.bank(bank),
		.data_o(DATA_o),
		.io_dir(),
		.irq()
		);
		
	wire [3:0] reg_lfo;
	wire [7:0] reg_21;
	
	ym3438_reg_ctrl reg_ctrl(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(data_bus),
		.bank(bank),
		.write_addr_en(write_addr_en),
		.write_data_en(write_data_en),
		.IC(IC),
		.fsm_sel_23(fsm_sel23),
		.fsm_sel_1(fsm_sel1),
		.timer_ed(fsm_timer_ed),
		.ch3_sel(fsm_ch3_sel),
		.reg_21(reg_21),
		.lfo(reg_lfo)
		);
		
	ym3438_lfo lfo
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.lfo(reg_lfo),
		.fsm_sel23(fsm_sel23),
		.reg_21(reg_21),
		.IC(IC)
		);
	
endmodule
