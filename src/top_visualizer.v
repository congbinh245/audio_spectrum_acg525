module top_visualizer (
    input  wire clk,          // T9 (50MHz)
    input  wire reset_n,      // C15 (KEY2)

    // Bus I2C cấu hình Codec WM8960
    output wire iic_0_scl,    // L7
    inout  wire iic_0_sda,    // H5

    // Giao tiếp I2S từ WM8960
    output wire I2S_MCLK,     // J6
    input  wire I2S_BCLK,     // K5
    input  wire I2S_ADCLRC,   // J7
    input  wire I2S_ADCDAT,   // H3
    output wire I2S_DACDAT,   // E3
    input  wire I2S_DACLRC,   // K6

    // Màn hình OLED SSD1306 (Cổng P9)
    output wire oled_scl,     // R3
    inout  wire oled_sda,     // T3

    // Cổng xuất màn hình HDMI (Tang Primer 25K)
    output wire       tmds_clk_p,   // M10
    output wire       tmds_clk_n,   // N9
    output wire [2:0] tmds_data_p,  // R7, T6, R5
    output wire [2:0] tmds_data_n,  // T7, V6, T5

    // 4 LED báo trạng thái onboard
    output wire led1,         // D14 (Nhịp tim Clock 50MHz)
    output wire led2,         // C14 (Sáng khi WM8960 nạp xong I2C)
    output wire led3,         // B9  (Chớp nháy theo nhịp Bass từ giắc 3.5mm)
    output wire led4          // A9  (Sáng khi OLED đã khởi tạo và HDMI PLL locked)
);

    // 1. Tạo xung MCLK 12.5MHz cấp cho WM8960
    reg [1:0] mclk_div;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) mclk_div <= 2'd0;
        else mclk_div <= mclk_div + 1'b1;
    end
    assign I2S_MCLK = mclk_div[1];

    // 2. Khởi tạo chip WM8960 chính hãng
    wire wm8960_done;
    WM8960_Init u_wm8960_init (
        .Clk(clk),
        .Rst_n(reset_n),
        .I2C_Init_Done(wm8960_done),
        .i2c_sclk(iic_0_scl),
        .i2c_sdat(iic_0_sda)
    );
    assign led2 = wm8960_done;

    // 3. Module thu nhận âm thanh I2S từ Line-In
    wire [15:0] audio_sample;
    wire        sample_valid;
    i2s_rx_audio u_i2s_rx (
        .clk(clk),
        .rst_n(reset_n & wm8960_done),
        .bclk(I2S_BCLK),
        .adclrc(I2S_ADCLRC),
        .adcdat(I2S_ADCDAT),
        .sample_out(audio_sample),
        .sample_valid(sample_valid)
    );

    // Đèn LED3 báo hiệu có tiếng nhạc
    wire signed [15:0] s_audio = audio_sample;
    wire [15:0] abs_audio = (s_audio < 0) ? -s_audio : s_audio;
    reg [21:0] audio_activity_cnt;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) audio_activity_cnt <= 22'd0;
        else if (sample_valid && (abs_audio > 16'd800))
            audio_activity_cnt <= 22'd2_000_000;
        else if (audio_activity_cnt > 0)
            audio_activity_cnt <= audio_activity_cnt - 1'b1;
    end
    assign led3 = (audio_activity_cnt > 0);

    // 4. IP Core Gowin FFT 1024 điểm & Bộ đệm
    wire        fft_start;
    wire [15:0] fft_xn_re;
    wire [15:0] fft_xn_im;
    wire        fft_busy;
    wire [9:0]  fft_idx;
    wire [15:0] fft_xk_re;
    wire [15:0] fft_xk_im;
    wire        fft_opd;

    fft_stream_ctrl u_fft_ctrl (
        .clk(clk),
        .rst_n(reset_n),
        .sample_in(audio_sample),
        .sample_valid(sample_valid),
        .fft_start(fft_start),
        .fft_xn_re(fft_xn_re),
        .fft_xn_im(fft_xn_im),
        .fft_busy(fft_busy),
        .fft_idx(fft_idx),
        .fft_xk_re(fft_xk_re),
        .fft_xk_im(fft_xk_im),
        .fft_opd(fft_opd),
        .bar_addr_in(5'd0),
        .bar_height_out()
    );

    wire fft_rst = ~reset_n;
    FFT_Top u_FFT_Spectrum (
        .idx(fft_idx),
        .xk_re(fft_xk_re),
        .xk_im(fft_xk_im),
        .sod(),
        .ipd(),
        .eod(),
        .busy(fft_busy),
        .soud(),
        .opd(fft_opd),
        .eoud(),
        .xn_re(fft_xn_re),
        .xn_im(fft_xn_im),
        .start(fft_start),
        .clk(clk),
        .rst(fft_rst)
    );

    // 5. Tính toán chiều cao 16 dải tần số
    wire [6:0] b_h0,  b_h1,  b_h2,  b_h3;
    wire [6:0] b_h4,  b_h5,  b_h6,  b_h7;
    wire [6:0] b_h8,  b_h9,  b_h10, b_h11;
    wire [6:0] b_h12, b_h13, b_h14, b_h15;

    spectrum_calc u_spec_calc (
        .clk(clk),
        .rst_n(reset_n),
        .fft_opd(fft_opd),
        .fft_idx(fft_idx),
        .fft_xk_re(fft_xk_re),
        .fft_xk_im(fft_xk_im),
        .bar_h0(b_h0),   .bar_h1(b_h1),   .bar_h2(b_h2),   .bar_h3(b_h3),
        .bar_h4(b_h4),   .bar_h5(b_h5),   .bar_h6(b_h6),   .bar_h7(b_h7),
        .bar_h8(b_h8),   .bar_h9(b_h9),   .bar_h10(b_h10), .bar_h11(b_h11),
        .bar_h12(b_h12), .bar_h13(b_h13), .bar_h14(b_h14), .bar_h15(b_h15),
        .frame_ready()
    );

    // 6. Quét và vẽ phổ liên tục lên màn hình OLED SSD1306
    wire oled_ready;

    oled_spectrum_streamer u_oled_streamer (
        .clk(clk),
        .rst_n(reset_n),
        .bar_h0(b_h0),   .bar_h1(b_h1),   .bar_h2(b_h2),   .bar_h3(b_h3),
        .bar_h4(b_h4),   .bar_h5(b_h5),   .bar_h6(b_h6),   .bar_h7(b_h7),
        .bar_h8(b_h8),   .bar_h9(b_h9),   .bar_h10(b_h10), .bar_h11(b_h11),
        .bar_h12(b_h12), .bar_h13(b_h13), .bar_h14(b_h14), .bar_h15(b_h15),
        .oled_scl(oled_scl),
        .oled_sda(oled_sda),
        .oled_ready(oled_ready)
    );

    // ========================================================================
    // 7. Khối xuất đồ họa qua cổng HDMI (Độ phân giải 800x480 @ 60Hz)
    // ========================================================================
    // 7.1. PLL tạo 33MHz (Pixel clock) và 165MHz (5x TMDS bit clock)
    wire clk_vga;    // 33MHz
    wire clk_vgax5;  // 165MHz
    wire pll_lock;

    Gowin_PLL u_hdmi_pll (
        .lock(pll_lock),
        .clkout0(clk_vga),
        .clkout1(clk_vgax5),
        .clkin(clk)
    );

    assign led4 = oled_ready & pll_lock;

    // 7.2. Bộ điều khiển quét màn hình VGA / HDMI Timing
    wire [11:0] hcount;
    wire [11:0] vcount;
    wire [23:0] disp_data;
    wire        disp_data_req;
    wire        video_hs;
    wire        video_vs;
    wire        video_de;
    wire [7:0]  video_r;
    wire [7:0]  video_g;
    wire [7:0]  video_b;

    disp_driver u_disp_driver (
        .ClkDisp(clk_vga),
        .Rst_n(reset_n),
        .Data(disp_data),
        .DataReq(disp_data_req),
        .H_Addr(hcount),
        .V_Addr(vcount),
        .Disp_HS(video_hs),
        .Disp_VS(video_vs),
        .Disp_Red(video_r),
        .Disp_Green(video_g),
        .Disp_Blue(video_b),
        .Disp_DE(video_de),
        .Disp_PCLK()
    );

    // 7.3. Bộ hiển thị phổ âm thanh FFT 16 cột lên màn hình HDMI 800x480
    //      color_bar_mode = 1'b0 : Xem phổ âm thanh thực tế với hiệu ứng LED gradient
    //      color_bar_mode = 1'b1 : Xem 8 thanh màu Color Bar để test cổng HDMI
    hdmi_spectrum_display #(
        .DISP_WIDTH(800),
        .DISP_HEIGHT(480)
    ) u_hdmi_display (
        .disp_clk(clk_vga),
        .rst_n(reset_n),
        .disp_h_addr(hcount),
        .disp_v_addr(vcount),
        .disp_data_req(disp_data_req),
        .bar_h0(b_h0),   .bar_h1(b_h1),   .bar_h2(b_h2),   .bar_h3(b_h3),
        .bar_h4(b_h4),   .bar_h5(b_h5),   .bar_h6(b_h6),   .bar_h7(b_h7),
        .bar_h8(b_h8),   .bar_h9(b_h9),   .bar_h10(b_h10), .bar_h11(b_h11),
        .bar_h12(b_h12), .bar_h13(b_h13), .bar_h14(b_h14), .bar_h15(b_h15),
        .color_bar_mode(1'b0),
        .disp_data(disp_data)
    );

    // 7.4. Bộ mã hóa DVI / TMDS 8b/10b và tuần tự hóa vi sai 10:1 (DDR)
    dvi_encoder u_dvi_encoder (
        .pixelclk(clk_vga),
        .pixelclk5x(clk_vgax5),
        .rst_n(reset_n),
        .blue_din(video_b),
        .green_din(video_g),
        .red_din(video_r),
        .hsync(video_hs),
        .vsync(video_vs),
        .de(video_de),
        .tmds_clk_p(tmds_clk_p),
        .tmds_clk_n(tmds_clk_n),
        .tmds_data_p(tmds_data_p),
        .tmds_data_n(tmds_data_n)
    );

    // Nhịp tim Clock 50MHz
    reg [24:0] hb_cnt;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) hb_cnt <= 25'd0;
        else hb_cnt <= hb_cnt + 1'b1;
    end
    assign led1 = hb_cnt[24];
    assign I2S_DACDAT = 1'b0;

endmodule