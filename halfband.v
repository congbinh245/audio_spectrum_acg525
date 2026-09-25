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


module halfband(
    clk_48k,
    clk_96k,
    rst_n,
    din,
    dout
    );

parameter N = 16;   //input/output length

input clk_48k;
input clk_96k;
input rst_n;
input [N-1:0] din;
output reg [N-1:0] dout;

reg [N-1:0] din_d0 ;
reg [N-1:0] din_d1 ;
reg [N-1:0] din_d2 ;
reg [N-1:0] din_d3 ;
reg [N-1:0] din_d4 ;
reg [N-1:0] din_d5 ;
reg [N-1:0] din_d6 ;
reg [N-1:0] din_d7 ;
reg [N-1:0] din_d8 ;
reg [N-1:0] din_d9 ;
reg [N-1:0] din_d10;
reg [N-1:0] din_d11;
reg [N-1:0] din_d12;
reg [N-1:0] din_d13;
reg [N-1:0] din_d14;
reg [N-1:0] din_d15;
reg [N-1:0] din_d16;
reg [N-1:0] din_d17;
reg [N-1:0] din_d18;
reg [N-1:0] din_d19;
reg [N-1:0] din_d20;
reg [N-1:0] din_d21;
reg [N-1:0] din_d22;
reg [N-1:0] din_d23;
reg [N-1:0] din_d24;
reg [N-1:0] din_d25;
reg [N-1:0] din_d26;
reg [N-1:0] din_d27;
reg [N-1:0] din_d28;
reg [N-1:0] din_d29;

always @(posedge clk_48k or negedge rst_n) begin
    if(~rst_n) begin
        din_d0  <= {N{1'b0}};
        din_d1  <= {N{1'b0}};
        din_d2  <= {N{1'b0}};
        din_d3  <= {N{1'b0}};
        din_d4  <= {N{1'b0}};
        din_d5  <= {N{1'b0}};
        din_d6  <= {N{1'b0}};
        din_d7  <= {N{1'b0}};
        din_d8  <= {N{1'b0}};
        din_d9  <= {N{1'b0}};
        din_d10 <= {N{1'b0}};
        din_d11 <= {N{1'b0}};
        din_d12 <= {N{1'b0}};
        din_d13 <= {N{1'b0}};
        din_d14 <= {N{1'b0}};
        din_d15 <= {N{1'b0}};
        din_d16 <= {N{1'b0}};
        din_d17 <= {N{1'b0}};
        din_d18 <= {N{1'b0}};
        din_d19 <= {N{1'b0}};
        din_d20 <= {N{1'b0}};
        din_d21 <= {N{1'b0}};
        din_d22 <= {N{1'b0}};
        din_d23 <= {N{1'b0}};
        din_d24 <= {N{1'b0}};
        din_d25 <= {N{1'b0}};
        din_d26 <= {N{1'b0}};
        din_d27 <= {N{1'b0}};
        din_d28 <= {N{1'b0}};
        din_d29 <= {N{1'b0}};
    end else begin
        din_d0  <= din    ;
        din_d1  <= din_d0 ;
        din_d2  <= din_d1 ;
        din_d3  <= din_d2 ;
        din_d4  <= din_d3 ;
        din_d5  <= din_d4 ;
        din_d6  <= din_d5 ;
        din_d7  <= din_d6 ;
        din_d8  <= din_d7 ;
        din_d9  <= din_d8 ;
        din_d10 <= din_d9 ;
        din_d11 <= din_d10;
        din_d12 <= din_d11;
        din_d13 <= din_d12;
        din_d14 <= din_d13;
        din_d15 <= din_d14;
        din_d16 <= din_d15;
        din_d17 <= din_d16;
        din_d18 <= din_d17;
        din_d19 <= din_d18;
        din_d20 <= din_d19;
        din_d21 <= din_d20;
        din_d22 <= din_d21;
        din_d23 <= din_d22;
        din_d24 <= din_d23;
        din_d25 <= din_d24;
        din_d26 <= din_d25;
        din_d27 <= din_d26;
        din_d28 <= din_d27;
        din_d29 <= din_d28;
    end
end

wire [N:0] add_1 ;
wire [N:0] add_2 ;
wire [N:0] add_3 ;
wire [N:0] add_4 ;
wire [N:0] add_5 ;
wire [N:0] add_6 ;
wire [N:0] add_7 ;
wire [N:0] add_8 ;
wire [N:0] add_9 ;
wire [N:0] add_10;
wire [N:0] add_11;
wire [N:0] add_12;
wire [N:0] add_13;
wire [N:0] add_14;
wire [N:0] add_15;

assign add_1 = {din_d0[N-1],din_d0}   + {din_d29[N-1],din_d29};
assign add_2 = {din_d1[N-1],din_d1}   + {din_d28[N-1],din_d28};
assign add_3 = {din_d2[N-1],din_d2}   + {din_d27[N-1],din_d27};
assign add_4 = {din_d3[N-1],din_d3}   + {din_d26[N-1],din_d26};
assign add_5 = {din_d4[N-1],din_d4}   + {din_d25[N-1],din_d25};
assign add_6 = {din_d5[N-1],din_d5}   + {din_d24[N-1],din_d24};
assign add_7 = {din_d6[N-1],din_d6}   + {din_d23[N-1],din_d23};
assign add_8 = {din_d7[N-1],din_d7}   + {din_d22[N-1],din_d22};
assign add_9 = {din_d8[N-1],din_d8}   + {din_d21[N-1],din_d21};
assign add_10= {din_d9[N-1],din_d9}   + {din_d20[N-1],din_d20};
assign add_11= {din_d10[N-1],din_d10} + {din_d19[N-1],din_d19};
assign add_12= {din_d11[N-1],din_d11} + {din_d18[N-1],din_d18};
assign add_13= {din_d12[N-1],din_d12} + {din_d17[N-1],din_d17};
assign add_14= {din_d13[N-1],din_d13} + {din_d16[N-1],din_d16};
assign add_15= {din_d14[N-1],din_d14} + {din_d15[N-1],din_d15};

wire [N+4:0]  mul_o1;  //mul+'00000000000001000b'
wire [N+6:0]  mul_o2;  //mul-'0000000000001010b0'
wire [N+7:0]  mul_o3;  //mul+'00000000000101010b'
wire [N+8:0]  mul_o4;  //mul-'00000000001010000b'
wire [N+9:0]  mul_o5;  //mul+'00000000010010b000'
wire [N+9:0]  mul_o6;  //mul-'00000000100b010b01'
wire [N+10:0] mul_o7;  //mul+'000000010b0b010100'
wire [N+11:0] mul_o8;  //mul-'00000001000100100b'
wire [N+11:0] mul_o9;  //mul+'00000010b001010b0b'
wire [N+12:0] mul_o10; //mul-'00000010010010b010'
wire [N+12:0] mul_o11; //mul+'0000010b0100100b01'
wire [N+13:0] mul_o12; //mul-'000001010b010b000b'
wire [N+13:0] mul_o13; //mul+'00001000b0b0010b00'
wire [N+14:0] mul_o14; //mul-'00010b0100100b0010'
wire [N+16:0] mul_o15; //mul+'001010001010b0b00b'
wire [N+15:0] mul_e15; //mul+'010000000000000000'

assign mul_o1 = {add_1,4'b0}
              - {{4{add_1[N]}},add_1};
assign mul_o2 = {add_2[N],add_2,5'b0}
              + {{3{add_2[N]}},add_2,3'b0}
              - {{5{add_2[N]}},add_2,1'b0};
assign mul_o3 = {add_3[N],add_3,6'b0}
              + {{3{add_3[N]}},add_3,4'b0}
              + {{5{add_3[N]}},add_3,2'b0}
              - {{7{add_3[N]}},add_3};
assign mul_o4 = {add_4[N],add_4,7'b0}
              + {{2{add_4[N]}},add_4,5'b0}
              - {{7{add_4[N]}},add_4};
assign mul_o5 = {add_5[N],add_5,8'b0}
              + {{4{add_5[N]}},add_5,5'b0}
              - {{6{add_5[N]}},add_5,3'b0};
assign mul_o6 = {add_6,9'b0}
              - {{3{add_6[N]}},add_6,6'b0}
              + {{5{add_6[N]}},add_6,4'b0} 
              - {{7{add_6[N]}},add_6,2'b0} 
              + {{9{add_6[N]}},add_6};
assign mul_o7 = {add_7,10'b0}
              - {{2{add_7[N]}},add_7,8'b0}
              - {{4{add_7[N]}},add_7,6'b0} 
              + {{6{add_7[N]}},add_7,4'b0}
              + {{8{add_7[N]}},add_7,2'b0};
assign mul_o8 = {add_8[N],add_8,10'b0}
              + {{5{add_8[N]}},add_8,6'b0} 
              + {{8{add_8[N]}},add_8,3'b0} 
              - {{11{add_8[N]}},add_8};
assign mul_o9 = {add_9,11'b0}
              - {{2{add_9[N]}},add_9,9'b0} 
              + {{5{add_9[N]}},add_9,6'b0} 
              + {{7{add_9[N]}},add_9,4'b0} 
              - {{9{add_9[N]}},add_9,2'b0} 
              - {{11{add_9[N]}},add_9};
assign mul_o10= {add_10[N],add_10,11'b0}
              + {{4{add_10[N]}},add_10,8'b0}
              + {{7{add_10[N]}},add_10,5'b0}
              - {{9{add_10[N]}},add_10,3'b0}
              + {{11{add_10[N]}},add_10,1'b0};
assign mul_o11= {add_11,12'b0}
              - {{2{add_11[N]}},add_11,10'b0}
              + {{4{add_11[N]}},add_11,8'b0}
              + {{7{add_11[N]}},add_11,5'b0}
              - {{10{add_11[N]}},add_11,2'b0}
              + {{12{add_11[N]}},add_11};
assign mul_o12= {add_12[N],add_12,12'b0}
              + {{3{add_12[N]}},add_12,10'b0}
              - {{5{add_12[N]}},add_12,8'b0}
              + {{7{add_12[N]}},add_12,6'b0}
              - {{9{add_12[N]}},add_12,4'b0}
              - {{13{add_12[N]}},add_12};
assign mul_o13= {add_13,13'b0}
              - {{4{add_13[N]}},add_13,9'b0}
              - {{6{add_13[N]}},add_13,7'b0}
              + {{9{add_13[N]}},add_13,4'b0}
              - {{11{add_13[N]}},add_13,2'b0};
assign mul_o14= {add_14,14'b0}
              - {{2{add_14[N]}},add_14,12'b0}
              + {{4{add_14[N]}},add_14,10'b0} 
              + {{7{add_14[N]}},add_14,7'b0}
              - {{10{add_14[N]}},add_14,4'b0}
              + {{13{add_14[N]}},add_14,1'b0};
assign mul_o15= {add_15[N],add_15,15'b0}
              + {{3{add_15[N]}},add_15,13'b0}
              + {{7{add_15[N]}},add_15,9'b0}
              + {{9{add_15[N]}},add_15,7'b0}
              - {{11{add_15[N]}},add_15,5'b0}
              - {{13{add_15[N]}},add_15,3'b0}
              - {{16{add_15[N]}},add_15};
assign mul_e15= {din_d14,16'b0};

wire [N+16:0] sum_1;
wire [N+15:0] sum_2;

assign sum_1 = {{12{mul_o1[N+4]}},mul_o1} 
             - {{10{mul_o2[N+6]}},mul_o2} 
             + {{9{mul_o3[N+7]}},mul_o3} 
             - {{8{mul_o4[N+8]}},mul_o4} 
             + {{7{mul_o5[N+9]}},mul_o5} 
             - {{7{mul_o6[N+9]}},mul_o6} 
             + {{6{mul_o7[N+10]}},mul_o7} 
             - {{5{mul_o8[N+11]}},mul_o8} 
             + {{5{mul_o9[N+11]}},mul_o9} 
             - {{4{mul_o10[N+12]}},mul_o10} 
             + {{4{mul_o11[N+12]}},mul_o11} 
             - {{3{mul_o12[N+13]}},mul_o12} 
             + {{3{mul_o13[N+13]}},mul_o13} 
             - {{2{mul_o14[N+14]}},mul_o14}
             + mul_o15;
assign sum_2 = mul_e15;

reg flag;
always @(posedge clk_96k or negedge rst_n)begin
    if(~rst_n)begin
        flag <= 1'b0;
    end else begin
        flag <= ~flag;
    end
end

reg [N-1:0] dout_temp1;
reg [N-1:0] dout_temp2;
always @(posedge clk_96k or negedge rst_n) begin
    if(~rst_n) begin
        dout_temp1 <= {N{1'b0}};
        dout_temp2 <= {N{1'b0}};
        dout       <= {N{1'b0}};
    end else if(flag) begin
        dout_temp1 <= sum_1[N+15:16];
        dout_temp2 <= dout_temp2;
        dout       <= dout_temp1;
    end else begin
        dout_temp1 <= dout_temp1;
        dout_temp2 <= sum_2[N+15:16];
        dout       <= dout_temp2;
    end
end

endmodule