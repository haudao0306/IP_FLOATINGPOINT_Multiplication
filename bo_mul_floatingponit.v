module bo_mul_floatingpoint (
    input         clk,
    input         reset,
    input         start,
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] result,
    output        overflow_flag
);

    // === Tín hi?u k?t n?i n?i b? ===
    wire MLB_significand_mult;
    wire bit_check_overflow;
    wire mux_en_reg;
    wire enable_reg;
    wire inc_shift_en;
    wire mux_en_rounding;
    wire enable_rounding;
    wire no_start;
    // === K?t n?i module nhân s? th?c ===
    datapath_floatingpoint_mul mul_inst (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .inc_shift_en(inc_shift_en),            // Tín hi?u ?i?u khi?n shift và t?ng exp
        .mux_en_rounding(mux_en_rounding),      // Ch?n gi?a k?t qu? làm tròn ho?c 
        .enable_rounding(enable_rounding),
        .mux_en_reg(mux_en_reg),
        .enable_reg(enable_reg),
        .no_start(no_start),
        .bit_check_overflow(bit_check_overflow),         // Báo tràn exponent
        .MLB_significand_mult(MLB_significand_mult), // Báo c?n shift
        .result(result),
        .overflow_flag(overflow_flag)                         // K?t qu? IEEE 754
    );

    // === K?t n?i b? ?i?u khi?n ===
    control_floatingpoint_mul ctrl_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .MLB_significand_mult(MLB_significand_mult),
        .bit_check_overflow(bit_check_overflow),
        .inc_shift_en(inc_shift_en),
        .mux_en_rounding(mux_en_rounding),
        .mux_en_reg(mux_en_reg), 
        .enable_reg(enable_reg),
        .enable_rounding(enable_rounding),
        .no_start(no_start)
    );

endmodule


