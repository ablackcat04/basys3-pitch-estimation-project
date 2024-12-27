`timescale 1ns / 1ps

module Sampler_and_Buffer_Writer(
    input clk,
    input rst,
    input f0_done,
    input [11:0] data,
    input sample_tick,
    output start_round,
    output reg [10:0] Addr,
    output reg [11:0] out,
    output reg now_writing,
    output reg [1:0] en
    );
    
    parameter WRITE = 1'd0;
    parameter WAIT = 1'd1;
    
    reg state;
        
    assign start_round = (Addr == 11'd2047 && f0_done && sample_tick);
    
    always @(posedge clk) begin
        if (~rst) begin
            out <= 12'd0;
        end else begin
            if (sample_tick) begin
                out <= data;
            end else begin
                out <= out;
            end
        end
            
        if (~rst || start_round) begin
            Addr <= 11'd0;   
        end else begin
            if (sample_tick && Addr != 11'd2047) begin
                Addr <= Addr + 11'd1;
            end else begin
                Addr <= Addr;
            end
        end
        
        
        if (~rst || start_round) begin
            state <= WRITE;
        end else begin
            if (state == WRITE && Addr == 11'd2047) begin
                state <= WAIT;
            end else begin
                state <= state;
            end
        end
        
        if (~rst) begin
            now_writing <= 1'b0;
        end else begin
            if (start_round) begin
                now_writing <= ~now_writing;
            end else begin
                now_writing <= now_writing;
            end
        end
    end
    
    always @(*) begin
        if (state == WAIT) begin
            en = 2'b00;
        end else begin
            if (now_writing == 1'b1) begin
                en = 2'b10;
            end else begin
                en = 2'b01;
            end
        end
    end
endmodule
