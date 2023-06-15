module ym3438_sr_bit #(parameter SR_LENGTH = 1, DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input bit_in,
	output [SR_LENGTH-1:0] sr_out
	);
	
	reg [SR_LENGTH-1:0] v1 = 0;
	reg [SR_LENGTH-1:0] v2 = 0;
	
	assign sr_out = v2;
	
	always @(posedge MCLK)
	begin
		if (c1)
		begin
			if (SR_LENGTH == 1)
				v1 <= bit_in;
			else
				v1 <= { v2[SR_LENGTH-2:0], bit_in };
		end
		if (c2)
			v2 <= v1;
	end


endmodule

module ym3438_sr_bit_array #(parameter SR_LENGTH = 1, DATA_WIDTH = 16)
	(
	input MCLK,
	input c1,
	input c2,
	input [DATA_WIDTH-1:0] data_in,
	output [DATA_WIDTH-1:0] data_out
	);
	
	wire [SR_LENGTH-1:0] out[0:DATA_WIDTH-1];
	
	generate
		genvar i;
		for (i = 0; i < DATA_WIDTH; i = i + 1)
		begin : l1
			ym3438_sr_bit #(.SR_LENGTH(SR_LENGTH)) sr (
			.MCLK(MCLK),
			.c1(c1),
			.c2(c2),
			.bit_in(data_in[i]),
			.sr_out(out[i])
			);
			
			assign data_out[i] = out[i][SR_LENGTH-1];
		end
	endgenerate

endmodule

module ym3438_cnt_bit #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input c_in,
	input reset,
	output [DATA_WIDTH-1:0] val,
	output c_out
	);
	
	wire [DATA_WIDTH-1:0] data_in;
	wire [DATA_WIDTH-1:0] data_out;
	wire [DATA_WIDTH:0] sum;
	
	ym3438_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH)) mem
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(data_in),
		.data_out(data_out)
		);
	
	assign sum = reset ? 0 : data_out + c_in;
	assign val = data_out;
	assign data_in = sum[DATA_WIDTH-1:0];
	assign c_out = sum[DATA_WIDTH];
	
endmodule

module ym3438_dlatch_1
	(
	input MCLK,
	input c1,
	input inp,
	output val,
	output nval
	);
	
	reg mem = 0;
	
	always @(posedge MCLK)
	begin
		if (c1)
			mem <= inp;
	end
	
	assign val = mem;
	assign nval = ~mem;
	
endmodule

module ym3438_dlatch_2
	(
	input MCLK,
	input c2,
	input inp,
	output val,
	output nval
	);
	
	reg mem = 0;
	
	always @(posedge MCLK)
	begin
		if (c2)
			mem <= inp;
	end
	
	assign val = mem;
	assign nval = ~mem;
	
endmodule

module ym3438_edge_detect
	(
	input MCLK,
	input c1,
	input inp,
	output outp
	);
	
	wire prev_out;
	
	ym3438_dlatch_1 prev
		(
		.MCLK(MCLK),
		.c1(c1),
		.inp(inp),
		.val(prev_out),
		.nval()
		);
	assign outp = ~(prev_out | ~inp);
endmodule
