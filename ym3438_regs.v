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
	output multi[3:0]
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
