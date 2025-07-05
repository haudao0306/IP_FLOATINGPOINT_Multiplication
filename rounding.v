module rounding(
    input         clk,
    input         reset,
    input  [47:0] mantissa_in,     // K?t qu? nhân sau d?ch
    input  [8:0]  exponent_in,     // S? m? sau bias + t?ng
    input         sign_in,
    input         mux_en_rounding, // = 1 thì tr? v? 0 (tràn)
    input         enable_rounding,
    input         no_start,
    output reg [31:0] result_out,   // K?t qu? cu?i cùng
    output reg        overflow_flag
);

    wire guard_bit  = mantissa_in[22];
    wire round_bit  = mantissa_in[21];
    wire sticky_bit = |mantissa_in[20:0];

    wire round_up = guard_bit & (round_bit | sticky_bit);
    wire [24:0] mantissa_rounded = mantissa_in[47:23] + round_up;

    wire [7:0] exponent_final = exponent_in[7:0];

    always @(posedge clk or posedge reset) begin
        if (reset || no_start) begin
            overflow_flag <= 1'b0;
        end else if (mux_en_rounding) begin
            overflow_flag <= 1'b1;
        end else begin
            overflow_flag <= 1'b0;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset || no_start) begin
            result_out <= 32'd0;
        end else if (mux_en_rounding) begin
            result_out <= 32'd0;
        end else begin
            if (enable_rounding) begin
                result_out <= {sign_in, exponent_final, mantissa_rounded[22:0]};
            end else begin
                result_out <= 32'd0;
            end
        end 
    end

endmodule





