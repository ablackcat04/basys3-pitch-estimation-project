`timescale 1ns / 1ps

module f0_estimation(
    input clk,
    input rst_n,
    input start,
    input [11:0] data,
    output reg done,
    output [10:0] Addr,
    output reg [35:0] C,
    output reg [35:0] D,
    output reg [35:0] E,
    output reg [35:0] G,
    output reg [35:0] A,
    
    output reg [2:0] note,
    output reg state,
    output reg auto_cycle,
    output reg [11:0] temp,
    output reg [35:0] sum
    );
    
    parameter note_C = 3'd0;
    parameter note_D = 3'd1;
    parameter note_E = 3'd2;
    parameter note_G = 3'd3;
    parameter note_A = 3'd4;
//    reg [2:0] note;
    
    parameter CAL = 1'b0;
    parameter DONE_CAL = 1'b1;
//    reg state;
    
    parameter FIRST = 1'b0;
    parameter SECOND = 1'b1;
//    reg auto_cycle;
    
    reg [10:0] pointer;
    
    wire change_note;
    wire change_state_done;
    
    assign change_note = state == CAL && pointer == 11'd1860 && auto_cycle == SECOND;
    assign change_state_done = note == note_A && change_note;
    // assign done = state == DONE_CAL;
    
    reg [7:0] shift;
    
    assign Addr = (auto_cycle == FIRST)? pointer : pointer + shift;
    
    //reg [11:0] temp;
    //reg [35:0] sum;
    
    always @(*) begin
        case (note)
            note_C:  shift = 8'd187;
            note_D:  shift = 8'd166;
            note_E:  shift = 8'd148;
            note_G:  shift = 8'd125;
            note_A:  shift = 8'd111;
            default: shift = 8'd187;
        endcase
        
    end
    
    wire [35:0] next_sum;
    bipolar_util bu(sum, temp, data, next_sum);
    
    always @(posedge clk) begin
        if (~rst_n) begin
            done <= 1'b0;
        end else begin
            done <= state == DONE_CAL;
        end
    
        if (~rst_n) begin
            state <= DONE_CAL;
        end else begin
            if (start) begin
                state <= CAL;
            end else begin
                if (change_state_done) begin
                    state <= DONE_CAL;
                end else begin
                    state <= state;
                end
            end
        end
        
        
        if (~rst_n || start || change_note) begin
            auto_cycle <= FIRST;
        end else begin
            auto_cycle <= ~auto_cycle;
        end
        
        
        if (~rst_n || start) begin
            note <= note_C;
        end else begin
            if (change_note) begin
                note <= note + 3'd1;
            end else begin
                note <= note;
            end
        end
        
        
        if (~rst_n || start || change_note) begin
            pointer <= 11'd0;
        end else begin
            if (auto_cycle == SECOND) begin
                pointer <= pointer + 11'd1;
            end else begin
                pointer <= pointer;
            end
        end
        
        
        if (~rst_n || start || change_note) begin
            temp <= 12'd0;
        end else begin
            if (auto_cycle == FIRST) begin
                temp <= data;
            end else begin
                temp <= temp;
            end
        end
        
        
        if (~rst_n || start || change_note) begin
            sum <= 36'd0;
        end else begin
            if (auto_cycle == SECOND) begin
                sum <= next_sum;
            end else begin
                sum <= sum;
            end
        end
        
        
        if (~rst_n) begin
            C <= 36'd0;
        end else begin
            if (change_note && note == note_C) begin
                C <= sum;
            end else begin
                C <= C;
            end
        end
        
        if (~rst_n) begin
            D <= 36'd0;
        end else begin
            if (change_note && note == note_D) begin
                D <= sum;
            end else begin
                D <= D;
            end
        end
        
        if (~rst_n) begin
            E <= 36'd0;
        end else begin
            if (change_note && note == note_E) begin
                E <= sum;
            end else begin
                E <= E;
            end
        end
        
        if (~rst_n) begin
            G <= 36'd0;
        end else begin
            if (change_note && note == note_G) begin
                G <= sum;
            end else begin
                G <= G;
            end
        end
        
        if (~rst_n) begin
            A <= 36'd0;
        end else begin
            if (change_note && note == note_A) begin
                A <= sum;
            end else begin
                A <= A;
            end
        end
    end
    
endmodule
