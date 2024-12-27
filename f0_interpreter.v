`timescale 1ns / 1ps

module f0_interpreter(
    input [35:0] C,
    input [35:0] D,
    input [35:0] E,
    input [35:0] G,
    input [35:0] A,
    input [35:0] threshold,
    output reg [4:0] out
    );

    wire [2:0] positive_notes;
    assign positive_notes = (C[35] ? 3'd0 : 3'd1) + (D[35] ? 3'd0 : 3'd1) + (E[35] ? 3'd0 : 3'd1) + (G[35] ? 3'd0 : 3'd1) + (A[35] ? 3'd0 : 3'd1);
    
    wire C_active, D_active, E_active, G_active, A_active;
    assign C_active = (C >= D || D[35]) && (C >= E || E[35]) && (C > G || G[35]) && (C > A || A[35]) && C >= threshold && ~C[35];
    assign D_active = (D >= E || E[35]) && (D >= G || G[35]) && (D >= A || A[35]) && D >= threshold && ~D[35];
    assign E_active = (E >= G || G[35]) && (E >= A || A[35]) && E >= threshold && ~E[35];
    assign G_active = (G >= A || A[35]) && G >= threshold && ~G[35];
    assign A_active = A >= threshold && ~A[35];
    
    always @(*) begin
        if (positive_notes == 3'd2 || positive_notes == 3'd3) begin
            if (C_active) begin
                out = 5'b10000;
            end else if (D_active) begin
                out = 5'b01000;
            end else if (E_active) begin
                out = 5'b00100;
            end else if (G_active) begin
                out = 5'b00010;
            end else if (A_active) begin
                out = 5'b00001;
            end else begin
                out = 5'b00000;
            end
        end else begin
            out = 5'b00000;
        end
    end
endmodule
