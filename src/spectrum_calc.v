module spectrum_calc (
    input  wire        clk,
    input  wire        rst_n,

    // Giao tiếp đầu ra FFT Gowin
    input  wire        fft_opd,      // Xung báo dữ liệu FFT hợp lệ
    input  wire [9:0]  fft_idx,      // Chỉ số tần số 0..1023
    input  wire [15:0] fft_xk_re,    // Phần thực
    input  wire [15:0] fft_xk_im,    // Phần ảo

    // Xuất 16 cột phổ âm thanh ra OLED (mỗi cột cao 0..64 pixel)
    output reg  [6:0]  bar_h0,  bar_h1,  bar_h2,  bar_h3,
    output reg  [6:0]  bar_h4,  bar_h5,  bar_h6,  bar_h7,
    output reg  [6:0]  bar_h8,  bar_h9,  bar_h10, bar_h11,
    output reg  [6:0]  bar_h12, bar_h13, bar_h14, bar_h15,
    output reg         frame_ready
);

    // Tính xấp xỉ Magnitude: |Re| + |Im|
    wire signed [15:0] s_re = fft_xk_re;
    wire signed [15:0] s_im = fft_xk_im;
    wire [15:0] abs_re = (s_re < 0) ? -s_re : s_re;
    wire [15:0] abs_im = (s_im < 0) ? -s_im : s_im;
    wire [16:0] mag = abs_re + abs_im;

    // Bộ tích lũy giá trị đỉnh cho 16 cột
    reg [16:0] max_val [0:15];
    integer i;

    // Phân loại dải tần số (Logarithmic Band Mapping)
    reg [3:0] band_sel;
    always @(*) begin
        if      (fft_idx <= 10'd2)   band_sel = 4'd0;   // Sub-bass
        else if (fft_idx <= 10'd5)   band_sel = 4'd1;   // Bass
        else if (fft_idx <= 10'd9)   band_sel = 4'd2;
        else if (fft_idx <= 10'd15)  band_sel = 4'd3;
        else if (fft_idx <= 10'd23)  band_sel = 4'd4;   // Low-mid
        else if (fft_idx <= 10'd34)  band_sel = 4'd5;
        else if (fft_idx <= 10'd48)  band_sel = 4'd6;
        else if (fft_idx <= 10'd68)  band_sel = 4'd7;   // Mid
        else if (fft_idx <= 10'd94)  band_sel = 4'd8;
        else if (fft_idx <= 10'd130) band_sel = 4'd9;
        else if (fft_idx <= 10'd180) band_sel = 4'd10;  // High-mid
        else if (fft_idx <= 10'd240) band_sel = 4'd11;
        else if (fft_idx <= 10'd310) band_sel = 4'd12;
        else if (fft_idx <= 10'd390) band_sel = 4'd13;  // Presence
        else if (fft_idx <= 10'd480) band_sel = 4'd14;  // Treble
        else                         band_sel = 4'd15;
    end

    // Hàm quy đổi biên độ sang chiều cao 0..64 pixel (đã tăng x2 độ nhạy)
    function [6:0] scale_to_bar;
        input [16:0] val;
        reg [16:0] scaled;
        begin
            scaled = val >> 8; 
            if (scaled > 17'd64) scale_to_bar = 7'd64;
            else scale_to_bar = scaled[6:0];
        end
    endfunction

    // Hàm cập nhật mượt (Fast Attack, Smooth Decay)
    function [6:0] smooth_fall;
        input [6:0] current_h;
        input [6:0] target_h;
        begin
            if (target_h >= current_h)
                smooth_fall = target_h;         // Đập lên tức thì
            else if (current_h > 7'd1)
                smooth_fall = current_h - 7'd1; // Hạ từ từ 1 pixel/frame
            else
                smooth_fall = 7'd0;
        end
    endfunction

    // Khối duy nhất xử lý tích lũy đỉnh và chốt làm mượt
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            frame_ready <= 1'b0;
            for (i = 0; i < 16; i = i + 1) max_val[i] <= 17'd0;
            bar_h0  <= 7'd0; bar_h1  <= 7'd0; bar_h2  <= 7'd0; bar_h3  <= 7'd0;
            bar_h4  <= 7'd0; bar_h5  <= 7'd0; bar_h6  <= 7'd0; bar_h7  <= 7'd0;
            bar_h8  <= 7'd0; bar_h9  <= 7'd0; bar_h10 <= 7'd0; bar_h11 <= 7'd0;
            bar_h12 <= 7'd0; bar_h13 <= 7'd0; bar_h14 <= 7'd0; bar_h15 <= 7'd0;
        end else begin
            frame_ready <= 1'b0;
            if (fft_opd && (fft_idx < 10'd512)) begin
                if (mag > max_val[band_sel])
                    max_val[band_sel] <= mag;

                // Khi quét xong 512 điểm tần số -> Chốt khung và làm mượt hạ cột
                if (fft_idx == 10'd511) begin
                    bar_h0  <= smooth_fall(bar_h0,  scale_to_bar(max_val[0]));
                    bar_h1  <= smooth_fall(bar_h1,  scale_to_bar(max_val[1]));
                    bar_h2  <= smooth_fall(bar_h2,  scale_to_bar(max_val[2]));
                    bar_h3  <= smooth_fall(bar_h3,  scale_to_bar(max_val[3]));
                    bar_h4  <= smooth_fall(bar_h4,  scale_to_bar(max_val[4]));
                    bar_h5  <= smooth_fall(bar_h5,  scale_to_bar(max_val[5]));
                    bar_h6  <= smooth_fall(bar_h6,  scale_to_bar(max_val[6]));
                    bar_h7  <= smooth_fall(bar_h7,  scale_to_bar(max_val[7]));
                    bar_h8  <= smooth_fall(bar_h8,  scale_to_bar(max_val[8]));
                    bar_h9  <= smooth_fall(bar_h9,  scale_to_bar(max_val[9]));
                    bar_h10 <= smooth_fall(bar_h10, scale_to_bar(max_val[10]));
                    bar_h11 <= smooth_fall(bar_h11, scale_to_bar(max_val[11]));
                    bar_h12 <= smooth_fall(bar_h12, scale_to_bar(max_val[12]));
                    bar_h13 <= smooth_fall(bar_h13, scale_to_bar(max_val[13]));
                    bar_h14 <= smooth_fall(bar_h14, scale_to_bar(max_val[14]));
                    bar_h15 <= smooth_fall(bar_h15, scale_to_bar(max_val[15]));

                    for (i = 0; i < 16; i = i + 1) max_val[i] <= 17'd0; // Reset khung mới
                    frame_ready <= 1'b1;
                end
            end
        end
    end

endmodule