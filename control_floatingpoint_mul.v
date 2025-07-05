module control_floatingpoint_mul (
    input         clk,
    input         reset,
    input         MLB_significand_mult,
    input         MLB_exponent_inc,
    input         start,
    output reg    inc_shift_en,
    output reg    mux_en_rounding,
    output reg    mux_en_reg,
    output reg    enable_reg,
    output reg    enable_rounding,
    output reg    no_start
);

    // === Tr?ng thái FSM
    parameter RESET                 = 2'b00;
    parameter IDLE                  = 2'b01;
    parameter CHECK_SHIFT_INCREMENT = 2'b10;
    parameter ROUND                 = 2'b11;

    reg [1:0] current_state, next_state;

    // === C?p nh?t tr?ng thái
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= RESET;
        else
            current_state <= next_state;
    end

    // === Chuy?n tr?ng thái
    always @(*) begin
        case (current_state)
            IDLE:                   next_state = CHECK_SHIFT_INCREMENT;
            CHECK_SHIFT_INCREMENT: next_state = ROUND;
            ROUND:                 next_state = RESET;
            default:               next_state = RESET;
        endcase
    end

    // === ?i?u khi?n tín hi?u ??u ra
    always @(*) begin
        // M?c ??nh
        inc_shift_en     = 0;
        mux_en_rounding  = 0;
        mux_en_reg       = 0;
        enable_rounding = 0;
        enable_reg      = 0;
        no_start = 0;
        case (current_state)
            RESET: begin 
                if (start) begin                  
                    next_state = IDLE;
                end else begin
                    no_start = 1;
                    next_state = current_state;
                end 
            end 
                    
            IDLE: begin
                enable_reg = 1;
            end 
            
            CHECK_SHIFT_INCREMENT: begin
                enable_reg = 1;
                mux_en_reg   = 1;
                inc_shift_en = MLB_significand_mult;
            end

            ROUND: begin
                mux_en_reg = 0;
                mux_en_rounding = MLB_exponent_inc;
                enable_rounding = 1;
            end
        endcase
    end

endmodule


