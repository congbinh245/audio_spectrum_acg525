module audio_lookback(
		input clk,                    
		input reset_n, 
		inout iic_0_scl,              
		inout iic_0_sda,  
		
		input I2S_ADCDAT,
		input I2S_ADCLRC,
		input I2S_BCLK,
        input uart_rx,
		output I2S_DACDAT,
		input I2S_DACLRC,
		output I2S_MCLK,
        output wire led1,
        output wire led2,
        output wire led3,
        output wire led4,
        output sh_cp,
        output st_cp,
        output ds
);
	
	parameter DATA_WIDTH        = 32;     
	
    Gowin_PLL Gowin_PLL(
        .clkout0(I2S_MCLK), //output clkout0
        .clkin(clk) //input clkin
    );
	
 	wire Init_Done;
	WM8960_Init WM8960_Init(
		.Clk(clk),
		.Rst_n(reset_n),
		.I2C_Init_Done(Init_Done),
		.i2c_sclk(iic_0_scl),
		.i2c_sdat(iic_0_sda)
	);
	
	//assign led = Init_Done;
	
	reg adcfifo_read;
	wire [DATA_WIDTH - 1:0] adcfifo_readdata;
	wire adcfifo_empty;

	reg dacfifo_write;
	reg [DATA_WIDTH - 1:0] dacfifo_writedata;
	wire dacfifo_full;
	

	always @ (posedge clk or negedge reset_n)
	begin
		if (~reset_n)
		begin
			adcfifo_read <= 1'b0;
		end
		else if (~adcfifo_empty)
		begin
			adcfifo_read <= 1'b1;  //当adcfifo非空时，adcfifo读信号置1
		end
		else
		begin
			adcfifo_read <= 1'b0;
		end
	end

	always @ (posedge clk or negedge reset_n)
	begin
		if(~reset_n)
			dacfifo_write <= 1'd0;
		else if(~dacfifo_full && (~adcfifo_empty)) begin
			dacfifo_write <= 1'd1; //当且仅当dacfifo数据未满，adcfifo数据非空时，dacfifo写标志置1
			dacfifo_writedata <= adcfifo_readdata; //！！！ adcfifo读出的数据写给dacfifo
		end
		else begin
			dacfifo_write <= 1'd0;
		end
	end

wire [7:0] rx_data;
wire rx_done;
wire [31:0] disp_data;

uart_byte_rx uart_byte_rx(
    .Clk(clk),
    .Reset_n(reset_n),
    .Baud_Set(3'd4),
    .uart_rx(uart_rx),
    .Data(rx_data),
    .Rx_Done(rx_done)  
); 

/*
uart_cmd uart_cmd(
    .Clk(clk),
    .Reset_n(reset_n),
    .rx_data(rx_data),
    .rx_done(rx_done),
    //.eqgain_set(eqgain_set),
    //.eqchannel_set(eqchannel_set)
    .led1(led1),
    .led2(led2),
    .led3(led3),
    .led4(led4)
);
*/		

	wire [7:0] sel;//数码管位选（选择当前要显示的数码管）
	wire [6:0] seg;//数码管段选（当前要显示的内容)
    wire [31:0] disp_data;
	i2s_rx 
	#(
		.DATA_WIDTH(DATA_WIDTH) 
	)i2s_rx
	(
		.reset_n(reset_n),
		.bclk(I2S_BCLK),
		.adclrc(I2S_ADCLRC),
		.adcdat(I2S_ADCDAT),
		.adcfifo_rdclk(clk),
		.adcfifo_read(adcfifo_read),
		.adcfifo_empty(adcfifo_empty),
		.adcfifo_readdata(adcfifo_readdata),
        .disp_data(disp_data),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .led1(led1),
        .led2(led2),
        .led3(led3),
        .led4(led4)        
	);
	i2s_tx
	#(
		 .DATA_WIDTH(DATA_WIDTH)
	)i2s_tx
	(
		 .reset_n(reset_n),
		 .dacfifo_wrclk(clk),
		 .dacfifo_wren(dacfifo_write),
		 .dacfifo_wrdata(dacfifo_writedata),
		 .dacfifo_full(dacfifo_full),
		 .bclk(I2S_BCLK),
		 .daclrc(I2S_DACLRC),
		 .dacdat(I2S_DACDAT)
	);


	hc595_driver hc595_driver(
		.clk(clk),
		.reset_n(reset_n),
		.data({1'd1,seg,sel}),
		.s_en(1'b1),
		.sh_cp(sh_cp),
		.st_cp(st_cp),
		.ds(ds)
	);
	
	hex8 hex8(
		.clk(clk),
		.reset_n(reset_n),
		.en(1'b1),
		.disp_data(disp_data),
		.sel(sel),
		.seg(seg)
	);
 
endmodule
