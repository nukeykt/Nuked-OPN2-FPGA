module mdinterface
	(
	input CLOCK_50,
	inout [7:0] DATA,
	input [1:0] ADDRESS,
	input IC,
	input CS,
	input RD,
	input WR,
	
	output AUDIO_L,
	output AUDIO_R,
	output D_PHI,
	output D_C1,
	output D_C2,
	output D_DATA_o_z
	);
	
	wire MCLK;
	
	wire reset = 1'h0;
	
	pll clkpll
		(
		.refclk(CLOCK_50),
		.rst(reset),
		.outclk_0(MCLK)
		);
	
	wire VCLK;
	
	reg dff1;
	reg dff2;
	reg dff3;
	reg dff4;
	
	always @ (posedge MCLK)
	begin
		if (reset)
		begin
			dff1 <= 0;
			dff2 <= 0;
			dff3 <= 0;
			dff4 <= 0;
		end
		else
		begin
			dff1 <= dff4;
			dff2 <= dff1;
			dff3 <= ~(dff1 | dff2);
			dff4 <= dff3;
		end
	end
	
	assign VCLK = ~dff4;
	
	wire [7:0] data_o;
	wire data_o_z;
	
	assign DATA = data_o_z ? 'bz : data_o;
	
	assign D_DATA_o_z = data_o_z;
	
	wire [8:0] mol, mor;
	
	ym3438 fm
		(
		.MCLK(MCLK),
		.PHI(VCLK),
		.DATA_i(DATA),
		.DATA_o(data_o),
		.DATA_o_z(data_o_z),
		.TEST_i(0),
		.TEST_o(),
		.TEST_o_z(),
		.IC(IC),
		.CS(CS),
		.WR(WR),
		.RD(RD),
		.ADDRESS(ADDRESS),
		.IRQ(),
		.MOL(mol),
		.MOR(mor),
		.d_c1(D_C1),
		.d_c2(D_C2)
		);
	
	//assign AUDIO_L = mol[8];
	//assign AUDIO_R = mor[8];
	
	assign D_PHI = VCLK;
	
	delta_sigma ds_l
		(
		.VCLK(VCLK),
		.pcm(mol),
		.audio_o(AUDIO_L)
		);
	
	delta_sigma ds_r
		(
		.VCLK(VCLK),
		.pcm(mor),
		.audio_o(AUDIO_R)
		);
	
endmodule

module delta_sigma(
	input VCLK,
	input [8:0] pcm,
	output audio_o
	);
	
	wire [9:0] data_in = pcm - 9'h100;
	
	reg [9:0] data;
	
	wire data_msb = data[9];
	
	wire [9:0] adc = data_msb ? 10'hff : 10'h300;
	
	wire [9:0] delta = data_in - adc;
	wire [9:0] sigma = delta + data;
	
	assign audio_o = data_msb;
	
	always @(posedge VCLK)
	begin
		data <= sigma;
	end

endmodule
