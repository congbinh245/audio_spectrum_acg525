module after_allpass_delay(
    input wire clk,
    input wire rst_n,
    input wire [1:0]rever_MODE,
    input En,
	input wire signed [15:0] in,
	output wire signed [15:0] out
	);
    parameter DW = 16;
	wire signed [DW-1:0] d_delay;
	wire signed [DW+11:0] D_gain;

    wire signed [DW-1:0]d_fromFIFO;
    wire [10:0]Wnum;
	reg RdEn;
always @(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn=1'b0;
else if(Wnum>=1022)RdEn=1'b1;
else RdEn=1'b0;
end
	fifo_sc_top after_allpass_FIFO1(
		.Data(in), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum), //output [10:0] Wnum
		.Q(d_fromFIFO), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);

//--------------------------------------------------------------------------
    wire [10:0]Wnumx;
	reg RdEnx;
always @(posedge clk or negedge rst_n)begin
if(~rst_n)RdEnx=1'b0;
else if(Wnumx>=112)RdEnx=1'b1;
else RdEnx=1'b0;
end
	fifo_sc_top after_allpass_FIFO2(
		.Data(d_fromFIFO), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEnx), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnumx), //output [10:0] Wnum
		.Q(d_delay), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//------------------------------------------------------------------------
/*
rever_MODE=1 1010 0010 0100
rever_MODE=2 0100 0100 1001
rever_MODE=3 0b00_0010_b001
*/
	assign D_gain=((rever_MODE==2)?(
    {{12{d_delay[DW-1]}},d_delay}+
    {{9{d_delay[DW-1]}},d_delay,3'b0}+
    {{6{d_delay[DW-1]}},d_delay,6'b0}+
    {{2{d_delay[DW-1]}},d_delay,10'b0}
    ):((rever_MODE==1)?(
    {{10{d_delay[DW-1]}},d_delay,2'b0}+
    {{7{d_delay[DW-1]}},d_delay,5'b0}+
    {{3{d_delay[DW-1]}},d_delay,9'b0}+
    {d_delay[DW-1],d_delay,11'b0}):'b0)
    );
	assign out=D_gain>>>12;
	
endmodule