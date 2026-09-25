module voice (
    input clk_48k,
    input clk_96k,
    input clk_192k,
    input clk_3_072M,
    input rst_n,
    input [15:0] din_half,
    output  [15:0] dout_cic,
    output  [16:0] dout_comp,
    output  [15:0] dout_half
);
cic top1(
      .clk_192k(clk_192k),
      .clk_3_072M(clk_3_072M),
      .rst_n(rst_n),
      .din(dout_comp),
      .dout(dout_cic)
    );
    comp top2(
     .clk_96k(clk_96k),
     .clk_192k(clk_192k),
     .rst_n(rst_n),
     .din(dout_half),
     .dout(dout_comp)
    );
    halfband top3(
     .clk_48k(clk_48k),
     .clk_96k(clk_96k),
     .rst_n(rst_n),
     .din(din_half),
     .dout(dout_half)
    );
endmodule