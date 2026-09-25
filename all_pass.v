module all_pass(
	input clk,
	input rst_n,
    input En,
	input wire signed [15:0] din,
	output wire signed [15:0] dout
    );

//	parameter delta_T=307;
    parameter DW=16;
	wire signed[DW-1:0] x,doutbuffer;
	wire signed[DW+11:0] Y;
	wire signed[DW-1:0] x_dd,y_dd;//将信号x、y延时delta_T个单位
//------------------------延时1024个（1023个单位）----------------------------------------------------	
    wire [10:0]Wnumxdd;
	reg RdEnxdd;
always @(posedge clk or negedge rst_n)begin
if(~rst_n)RdEnxdd=1'b0;
else if(Wnumxdd>=286)RdEnxdd=1'b1;
else RdEnxdd=1'b0;
end
	fifo_sc_top xdd_allpass_FIFO(
		.Data(x), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEnxdd), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnumxdd), //output [10:0] Wnum
		.Q(x_dd), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//--------------------------------------------------------------------------
    wire [10:0]Wnumydd;
	reg RdEnydd;
always @(posedge clk or negedge rst_n)begin
if(~rst_n)RdEnydd=1'b0;
else if(Wnumydd>=286)RdEnydd=1'b1;
else RdEnydd=1'b0;
end
	fifo_sc_top ydd_allpass_FIFO(
		.Data(doutbuffer), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEnydd), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnumydd), //output [10:0] Wnum
		.Q(y_dd), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//--------------------------------------------------------------------------
	assign x=din;

//	y[n]=g*y[n-307]-g*x[n]+x[n-307],其中y[n]=dout,x[n]=din,还有x_dd,y_dd 
//量化后g=0.7*4096=2867.2=2867=1011_0011_0011=csd0b0b_010b_010b
	assign Y={x_dd,12'b0}-
        {{12{y_dd[DW-1]}},y_dd}+
        {{10{y_dd[DW-1]}},y_dd,2'b0}-
        {{8{y_dd[DW-1]}},y_dd,4'b0}+
        {{6{y_dd[DW-1]}},y_dd,6'b0}-
        {{4{y_dd[DW-1]}},y_dd,8'b0}-
        {{2{y_dd[DW-1]}},y_dd,10'b0}-
        (-{{12{x[DW-1]}},x}+
        {{10{x[DW-1]}},x,2'b0}-
        {{8{x[DW-1]}},x,4'b0}+
        {{6{x[DW-1]}},x,6'b0}-
        {{4{x[DW-1]}},x,8'b0}-
        {{2{x[DW-1]}},x,10'b0});
	
	assign doutbuffer = Y>>>12;
    assign dout=doutbuffer;
endmodule