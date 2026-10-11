module oled_spectrum_streamer (
    input  wire        clk,        // 50MHz
    input  wire        rst_n,      // Reset C15

    // Chiều cao 16 cột phổ nhận từ spectrum_calc
    input  wire [6:0]  bar_h0,  bar_h1,  bar_h2,  bar_h3,
    input  wire [6:0]  bar_h4,  bar_h5,  bar_h6,  bar_h7,
    input  wire [6:0]  bar_h8,  bar_h9,  bar_h10, bar_h11,
    input  wire [6:0]  bar_h12, bar_h13, bar_h14, bar_h15,

    // Bus I2C màn hình OLED (R3, T3)
    output wire        oled_scl,
    inout  wire        oled_sda,
    output reg         oled_ready
);

    // 1. Module I2C chuẩn của Xiaomeige
    reg         i2c_req;
    reg         i2c_mode; // 0: Lệnh, 1: Dữ liệu RAM
    reg  [7:0]  i2c_data;
    wire        i2c_done;
    wire        i2c_ack;

    wire [15:0] i2c_ctrl_addr = {8'h00, i2c_mode ? 8'h40 : 8'h00};

    i2c_control  u_oled_i2c (
        .Clk(clk),
        .Rst_n(rst_n),
        .wrreg_req(i2c_req),
        .rdreg_req(1'b0),
        .addr(i2c_ctrl_addr),
        .addr_mode(1'b0),
        .wrdata(i2c_data),
        .rddata(),
        .device_id(8'h78),
        .RW_Done(i2c_done),
        .ack(i2c_ack),
        //.dly_cnt_max(32'd0),
        .i2c_sclk(oled_scl),
        .i2c_sdat(oled_sda)
    );

    // 2. ROM 28 lệnh khởi tạo chuẩn SSD1306
    reg [7:0] init_rom [0:27];
    initial begin
        init_rom[0]  = 8'hAE; // OFF
        init_rom[1]  = 8'hD5; init_rom[2]  = 8'h80;
        init_rom[3]  = 8'hA8; init_rom[4]  = 8'h3F;
        init_rom[5]  = 8'hD3; init_rom[6]  = 8'h00;
        init_rom[7]  = 8'h40;
        init_rom[8]  = 8'h8D; init_rom[9]  = 8'h14; // Charge Pump
        init_rom[10] = 8'h20; init_rom[11] = 8'h02; // Page Mode
        init_rom[12] = 8'hA1; // Segment Remap
        init_rom[13] = 8'hC8; // COM Scan Direction
        init_rom[14] = 8'hDA; init_rom[15] = 8'h12;
        init_rom[16] = 8'h81; init_rom[17] = 8'hFF; // Contrast Max
        init_rom[18] = 8'hD9; init_rom[19] = 8'hF1;
        init_rom[20] = 8'hDB; init_rom[21] = 8'h40;
        init_rom[22] = 8'hA4; init_rom[23] = 8'hA6;
        init_rom[24] = 8'h2E; init_rom[25] = 8'h00; init_rom[26] = 8'h10;
        init_rom[27] = 8'hAF; // ON
    end

    // 3. Tra cứu chiều cao của 16 cột
    reg [6:0] cur_bar_h;
    wire [3:0] cur_band = col_cnt[6:3]; // 128 pixel / 16 cột = mỗi cột rộng 8 pixel
    // Thanh ghi đệm chốt dữ liệu (Shadow Registers) chống rách hình
    reg [6:0] lat_h0,  lat_h1,  lat_h2,  lat_h3;
    reg [6:0] lat_h4,  lat_h5,  lat_h6,  lat_h7;
    reg [6:0] lat_h8,  lat_h9,  lat_h10, lat_h11;
    reg [6:0] lat_h12, lat_h13, lat_h14, lat_h15;

    // Chỉ chốt khung mới khi OLED hoàn thành quét 1 lượt toàn màn hình
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lat_h0 <= 0; lat_h1 <= 0; lat_h2 <= 0; lat_h3 <= 0;
            lat_h4 <= 0; lat_h5 <= 0; lat_h6 <= 0; lat_h7 <= 0;
            lat_h8 <= 0; lat_h9 <= 0; lat_h10<= 0; lat_h11<= 0;
            lat_h12<= 0; lat_h13<= 0; lat_h14<= 0; lat_h15<= 0;
        end else if (state == S_PAGE_SET && cur_page == 3'd0 && page_step == 2'd0) begin
            lat_h0  <= bar_h0;  lat_h1  <= bar_h1;  lat_h2  <= bar_h2;  lat_h3  <= bar_h3;
            lat_h4  <= bar_h4;  lat_h5  <= bar_h5;  lat_h6  <= bar_h6;  lat_h7  <= bar_h7;
            lat_h8  <= bar_h8;  lat_h9  <= bar_h9;  lat_h10 <= bar_h10; lat_h11 <= bar_h11;
            lat_h12 <= bar_h12; lat_h13 <= bar_h13; lat_h14 <= bar_h14; lat_h15 <= bar_h15;
        end
    end

    // Thay thế ngõ vào tra cứu từ bar_h sang lat_h:
    always @(*) begin
        case (cur_band)
            4'd0:  cur_bar_h = lat_h0;
            4'd1:  cur_bar_h = lat_h1;
            4'd2:  cur_bar_h = lat_h2;
            4'd3:  cur_bar_h = lat_h3;
            4'd4:  cur_bar_h = lat_h4;
            4'd5:  cur_bar_h = lat_h5;
            4'd6:  cur_bar_h = lat_h6;
            4'd7:  cur_bar_h = lat_h7;
            4'd8:  cur_bar_h = lat_h8;
            4'd9:  cur_bar_h = lat_h9;
            4'd10: cur_bar_h = lat_h10;
            4'd11: cur_bar_h = lat_h11;
            4'd12: cur_bar_h = lat_h12;
            4'd13: cur_bar_h = lat_h13;
            4'd14: cur_bar_h = lat_h14;
            default: cur_bar_h = lat_h15;
        endcase
    end

    // 4. Thuật toán render điểm ảnh: Cột sóng bám đáy dưới cùng, vọt lên đỉnh
    reg [7:0] render_byte;
    wire [2:0] col_in_band = col_cnt[2:0]; // 0..7 (mỗi cột rộng 6px + 2px khoảng cách)

    // Tọa độ đáy của từng Page (tính từ mép dưới cùng màn hình lên)
    // Page 7 ở dưới đáy (y_base = 0), Page 0 ở trên đỉnh (y_base = 56)
    wire [6:0] y_base = (3'd7 - cur_page) * 7'd8;

    always @(*) begin
        if (col_in_band >= 3'd6) begin
            // 2 pixel khoảng cách giữa các cột
            // Riêng ở Page 7 (đáy), giữ vạch chân đế ở mép dưới cùng (Bit 7)
            render_byte = (cur_page == 3'd7) ? 8'b1000_0000 : 8'h00;
        end else begin
            // Bit 7 nằm sát mép dưới cùng, Bit 0 hướng lên phía trên đỉnh màn hình
            // Điểm ảnh sáng khi chiều cao cột (cur_bar_h) vươn tới tọa độ Y đó:
            render_byte[7] = ((y_base + 7'd0) < cur_bar_h) || (cur_page == 3'd7); // Mép đáy dưới cùng (luôn giữ vạch đáy)
            render_byte[6] = ((y_base + 7'd1) < cur_bar_h);
            render_byte[5] = ((y_base + 7'd2) < cur_bar_h);
            render_byte[4] = ((y_base + 7'd3) < cur_bar_h);
            render_byte[3] = ((y_base + 7'd4) < cur_bar_h);
            render_byte[2] = ((y_base + 7'd5) < cur_bar_h);
            render_byte[1] = ((y_base + 7'd6) < cur_bar_h);
            render_byte[0] = ((y_base + 7'd7) < cur_bar_h);                       // Đỉnh của Page đó (hướng lên trên)
        end
    end

    // 5. Máy trạng thái quét liên tục màn hình
    localparam S_PWR_WAIT  = 3'd0,
               S_INIT_SEND = 3'd1,
               S_INIT_WAIT = 3'd2,
               S_PAGE_SET  = 3'd3,
               S_PAGE_WAIT = 3'd4,
               S_DATA_SEND = 3'd5,
               S_DATA_WAIT = 3'd6;

    reg [2:0]  state;
    reg [21:0] pwr_cnt;
    reg [4:0]  init_idx;
    reg [2:0]  cur_page;
    reg [1:0]  page_step;
    reg [6:0]  col_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_PWR_WAIT;
            pwr_cnt    <= 22'd0;
            init_idx   <= 5'd0;
            cur_page   <= 3'd0;
            page_step  <= 2'd0;
            col_cnt    <= 7'd0;
            oled_ready <= 1'b0;
            i2c_req    <= 1'b0;
            i2c_mode   <= 1'b0;
            i2c_data   <= 8'd0;
        end else begin
            i2c_req <= 1'b0;
            case (state)
                S_PWR_WAIT: begin
                    if (pwr_cnt >= 22'd3_000_000) state <= S_INIT_SEND;
                    else pwr_cnt <= pwr_cnt + 1'b1;
                end

                S_INIT_SEND: begin
                    i2c_req  <= 1'b1;
                    i2c_mode <= 1'b0; // Gửi lệnh
                    i2c_data <= init_rom[init_idx];
                    state    <= S_INIT_WAIT;
                end

                S_INIT_WAIT: begin
                    if (i2c_done) begin
                        if (init_idx == 5'd27) begin
                            cur_page   <= 3'd0;
                            page_step  <= 2'd0;
                            oled_ready <= 1'b1;
                            state      <= S_PAGE_SET;
                        end else begin
                            init_idx <= init_idx + 1'b1;
                            state    <= S_INIT_SEND;
                        end
                    end
                end

                // Gửi 3 lệnh đặt Page và Column (0xBn, 0x00, 0x10)
                S_PAGE_SET: begin
                    i2c_req  <= 1'b1;
                    i2c_mode <= 1'b0; // Lệnh
                    case (page_step)
                        2'd0: i2c_data <= 8'hB0 | cur_page;
                        2'd1: i2c_data <= 8'h00;
                        2'd2: i2c_data <= 8'h10;
                        default: i2c_data <= 8'h00;
                    endcase
                    state <= S_PAGE_WAIT;
                end

                S_PAGE_WAIT: begin
                    if (i2c_done) begin
                        if (page_step == 2'd2) begin
                            col_cnt   <= 7'd0;
                            state     <= S_DATA_SEND;
                        end else begin
                            page_step <= page_step + 1'b1;
                            state     <= S_PAGE_SET;
                        end
                    end
                end

                // Gửi liên tục 128 byte điểm ảnh của Page hiện tại
                S_DATA_SEND: begin
                    i2c_req  <= 1'b1;
                    i2c_mode <= 1'b1; // Dữ liệu RAM
                    i2c_data <= render_byte;
                    state    <= S_DATA_WAIT;
                end

                S_DATA_WAIT: begin
                    if (i2c_done) begin
                        if (col_cnt == 7'd127) begin
                            col_cnt   <= 7'd0;
                            page_step <= 2'd0;
                            cur_page  <= cur_page + 1'b1; // Tự động vòng 0..7
                            state     <= S_PAGE_SET;      // Quét tiếp trang sau
                        end else begin
                            col_cnt <= col_cnt + 1'b1;
                            state   <= S_DATA_SEND;
                        end
                    end
                end
            endcase
        end
    end

endmodule