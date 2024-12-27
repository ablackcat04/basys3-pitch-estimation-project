`timescale 1ns / 1ps

module top_t(

);
    reg clk;
    reg rst;
        
    wire ready;
    wire [15:0] data;
    
    assign ready = 1'b1;
    
//    xadc_wiz_0  XLXI_7 (
//        .dclk_in(clk), 
//        .busy_out(),
//        .vn_in(vn_in), 
//        .vp_in(vp_in), 
//        .alarm_out(), 
//        .reset_in(1'b0),
//        .eoc_out(enable),          // End of conversion output
//        .eos_out(),          // End of sequence output
//        .channel_out(),
//        .do_out(data),
//        .drdy_out(ready),    // Use XADC's ready signal
//        .daddr_in(Address_in),
//        .den_in(enable),
//        .di_in(16'h0000),    // Explicit width for input
//        .dwe_in(1'b0),        // Write disable
//        .vauxp15(vauxp15),
//        .vauxn15(vauxn15)
//    );

    wire [7:0] unipolar_out;
    
    reg [15:0] wave_length;

    triangle_wave_gen tg(
        .clk(clk),
        .rst(rst_n),
        .sample_tick(sample_tick),
        .wave_length(wave_length),
        .amplitude(7'd127),
        .out(unipolar_out)
    );
    
    wire [7:0] bipolar_out;
    assign bipolar_out = unipolar_out - 8'd127;
    
    assign data = {bipolar_out, 4'd0};
    
    reg [15:0] r_data;
    
    always @(*) begin     
//        if (ready) begin
//            if (data[15]) begin
//                led <= ~data;
//            end else begin
//                led <= data;
//            end
//        end else
//            led <= led;
            
        if (ready) begin
            r_data <= data;
        end else
            r_data <= r_data;
    end
    
    wire rst_n;
    
    button bt1(clk, rst, rst_n);
    
    wire sample_tick;
    
    clock_divider cd(
        clk,
        rst_n,
        32'd16,
        sample_tick
    );
    
    reg [11:0] current_data;
    
    always @(posedge clk) begin
        current_data <= r_data;
    end
    
    wire f0_done;
    wire start_round;
    wire [10:0] Addr_sampler;
    wire [11:0] current_sample;
    wire now_writing;
    wire [1:0]en;
    
    Sampler_and_Buffer_Writer sbw(
        clk,
        rst_n,
        f0_done,
        current_data,
        sample_tick,
        start_round,
        Addr_sampler,
        current_sample,
        now_writing,
        en
    );
    
    wire [11:0] mem_data;
    wire [10:0] Addr_f0;
    wire [35:0] C;
    wire [35:0] D;
    wire [35:0] E;
    wire [35:0] G;
    wire [35:0] A;
    
    f0_estimation f0(
        clk,
        rst_n,
        start_round,
        mem_data,
        f0_done,
        Addr_f0,
        C,
        D,
        E,
        G,
        A
    );
    

    
//    blk_mem_gen_0 mem0(
//        .addra(Addr_sampler),
//        .clka(clk),
//        .dina(current_sample),
//        .wea(en[0]),
//        .addrb(Addr_f0),
//        .clkb(clk),
//        .doutb(mem_data0),
//        .enb(~en[0])
//    );
    
//    blk_mem_gen_0 mem1(
//        .addra(Addr_sampler),
//        .clka(clk),
//        .dina(current_sample),
//        .wea(en[1]),
//        .addrb(Addr_f0),
//        .clkb(clk),
//        .doutb(mem_data1),
//        .enb(~en[1])
//    );
    reg [11:0] mem_data0, mem_data1;
    reg [11:0]mem0[2047:0];
    reg [11:0]mem1[2047:0];
    
    always @(posedge clk) begin
        if (en[0]) begin
            mem0[Addr_sampler] <= current_sample;
        end else begin
            mem_data0 <= mem0[Addr_f0];
        end
        
        if (en[1]) begin
            mem1[Addr_sampler] <= current_sample;
        end else begin
            mem_data1 <= mem1[Addr_f0];
        end
    end
    
    assign mem_data = (~en[0])? mem_data0 : mem_data1;
    
    reg [4:0] note_trigger;
    wire [4:0] note_interpreted;
    
    f0_interpreter f0i(
        C,
        D,
        E,
        G,
        A,
        36'd250000000,
        note_interpreted
    );
    
    always @(posedge clk) begin
        if (f0_done) begin
            note_trigger <= note_interpreted;
        end else begin
            note_trigger <= note_trigger;
        end
    end
    
    
    
    parameter cyc = 10;
    always #(cyc / 2) clk <= ~clk;
    
    initial begin
        clk <= 1'b1;
        wave_length <= 16'd187;
        rst <= 1'b1;
        
        @(negedge clk) rst <= 1'b0;
        @(negedge clk) rst <= 1'b1;
        
        @(posedge start_round) wave_length <= 16'd166;
        @(posedge start_round) wave_length <= 16'd148;
        @(posedge start_round) wave_length <= 16'd125;
        @(posedge start_round) wave_length <= 16'd111;
        
        @(posedge start_round) wave_length <= 16'd100;
        
        @(posedge start_round) wave_length <= 16'd1000;
        @(posedge start_round) wave_length <= 16'd10;
        @(posedge start_round) wave_length <= 16'd10000;
        @(posedge start_round) wave_length <= 16'd155;
        @(posedge start_round) wave_length <= 16'd134;
    end
    
endmodule