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


module comp(
    clk_96k,
    clk_192k,
    rst_n,
    din,
    dout
    );

parameter N = 16;   //input/output length

input clk_96k;
input clk_192k;
input rst_n;
input [N-1:0] din;
output reg [N:0] dout;

reg [N-1:0] din_d1;
reg [N-1:0] din_d2;
reg [N-1:0] din_d3;
reg [N-1:0] din_d4;
reg [N-1:0] din_d5;
reg [N-1:0] din_d6;
reg [N-1:0] din_d7;

always @(posedge clk_96k or negedge rst_n) begin
    if(~rst_n) begin
        din_d1  <= {N{1'b0}};
        din_d2  <= {N{1'b0}};
        din_d3  <= {N{1'b0}};
        din_d4  <= {N{1'b0}};
        din_d5  <= {N{1'b0}};
        din_d6  <= {N{1'b0}};
        din_d7  <= {N{1'b0}};
    end else begin
        din_d1  <= din;
        din_d2  <= din_d1;
        din_d3  <= din_d2;
        din_d4  <= din_d3;
        din_d5  <= din_d4;
        din_d6  <= din_d5;
        din_d7  <= din_d6;
    end
end

wire [N:0] add_1;
wire [N:0] add_2;
wire [N:0] add_3;
wire [N:0] add_4;
wire [N:0] add_5;
wire [N:0] add_6;
wire [N:0] add_7;

assign add_1 = {din[N-1],din}       + {din_d7[N-1],din_d7};
assign add_2 = {din[N-1],din}       + {din_d6[N-1],din_d6};
assign add_3 = {din_d1[N-1],din_d1} + {din_d6[N-1],din_d6};
assign add_4 = {din_d1[N-1],din_d1} + {din_d5[N-1],din_d5};
assign add_5 = {din_d2[N-1],din_d2} + {din_d5[N-1],din_d5};
assign add_6 = {din_d2[N-1],din_d2} + {din_d4[N-1],din_d4};
assign add_7 = {din_d3[N-1],din_d3} + {din_d4[N-1],din_d4};

wire [N+6:0]  mul_1;  //mul-'0000000010b0101'
wire [N+4:0]  mul_2;  //mul+'000000000001001'
wire [N+9:0]  mul_3;  //mul+'0000010b0000001'
wire [N+5:0]  mul_4;  //mul+'000000000010101'
wire [N+11:0] mul_5;  //mul-'00010b0000b0000'
wire [N+9:0]  mul_6;  //mul-'000001000b00001'
wire [N+13:0] mul_7;  //mul+'001010010100100'
wire [N+13:0] mul_8;  //mul+'0100100b0001001'

assign mul_1 = {add_1,6'b0}
             - {{2{add_1[N]}},add_1,4'b0}
             + {{4{add_1[N]}},add_1,2'b0}
             + {{6{add_1[N]}},add_1};
assign mul_2 = {add_2[N],add_2,3'b0}
             + {{4{add_2[N]}},add_2};
assign mul_3 = {add_3,9'b0}
             - {{2{add_3[N]}},add_3,7'b0}
             + {{9{add_3[N]}},add_3};
assign mul_4 = {add_4[N],add_4,4'b0}
             + {{2{add_4[N]}},add_4,2'b0}
             + {{4{add_4[N]}},add_4};
assign mul_5 = {add_5,11'b0}
             - {{2{add_5[N]}},add_5,9'b0}
             - {{7{add_5[N]}},add_5,4'b0};
assign mul_6 = {add_6,9'b0}
             - {{4{add_6[N]}},add_6,5'b0}
             + {{9{add_6[N]}},add_6};
assign mul_7 = {add_7[N],add_7,12'b0}
             + {{3{add_7[N]}},add_7,10'b0}
             + {{6{add_7[N]}},add_7,7'b0}
             + {{8{add_7[N]}},add_7,5'b0}
             + {{11{add_7[N]}},add_7,2'b0};
assign mul_8 = {din_d3[N-1],din_d3,13'b0}
             + {{4{din_d3[N-1]}},din_d3,10'b0}
             - {{7{din_d3[N-1]}},din_d3,7'b0} 
             + {{11{din_d3[N-1]}},din_d3,3'b0}
             + {{14{din_d3[N-1]}},din_d3};

wire [N+13:0] sum_1;
wire [N+13:0] sum_2;
assign sum_1 = - {{7{mul_1[N+6]}},mul_1}
               + {{4{mul_3[N+9]}},mul_3}
               - {{2{mul_5[N+11]}},mul_5}
               + mul_7;
assign sum_2 =   {{9{mul_2[N+4]}},mul_2}
               + {{8{mul_4[N+5]}},mul_4}
               - {{4{mul_6[N+9]}},mul_6}
               + mul_8;

reg flag;
always @(posedge clk_192k or negedge rst_n)begin
    if(~rst_n)begin
        flag <= 1'b0;
    end else begin
        flag <= ~flag;
    end
end

reg [N:0] dout_temp1;
reg [N:0] dout_temp2;
always @(posedge clk_192k or negedge rst_n) begin
    if(~rst_n) begin
        dout_temp1 <= {N+1{1'b0}};
        dout_temp2 <= {N+1{1'b0}};
        dout       <= {N+1{1'b0}};
    end else if(flag) begin
        dout_temp1 <= sum_1[N+13:13];
        dout_temp2 <= dout_temp2;
        dout       <= dout_temp1;
    end else begin
        dout_temp1 <= dout_temp1;
        dout_temp2 <= sum_2[N+13:13];
        dout       <= dout_temp2;
    end
end


endmodule