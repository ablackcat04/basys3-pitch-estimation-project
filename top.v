module f0_top(
    input clk,
    input rst,
    input vauxp15,
    input vauxn15,
    input vp_in,
    input vn_in,
    output reg [15:0] led
);

    // Use parameter instead of register for constant address
    localparam [6:0] Address_in = 8'h1f; // XA4/AD15
    
    wire enable;  
    wire ready;
    wire [15:0] data;
    
    xadc_wiz_0  XLXI_7 (
        .dclk_in(clk), 
        .busy_out(),
        .vn_in(vn_in), 
        .vp_in(vp_in), 
        .alarm_out(), 
        .reset_in(1'b0),
        .eoc_out(enable),          // End of conversion output
        .eos_out(),          // End of sequence output
        .channel_out(),
        .do_out(data),
        .drdy_out(ready),    // Use XADC's ready signal
        .daddr_in(Address_in),
        .den_in(enable),
        .di_in(16'h0000),    // Explicit width for input
        .dwe_in(1'b0),        // Write disable
        .vauxp15(vauxp15),
        .vauxn15(vauxn15)
    );
    
    wire rst_n;
    
    button bt1(clk, rst, rst_n);
    
    wire sample_tick;
    
    clock_divider cd(
        clk,
        rst_n,
        32'd4096,
        sample_tick
    );
    
    reg [15:0] r_data;
    
    always @(*) begin     
        if (ready) begin
            if (data[15]) begin
                led[15:8] = ~(data[15:8]);
            end else begin
                led[15:8] = data[15:8];
            end
        end else begin
            led[15:8] = led[15:8];
        end
        
        led[7:5] = 3'd0;
        led[4:0] = note_trigger;
        
        
        if (ready) begin
            r_data <= data;
        end else
            r_data <= r_data;
    end
    
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
    
    wire [11:0] mem_data;
    wire [10:0] Addr_f0;
    wire [35:0] C;
    wire [35:0] D;
    wire [35:0] E;
    wire [35:0] G;
    wire [35:0] A;
    
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
    
    wire [11:0] mem_data0, mem_data1;
    
    blk_mem_gen_00 mem0(
        .addra(Addr_sampler),
        .clka(clk),
        .dina(current_sample),
        .wea(en[0]),
        .addrb(Addr_f0),
        .clkb(clk),
        .doutb(mem_data0),
        .enb(~en[0])
    );
    
    blk_mem_gen_00 mem1(
        .addra(Addr_sampler),
        .clka(clk),
        .dina(current_sample),
        .wea(en[1]),
        .addrb(Addr_f0),
        .clkb(clk),
        .doutb(mem_data1),
        .enb(~en[1])
    );
    
    assign mem_data = (~en[0])? mem_data0 : mem_data1;
    
    reg [4:0] note_trigger;
    wire [4:0] note_interpreted;
    
    f0_interpreter f0i(
        C,
        D,
        E,
        G,
        A,
        36'd100_000_000,
        note_interpreted
    );
    
    always @(posedge clk) begin
        if (f0_done) begin
            note_trigger <= note_interpreted;
        end else begin
            note_trigger <= note_trigger;
        end
    end
    
    
    
endmodule