`timescale 1ns / 1ps

module tb_control_floatingpoint_mul;

    reg clk;
    reg reset;
    reg MLB_significand_mult;
    reg MLB_exponent_inc;
    wire enable_rounding;
    wire inc_shift_en;
    wire mux_en_rounding;
    wire mux_en_reg;
    wire enable_reg;

    // Instantiate DUT
    control_floatingpoint_mul dut (
        .clk(clk),
        .reset(reset),
        .MLB_significand_mult(MLB_significand_mult),
        .MLB_exponent_inc(MLB_exponent_inc),
        .inc_shift_en(inc_shift_en),
        .mux_en_rounding(mux_en_rounding),
        .mux_en_reg(mux_en_reg),
        .enable_reg(enable_reg),
        .enable_rounding(enable_rounding)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        // Kh?i t?o tín hi?u
        clk = 0;
        reset = 1;
        MLB_significand_mult = 0;
        MLB_exponent_inc     = 0;

        // === Chu k? 1: reset b?t ===
        @(posedge clk);  // Cycle 1
        reset <= 0;

        // === Chu k? 2: tr?ng thái CHECK_SHIFT_INCREMENT ===
        @(posedge clk);  // Cycle 2
        MLB_significand_mult <= 1;

        // === Chu k? 3: ROUND ===
        @(posedge clk);  // Cycle 3
        MLB_significand_mult <= 0;
        MLB_exponent_inc <= 1;

        // === Chu k? 4: quay l?i IDLE ===
        @(posedge clk);  // Cycle 4
        MLB_exponent_inc <= 0;

        // === Chu k? 5: ti?p t?c vòng FSM n?u mu?n test thêm ===
        @(posedge clk);

        $finish;
    end

    // Theo dõi k?t qu?
    initial begin
        $display("Time\tState\tinc_shift_en\tmux_en_reg\tmux_en_rounding\tenable_reg");
        $monitor("%0t\t%b\t%b\t\t%b\t\t%b\t\t%b",
            $time,
            dut.current_state,
            inc_shift_en,
            mux_en_reg,
            mux_en_rounding,
            enable_reg);
    end

endmodule

