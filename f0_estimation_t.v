`timescale 1ns / 1ps

module f0_estimation_t(

    );
    
    reg clk;
    reg rst_n;
    reg start;
    reg [11:0] data;
    wire done;
    wire [10:0] Addr;
    wire [35:0] C;
    wire [35:0] D;
    wire [35:0] E;
    wire [35:0] G;
    wire [35:0] A;
    
    wire [2:0] note;
    wire state;
    wire auto_cycle;
    wire [11:0] temp;
    wire [35:0] sum;
    
    f0_estimation f0(
    clk,
    rst_n,
    start,
    data,
    done,
    Addr,
    C,
    D,
    E,
    G,
    A,
    
    note,
    state,
    auto_cycle,
    temp,
    sum
    );
    
    parameter cyc = 10;
    always #cyc clk <= ~clk;
    always @(posedge clk) data <= data + 12'd1;
    
    always @(posedge done) begin
        #(cyc * 10);
        @(negedge clk) start <= 1'b1;
        @(negedge clk) start <= 1'b0;
    end
    
    initial begin
        clk <= 1'b1;
        start <= 1'b1;
        rst_n <= 1'b1;
        data <= 12'd0;
        
        @(negedge clk) rst_n <= 1'b0;
        
        @(negedge clk) rst_n <= 1'b1;
        
        @(negedge clk) start <= 1'b0;
        
        #1000000;
    end
endmodule
