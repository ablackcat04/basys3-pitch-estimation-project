`timescale 1ns / 1ps

module sampler_t();
    
    reg clk;
    reg rst_n;
    reg f0_done;
    reg [11:0] data;
    wire sample_tick;
    wire start_round;
    wire [10:0] Addr;
    wire [11:0] out;
    wire now_writing;
    wire [1:0] en;
    
    Sampler_and_Buffer_Writer sbw(
        clk,
        rst_n,
        f0_done,
        data,
        sample_tick,
        start_round,
        Addr,
        out,
        now_writing,
        en
    );
        
    clock_divider cd(
        .clk(clk),
        .rst_n(rst_n),
        .num(32'd16),
        .clk_div(sample_tick)
    );
    
    parameter cyc = 10;
    always #cyc clk <= ~clk;
    always @(posedge clk) data <= data + 12'd1;
    
    initial begin
        clk <= 1'b1;
        f0_done <= 1'b1;
        rst_n <= 1'b1;
        data <= 12'd0;
        
        @(negedge clk) rst_n <= 1'b0;
        @(negedge clk) rst_n <= 1'b1;
        
        #1000000;
    end
    
endmodule
