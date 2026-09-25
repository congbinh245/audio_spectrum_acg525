`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/04 09:48:37
// Design Name: 
// Module Name: pdm_5
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cic(
    clk_192k,
    clk_3_072M,
    rst_n,
    din,
    dout
    );

parameter N = 16;   //input/output length

input clk_192k;
input clk_3_072M;
input rst_n;
input [N:0] din;
output [N-1:0] dout;

//-----------------------Comb---------------------------
reg [N:0] din_d;
always@ (posedge clk_192k or negedge rst_n)begin
    if(~rst_n)
        din_d <= {N+1{1'b0}};
    else
        din_d <= din;
end

wire [N+1:0] sub_1;
reg  [N+1:0] sub_1_d;
assign sub_1 = {din[N],din} - {din_d[N],din_d};
always @(posedge clk_192k or negedge rst_n) begin
    if(~rst_n) begin
        sub_1_d <= {N+2{1'b0}};
    end else begin
        sub_1_d <= sub_1;
    end
end

wire [N+2:0] sub_2;
reg  [N+2:0] sub_2_d;
assign sub_2 = {sub_1[N+1],sub_1} - {sub_1_d[N+1],sub_1_d};
always @(posedge clk_192k or negedge rst_n) begin
    if(~rst_n) begin
        sub_2_d <= {N+3{1'b0}};
    end else begin
        sub_2_d <= sub_2;
    end
end

wire [N+3:0] sub_3;
reg  [N+3:0] sub_3_d;
assign sub_3 = {sub_2[N+2],sub_2} - {sub_2_d[N+2],sub_2_d};
always @(posedge clk_192k or negedge rst_n) begin
    if(~rst_n) begin
        sub_3_d <= {N+4{1'b0}};
    end else begin
        sub_3_d <= sub_3;
    end
end

wire [N+4:0] sub_4;
assign sub_4 = {sub_3[N+3],sub_3} - {sub_3_d[N+3],sub_3_d};


//-----------------------Sig_int---------------------------
reg [3:0] cnt;
always @(posedge clk_3_072M or negedge rst_n) begin
    if(~rst_n)
        cnt <= 4'd0;
    else if(cnt == 4'd15)
        cnt <= 4'd0;
    else
        cnt <= cnt +1'b1;
end

reg [N+4:0] sub_4_d;
always @(posedge clk_3_072M or negedge rst_n) begin
    if(~rst_n)
        sub_4_d <= {N+5{1'b0}};
    else
        sub_4_d <= sub_4;
end

reg [N+4:0] sig_int;
always @(posedge clk_3_072M or negedge rst_n) begin
    if(~rst_n)
        sig_int <= {N+5{1'b0}};
    else if (cnt == 4'd15)
        sig_int <= sub_4_d;
    else
        sig_int <= {N+5{1'b0}};
end

//-----------------------Integrator---------------------------
wire [N+11:0] sum_1;
reg  [N+11:0] sum_1_d;
assign sum_1 = sum_1_d + {{7{sig_int[N+4]}},sig_int};
always @(posedge clk_3_072M or negedge rst_n) begin
    if(~rst_n) 
        sum_1_d <= {N+12{1'b0}};
    else
        sum_1_d <= sum_1;
end

wire [N+11:0] sum_2;
reg  [N+11:0] sum_2_d;
assign sum_2 = sum_2_d + sum_1_d;
always @(posedge clk_3_072M or negedge rst_n) begin
    if(~rst_n) 
        sum_2_d <= {N+12{1'b0}};
    else
        sum_2_d <= sum_2;
end

wire [N+11:0] sum_3;
reg  [N+11:0] sum_3_d;
assign sum_3 = sum_3_d + sum_2_d;
always @(posedge clk_3_072M or negedge rst_n) begin
    if(~rst_n) 
        sum_3_d <= {N+12{1'b0}};
    else
        sum_3_d <= sum_3;
end

wire [N+11:0] sum_4;
reg  [N+11:0] sum_4_d;
assign sum_4 = sum_4_d + sum_3_d;
always @(posedge clk_3_072M or negedge rst_n) begin
    if(~rst_n) 
        sum_4_d <= {N+12{1'b0}};
    else
        sum_4_d <= sum_4;
end

assign dout = sum_4_d[N+11:12];

endmodule