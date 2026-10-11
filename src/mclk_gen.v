module mclk_gen (
    input  wire clk,      // 50MHz (T9)
    input  wire rst_n,    // Reset (C15)
    output reg  mclk      // 12.5MHz (J6)
);
    reg [1:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt  <= 2'd0;
            mclk <= 1'b0;
        end else begin
            cnt  <= cnt + 1'b1;
            mclk <= cnt[1];
        end
    end
endmodule