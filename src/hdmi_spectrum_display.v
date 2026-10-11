`timescale 1ns / 1ps
// ============================================================================
// Module: hdmi_spectrum_display
// Thiết kế: 
// - Nền đen tuyền nguyên bản (không chia ô, không đường kẻ lưới).
// - Hiển thị 16 cột phổ âm thanh FFT trải đều trên độ phân giải 800x480.
// - Hiệu ứng cầu vồng RGB phân tầng theo cao độ từ đáy lên đỉnh:
//     Vạch 1 (đáy): Đỏ rực -> Vạch 2: Đỏ cam -> Vạch 3: Cam -> ... 
//     -> Vàng -> Xanh lá -> Cyan -> Xanh dương -> Tím -> Hồng neon (đỉnh).
// - Mỗi vạch có rãnh ngăn cách tạo hiệu ứng đèn LED VU-meter rời rạc bắt mắt.
// - Đỉnh chóp mỗi cột có vạch chốt màu trắng sáng (Peak Cap).
// ============================================================================

module hdmi_spectrum_display #(
    parameter DISP_WIDTH  = 800,
    parameter DISP_HEIGHT = 480
)(
    input  wire        disp_clk,       // Pixel clock 33MHz
    input  wire        rst_n,          // Reset
    
    // Tọa độ quét từ disp_driver
    input  wire [11:0] disp_h_addr,
    input  wire [11:0] disp_v_addr,
    input  wire        disp_data_req,  // Disp_DE (vùng quét hợp lệ)

    // Chiều cao 16 dải tần số nhận từ spectrum_calc (mỗi dải 0..64)
    input  wire [6:0]  bar_h0,  bar_h1,  bar_h2,  bar_h3,
    input  wire [6:0]  bar_h4,  bar_h5,  bar_h6,  bar_h7,
    input  wire [6:0]  bar_h8,  bar_h9,  bar_h10, bar_h11,
    input  wire [6:0]  bar_h12, bar_h13, bar_h14, bar_h15,

    // Chọn chế độ hiển thị: 0 = Phổ âm thanh cầu vồng RGB, 1 = Color Bar test
    input  wire        color_bar_mode,

    // Dữ liệu màu RGB888 xuất sang DVI Encoder
    output reg  [23:0] disp_data
);

    // ========================================================================
    // 1. Chốt (Latch) chiều cao 16 cột phổ tại đầu mỗi khung hình (chống rách hình)
    // ========================================================================
    reg [6:0] lat_h [0:15];
    integer k;

    always @(posedge disp_clk or negedge rst_n) begin
        if (!rst_n) begin
            for (k = 0; k < 16; k = k + 1)
                lat_h[k] <= 7'd0;
        end else if (disp_v_addr == 12'd0 && disp_h_addr == 12'd0) begin
            lat_h[0]  <= bar_h0;  lat_h[1]  <= bar_h1;
            lat_h[2]  <= bar_h2;  lat_h[3]  <= bar_h3;
            lat_h[4]  <= bar_h4;  lat_h[5]  <= bar_h5;
            lat_h[6]  <= bar_h6;  lat_h[7]  <= bar_h7;
            lat_h[8]  <= bar_h8;  lat_h[9]  <= bar_h9;
            lat_h[10] <= bar_h10; lat_h[11] <= bar_h11;
            lat_h[12] <= bar_h12; lat_h[13] <= bar_h13;
            lat_h[14] <= bar_h14; lat_h[15] <= bar_h15;
        end
    end

    // ========================================================================
    // 2. Xác định vị trí 16 cột ngang (Mỗi cột chiếm 50px trong 800px)
    //    Thân cột rộng 40px (x_in_col từ 5 đến 44), khe cách nhau 10px nền đen
    // ========================================================================
    reg [3:0]  col_idx;
    reg [5:0]  x_in_col;
    reg        in_bar_x;

    always @(*) begin
        if (disp_h_addr < 12'd50)        begin col_idx = 4'd0;  x_in_col = disp_h_addr - 12'd0;   end
        else if (disp_h_addr < 12'd100)  begin col_idx = 4'd1;  x_in_col = disp_h_addr - 12'd50;  end
        else if (disp_h_addr < 12'd150)  begin col_idx = 4'd2;  x_in_col = disp_h_addr - 12'd100; end
        else if (disp_h_addr < 12'd200)  begin col_idx = 4'd3;  x_in_col = disp_h_addr - 12'd150; end
        else if (disp_h_addr < 12'd250)  begin col_idx = 4'd4;  x_in_col = disp_h_addr - 12'd200; end
        else if (disp_h_addr < 12'd300)  begin col_idx = 4'd5;  x_in_col = disp_h_addr - 12'd250; end
        else if (disp_h_addr < 12'd350)  begin col_idx = 4'd6;  x_in_col = disp_h_addr - 12'd300; end
        else if (disp_h_addr < 12'd400)  begin col_idx = 4'd7;  x_in_col = disp_h_addr - 12'd350; end
        else if (disp_h_addr < 12'd450)  begin col_idx = 4'd8;  x_in_col = disp_h_addr - 12'd400; end
        else if (disp_h_addr < 12'd500)  begin col_idx = 4'd9;  x_in_col = disp_h_addr - 12'd450; end
        else if (disp_h_addr < 12'd550)  begin col_idx = 4'd10; x_in_col = disp_h_addr - 12'd500; end
        else if (disp_h_addr < 12'd600)  begin col_idx = 4'd11; x_in_col = disp_h_addr - 12'd550; end
        else if (disp_h_addr < 12'd650)  begin col_idx = 4'd12; x_in_col = disp_h_addr - 12'd600; end
        else if (disp_h_addr < 12'd700)  begin col_idx = 4'd13; x_in_col = disp_h_addr - 12'd650; end
        else if (disp_h_addr < 12'd750)  begin col_idx = 4'd14; x_in_col = disp_h_addr - 12'd700; end
        else if (disp_h_addr < 12'd800)  begin col_idx = 4'd15; x_in_col = disp_h_addr - 12'd750; end
        else                             begin col_idx = 4'd0;  x_in_col = 6'd0;                  end

        in_bar_x = (x_in_col >= 6'd5) && (x_in_col < 6'd45);
    end

    // ========================================================================
    // 3. Tính toán độ cao theo trục Y và phân lớp 16 vạch cầu vồng RGB
    //    Đường đáy (Y_BASE) nằm tại y = 440.
    //    Cột dâng lên tối đa 384 pixel (64 * 6) -> 16 vạch, mỗi vạch cao 24px.
    // ========================================================================
    localparam Y_BASE = 12'd440;

    wire [6:0]  cur_h_val = lat_h[col_idx];
    wire [11:0] cur_h_pix = {cur_h_val, 2'b00} + {cur_h_val, 1'b0}; // cur_h_val * 6

    // Khoảng cách pixel tính từ đáy trở lên (0 ở đáy Y_BASE, tăng dần khi vươn lên đỉnh)
    wire [11:0] v_from_base = (disp_v_addr <= Y_BASE) ? (Y_BASE - disp_v_addr) : 12'd0;

    // Pixel thuộc phạm vi đang phát sáng của cột sóng
    wire in_bar_active = (disp_v_addr <= Y_BASE) && (v_from_base <= cur_h_pix) && (cur_h_val > 7'd0);

    // Đỉnh chốt (Peak Cap) màu trắng sáng dày 3 pixel tại đầu ngọn cột sóng
    wire is_peak_cap = (cur_h_pix > 12'd2) && (v_from_base >= cur_h_pix - 12'd2) && (v_from_base <= cur_h_pix);

    // Xác định chỉ số vạch (0..15): mỗi vạch cao 24 pixel
    reg [3:0] seg_idx;
    reg [4:0] v_in_seg; // Tọa độ tương đối bên trong mỗi vạch (0..23)

    always @(*) begin
        if (v_from_base < 12'd24)        begin seg_idx = 4'd0;  v_in_seg = v_from_base - 12'd0;   end
        else if (v_from_base < 12'd48)   begin seg_idx = 4'd1;  v_in_seg = v_from_base - 12'd24;  end
        else if (v_from_base < 12'd72)   begin seg_idx = 4'd2;  v_in_seg = v_from_base - 12'd48;  end
        else if (v_from_base < 12'd96)   begin seg_idx = 4'd3;  v_in_seg = v_from_base - 12'd72;  end
        else if (v_from_base < 12'd120)  begin seg_idx = 4'd4;  v_in_seg = v_from_base - 12'd96;  end
        else if (v_from_base < 12'd144)  begin seg_idx = 4'd5;  v_in_seg = v_from_base - 12'd120; end
        else if (v_from_base < 12'd168)  begin seg_idx = 4'd6;  v_in_seg = v_from_base - 12'd144; end
        else if (v_from_base < 12'd192)  begin seg_idx = 4'd7;  v_in_seg = v_from_base - 12'd168; end
        else if (v_from_base < 12'd216)  begin seg_idx = 4'd8;  v_in_seg = v_from_base - 12'd192; end
        else if (v_from_base < 12'd240)  begin seg_idx = 4'd9;  v_in_seg = v_from_base - 12'd216; end
        else if (v_from_base < 12'd264)  begin seg_idx = 4'd10; v_in_seg = v_from_base - 12'd240; end
        else if (v_from_base < 12'd288)  begin seg_idx = 4'd11; v_in_seg = v_from_base - 12'd264; end
        else if (v_from_base < 12'd312)  begin seg_idx = 4'd12; v_in_seg = v_from_base - 12'd288; end
        else if (v_from_base < 12'd336)  begin seg_idx = 4'd13; v_in_seg = v_from_base - 12'd312; end
        else if (v_from_base < 12'd360)  begin seg_idx = 4'd14; v_in_seg = v_from_base - 12'd336; end
        else                             begin seg_idx = 4'd15; v_in_seg = v_from_base - 12'd360; end
    end

    // Rãnh đen ngăn cách giữa các vạch LED (3 pixel trên cùng của mỗi vạch là màu đen)
    wire is_slit = (v_in_seg >= 5'd21);

    // ========================================================================
    // 4. Bảng 16 màu Cầu vồng Quang phổ RGB (Từ Đỏ dưới đáy -> Tím/Hồng trên đỉnh)
    // ========================================================================
    reg [23:0] rainbow_seg_color;

    always @(*) begin
        case (seg_idx)
            4'd0:  rainbow_seg_color = 24'hFF0000; // Vạch 1:  Đỏ rực (Red)
            4'd1:  rainbow_seg_color = 24'hFF3300; // Vạch 2:  Đỏ cam
            4'd2:  rainbow_seg_color = 24'hFF6600; // Vạch 3:  Cam đậm (Orange)
            4'd3:  rainbow_seg_color = 24'hFF9900; // Vạch 4:  Cam sáng
            4'd4:  rainbow_seg_color = 24'hFFCC00; // Vạch 5:  Vàng cam (Gold)
            4'd5:  rainbow_seg_color = 24'hFFFF00; // Vạch 6:  Vàng tươi (Yellow)
            4'd6:  rainbow_seg_color = 24'hBFFF00; // Vạch 7:  Vàng chanh
            4'd7:  rainbow_seg_color = 24'h66FF00; // Vạch 8:  Xanh nõn chuối
            4'd8:  rainbow_seg_color = 24'h00FF33; // Vạch 9:  Xanh lá Neon (Green)
            4'd9:  rainbow_seg_color = 24'h00FF99; // Vạch 10: Xanh ngọc (Aqua)
            4'd10: rainbow_seg_color = 24'h00FFFF; // Vạch 11: Xanh lơ (Cyan)
            4'd11: rainbow_seg_color = 24'h0099FF; // Vạch 12: Xanh da trời
            4'd12: rainbow_seg_color = 24'h0033FF; // Vạch 13: Xanh dương (Blue)
            4'd13: rainbow_seg_color = 24'h6600FF; // Vạch 14: Chàm tím (Indigo)
            4'd14: rainbow_seg_color = 24'hCC00FF; // Vạch 15: Tím tươi (Purple)
            4'd15: rainbow_seg_color = 24'hFF007F; // Vạch 16: Hồng neon cực đại (Hot Pink)
        endcase
    end

    // ========================================================================
    // 5. Kết hợp màu sắc: Nền đen tuyền + Cột sóng cầu vồng RGB + Peak trắng
    // ========================================================================
    reg [23:0] spectrum_pixel;

    always @(*) begin
        if (!in_bar_x || !in_bar_active) begin
            // Nền đen hoàn toàn (100% Black) không chia ô hay đường lưới
            spectrum_pixel = 24'h000000;
        end else if (is_peak_cap) begin
            // Đỉnh chóp cột phát sáng màu trắng tinh
            spectrum_pixel = 24'hFFFFFF;
        end else if (is_slit) begin
            // Khe rãnh ngăn cách giữa các vạch LED
            spectrum_pixel = 24'h000000;
        end else begin
            // Vạch LED sáng màu tương ứng theo cao độ cầu vồng RGB
            spectrum_pixel = rainbow_seg_color;
        end
    end

    // ========================================================================
    // 6. Mẫu màu Color Bar chuẩn (để test khi cần)
    // ========================================================================
    reg [23:0] color_bar_data;
    always @(*) begin
        if (disp_h_addr < 12'd100)       color_bar_data = 24'hFFFFFF; // Trắng
        else if (disp_h_addr < 12'd200) color_bar_data = 24'hFFFF00; // Vàng
        else if (disp_h_addr < 12'd300) color_bar_data = 24'h00FFFF; // Cyan
        else if (disp_h_addr < 12'd400) color_bar_data = 24'h00FF00; // Xanh lá
        else if (disp_h_addr < 12'd500) color_bar_data = 24'hFF00FF; // Tím
        else if (disp_h_addr < 12'd600) color_bar_data = 24'hFF0000; // Đỏ
        else if (disp_h_addr < 12'd700) color_bar_data = 24'h0000FF; // Xanh dương
        else                            color_bar_data = 24'h000000; // Đen
    end

    // ========================================================================
    // 7. Ngõ ra Pixel xuất sang DVI Encoder
    // ========================================================================
    always @(posedge disp_clk) begin
        if (!disp_data_req)
            disp_data <= 24'h000000;
        else if (color_bar_mode)
            disp_data <= color_bar_data;
        else
            disp_data <= spectrum_pixel;
    end

endmodule
