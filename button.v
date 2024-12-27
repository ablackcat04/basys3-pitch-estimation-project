`timescale 1ns / 1ps

module button(clk, in, out);
    input clk, in;
    output out;
    
    wire w, w2;
    
    debounce d(w, in, clk);
    
    one_pulse o(clk, w, w2);
    
    assign out = ~w2;
endmodule

module debounce (pb_debounced, pb, clk);
    output pb_debounced; 
    input pb;
    input clk;
    reg [4:0] DFF;
    
    always @(posedge clk) begin
        DFF[4:1] <= DFF[3:0];
        DFF[0] <= pb; 
    end
    assign pb_debounced = (&(DFF)); 
endmodule

module one_pulse(clk, in, PB_one_pulse);
    input clk, in;
    output reg PB_one_pulse;
    
    reg PB_debounced_delay;
    
    always @(posedge clk) begin
        PB_one_pulse <= in & (! PB_debounced_delay);
        PB_debounced_delay <= in;
    end
endmodule