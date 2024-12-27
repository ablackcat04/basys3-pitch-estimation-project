`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/10 01:18:06
// Design Name: 
// Module Name: bipolar_util
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bipolar_util(
    input [35:0] sum,
    input [11:0] temp,
    input [11:0] data,
    output [35:0] next_sum
    );
    
    wire [11:0] abs_data, abs_temp;
    
    assign abs_data = (data[11])? (~data + 12'd1) : data;
    assign abs_temp = (temp[11])? (~temp + 12'd1) : temp;
    
    wire [35:0] abs_mul;
    wire [35:0] mul;
    
    assign abs_mul = abs_data * abs_temp;
    assign mul = (data[11] ^ temp[11])? (~abs_mul - 36'd1) : abs_mul;
    assign next_sum = sum + mul;
    
endmodule
