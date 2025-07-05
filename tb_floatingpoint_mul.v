`timescale 1ns / 1ps

module tb_floatingpoint_mul;

    reg         clk;
    reg         reset;
    reg         start;
    reg  [31:0] A, B;
    wire [31:0] result;
    wire        overflow_flag;

    // Instantiate DUT
    bo_mul_floatingpoint dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A(A),
        .B(B),
        .result(result),
        .overflow_flag(overflow_flag)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test values
    reg [31:0] A_vals[0:2];
    reg [31:0] B_vals[0:2];
    reg        start_vals[0:2];

    integer i;

    initial begin
        clk   = 0;
        reset = 1;
        start = 0;
        A     = 32'd0;
        B     = 32'd0;

        // === Kh?i t?o test vector ===
        A_vals[0] = 32'hF0400000;  // -3.0
        B_vals[0] = 32'hF0400000;  // -3.0
        start_vals[0] = 1;

        A_vals[1] = 32'h3FC00000;  // 1.5
        B_vals[1] = 32'h40000000;  // 2.0
        start_vals[1] = 1;

        A_vals[2] = A_vals[1];     // gi?ng c?p 2
        B_vals[2] = B_vals[1];
        start_vals[2] = 0;         // nh?ng không b?t start

        // === Reset ban ??u gi? 2 chu k? ===
        @(posedge clk);
        @(posedge clk);
        reset = 0;

        // === Th?c hi?n t?ng test case ===
        for (i = 0; i < 3; i = i + 1) begin
            // Áp A, B và start t?i th?i ?i?m ngay sau reset
            A = A_vals[i];
            B = B_vals[i];
            start = start_vals[i];

            @(posedge clk);  // chu k? 1 gi? A/B
            start = 0;

            @(posedge clk);  // chu k? 2 gi? A/B
            A = 32'd0;
            B = 32'd0;

            // In k?t qu?
            $display("A = %h, B = %h, clk = %b, reset = %b, start = %b, overflow = %b",
                     A_vals[i], B_vals[i], clk, reset, start_vals[i], overflow_flag);

            // ??i x? lý 3 chu k? + ??m
            repeat (4) @(posedge clk);

            // B?t reset 2 chu k? sau m?i test
            reset = 1;
            @(posedge clk);
            @(posedge clk);
            reset = 0;
        end

        // K?t thúc
        #50;
        $finish;
    end

endmodule













