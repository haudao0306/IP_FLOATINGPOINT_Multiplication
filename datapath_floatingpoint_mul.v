module datapath_floatingpoint_mul (
    input         clk,
    input         reset,
    input  [31:0] A,
    input  [31:0] B,
    input         mux_en_reg,
    input         inc_shift_en,           // t? control_unit
    input         mux_en_rounding,        // t? control_unit
    input         enable_reg,
    input         enable_rounding,
    input         no_start,
    output        MLB_exp_inc,
    output        MLB_significand_mult,
    output [31:0] result,
    output        overflow_flag
);  
    wire [31:0] reg_A_in;
    reg [31:0] reg_A_out;
    wire [63:0] reg_B_in;
    reg [63:0] reg_B_out;
    
    //chon ngo vao cho reg_A
    assign reg_A_in = mux_en_reg ? exp_sum : A;
   // G?i register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_A_out <= 32'd0;
        end else begin
            if (enable_reg) begin
                reg_A_out <= reg_A_in;
            end
        end
    end
    
    //chon ngo vao cho reg_B
    assign reg_B_in = mux_en_reg ? significand_mult : B;
   // G?i register
   always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_B_out <= 64'd0;
        end else begin
            if (enable_reg) begin
                reg_B_out <= reg_B_in;
            end
        end
    end
    
    // === Tách thành ph?n IEEE 754 ===
    wire sign_A        = reg_A_out[31];
    wire sign_B        = reg_B_out[31];
    wire [7:0] exp_A   = reg_A_out[30:23];
    wire [7:0] exp_B   = reg_B_out[30:23];
    wire [22:0] frac_A = reg_A_out[22:0];
    wire [22:0] frac_B = reg_B_out[22:0];

    // === D?u k?t qu? ===
    wire sign_out = sign_A ^ sign_B;

    // === T?ng s? m? ?ã bias
    wire [8:0] exp_sum = exp_A + exp_B - 8'd127;
    
    //xu ly bo nhan
    // === Thêm bit 1 ?n vào mantissa
    wire [23:0] significand_A = {1'b1, frac_A};
    wire [23:0] significand_B = {1'b1, frac_B};
    // === Nhân mantissa
    wire [47:0] significand_mult;
    assign significand_mult = significand_A * significand_B;
    
    // === bo tang mu 1 don vi
    wire [8:0] exp_inc;
    assign exp_inc = inc_shift_en ? (reg_A_out[8:0] + 1'b1) : reg_A_out[8:0];
    
    // === bo dich phai
    wire [47:0] significand_shifted;
    assign significand_shifted = inc_shift_en ? (reg_B_out[47:0] >> 1) : reg_B_out[47:0];
    
    // === Làm tròn
    rounding round_inst (
        .clk(clk),
        .reset(reset),
        .mantissa_in(significand_shifted),
        .exponent_in(exp_inc),
        .sign_in(sign_out),
        .mux_en_rounding(mux_en_rounding), // t? FSM: =1 thì xu?t 0
        .enable_rounding(enable_rounding),
        .no_start(no_start),
        .result_out(result),
        .overflow_flag(overflow_flag)
    );

    // === C?nh báo tràn
    assign MLB_significand_mult = significand_mult[47]; // n?u MSB = 1 thì c?n d?ch
    assign MLB_exp_inc = exp_inc[8];                    // n?u bit cao c?a exponent = 1 ? tràn

endmodule



