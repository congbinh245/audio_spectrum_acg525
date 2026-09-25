module i2s_rx
#(
    parameter DATA_WIDTH= 32     
)
(
    input reset_n,
    input bclk,
    input adclrc,
    input adcdat,   
    input adcfifo_rdclk,
    input adcfifo_read,
    input [7:0] rx_data,
    input rx_done,
    output  led1,
    output  led2,
    output  led3,
    output  led4,
    output disp_data,
    
    output adcfifo_empty,
    output [DATA_WIDTH - 1:0] adcfifo_readdata 
);
 
parameter state_idle        = 2'd0;   //空闲状态
parameter state_left_data   = 2'd1;   //采集左通道数据
parameter state_right_data  = 2'd2;   //采集右通道数据
parameter state_fifo_write  = 2'd3;   //FIFO的写数据状态
parameter div_4 = 4;
parameter div_64 = 64;
parameter div_128 = 128;
parameter div_256 = 256;

reg [31:0] disp_data;
reg [1:0] state;
reg [7:0] bit_cnt;      //位计数
reg [DATA_WIDTH - 1:0] reg_wrfifo_data; //定义中间变量，存放adc处理后的数据
reg [DATA_WIDTH/2 - 1:0] reg_cic_data1; //定义中间变量，存放wrfifo的数据，为cic的输入口
reg [DATA_WIDTH/2 - 1:0] reg_cic_data2; 

reg adcfifo_write;    //FIFO的写使能信号
//检测adclrc的下降沿，标志着采集数据左通道数据，上升沿标志采集右通道数据

reg adclrc_nege;
reg adclrc_pose;

reg adclrc_r0;
reg adclrc_r1;
reg adcdat_r0;
reg adcdat_r1;

reg [2:0] cnt_4;
reg [6:0] cnt_64;
reg [7:0] cnt_128;
reg [8:0] cnt_256;

reg clk_48k;
reg clk_96k;
reg clk_192k;
reg clk_3_072M;

always @(posedge bclk or negedge reset_n)
if (~reset_n) begin
    clk_48k <= 1'b0;
    cnt_256 <= 9'b0;
end
else begin
    if(cnt_256 == div_256/2 - 1) begin
        clk_48k = ~clk_48k;
        cnt_256 <= 9'b0;
    end
    else begin
        cnt_256 <= cnt_256 + 1'b1;
    end
end

always @(posedge bclk or negedge reset_n)
if (~reset_n) begin
    clk_96k <= 1'b0;
    cnt_128 <= 8'b0;
end
else begin
    if(cnt_128 == div_128/2 - 1) begin
        clk_96k = ~clk_96k;
        cnt_128 <= 8'b0;
    end
    else begin
        cnt_128 <= cnt_128 + 1'b1;
    end
end

always @(posedge bclk or negedge reset_n)
if (~reset_n) begin
    clk_192k <= 1'b0;
    cnt_64 <= 7'b0;
end
else begin
    if(cnt_64 == div_64/2 - 1) begin
        clk_192k = ~clk_192k;
        cnt_64 <= 7'b0;
    end
    else begin
        cnt_64 <= cnt_64 + 1'b1;
    end
end

always @(posedge bclk or negedge reset_n)
if (~reset_n) begin
    clk_3_072M <= 1'b0;
    cnt_4 <= 3'b0;
end
else begin
    if(cnt_4 == div_4/2 - 1) begin
        clk_3_072M = ~clk_3_072M;
        cnt_4 <= 3'b0;
    end
    else begin
        cnt_4 <= cnt_4 + 1'b1;
    end
end
    
always @(posedge bclk) begin
    adclrc_r0 <= adclrc;
    adclrc_r1 <= adclrc_r0;
    adcdat_r0 <= adcdat;
	 adcdat_r1 <= adcdat_r0;
end

always@(posedge bclk or negedge reset_n)
if(~reset_n) begin
	adclrc_nege <= 1'd0;
	adclrc_pose <= 1'd0;
end
else begin
	adclrc_nege <= adclrc_r1 & (!adclrc_r0);
	adclrc_pose <= (!adclrc_r1) & adclrc_r0;
end


always@(posedge bclk or negedge reset_n)
if(~reset_n)
begin
    state <= state_idle;
    bit_cnt <= 8'd0;
    reg_wrfifo_data <= 0;
    adcfifo_write <= 0;
    //adcfifo_writedata <= 0;
end
else begin
    case(state)
        state_idle:
        begin
            adcfifo_write <= 1'd0;
            if(adclrc_nege)
            begin
                bit_cnt <= DATA_WIDTH - 1;
                state <= state_left_data;
            end
        end

        state_left_data:
        begin
            if(bit_cnt == (DATA_WIDTH/2 - 1)) //左通道数据采集完成
            begin
                if(adclrc_pose)        //进入左通道采集数据
                begin
                    state <= state_right_data;
                end
            end
            else 
            begin
                bit_cnt <= bit_cnt - 1'd1;
                reg_wrfifo_data[bit_cnt] = adcdat_r1;
            end
        end

        state_right_data:
        begin
            if(bit_cnt == 5'd0)         //32位数据采集完成
            begin
                reg_wrfifo_data[bit_cnt] = adcdat_r1;
                state <= state_fifo_write;
            end
            else begin
                bit_cnt <= bit_cnt - 1'd1;
                reg_wrfifo_data[bit_cnt] = adcdat_r1;
                state <= state_right_data;
            end
        end

        state_fifo_write:
        begin
            adcfifo_write <= 1'd1;
            reg_cic_data1 <= reg_wrfifo_data[31:16]; //向adcfifo中写入数据
            reg_cic_data2 <= reg_wrfifo_data[15:0]; 
            state <= state_idle; //经过一轮数据传输后重新回到空闲模式
        end

        default: state <= state_idle;

    endcase
end

reg [DATA_WIDTH - 1:0] adcfifo_writedata;    //写入FIFO中的数据
wire [DATA_WIDTH/2 - 1:0] adcfifo_writedata1;
wire [DATA_WIDTH/2 - 1:0] adcfifo_writedata2;
/*
wire [DATA_WIDTH/2 - 1:0] reverberator1_in;
wire [DATA_WIDTH/2 - 1:0] reverberator2_in;
wire [DATA_WIDTH/2 - 1:0] reverberator1_out;
wire [DATA_WIDTH/2 - 1:0] reverberator2_out;
*/
wire [DATA_WIDTH/2 - 1:0] cicleft_out;
wire [DATA_WIDTH/2 - 1:0] cicright_out;
wire [16:0] compleft_out;
wire [16:0] compright_out;
wire [15:0] halfleft_out;
wire [15:0] halfright_out;
wire [DATA_WIDTH/2 - 1:0] filterleft_out;
wire [DATA_WIDTH/2 - 1:0] filterright_out;

wire rx_done;
reg [7:0] data_str [4:0];
always@(posedge adcfifo_rdclk)
    if(rx_done)begin
        data_str[4] <=  rx_data;
        data_str[3] <=  data_str[4];
        data_str[2] <=  data_str[3];
        data_str[1] <=  data_str[2];
        data_str[0] <=  data_str[1];        
    end 
reg r_rx_done;
reg [2:0] mode_state;
reg [1:0] rever_state;
reg [1:0] echo_state;
reg [3:0] disp_state;
always@(posedge adcfifo_rdclk)
    r_rx_done <= rx_done;

reg led1;
reg led2;
reg led3;
reg led4;
reg [1:0] rever_MODE;
reg [1:0] echo_MODE;

always @(posedge adcfifo_rdclk) begin
    if(r_rx_done)begin 
        if((data_str[0] == 8'hd1) && (data_str[1] == 8'h01) && (data_str[2] == 8'h00) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            led1 <= ~led1;
            mode_state <= 3'd0;
            disp_state <= 4'd9;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h01) && (data_str[2] == 8'h00) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            led1 <= ~led1;
            mode_state <= 3'd1;
            disp_state <= 4'd1;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h01) && (data_str[2] == 8'h00) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            led1 <= ~led1;
            mode_state <= 3'd2;
            disp_state <= 4'd2;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[4] == 8'hd2))begin
            led2 <= ~led2;
            mode_state <= 3'd3;
            disp_state <= 4'd3;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h03) && (data_str[2] == 8'h00) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            led3 <= ~led3;
            mode_state <= 3'd4;
            rever_state <= 2'd1;
            disp_state <= 4'd4;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h03) && (data_str[2] == 8'h00) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            led3 <= ~led3;
            mode_state <= 3'd4;
            rever_state <= 2'd2;
            disp_state <= 4'd5;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h04) && (data_str[2] == 8'h00) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            led4 <= ~led4;
            mode_state <= 3'd5;
            echo_state <= 2'd1;
            disp_state <= 4'd6;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h04) && (data_str[2] == 8'h00) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            led4 <= ~led4;
            mode_state <= 3'd5;
            echo_state <= 2'd2;
            disp_state <= 4'd7;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h05) && (data_str[2] == 8'h00) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            led1 <= 1'b1;
            led2 <= 1'b0;
            led3 <= 1'b1;
            led4 <= 1'b0;
            mode_state <= 3'd6;
            disp_state <= 4'd8;
        end

    end
end

voice cic1(
    .clk_48k(clk_48k),
    .clk_96k(clk_96k),
    .clk_192k(clk_192k),
    .clk_3_072M(clk_3_072M),
    .rst_n(reset_n),
    .din_half(reg_cic_data1),
    .dout_cic(cicleft_out),
    .dout_comp(compleft_out),
    .dout_half(halfleft_out)
);
voice cic2(
    .clk_48k(clk_48k),
    .clk_96k(clk_96k),
    .clk_192k(clk_192k),
    .clk_3_072M(clk_3_072M),
    .rst_n(reset_n),
    .din_half(reg_cic_data2),
    .dout_cic(cicright_out),
    .dout_comp(compright_out),
    .dout_half(halfright_out)
);
/*
reverberator U1(
    .clk(bclk),
    .rst_n(reset_n),
    .din(reverberator1_in),
    .dout(reverberator1_out)
);

reverberator U2(
    .clk(bclk),
    .rst_n(reset_n),
    .din(reverberator2_in),
    .dout(reverberator2_out)
);

assign adcfifo_writedata = {reverberator1_out,reverberator2_out};
*/

eq_filter left(
    .clk(adcfifo_rdclk),
    .bclk(clk_192k),
    .reset(reset_n),
    .filter_in(cicleft_out),
    .filter_out(filterleft_out),
    .rx_data(rx_data),
    .rx_done(rx_done)
    //.led1(led1),
    //.led2(led2),
    //.led3(led3),
    //.led4(led4)
);

eq_filter right(
    .clk(adcfifo_rdclk),
    .bclk(clk_192k),
    .reset(reset_n),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .filter_in(cicright_out),
    .filter_out(filterright_out)
);

wire [15:0] reverberator_out1;
wire [15:0] echosounders_out1;
wire [15:0] distortion_out;
 
reverberator U(
    .clk(clk_48k),
    .rst_n(reset_n),
    .rever_MODE(rever_MODE),
    .reverberator_En(1'b1),
    .din(cicleft_out),
    .dout(reverberator_out1)
    );

echosounders(
    .clk(clk_48k),
    .rst_n(reset_n),
    .adapt_MODE(echo_MODE),
    .echosounders_En(1'b1),
    .din(cicleft_out),
    .dout(echosounders_out1)
    );

broken_line broken_line(
    .din(cicleft_out),
    .dout(distortion_out)
);

always @(*) begin
    case(rever_state)
        2'd1:rever_MODE <= 2'd1;
        2'd2:rever_MODE <= 2'd2;
        default:rever_MODE <= 2'd1;
    endcase
end

always @(*) begin
    case(echo_state)
        2'd1:echo_MODE <= 2'd1;
        2'd2:echo_MODE <= 2'd2;
        default:echo_MODE <= 2'd1;
    endcase
end

always @(*) begin   
    case(disp_state)
        4'd0:disp_data <= 32'hffffffff;
        4'd1:disp_data <= 32'hffffffbe; //comp
        4'd2:disp_data <= 32'hfffffb1b; //cic
        4'd3:disp_data <= 32'hffff4567; //equalizer
        4'd4:disp_data <= 32'hffff8901; //reverberator_mode1
        4'd5:disp_data <= 32'hffff8902; //reverberator_mode2
        4'd6:disp_data <= 32'hffff4a01; //echosounders_mode1
        4'd7:disp_data <= 32'hffff4a02; //echosounders_mode2
        4'd8:disp_data <= 32'hfffffd1a; //distortion
        4'd9:disp_data <= 32'hffffffc9; //halfband
        default: disp_data <= 32'hffffffff; //默认不亮灯
    endcase
end

always @(*) begin   
    case(mode_state)
        3'd0:adcfifo_writedata <= {halfleft_out,halfright_out};
        3'd1:adcfifo_writedata <= {compleft_out,compright_out};
        3'd2:adcfifo_writedata <= {cicleft_out,cicright_out};
        3'd3:adcfifo_writedata <= {filterright_out,filterright_out};
        3'd4:adcfifo_writedata <= {reverberator_out1,reverberator_out1};
        3'd5:adcfifo_writedata <= {echosounders_out1,echosounders_out1};
        3'd6:adcfifo_writedata <= {distortion_out,distortion_out};
        default:adcfifo_writedata <= {cicleft_out,cicright_out};
    endcase
end

//assign adcfifo_writedata = {reverberator_out1,reverberator_out1};
//assign adcfifo_writedata = {filterleft_out,filterright_out};

async_fifo #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(8),
	.FULL_AHEAD(1),
	.SHOWAHEAD_EN(0)
)adc_fifo
(
	.reset(~reset_n),
	//fifo wr
	.wrclk(bclk),
	.wren(adcfifo_write),
	.wrdata(adcfifo_writedata),
	.full(adcfifo_full),
	.almost_full(),
	.wrusedw(),
	//fifo rd
	.rdclk(adcfifo_rdclk),
	.rden(adcfifo_read),
	.rddata(adcfifo_readdata),
	.empty(adcfifo_empty),
	.rdusedw()
);
/*
reg [7:0] data_str [4:0];
    always@(posedge adcfifo_rdclk)
/*
    if(rx_done)begin
        data_str[7] <= #1 rx_data;
        data_str[6] <= #1 data_str[7];
        data_str[5] <= #1 data_str[6];
        data_str[4] <= #1 data_str[5];
        data_str[3] <= #1 data_str[4];
        data_str[2] <= #1 data_str[3];
        data_str[1] <= #1 data_str[2];
        data_str[0] <= #1 data_str[1];        
    end
*/
/*  
        if(rx_done)begin
            data_str[4] <=  rx_data;
            data_str[3] <=  data_str[4];
            data_str[2] <=  data_str[3];
            data_str[1] <=  data_str[2];
            data_str[0] <=  data_str[1];        
        end 
    reg r_rx_done;
    always@(posedge adcfifo_rdclk)
        r_rx_done <= rx_done;
*/
  /* 
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n) begin
        ctrl <= #1 0;
        time_set <= #1 0;
    
    else if(r_rx_done)begin
        if((data_str[0] == 8'h55) && (data_str[1] == 8'hA5) && (data_str[7] == 8'hF0))begin
            time_set[31:24] <= #1 data_str[2];
            time_set[23:16] <= #1 data_str[3];
            time_set[15:8] <= #1 data_str[4];
            time_set[7:0] <= #1 data_str[5];
            ctrl <= #1 data_str[6];
        end
    end  
*/
//assign led = r_rx_done;
/*
always@(posedge adcfifo_rdclk)
    if(r_rx_done)begin 
        if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h01) && (data_str[3] == 8'h01) && (data_str[4] == 8'hd2))begin
            led1 <= ~led1;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h01) && (data_str[3] == 8'h02) && (data_str[4] == 8'hd2))begin
            led2 <= ~led2;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h01) && (data_str[3] == 8'h03) && (data_str[4] == 8'hd2))begin
            led3 <= ~led3;
        end
        else if((data_str[0] == 8'hd1) && (data_str[1] == 8'h02) && (data_str[2] == 8'h01) && (data_str[3] == 8'h04) && (data_str[4] == 8'hd2))begin
            led4 <= ~led4;
        end
    end
*/
endmodule