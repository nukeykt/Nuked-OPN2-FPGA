module ym3438_reg_ctrl
	(
	input MCLK,
	input c1,
	input c2,
	input [7:0] data,
	input bank,
	input write_addr_en,
	input write_data_en,
	input IC,
	input fsm_sel_23,
	input [1:0] rate_sel,
	output [3:0] multi,
	output [2:0] dt,
	output [6:0] tl,
	output [1:0] ks,
	output am,
	output [3:0] rr,
	output [3:0] sl,
	output [3:0] ssgeg,
	output [4:0] rate,
	output [10:0] fnum,
	output [2:0] block,
	output [1:0] note,
	output [2:0] connect,
	output [2:0] fb,
	output [2:0] pms,
	output [1:0] ams,
	output [1:0] pan
	);
	
	wire fm_addr_write = (data[7:4] != 0) & write_addr_en;
	
	wire fm_addr_sr_o;
	
	ym3438_sr_bit fm_addr_sr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.bit_in(~((~write_addr_en & ~fm_addr_sr_o) | fm_addr_write)),
		.sr_out(fm_addr_sr_o)
		);
	
	wire fm_data_write = ~fm_addr_sr_o & write_data_en;
	
	wire fm_data_sr_o2;
	wire fm_data_sr_o = ~fm_data_sr_o2;
	
	ym3438_sr_bit fm_data_sr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.bit_in(~((~write_addr_en & fm_data_sr_o) | fm_data_write)),
		.sr_out(fm_data_sr_o2)
		);
		
	wire nIC = ~IC;
	
	wire [8:0] fm_address_in;
	wire [8:0] fm_address_out;
	
	assign fm_address_in = nIC ? 0 : (fm_addr_write ? { bank, data } : fm_address_out); 
	
	ym3438_sr_bit_array #(.DATA_WIDTH(9)) fm_address
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(fm_address_in),
		.data_out(fm_address_out)
		);
	
	wire [7:0] fm_data_in;
	wire [7:0] fm_data_out;
	
	assign fm_data_in = nIC ? 0 : (fm_data_write ? data : fm_data_out); 
	
	ym3438_sr_bit_array #(.DATA_WIDTH(8)) fm_data
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(fm_data_in),
		.data_out(fm_data_out)
		);
	
	wire [1:0] cnt_low_out;
	wire [2:0] cnt_high_out;
	
	wire [4:0] reg_cnt = { cnt_high_out, cnt_low_out };
	
	wire cnt_reset = nIC | fsm_sel_23;
	
	wire reset_low_cnt = cnt_reset | cnt_low_out[1];
	
	ym3438_cnt_bit #(.DATA_WIDTH(2)) cnt_low
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.c_in(1),
		.reset(reset_low_cnt),
		.val(cnt_low_out),
		.c_out()
		);
	
	ym3438_cnt_bit #(.DATA_WIDTH(3)) cnt_high
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.c_in(cnt_low_out[1]),
		.reset(cnt_reset),
		.val(cnt_high_out),
		.c_out()
		);

	wire ch_match = ~((reg_cnt[0] ^ fm_address_out[0]) | (reg_cnt[1] ^ fm_address_out[1]) | (reg_cnt[2] ^ fm_address_out[8]));
	
	wire ch_write = ch_match & fm_data_sr_o;
	
	wire ch_writeA0 = ch_write & (fm_address_out[7:2] == 6'h28);
	wire ch_writeA4 = ch_write & (fm_address_out[7:2] == 6'h29);
	wire ch_writeA8 = ch_write & (fm_address_out[7:2] == 6'h2a);
	wire ch_writeAC = ch_write & (fm_address_out[7:2] == 6'h2b);
	wire ch_writeB0 = ch_write & (fm_address_out[7:2] == 6'h2c);
	wire ch_writeB4 = ch_write & (fm_address_out[7:2] == 6'h2d);
	
	wire op_match = ~((reg_cnt[0] ^ fm_address_out[0]) | (reg_cnt[1] ^ fm_address_out[1]) | (reg_cnt[3] ^ fm_address_out[2]) | (reg_cnt[2] ^ fm_address_out[8]));
	
	wire op_write = op_match & fm_data_sr_o;
	
	wire op_write30 = op_write & (fm_address_out[7:4] == 4'h3);
	wire op_write40 = op_write & (fm_address_out[7:4] == 4'h4);
	wire op_write50 = op_write & (fm_address_out[7:4] == 4'h5);
	wire op_write60 = op_write & (fm_address_out[7:4] == 4'h6);
	wire op_write70 = op_write & (fm_address_out[7:4] == 4'h7);
	wire op_write80 = op_write & (fm_address_out[7:4] == 4'h8);
	wire op_write90 = op_write & (fm_address_out[7:4] == 4'h9);
	
	ym3438_op_register #(.DATA_WIDTH(4)) reg_multi
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[3:0]),
		.write_en(op_write30),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(multi)
		);
	
	ym3438_op_register #(.DATA_WIDTH(3)) reg_dt
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[6:4]),
		.write_en(op_write30),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(dt)
		);
	
	ym3438_op_register #(.DATA_WIDTH(7)) reg_tl
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[6:0]),
		.write_en(op_write40),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(tl)
		);
	
	ym3438_op_register #(.DATA_WIDTH(5)) reg_ar
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[4:0]),
		.write_en(op_write50),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(ar)
		);
	
	ym3438_op_register #(.DATA_WIDTH(2)) reg_ks
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[7:6]),
		.write_en(op_write50),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(ks)
		);
	
	ym3438_op_register #(.DATA_WIDTH(5)) reg_dr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[4:0]),
		.write_en(op_write60),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(dr)
		);
	
	ym3438_op_register #(.DATA_WIDTH(1)) reg_am
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[7:7]),
		.write_en(op_write60),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(am)
		);
	
	ym3438_op_register #(.DATA_WIDTH(5)) reg_sr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[4:0]),
		.write_en(op_write70),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(sr)
		);
	
	ym3438_op_register #(.DATA_WIDTH(4)) reg_rr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[3:0]),
		.write_en(op_write80),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(rr)
		);
	
	ym3438_op_register #(.DATA_WIDTH(4)) reg_sl
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[7:4]),
		.write_en(op_write80),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(sl)
		);
	
	ym3438_op_register #(.DATA_WIDTH(4)) reg_ssgeg
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[3:0]),
		.write_en(op_write90),
		.rst(nIC),
		.bank(fm_address_out[3]),
		.obank(reg_cnt[4]),
		.data_o(ssgeg)
		);
		
	wire [5:0] reg_a4_in;
	wire [5:0] reg_a4_out;
	
	ym3438_sr_bit_array #(.DATA_WIDTH(6)) reg_a4
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(reg_a4_in),
		.data_out(reg_a4_out)
		);
	
	assign reg_a4_in = nIC ? 0 : (ch_writeA4 ? fm_data_out[5:0] : reg_a4_out);
		
	wire [5:0] reg_ac_in;
	wire [5:0] reg_ac_out;
	
	ym3438_sr_bit_array #(.DATA_WIDTH(6)) reg_ac
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(reg_ac_in),
		.data_out(reg_ac_out)
		);
	
	assign reg_ac_in = nIC ? 0 : (ch_writeAC ? fm_data_out[5:0] : reg_ac_out);
	
	wire [10:0] reg_fnum_o;
	
	ym3438_ch_register #(.DATA_WIDTH(11)) reg_fnum
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data({reg_a4_out[2:0], fm_data_out}),
		.write_en(ch_writeA0),
		.rst(nIC),
		.data_o_4(reg_fnum_o)
		);
	
	wire [2:0] reg_block_o;
	
	ym3438_ch_register #(.DATA_WIDTH(3)) reg_block
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(reg_a4_out[5:3]),
		.write_en(ch_writeA0),
		.rst(nIC),
		.data_o_4(reg_block_o)
		);
	
	wire [10:0] reg_fnum_ch3_o_0;
	wire [10:0] reg_fnum_ch3_o_4;
	wire [10:0] reg_fnum_ch3_o_5;
	
	ym3438_ch_register #(.DATA_WIDTH(11)) reg_fnum_ch3
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data({reg_ac_out[2:0], fm_data_out}),
		.write_en(ch_writeA8),
		.rst(nIC),
		.data_o_0(reg_fnum_ch3_o_0),
		.data_o_4(reg_fnum_ch3_o_4),
		.data_o_5(reg_fnum_ch3_o_5)
		);
	
	wire [2:0] reg_block_ch3_o_0;
	wire [2:0] reg_block_ch3_o_4;
	wire [2:0] reg_block_ch3_o_5;
	
	ym3438_ch_register #(.DATA_WIDTH(3)) reg_block_ch3
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(reg_ac_out[5:3]),
		.write_en(ch_writeA8),
		.rst(nIC),
		.data_o_0(reg_block_ch3_o_0),
		.data_o_4(reg_block_ch3_o_4),
		.data_o_5(reg_block_ch3_o_5)
		);
	
	ym3438_ch_register #(.DATA_WIDTH(3)) reg_connect
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[2:0]),
		.write_en(ch_writeB0),
		.rst(nIC),
		.data_o_5(connect)
		);
	
	ym3438_ch_register #(.DATA_WIDTH(3)) reg_fb
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[5:3]),
		.write_en(ch_writeB0),
		.rst(nIC),
		.data_o_0(fb)
		);
	
	ym3438_ch_register #(.DATA_WIDTH(3)) reg_pms
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[2:0]),
		.write_en(ch_writeB4),
		.rst(nIC),
		.data_o_5(pms)
		);
	
	ym3438_ch_register #(.DATA_WIDTH(2)) reg_ams
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(fm_data_out[5:4]),
		.write_en(ch_writeB4),
		.rst(nIC),
		.data_o_5(ams)
		);
	
	ym3438_ch_register #(.DATA_WIDTH(2)) reg_pan
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data(~fm_data_out[7:6]),
		.write_en(ch_writeB4),
		.rst(nIC),
		.data_o_5(pan)
		);

	
endmodule

module ym3438_op_register #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input [DATA_WIDTH-1:0] data,
	input write_en,
	input rst,
	input bank,
	input obank,
	output [DATA_WIDTH-1:0] data_o
	);
	
	wire [DATA_WIDTH-1:0] sr1_in;
	wire [DATA_WIDTH-1:0] sr1_out;
	ym3438_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH), .SR_LENGTH(12)) sr1
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(sr1_in),
		.data_out(sr1_out)
		);
		
	wire [DATA_WIDTH-1:0] sr2_in;
	wire [DATA_WIDTH-1:0] sr2_out;
	ym3438_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH), .SR_LENGTH(12)) sr2
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(sr2_in),
		.data_out(sr2_out)
		);
	
	wire write1 = write_en & ~bank;
	wire write2 = write_en & bank;

	assign sr1_in = rst ? 0 : (write1 ? data : sr1_out);
	assign sr2_in = rst ? 0 : (write2 ? data : sr2_out);
	
	assign data_o = obank ? sr2_out : sr1_out;
	
endmodule

module ym3438_ch_register #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input [DATA_WIDTH-1:0] data,
	input write_en,
	input rst,
	output [DATA_WIDTH-1:0] data_o_0,
	output [DATA_WIDTH-1:0] data_o_1,
	output [DATA_WIDTH-1:0] data_o_2,
	output [DATA_WIDTH-1:0] data_o_3,
	output [DATA_WIDTH-1:0] data_o_4,
	output [DATA_WIDTH-1:0] data_o_5
	);
	
	wire [DATA_WIDTH-1:0] sr_in[0:5];
	wire [DATA_WIDTH-1:0] sr_out[0:5];
	ym3438_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH)) sr_array[0:5]
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(sr_in),
		.data_out(sr_out)
		);
	
	assign sr_in[0] = rst ? 0 : (write_en ? data : sr_out[5]);
	assign sr_in[1] = sr_out[0]; 
	assign sr_in[2] = sr_out[1]; 
	assign sr_in[3] = sr_out[2]; 
	assign sr_in[4] = sr_out[3]; 
	assign sr_in[5] = sr_out[4];

	assign data_o_0 = sr_out[0];
	assign data_o_1 = sr_out[1];
	assign data_o_2 = sr_out[2];
	assign data_o_3 = sr_out[3];
	assign data_o_4 = sr_out[4];
	assign data_o_5 = sr_out[5];
	
endmodule
