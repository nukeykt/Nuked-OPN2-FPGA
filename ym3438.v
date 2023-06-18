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
	wire fsm_dac_load;
	wire fsm_dac_out_sel;
	wire fsm_dac_ch6;
	
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
		.alg_out_o(alg_out),
		.fsm_dac_load(fsm_dac_load),
		.fsm_dac_out_sel(fsm_dac_out_sel),
		.fsm_dac_ch6(fsm_dac_ch6)
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
	wire [7:3] reg_2c;
	
	wire [2:0] reg_pms;
	
	wire [10:0] reg_fnum;
	
	wire [4:0] reg_kcode;
	
	wire [2:0] reg_dt;
	wire [3:0] reg_multi;
	
	wire [4:0] reg_rate;
	wire [1:0] reg_ks;
	
	wire [1:0] rate_sel;
	wire [4:0] reg_sl;
	
	wire kon;
	wire kon_csm;
	
	wire ssg_enable;
	wire ssg_inv;
	wire ssg_repeat;
	wire ssg_holdup;
	wire ssg_type0;
	wire ssg_type2;
	wire ssg_type3;
	
	wire [6:0] reg_tl;
	wire [1:0] reg_ams;
	
	wire [2:0] reg_fb;
	
	wire mode_csm;
	
	wire dac_en;
	wire [7:0] dac;
	
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
		.reg_2c(reg_2c),
		.lfo(reg_lfo),
		.pms(reg_pms),
		.fnum(reg_fnum),
		.block(reg_kcode[4:2]),
		.note(reg_kcode[1:0]),
		.dt(reg_dt),
		.multi(reg_multi),
		.rate(reg_rate),
		.ks(reg_ks),
		.rate_sel(rate_sel),
		.sl(reg_sl),
		.kon(kon),
		.kon_csm(kon_csm),
		.ssg_enable(ssg_enable),
		.ssg_inv(ssg_inv),
		.ssg_repeat(ssg_repeat),
		.ssg_holdup(ssg_holdup),
		.ssg_type0(ssg_type0),
		.ssg_type2(ssg_type2),
		.ssg_type3(ssg_type3),
		.tl(reg_tl),
		.ams(reg_ams),
		.mode_csm(mode_csm),
		.fb(reg_fb),
		.dac(dac),
		.dac_en(dac_en),
		.fsm_dac_load(fsm_dac_load),
		.fsm_dac_out_sel(fsm_dac_out_sel)
		);
	
	wire [11:0] fnum_lfo;
	wire [5:0] lfo_am;
		
	ym3438_lfo lfo
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.lfo(reg_lfo),
		.fsm_sel23(fsm_sel23),
		.reg_21(reg_21),
		.pms(reg_pms),
		.IC(IC),
		.fnum(reg_fnum),
		.fnum_lfo(fnum_lfo),
		.lfo_am(lfo_am)
		);
	
	wire [4:0] kcode_sr1_o;
	wire [4:0] kcode_sr2_o;
	
	ym3438_sr_bit_array #(.DATA_WIDTH(5)) kcode_sr1
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(reg_kcode),
		.data_out(kcode_sr1_o)
		);
	
	ym3438_sr_bit_array #(.DATA_WIDTH(5)) kcode_sr2
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(kcode_sr1_o),
		.data_out(kcode_sr2_o)
		);
	
	wire dt_sign_1;
	wire dt_sign_2;
	wire [4:0] dt_value;
	
	ym3438_detune detune
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.dt(reg_dt),
		.kcode(kcode_sr2_o),
		.dt_sign_1(dt_sign_1),
		.dt_sign_2(dt_sign_2),
		.dt_value(dt_value)
		);
	
	wire [9:0] pg_out;
	wire pg_dbg_o;
	
	wire pg_reset;
	
	ym3438_pg pg
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.fnum(fnum_lfo),
		.block(kcode_sr1_o[4:2]),
		.dt_sign_1(dt_sign_1),
		.dt_sign_2(dt_sign_2),
		.dt_value(dt_value),
		.multi(reg_multi),
		.pg_reset(pg_reset),
		.reg_21(reg_21),
		.fsm_sel2(fsm_sel2),
		.pg_out(pg_out),
		.pg_dbg_o(pg_dbg_o)
		);
	
	wire [9:0] eg_out;
	wire eg_dbg_o;
	wire eg_test_inc;
		
	ym3438_eg eg
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.fsm_sel0(fsm_sel0),
		.fsm_sel2(fsm_sel2),
		.IC(IC),
		.TEST_i(TEST_i),
		.lsi_21(reg_21),
		.lsi_2c(reg_2c),
		.rate(reg_rate),
		.ks(reg_ks),
		.kcode(kcode_sr1_o),
		.sl(reg_sl),
		.kon(kon),
		.csm_kon(kon_csm),
		.ssg_enable(ssg_enable),
		.ssg_inv(ssg_inv),
		.ssg_repeat(ssg_repeat),
		.ssg_holdup(ssg_holdup),
		.ssg_type0(ssg_type0),
		.ssg_type2(ssg_type2),
		.ssg_type3(ssg_type3),
		.tl(reg_tl),
		.ams(reg_ams),
		.lfo_am(lfo_am),
		.mode_csm(mode_csm),
		.ch3_sel(fsm_ch3_sel),
		.rate_sel(rate_sel),
		.pg_reset(pg_reset),
		.eg_out(eg_out),
		.test_inc(eg_test_inc),
		.eg_dbg(eg_dbg_o)
		);
	
	wire [13:0] op_output;
	
	ym3438_op op
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.pg_phase(pg_out),
		.eg_att(eg_out),
		.reg_21(reg_21),
		.is_op1(fsm_op1_sel),
		.is_op2(fsm_op2_sel),
		.add1_cur(alg_cur1),
		.add1_op1_2(fsm_op2_sel),
		.add1_op2(alg_op2),
		.add2_cur(alg_cur2),
		.add2_op1_1(alg_op1_0),
		.no_fb(alg_fb_sel),
		.fb(reg_fb),
		.op_output(op_output)
		);
	
	wire [8:0] ch_dbg;
	wire [8:0] ch_out;
	
	ym3438_ch ch
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.op_value(op_output[13:5]),
		.op_out(alg_out),
		.dac_en(dac_en),
		.dac(dac),
		.reg_2c(reg_2c),
		.op1_sel(fsm_op1_sel),
		.fsm_dac_load(fsm_dac_load),
		.fsm_dac_out_sel(fsm_dac_out_sel),
		.fsm_dac_ch6(fsm_dac_ch6),
		.ch_dbg(ch_dbg),
		.ch_out(ch_out)
		);
	
endmodule
