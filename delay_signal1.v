module sig_delay1#(
	parameter DW=16,
    parameter deltaT=1579
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

wire signed [DW-1:0] d_delay;

parameter ADDR=deltaT-1025;//when deltaT>1024 but <=2048

RAMbased_shiftreg_top delaythis1st(
		.clk(clk), //input clk
		.Reset(rst_n), //input Reset
		.Din(din), //input [15:0] Din
		.ADDR(1023), //input [9:0] ADDR
		.Q(d_delay) //output [15:0] Q
	);
RAMbased_shiftreg_top delaythis2nd(
		.clk(clk), //input clk
		.Reset(rst_n), //input Reset
		.Din(d_delay), //input [15:0] Din
		.ADDR(ADDR), //input [9:0] ADDR
		.Q(dout) //output [15:0] Q
	);

endmodule