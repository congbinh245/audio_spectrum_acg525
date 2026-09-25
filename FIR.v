module FIR_18(
    input wire clk,
    input wire rst_n,
    input wire En,
	input wire signed [15:0] in,
	output wire signed [15:0] out
	);
parameter DW = 16;
/*
FIRcsd编码
00-10_-100-1_0101
1000_0001_0000
1000_00-10_-100-1
10-10_0001_0000
10-10_0001_0101
10-10_-1000_1001
0100_1010_0000
0100_10-10_-1010
010-1_0001_0010
010-1_0010_-100-1
0100_-1000_-1001
010-1_00-10_0101
010-1_00-10_0010
010-1_00-10_0101
010-1_0-101_0001
0010_0100_10-10
010-1_0-10-1_0-100
0010_0010_0101
*/
	wire signed [DW-1:0] data_delay0,data_delay1,data_delay2,data_delay3,data_delay4,data_delay5;
	wire signed [DW-1:0] data_delay6,data_delay7,data_delay8,data_delay9,data_delay10,data_delay11;
	wire signed [DW-1:0] data_delay12,data_delay13,data_delay14,data_delay15,data_delay16,data_delay17;
	
	wire signed [DW+11:0] data_gain0,data_gain1,data_gain2,data_gain3,data_gain4,data_gain5;
	wire signed [DW+11:0] data_gain6,data_gain7,data_gain8,data_gain9,data_gain10,data_gain11;
	wire signed [DW+11:0] data_gain12,data_gain13,data_gain14,data_gain15,data_gain16,data_gain17;
	
	wire signed [DW+11:0] out_add,in_add;
//-----------------------信号延时---------------------------
//----------------------------------------------------------------------------------------
    wire [10:0]Wnum1;
	reg RdEn1;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn1=1'b0;
else if(Wnum1>=204)RdEn1=1'b1;
else RdEn1=1'b0;
end
	fifo_sc_top FIR1_FIFO(
		.Data(in), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn1), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum1), //output [10:0] Wnum
		.Q(data_delay0), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,206)  delay1(clk,rst_n,in,    data_delay0);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum2;
	reg RdEn2;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn2=1'b0;
else if(Wnum2>=824)RdEn2=1'b1;
else RdEn2=1'b0;
end
	fifo_sc_top FIR2_FIFO(
		.Data(data_delay0), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn2), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum2), //output [10:0] Wnum
		.Q(data_delay1), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,826)  delay2(clk,rst_n,data_delay0,   data_delay1);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum3;
	reg RdEn3;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn3=1'b0;
else if(Wnum3>=46)RdEn3=1'b1;
else RdEn3=1'b0;
end
	fifo_sc_top FIR3_FIFO(
		.Data(data_delay1), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn3), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum3), //output [10:0] Wnum
		.Q(data_delay2), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,48)   delay3(clk,rst_n,data_delay1,   data_delay2);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum4;
	reg RdEn4;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn4=1'b0;
else if(Wnum4>=204)RdEn4=1'b1;
else RdEn4=1'b0;
end
	fifo_sc_top FIR4_FIFO(
		.Data(data_delay2), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn4), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum4), //output [10:0] Wnum
		.Q(data_delay3), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,206)  delay4(clk,rst_n,data_delay2,   data_delay3);
	sig_delay#(DW,10)    delay5(clk,rst_n,data_delay3,   data_delay4);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum6;
	reg RdEn6;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn6=1'b0;
else if(Wnum6>=132)RdEn6=1'b1;
else RdEn6=1'b0;
end
	fifo_sc_top FIR6_FIFO(
		.Data(data_delay4), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn6), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum6), //output [10:0] Wnum
		.Q(data_delay5), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,134)  delay6(clk,rst_n,data_delay4,   data_delay5);
//----------------------------------------------------------------------------------------
    wire [10:0]Wnum7;
	reg RdEn7;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn7=1'b0;
else if(Wnum7>=766)RdEn7=1'b1;
else RdEn7=1'b0;
end
	fifo_sc_top FIR7_FIFO(
		.Data(data_delay5), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn7), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum7), //output [10:0] Wnum
		.Q(data_delay6), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,768)  delay7(clk,rst_n,data_delay5,   data_delay6);
//----------------------------------------------------------------------------------------
    wire [10:0]Wnum8;
	reg RdEn8;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn8=1'b0;
else if(Wnum8>=128)RdEn8=1'b1;
else RdEn8=1'b0;
end
	fifo_sc_top FIR8_FIFO(
		.Data(data_delay6), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn8), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum8), //output [10:0] Wnum
		.Q(data_delay7), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,130)  delay8(clk,rst_n,data_delay6,   data_delay7);
//----------------------------------------------------------------------------------------
    wire [10:0]Wnum9;
	reg RdEn9;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn9=1'b0;
else if(Wnum9>=416)RdEn9=1'b1;
else RdEn9=1'b0;
end
	fifo_sc_top FIR9_FIFO(
		.Data(data_delay7), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn9), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum9), //output [10:0] Wnum
		.Q(data_delay8), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,418)  delay9(clk,rst_n,data_delay7,   data_delay8);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum10;
	reg RdEn10;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn10=1'b0;
else if(Wnum10>=70)RdEn10=1'b1;
else RdEn10=1'b0;
end
	fifo_sc_top FIR10_FIFO(
		.Data(data_delay8), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn10), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum10), //output [10:0] Wnum
		.Q(data_delay9), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,72)   delay10(clk,rst_n,data_delay8,  data_delay9);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum11;
	reg RdEn11;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn11=1'b0;
else if(Wnum11>=36)RdEn11=1'b1;
else RdEn11=1'b0;
end
	fifo_sc_top FIR11_FIFO(
		.Data(data_delay9), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn11), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum11), //output [10:0] Wnum
		.Q(data_delay10), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,38)   delay11(clk,rst_n,data_delay9,  data_delay10);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum12;
	reg RdEn12;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn12=1'b0;
else if(Wnum12>=80)RdEn12=1'b1;
else RdEn12=1'b0;
end
	fifo_sc_top FIR12_FIFO(
		.Data(data_delay10), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn12), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum12), //output [10:0] Wnum
		.Q(data_delay11), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,82)   delay12(clk,rst_n,data_delay10, data_delay11);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum13;
	reg RdEn13;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn13=1'b0;
else if(Wnum13>=454)RdEn13=1'b1;
else RdEn13=1'b0;
end
	fifo_sc_top FIR13_FIFO(
		.Data(data_delay11), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn13), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum13), //output [10:0] Wnum
		.Q(data_delay12), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,456)  delay13(clk,rst_n,data_delay11, data_delay12);
	sig_delay#(DW,5)    delay14(clk,rst_n,data_delay12, data_delay13);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum15;
	reg RdEn15;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn15=1'b0;
else if(Wnum15>=84)RdEn15=1'b1;
else RdEn15=1'b0;
end
	fifo_sc_top FIR15_FIFO(
		.Data(data_delay13), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn15), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum15), //output [10:0] Wnum
		.Q(data_delay14), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,86)   delay15(clk,rst_n,data_delay13, data_delay14);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum16;
	reg RdEn16;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn16=1'b0;
else if(Wnum16>=70)RdEn16=1'b1;
else RdEn16=1'b0;
end
	fifo_sc_top FIR16_FIFO(
		.Data(data_delay14), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn16), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum16), //output [10:0] Wnum
		.Q(data_delay15), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,72)   delay16(clk,rst_n,data_delay14, data_delay15);

//----------------------------------------------------------------------------------------
    wire [10:0]Wnum17;
	reg RdEn17;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn17=1'b0;
else if(Wnum17>=56)RdEn17=1'b1;
else RdEn17=1'b0;
end
	fifo_sc_top FIR17_FIFO(
		.Data(data_delay15), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn17), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum17), //output [10:0] Wnum
		.Q(data_delay16), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,58)   delay17(clk,rst_n,data_delay15, data_delay16);
//----------------------------------------------------------------------------------------
    wire [10:0]Wnum18;
	reg RdEn18;
always@(posedge clk or negedge rst_n)begin
if(~rst_n)RdEn18=1'b0;
else if(Wnum18>=209)RdEn18=1'b1;
else RdEn18=1'b0;
end
	fifo_sc_top FIR18_FIFO(
		.Data(data_delay16), //input [31:0] Data
		.Clk(clk), //input Clk
		.WrEn(En), //input WrEn
		.RdEn(En&RdEn18), //input RdEn
		.Reset(~rst_n), //input Reset
		.Wnum(Wnum18), //output [10:0] Wnum
		.Q(data_delay17), //output [31:0] Q
		.Empty(), //output Empty
		.Full() //output Full
	);
//----------------------------------------------------------------------------------------
//	sig_delay#(DW,211)  delay18(clk,rst_n,data_delay16, data_delay17);
	
//-----------------------移位相加---------------------------
	//1101_0111_0101/00-10_-100-1_0101*
	assign data_gain0={{12{data_delay0[DW-1]}},data_delay0}+
	{{10{data_delay0[DW-1]}},data_delay0,2'b0}-
	{{8{data_delay0[DW-1]}},data_delay0,4'b0}-
	{{5{data_delay0[DW-1]}},data_delay0,7'b0}-
	{{3{data_delay0[DW-1]}},data_delay0,9'b0};
	
	//1000_0001_0000*
	assign data_gain1={{8{data_delay1[DW-1]}},data_delay1,4'b0}+{{1{data_delay1[DW-1]}},data_delay1,11'b0};
	
	//0111_1101_0111/1000_00-10_-100-1*
	assign data_gain2=-{{12{data_delay2[DW-1]}},data_delay2}-
	{{9{data_delay2[DW-1]}},data_delay2,3'b0}-
	{{7{data_delay2[DW-1]}},data_delay2,5'b0}+
	{data_delay2[DW-1],data_delay2,11'b0};
	
	//0110_0001_0000*
	assign data_gain3={{8{data_delay3[DW-1]}},data_delay3,4'b0}+
	{{3{data_delay3[DW-1]}},data_delay3,9'b0}+
	{{2{data_delay3[DW-1]}},data_delay3,10'b0};
	
	//0110_0001_0101*
	assign data_gain4={{12{data_delay4[DW-1]}},data_delay4}+
	{{10{data_delay4[DW-1]}},data_delay4,2'b0}+
	{{8{data_delay4[DW-1]}},data_delay4,4'b0}+
	{{3{data_delay4[DW-1]}},data_delay4,9'b0}+
	{{2{data_delay4[DW-1]}},data_delay4,10'b0};
	
	//0101_1000_1001*
	assign data_gain5={{12{data_delay5[DW-1]}},data_delay5}+
	{{9{data_delay5[DW-1]}},data_delay5,3'b0}+
	{{5{data_delay5[DW-1]}},data_delay5,7'b0}+
	{{4{data_delay5[DW-1]}},data_delay5,8'b0}+
	{{2{data_delay5[DW-1]}},data_delay5,10'b0};
	
	//0100_1010_0000*
	assign data_gain6={{7{data_delay6[DW-1]}},data_delay6,5'b0}+
	{{5{data_delay6[DW-1]}},data_delay6,7'b0}+
	{{2{data_delay6[DW-1]}},data_delay6,10'b0};
	
	//0100_0101_1010*
	assign data_gain7={{11{data_delay7[DW-1]}},data_delay7,1'b0}+
	{{9{data_delay7[DW-1]}},data_delay7,3'b0}+
	{{8{data_delay7[DW-1]}},data_delay7,4'b0}+
	{{6{data_delay7[DW-1]}},data_delay7,6'b0}+
	{{2{data_delay7[DW-1]}},data_delay7,10'b0};
	
	//0011_0001_0010*
	assign data_gain8={{11{data_delay8[DW-1]}},data_delay8,1'b0}+
	{{8{data_delay8[DW-1]}},data_delay8,4'b0}+
	{{4{data_delay8[DW-1]}},data_delay8,8'b0}+
	{{3{data_delay8[DW-1]}},data_delay8,9'b0};
	
	//0011_0001_0111/010-1_0010_-100-1*
	assign data_gain9=-{{12{data_delay9[DW-1]}},data_delay9}-
	{{9{data_delay9[DW-1]}},data_delay9,3'b0}+
	{{7{data_delay9[DW-1]}},data_delay9,5'b0}-
	{{4{data_delay9[DW-1]}},data_delay9,8'b0}+
	{{2{data_delay9[DW-1]}},data_delay9,10'b0};
	
	//0011_0111_1001/0100_-1000_-1001*
	assign data_gain10={{12{data_delay10[DW-1]}},data_delay10}-
	{{9{data_delay10[DW-1]}},data_delay10,3'b0}-
	{{5{data_delay10[DW-1]}},data_delay10,7'b0}+
	{{2{data_delay10[DW-1]}},data_delay10,10'b0};
	
	//0010_1110_0101/010-1_00-10_0101*
	assign data_gain11={{12{data_delay11[DW-1]}},data_delay11}+
	{{10{data_delay11[DW-1]}},data_delay11,2'b0}-
	{{7{data_delay11[DW-1]}},data_delay11,5'b0}-
	{{4{data_delay11[DW-1]}},data_delay11,8'b0}+
	{{2{data_delay11[DW-1]}},data_delay11,10'b0};
	
	//0010_1110_0010/010-1_00-10_0010*
	assign data_gain12={{11{data_delay12[DW-1]}},data_delay12,1'b0}-
	{{7{data_delay12[DW-1]}},data_delay12,5'b0}-
	{{4{data_delay12[DW-1]}},data_delay12,8'b0}+
	{{2{data_delay12[DW-1]}},data_delay12,10'b0};
	
	//0010_1110_0101/010-1_00-10_0101*
	assign data_gain13={{12{data_delay13[DW-1]}},data_delay13}+
	{{10{data_delay13[DW-1]}},data_delay13,2'b0}-
	{{7{data_delay13[DW-1]}},data_delay13,5'b0}-
	{{4{data_delay13[DW-1]}},data_delay13,8'b0}+
	{{2{data_delay13[DW-1]}},data_delay13,10'b0};
	
	//0010_1101_0001*
	assign data_gain14={{12{data_delay14[DW-1]}},data_delay14}+
	{{8{data_delay14[DW-1]}},data_delay14,4'b0}+
	{{6{data_delay14[DW-1]}},data_delay14,6'b0}+
	{{5{data_delay14[DW-1]}},data_delay14,7'b0}+
	{{3{data_delay14[DW-1]}},data_delay14,9'b0};

	//0010_0100_0110*
	assign data_gain15={{11{data_delay15[DW-1]}},data_delay15,1'b0}+
	{{10{data_delay15[DW-1]}},data_delay15,2'b0}+
	{{6{data_delay15[DW-1]}},data_delay15,6'b0}+
	{{3{data_delay15[DW-1]}},data_delay15,9'b0};
	
	//0010_1010_1100*
	assign data_gain16={{10{data_delay16[DW-1]}},data_delay16,2'b0}+
	{{9{data_delay16[DW-1]}},data_delay16,3'b0}+
	{{7{data_delay16[DW-1]}},data_delay16,5'b0}+
	{{5{data_delay16[DW-1]}},data_delay16,7'b0}+
	{{3{data_delay16[DW-1]}},data_delay16,9'b0};
	
	//0010_0010_0101*
	assign data_gain17={{12{data_delay17[DW-1]}},data_delay17}+
	{{10{data_delay17[DW-1]}},data_delay17,2'b0}+
	{{7{data_delay17[DW-1]}},data_delay17,5'b0}+
	{{3{data_delay17[DW-1]}},data_delay17,9'b0};
	
	assign in_add={in,12'b0};
	assign out_add=in_add+data_gain0+data_gain1+data_gain2+data_gain3+
	data_gain4+data_gain5+data_gain6+data_gain7+
	data_gain8+data_gain9+data_gain10+data_gain11+
	data_gain12+data_gain13+data_gain14+data_gain15+
	data_gain16+data_gain17;
	
	assign out=out_add>>>12;
	
endmodule