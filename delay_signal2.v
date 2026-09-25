module sig_delay2#(
	parameter DW=16,
    parameter deltaT=2113
)(
    clk,
    rst_n,
    din,
    dout
    );

    input clk;
    input rst_n;
    input wire signed [DW-1:0] din;
    output wire signed [DW-1:0] dout;

wire signed [DW-1:0] d_delay1,d_delay2;

parameter ADDR=deltaT-2049;//when deltaT>2048

RAMbased_shiftreg_top delay1st(
		.clk(clk), //input clk
		.Reset(rst_n), //input Reset
		.Din(din), //input [15:0] Din
		.ADDR(1023), //input [9:0] ADDR
		.Q(d_delay1) //output [15:0] Q
	);
RAMbased_shiftreg_top delay2nd(
		.clk(clk), //input clk
		.Reset(rst_n), //input Reset
		.Din(d_delay1), //input [15:0] Din
		.ADDR(1023), //input [9:0] ADDR
		.Q(d_delay2) //output [15:0] Q
	);
RAMbased_shiftreg_top delay3rd(
		.clk(clk), //input clk
		.Reset(rst_n), //input Reset
		.Din(d_delay2), //input [15:0] Din
		.ADDR(ADDR), //input [9:0] ADDR
		.Q(dout) //output [15:0] Q
	);
endmodule