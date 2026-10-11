module fft_stream_ctrl (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] sample_in,
    input  wire        sample_valid,
    output reg         fft_start,
    output reg  [15:0] fft_xn_re,
    output wire [15:0] fft_xn_im,
    input  wire        fft_busy,
    input  wire [9:0]  fft_idx,
    input  wire [15:0] fft_xk_re,
    input  wire [15:0] fft_xk_im,
    input  wire        fft_opd,
    input  wire [4:0]  bar_addr_in,
    output wire [5:0]  bar_height_out
);

    assign fft_xn_im = 16'd0;

    reg [15:0] sample_buf [0:1023];
    reg [9:0]  wr_ptr;
    reg        buf_ready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr    <= 10'd0;
            buf_ready <= 1'b0;
        end else if (sample_valid) begin
            sample_buf[wr_ptr] <= sample_in;
            wr_ptr <= wr_ptr + 1'b1;
            buf_ready <= (wr_ptr == 10'd1023);
        end else begin
            buf_ready <= 1'b0;
        end
    end

    reg [9:0] rd_ptr;
    reg       feeding;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr    <= 10'd0;
            fft_start <= 1'b0;
            feeding   <= 1'b0;
            fft_xn_re <= 16'd0;
        end else begin
            fft_start <= 1'b0;
            if (buf_ready && !fft_busy && !feeding) begin
                fft_start <= 1'b1;
                feeding   <= 1'b1;
                rd_ptr    <= 10'd0;
            end else if (feeding) begin
                fft_xn_re <= sample_buf[rd_ptr];
                rd_ptr    <= rd_ptr + 1'b1;
                if (rd_ptr == 10'd1023) feeding <= 1'b0;
            end
        end
    end

    // Tính Magnitude gần đúng
    wire [15:0] abs_re = fft_xk_re[15] ? (~fft_xk_re + 1'b1) : fft_xk_re;
    wire [15:0] abs_im = fft_xk_im[15] ? (~fft_xk_im + 1'b1) : fft_xk_im;
    wire [15:0] mag = (abs_re > abs_im) ? (abs_re + (abs_im >> 1)) : (abs_im + (abs_re >> 1));

    reg [5:0] col_heights [0:31];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i=0; i<32; i=i+1) col_heights[i] <= 6'd0;
        end else if (fft_opd && fft_idx < 10'd512) begin
            if (mag[15:10] > col_heights[fft_idx[8:4]])
                col_heights[fft_idx[8:4]] <= (mag[15:10] > 6'd63) ? 6'd63 : mag[15:10];
        end else if (buf_ready) begin
            for (i=0; i<32; i=i+1) begin
                if (col_heights[i] > 6'd1) col_heights[i] <= col_heights[i] - 6'd1;
                else col_heights[i] <= 6'd0;
            end
        end
    end

    assign bar_height_out = col_heights[bar_addr_in];
endmodule