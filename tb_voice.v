`timescale 1ns/1ps
module tb_voice;

reg clk_48k;
reg clk_96k;
reg clk_192k;
reg clk_3_072M;
reg rst_n;
reg [23:0] din_half;

voice voice_inst(
    .clk_48k(clk_48k),
    .clk_96k(clk_96k),
    .clk_192k(clk_192k),
    .clk_3_072M(clk_3_072M),
    .rst_n(rst_n),
    .din_half(din_half)
);

integer Pattern;
reg [23:0] stimulus[1:14999];
initial begin
  $readmemb("D:/Gowin/example/hb_in_1125.txt",stimulus);
  //$readmemb("D:/matlab_file/cic/simulink_quan/hb_in_18000.txt",stimulus);
  Pattern = 0;
  #5;
  repeat(14999) begin
    Pattern = Pattern + 1;
    din = stimulus[Pattern];
    #64;
  end
end

initial begin
    clk_48k = 0;
    clk_96k = 0;
    clk_192k = 0;
    clk_3_072M = 0;
    rst_n = 0;
    #100;
    rst_n = 1;
    #400;
end
always #1 clk_3_072M = ~clk_3_072M;
always #16 clk_192k = ~clk_192k;
always #32 clk_96k = ~clk_96k;
always #64 clk_48k = ~clk_48k;
endmodule