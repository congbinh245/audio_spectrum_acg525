module sig_delay#(
	parameter DW=16,
    parameter deltaT=307
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

    reg signed [DW-1:0] Dreg [0:deltaT-1];

    always @(posedge clk or negedge rst_n)begin
            if(~rst_n)Dreg[0]<='b0;
            else Dreg[0]<=din;
        end

    genvar i;
    generate
        for(i=1;i<deltaT;i=i+1)begin:gen_block1
            always @(posedge clk or negedge rst_n)begin
            if(~rst_n)Dreg[i]<='b0;
            else Dreg[i]<=Dreg[i-1];
            end
        end
    endgenerate
/*genvar i,t;
generate
    for(i=1;(i<deltaT)&&(i<2000);i=i+1)begin:gen_block1
        always@ (posedge clk or negedge rst_n)begin
        if(~rst_n)Dreg[i]<='b0;
        else Dreg[i]<=Dreg[i-1];
        end
    end
//如果延时小于2000，显而易见；如果延时大于2000，则运行2000次，从1到1999的Dreg被依次用前一级非阻塞赋值
endgenerate

generate
   for(t=2000;t<deltaT;t=t+1)begin:gen_block2//从2000到
        always@ (posedge clk or negedge rst_n)begin
        if(~rst_n)Dreg[t]<='b0;
        else Dreg[t]<=Dreg[t-1];
        end
    end
//如果延时小于等于2000，第二个for循环不执行；如果延时大于2000，则从2000到deltaT-1的Dreg被依次用前一级非阻塞赋值

endgenerate
*/
assign dout = Dreg[deltaT-1];
endmodule