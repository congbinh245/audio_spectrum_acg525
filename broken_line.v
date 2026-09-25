module broken_line(
    input wire signed [15:0] din,
    output reg signed [15:0] dout
);

parameter x_th = 16'b0000_0010_0000_0000;
wire [13:0] div4_din;
wire [17:0] triple_xth;
wire [15:0] triple_and_div4_xth; //值为正
wire [15:0] rev_triple_and_div4_xth; //值为负
wire [15:0] abs_din;

assign abs_din = (din[15]==1)? (~din + 1'b1):din;
assign div4_din = din >>> 2;
assign triple_xth = 3 * x_th;
assign triple_and_div4_xth = triple_xth >>> 2;
assign rev_triple_and_div4_xth = (~triple_and_div4_xth + 1'b1);

always @(din) begin
    if (abs_din > x_th) begin
        if (din[15] == 1) begin
            dout <= {{2{1'b1}},din[15:2]} - triple_and_div4_xth;
        end
        else begin
            dout <= {{2{1'b0}},din[15:2]}  + triple_and_div4_xth;
        end
    end
    else begin
        dout <= din;
    end
end

endmodule
