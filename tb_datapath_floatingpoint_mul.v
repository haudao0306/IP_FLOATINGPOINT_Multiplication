`timescale 1ns / 1ps

module tb_datapath_floatingpoint_mul;

    reg clk;
    reg reset;
    reg [31:0] A, B;
    reg mux_en_reg;
    reg inc_shift_en;
    reg mux_en_rounding;
    reg enable_reg;
    reg enable_rounding;
    wire MLB_exp_inc;
    wire MLB_significand_mult;
    wire [31:0] result;
    wire overflow_flag;

    // DUT instantiation
    datapath_floatingpoint_mul dut (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .mux_en_reg(mux_en_reg),
        .inc_shift_en(inc_shift_en),
        .mux_en_rounding(mux_en_rounding),
        .enable_reg(enable_reg),
        .enable_rounding(enable_rounding),
        .MLB_exp_inc(MLB_exp_inc),
        .MLB_significand_mult(MLB_significand_mult),
        .result(result),
        .overflow_flag(overflow_flag)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // === Kh?i t?o
        clk = 0;
        reset = 1;
        A = 0;
        B = 0;
        mux_en_reg = 0;
        inc_shift_en = 0;
        mux_en_rounding = 0;
        enable_reg = 0;
        enable_rounding = 0;

        // === Chu k? 0: reset
        @(posedge clk);
        reset <= 0;

        // === Chu k? 1: N?p giá tr? vào thanh ghi
        @(posedge clk);
        A <= 32'hF0400000;  
        B <= 32'hF0400000;  
        enable_reg <= 1;
        mux_en_reg <= 0;

        // === Chu k? 2: phép nhân mantissa và c?ng exponent
        @(posedge clk);
        A <= 0;
        B <= 0;
        mux_en_reg <= 1;
        enable_reg <= 1;
        inc_shift_en <= 1;

        @(posedge clk);
        enable_reg <= 0;
        mux_en_reg <= 0;
        inc_shift_en <= 0;
        enable_rounding <= 1;
        mux_en_rounding <= 1;
        // === Chu k? 4: d?ng rounding
        @(posedge clk);
        mux_en_rounding <= 0;
        enable_rounding <= 0;
        enable_reg <= 1;
        // === Ch? k?t qu?
        @(posedge clk);
        enable_reg <= 0;
        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset <= 0;
        // === Chu k? 1: Load A, B vào thanh ghi
        @(posedge clk);
        A <= 32'h3FC00000;  // 1.5
        B <= 32'h40000000;  // 2.0
        enable_reg <= 1;
        mux_en_reg <= 0;

        // === Chu k? 2: Load exp_sum và mantissa nhân
        @(posedge clk);
        A <= 0;
        B <= 0;
        mux_en_reg <= 1;
        enable_reg <= 1;

        @(posedge clk);
        enable_reg <= 0;         // ? disable ?úng chu k? k?t qu? ra
        mux_en_reg <= 0;
        enable_rounding <= 1;
        // === Chu k? 4: k?t thúc làm tròn, tr? v? IDLE
        @(posedge clk);
        mux_en_rounding <= 0;
        enable_rounding <= 0;
        enable_reg <= 1;
        // === Chu k? 5+
        repeat (3) @(posedge clk);
        $finish;
    end

    // Theo dõi k?t qu?
    initial begin
        $display("Time\t\tA\t\t\tB\t\t\tResult\t\t\tOverflow");
        $monitor("%0t\t%h\t%h\t%h\t%b", $time, A, B, result, overflow_flag);
    end

endmodule






