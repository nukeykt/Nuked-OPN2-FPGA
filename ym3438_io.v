module ym3438_io
	(
	input MCLK,
	input c1,
	input c2,
	input [1:0] address,
	input [7:0] data,
	input CS,
	input WR,
	input RD,
	input IC,
	input timer_a,
	input timer_b,
	input read_mode,
	output write_addr_en,
	output write_data_en,
	output io_IC,
	output [7:0] data_bus,
	output bank,
	output [7:0] data_o,
	output io_dir,
	output irq
	);
	
	
	wire read_en = ~RD & IC & ~CS;
	wire write_addr = (~WR & ~CS & ~address[0]) | ~IC;
	wire write_data = ~WR & ~CS & address[0] & IC;
	
	assign io_IC = IC;
	
	wire write_a_tr1_q, write_a_tr1_nq;
	
	wire write_a_sig;
	
	ym3438_rs_trig write_a_tr1
		(
		.MCLK(MCLK),
		.set(write_addr),
		.rst(write_a_sig),
		.q(write_a_tr1_q),
		.nq(write_a_tr1_nq)
		);
	
	wire write_a_tr2_q;
	
	ym3438_rs_trig_sync write_a_tr2
		(
		.MCLK(MCLK),
		.set(write_a_tr1_q),
		.rst(write_a_tr1_nq),
		.c1(c1),
		.q(write_a_tr2_q),
		.nq()
		);
	
	ym3438_slatch write_a_sl
		(
		.MCLK(MCLK),
		.en(c2),
		.inp(write_a_tr2_q),
		.val(write_a_sig),
		.nval()
		);
	
	wire write_a_sig_delay;
	
	ym3438_sr_bit write_a_sr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.bit_in(write_a_sig),
		.sr_out(write_a_sig_delay)
		);
	
	assign write_addr_en = write_a_sig & ~write_a_sig_delay;
	
	wire write_d_tr1_q, write_d_tr1_nq;
	
	wire write_d_sig;
	
	ym3438_rs_trig write_d_tr1
		(
		.MCLK(MCLK),
		.set(write_data),
		.rst(write_d_sig),
		.q(write_d_tr1_q),
		.nq(write_d_tr1_nq)
		);
	
	wire write_d_tr2_q;
	
	ym3438_rs_trig_sync write_d_tr2
		(
		.MCLK(MCLK),
		.set(write_d_tr1_q),
		.rst(write_d_tr1_nq),
		.c1(c1),
		.q(write_d_tr2_q),
		.nq()
		);
	
	ym3438_slatch write_d_sl
		(
		.MCLK(MCLK),
		.en(c2),
		.inp(write_d_tr2_q),
		.val(write_d_sig),
		.nval()
		);
		
	wire write_d_sig_delay;
	
	ym3438_sr_bit write_d_sr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.bit_in(write_d_sig),
		.sr_out(write_d_sig_delay)
		);
	
	assign write_data_en = write_d_sig & ~write_d_sig_delay;
	
	wire [8:0] data_l_out;
	wire [8:0] data_in = { address[1], data };
	wire data_l_en = ~WR & ~CS;
	
	ym3438_slatch data_l[0:8]
		(
		.MCLK(MCLK),
		.en(data_l_en),
		.inp(data_in),
		.val(data_l_out),
		.nval()
		);
	
	wire busy_of;
	
	wire busy_state_o;
	
	ym3438_cnt_bit #(.DATA_WIDTH(5)) busy_cnt
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.c_in(~busy_state_o),
		.reset(~io_IC),
		.val(),
		.c_out(busy_of)
		);
	
	wire busy_state_i = ~(write_data_en | (~busy_state_o & ~(busy_of | ~io_IC)));
	
	ym3438_sr_bit busy_sr
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.bit_in(busy_state_i),
		.sr_out(busy_state_o)
		);
	
	assign io_dir = ~(IC & ~RD & ~CS);
	
	assign data_bus = (io_dir & IC) ? data_l_out[7:0] : 8'h00; // tristate + pull down

	assign bank = data_l_out[8];
	
	wire read_status = ~read_mode & read_en;
	
	wire timer_a_status_sl_out;
	
	ym3438_slatch timer_a_status_sl
		(
		.MCLK(MCLK),
		.en(c2),
		.inp(timer_a),
		.val(),
		.nval(timer_a_status_sl_out)
		);
	
	wire timer_b_status_sl_out;
	
	ym3438_slatch timer_b_status_sl
		(
		.MCLK(MCLK),
		.en(c2),
		.inp(timer_b),
		.val(),
		.nval(timer_a_status_sl_out)
		);
	
	bufif1(data_o[0], timer_b_status_sl_out, read_status);
	bufif1(data_o[1], timer_a_status_sl_out, read_status);
	bufif1(data_o[7], ~busy_state_o, read_status);
	
	assign irq = ~(timer_a_status_sl_out | timer_b_status_sl_out);

endmodule
