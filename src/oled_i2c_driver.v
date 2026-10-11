module oled_i2c_driver (
    input  wire       clk,        // 50MHz (T9)
    input  wire       rst_n,      // C15
    output reg        oled_scl,   // R3
    inout  wire       oled_sda,   // T3
    output wire [4:0] bar_addr,   // 0..31
    input  wire [5:0] bar_height  // 0..63
);

    // 1. Bộ trễ 100ms chờ nguồn màn hình ổn định sau reset
    reg [22:0] power_delay_cnt;
    reg        power_ready;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            power_delay_cnt <= 23'd0;
            power_ready     <= 1'b0;
        end else if (power_delay_cnt < 23'd5_000_000) begin // 100ms @ 50MHz
            power_delay_cnt <= power_delay_cnt + 1'b1;
            power_ready     <= 1'b0;
        end else begin
            power_ready     <= 1'b1;
        end
    end

    // 2. Chia tần số I2C ~ 100kHz (50MHz / 500)
    reg [8:0] clk_div;
    wire i2c_tick = (clk_div == 9'd499);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) clk_div <= 9'd0;
        else if (!power_ready) clk_div <= 9'd0;
        else if (i2c_tick) clk_div <= 9'd0;
        else clk_div <= clk_div + 1'b1;
    end

    // 3. Điều khiển Open-Drain cho chân SDA (Thả nổi khi phát mức 1)
    reg sda_r;
    assign oled_sda = sda_r ? 1'bz : 1'b0;

    // 4. Bảng mã lệnh khởi tạo SSD1306 (128x64)
    reg [7:0] init_rom [0:24];
    initial begin
        init_rom[0]  = 8'hAE; // Tắt hiển thị
        init_rom[1]  = 8'hD5; init_rom[2]  = 8'h80; // Thiết lập dao động
        init_rom[3]  = 8'hA8; init_rom[4]  = 8'h3F; // Tỉ lệ quét 64
        init_rom[5]  = 8'hD3; init_rom[6]  = 8'h00; // Offset 0
        init_rom[7]  = 8'h40; // Dòng bắt đầu 0
        init_rom[8]  = 8'h8D; init_rom[9]  = 8'h14; // Bật Charge Pump (Bắt buộc để màn sáng)
        init_rom[10] = 8'h20; init_rom[11] = 8'h02; // Page addressing mode
        init_rom[12] = 8'hA1; // Segment re-map
        init_rom[13] = 8'hC8; // COM scan direction
        init_rom[14] = 8'hDA; init_rom[15] = 8'h12; // Cấu hình chân COM
        init_rom[16] = 8'h81; init_rom[17] = 8'hCF; // Độ tương phản cực đại
        init_rom[18] = 8'hD9; init_rom[19] = 8'hF1; // Pre-charge
        init_rom[20] = 8'hDB; init_rom[21] = 8'h40; // VCOMH
        init_rom[22] = 8'hA4; // Hiển thị theo nội dung RAM
        init_rom[23] = 8'hA6; // Normal mode (không đảo màu)
        init_rom[24] = 8'hAF; // BẬT MÀN HÌNH (Display ON)
    end

    reg [2:0] page_cnt;
    reg [6:0] col_cnt;
    assign bar_addr = col_cnt[6:2]; // 128 pixel / 4 = 32 cột

    // 5. Thuật toán tạo byte pixel theo chiều cao cột phổ
    reg [7:0] render_byte;
    wire [5:0] page_y_bottom = (3'd7 - page_cnt) * 6'd8;
    always @(*) begin
        if (bar_height >= page_y_bottom + 8) begin
            render_byte = 8'hFF;
        end else if (bar_height <= page_y_bottom) begin
            render_byte = (page_cnt == 3'd7) ? 8'b10000000 : 8'h00; // Vạch đáy mép dưới
        end else begin
            case (bar_height - page_y_bottom)
                3'd1: render_byte = 8'b00000001;
                3'd2: render_byte = 8'b00000011;
                3'd3: render_byte = 8'b00000111;
                3'd4: render_byte = 8'b00001111;
                3'd5: render_byte = 8'b00011111;
                3'd6: render_byte = 8'b00111111;
                3'd7: render_byte = 8'b01111111;
                default: render_byte = (page_cnt == 3'd7) ? 8'b10000000 : 8'h00;
            endcase
        end
    end

    // 6. Máy trạng thái điều khiển I2C hoàn chỉnh
    reg [3:0] state;
    localparam S_IDLE       = 4'd0,
               S_START      = 4'd1,
               S_WRITE_BYTE = 4'd2,
               S_ACK        = 4'd3,
               S_STOP       = 4'd4,
               S_SEND_INIT  = 4'd5,
               S_SET_PAGE   = 4'd6,
               S_SEND_DATA  = 4'd7;

    reg [7:0] tx_data;
    reg [3:0] bit_cnt;
    reg [1:0] phase;
    reg [4:0] init_idx;
    reg [2:0] sub_step;
    reg [3:0] next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            oled_scl   <= 1'b1;
            sda_r      <= 1'b1;
            bit_cnt    <= 4'd0;
            phase      <= 2'd0;
            init_idx   <= 5'd0;
            page_cnt   <= 3'd0;
            col_cnt    <= 7'd0;
            sub_step   <= 3'd0;
            next_state <= S_IDLE;
        end else if (power_ready && i2c_tick) begin
            case (state)
                S_IDLE: begin
                    oled_scl <= 1'b1;
                    sda_r    <= 1'b1;
                    phase    <= 2'd0;
                    if (init_idx < 5'd25) begin
                        state <= S_SEND_INIT;
                    end else begin
                        state <= S_SET_PAGE;
                    end
                end

                // Điều kiện START
                S_START: begin
                    case (phase)
                        2'd0: begin oled_scl <= 1'b1; sda_r <= 1'b1; end
                        2'd1: begin sda_r    <= 1'b0; end // SDA kéo xuống trước
                        2'd2: begin oled_scl <= 1'b0; end // SCL kéo xuống sau
                        2'd3: begin
                            bit_cnt <= 4'd7;
                            phase   <= 2'd0;
                            state   <= S_WRITE_BYTE;
                        end
                    endcase
                    if (state == S_START) phase <= phase + 1'b1;
                end

                // Gửi 8 bit
                S_WRITE_BYTE: begin
                    case (phase)
                        2'd0: begin
                            oled_scl <= 1'b0;
                            sda_r    <= tx_data[bit_cnt];
                        end
                        2'd1: begin oled_scl <= 1'b1; end
                        2'd2: begin oled_scl <= 1'b1; end
                        2'd3: begin
                            oled_scl <= 1'b0;
                            if (bit_cnt > 4'd0) begin
                                bit_cnt <= bit_cnt - 1'b1;
                            end else begin
                                sda_r <= 1'b1; // Thả nổi chân cho Slave kéo ACK
                                phase <= 2'd0;
                                state <= S_ACK;
                            end
                        end
                    endcase
                    if (state == S_WRITE_BYTE) phase <= phase + 1'b1;
                end

                // Chu kỳ xung nhịp thứ 9 (ACK)
                S_ACK: begin
                    case (phase)
                        2'd0: begin oled_scl <= 1'b0; end
                        2'd1: begin oled_scl <= 1'b1; end
                        2'd2: begin oled_scl <= 1'b1; end
                        2'd3: begin
                            oled_scl <= 1'b0;
                            phase    <= 2'd0;
                            state    <= next_state;
                        end
                    endcase
                    phase <= phase + 1'b1;
                end

                // Điều kiện STOP
                S_STOP: begin
                    case (phase)
                        2'd0: begin oled_scl <= 1'b0; sda_r <= 1'b0; end
                        2'd1: begin oled_scl <= 1'b1; end
                        2'd2: begin sda_r    <= 1'b1; end // SDA lên sau khi SCL đã lên cao
                        2'd3: begin
                            phase <= 2'd0;
                            state <= next_state;
                        end
                    endcase
                    phase <= phase + 1'b1;
                end

                // Gửi tuần tự 25 lệnh cấu hình
                S_SEND_INIT: begin
                    case (sub_step)
                        3'd0: begin
                            tx_data    <= 8'h78; // Địa chỉ I2C SSD1306
                            next_state <= S_SEND_INIT;
                            sub_step   <= 3'd1;
                            state      <= S_START;
                        end
                        3'd1: begin
                            tx_data    <= 8'h00; // Byte điều khiển: Lệnh tiếp theo
                            next_state <= S_SEND_INIT;
                            sub_step   <= 3'd2;
                            state      <= S_WRITE_BYTE;
                        end
                        3'd2: begin
                            tx_data    <= init_rom[init_idx];
                            init_idx   <= init_idx + 1'b1;
                            next_state <= S_IDLE; // Kết thúc chu kỳ lệnh bằng STOP
                            sub_step   <= 3'd0;
                            state      <= S_STOP;
                        end
                    endcase
                end

                // Thiết lập Page và địa chỉ cột
                S_SET_PAGE: begin
                    case (sub_step)
                        3'd0: begin
                            tx_data    <= 8'h78;
                            next_state <= S_SET_PAGE;
                            sub_step   <= 3'd1;
                            state      <= S_START;
                        end
                        3'd1: begin
                            tx_data    <= 8'h00; // Byte điều khiển: Lệnh
                            next_state <= S_SET_PAGE;
                            sub_step   <= 3'd2;
                            state      <= S_WRITE_BYTE;
                        end
                        3'd2: begin
                            tx_data    <= 8'hB0 | page_cnt; // Chọn Page
                            next_state <= S_SET_PAGE;
                            sub_step   <= 3'd3;
                            state      <= S_WRITE_BYTE;
                        end
                        3'd3: begin
                            tx_data    <= 8'h00; // Địa chỉ cột thấp = 0
                            next_state <= S_SET_PAGE;
                            sub_step   <= 3'd4;
                            state      <= S_WRITE_BYTE;
                        end
                        3'd4: begin
                            tx_data    <= 8'h10; // Địa chỉ cột cao = 0
                            next_state <= S_SEND_DATA;
                            sub_step   <= 3'd0;
                            col_cnt    <= 7'd0;
                            state      <= S_STOP;
                        end
                    endcase
                end

                // Gửi dữ liệu điểm ảnh (128 cột cho mỗi Page)
                S_SEND_DATA: begin
                    case (sub_step)
                        3'd0: begin
                            tx_data    <= 8'h78;
                            next_state <= S_SEND_DATA;
                            sub_step   <= 3'd1;
                            state      <= S_START;
                        end
                        3'd1: begin
                            tx_data    <= 8'h40; // Byte điều khiển: Dữ liệu RAM hiển thị
                            next_state <= S_SEND_DATA;
                            sub_step   <= 3'd2;
                            state      <= S_WRITE_BYTE;
                        end
                        3'd2: begin
                            tx_data <= render_byte;
                            col_cnt <= col_cnt + 1'b1;
                            if (col_cnt == 7'd127) begin
                                page_cnt   <= page_cnt + 1'b1;
                                sub_step   <= 3'd0;
                                next_state <= S_SET_PAGE;
                                state      <= S_STOP;
                            end else begin
                                next_state <= S_SEND_DATA;
                                state      <= S_WRITE_BYTE;
                            end
                        end
                    endcase
                end
            endcase
        end
    end

endmodule