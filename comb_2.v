module comb_2(
	input clk,
	input rst_n,
    input wire [1:0]rever_MODE,
    input En,
	input wire signed [15:0] din,
	output wire signed [15:0] dout
    );
    parameter DW=16;

	wire signed [DW+11:0] X,X1,X2;
	wire signed [DW-1:0] x1,x1_d1,x1_dd;//将信号x1延时1个单位、delta_T个单位并储存
//----------------------------------------------------------------------------------------	

//    sig_delay#(DW,1)comb2x1_delay1(clk,rst_n,x1,x1_d1);

    wire signed [DW-1:0]d_fromFIFO;
    wire [10:0]Wnum;
	reg RdEn;
always @(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn=1'b0;
else if(Wnum>=1022)RdEn=1'b1;
else RdEn=1'b0;
end
	fifo_sc_top comb2_FIFO1(
		.Data(x1), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum), //output [10:0] Wnum
		.Q(d_fromFIFO), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);

    wire signed [DW-1:0]d_fromFIFO1;
    wire [10:0]Wnum1;
	reg RdEn1;

always @(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn1=1'b0;
else if(Wnum1>=1022)RdEn1=1'b1;
else RdEn1=1'b0;
end
	fifo_sc_top comb2_FIFO2(
		.Data(d_fromFIFO), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn1), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum1), //output [10:0] Wnum
		.Q(d_fromFIFO1), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
    wire signed [DW-1:0]d_fromFIFOx;
    wire [10:0]Wnumx;
	reg RdEnx;
always @(posedge clk or negedge rst_n)begin
if(~rst_n)RdEnx=1'b0;
else if(Wnumx>=686)RdEnx=1'b1;
else RdEnx=1'b0;
end
	fifo_sc_top comb2_FIFOx(
		.Data(d_fromFIFO1), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEnx), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnumx), //output [10:0] Wnum
		.Q(d_fromFIFOx), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
assign x1_dd=d_fromFIFOx;

        reg signed [DW-1:0] x1d1;
    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)x1d1<='b0;
        else x1d1<=x1;
    end
    assign x1_d1=x1d1;

	assign X=(~rst_n)?'b0:{din,12'b0};
    assign x1=(~rst_n)?'b0:(X1>>>12);

//g=1000_0b0b_00b0	
	assign X1=X2-
	{{11{x1_d1[DW-1]}},x1_d1,1'b1}-
	{{8{x1_d1[DW-1]}},x1_d1,4'b0}-
    {{6{x1_d1[DW-1]}},x1_d1,6'b0}+
	{x1_d1[DW-1],x1_d1,11'b0};
//x1(t)=x2(t)+g*x1(t-1),其中g=0.090,量化后g=368.6400=369=1_0111_0001=csd0_-100-1_0001
	

//x2=(din+a*x1_dd),a=0.698,量化a=2818=1011_0000_0010=csd0-10-1_0000_0010
//1 0010 0100 0b0b
//2 0101 0100 10b0
//3 00b0_0100_1010
	assign X2=X+
	((rever_MODE==2)?(
    -{{11{x1_dd[DW-1]}},x1_dd,1'b0}+
	{{9{x1_dd[DW-1]}},x1_dd,3'b0}-
	{{6{x1_dd[DW-1]}},x1_dd,6'b0}+
	{{4{x1_dd[DW-1]}},x1_dd,8'b0}+
	{{2{x1_dd[DW-1]}},x1_dd,10'b0}
	):((rever_MODE==1)?(
    -{{12{x1_dd[DW-1]}},x1_dd}-
	{{10{x1_dd[DW-1]}},x1_dd,2'b0}+
	{{6{x1_dd[DW-1]}},x1_dd,6'b0}+
	{{3{x1_dd[DW-1]}},x1_dd,9'b0}
	):'b0)
    );
	
	assign dout = X2>>>12;

endmodule