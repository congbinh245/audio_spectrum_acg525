module reverberator(
    clk,
    rst_n,
    rever_MODE,
    reverberator_En,
    din,
    dout
    );
    input clk;
    input rst_n;
    input [1:0]rever_MODE;
    input reverberator_En;
    input wire signed [15:0] din;
    output wire signed [15:0] dout;

//rever_MODE=1    //(MODE=1,T=0.5S)(MODE=2,T=1S)

    parameter DW=16;
    wire signed [DW-1:0] fir_out,allpass_in,allpass_out,allpass_delay;
    wire signed [DW-1:0] comb_out1,comb_out2,comb_out3,comb_out4,comb_out5,comb_out6;


    FIR_18 Fir(clk,rst_n,reverberator_En,din,fir_out);

    comb_1 Comb1(clk,rst_n,rever_MODE,reverberator_En,fir_out,comb_out1);
    comb_2 Comb2(clk,rst_n,rever_MODE,reverberator_En,fir_out,comb_out2);
    comb_3 Comb3(clk,rst_n,rever_MODE,reverberator_En,fir_out,comb_out3);
    comb_4 Comb4(clk,rst_n,rever_MODE,reverberator_En,fir_out,comb_out4);
    comb_5 Comb5(clk,rst_n,rever_MODE,reverberator_En,fir_out,comb_out5);
    comb_6 Comb6(clk,rst_n,rever_MODE,reverberator_En,fir_out,comb_out6);

    assign allpass_in=comb_out1+comb_out2+comb_out3+comb_out4+comb_out5+comb_out6;

    all_pass AllPass(clk,rst_n,reverberator_En,allpass_in,allpass_out);
    after_allpass_delay AllPassDelay(clk,rst_n,rever_MODE,reverberator_En,allpass_out,allpass_delay);

    assign dout=din+fir_out+allpass_delay;

endmodule