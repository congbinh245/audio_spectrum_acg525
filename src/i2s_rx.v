module i2s_rx_audio (
    input  wire        clk,          // 50MHz
    input  wire        rst_n,        // Reset C15
    input  wire        bclk,         // K5
    input  wire        adclrc,       // J7
    input  wire        adcdat,       // H3
    output reg  [15:0] sample_out,   // Mẫu âm thanh 16-bit cho FFT
    output reg         sample_valid  // Xung báo mẫu mới
);

    reg [2:0] bclk_r, lrck_r;
    reg [1:0] sdata_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bclk_r  <= 3'b0;
            lrck_r  <= 3'b0;
            sdata_r <= 2'b0;
        end else begin
            bclk_r  <= {bclk_r[1:0], bclk};
            lrck_r  <= {lrck_r[1:0], adclrc};
            sdata_r <= {sdata_r[0], adcdat};
        end
    end

    wire bclk_pos = (bclk_r[2:1] == 2'b01);
    wire lrck_edge = (lrck_r[2] ^ lrck_r[1]);

    reg [5:0]  bit_cnt;
    reg [15:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt      <= 6'd0;
            shift_reg    <= 16'd0;
            sample_out   <= 16'd0;
            sample_valid <= 1'b0;
        end else begin
            sample_valid <= 1'b0;
            if (lrck_edge) begin
                bit_cnt <= 6'd0;
            end else if (bclk_pos) begin
                bit_cnt <= bit_cnt + 1'b1;
                // Chuẩn I2S: bit đầu tiên bỏ qua, 16 bit tiếp theo là Data MSB->LSB
                if (bit_cnt >= 6'd1 && bit_cnt <= 6'd16) begin
                    shift_reg <= {shift_reg[14:0], sdata_r[1]};
                    if (bit_cnt == 6'd16 && lrck_r[1] == 1'b0) begin // Kênh trái
                        sample_out   <= {shift_reg[14:0], sdata_r[1]};
                        sample_valid <= 1'b1;
                    end
                end
            end
        end
    end

endmodule