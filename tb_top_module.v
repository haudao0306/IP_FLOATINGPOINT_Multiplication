`timescale 1ns / 1ps

module tb_top_module();

    // Inputs
    reg clk;
    reg reset;
    reg datain_valid;
    reg [31:0] datain1;
    reg [31:0] datain2;

    // Outputs
    wire [31:0] dataout;
    wire datain_ready;
    wire dataout_valid;
    wire overflow_flag;

    // Instantiate DUT
    top_module uut (
        .clk(clk),
        .reset(reset),
        .datain_valid(datain_valid),
        .datain1(datain1),
        .datain2(datain2),
        .dataout(dataout),
        .datain_ready(datain_ready),
        .dataout_valid(dataout_valid),
        .overflow_flag(overflow_flag)
    );

    // Clock: 50MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Init
        reset = 1;
        datain_valid = 0;
        datain1 = 0;
        datain2 = 0;

        #25 reset = 0;

        // === Test 1: 2.5 * 3.0 = 7.5 ===
        @(posedge clk);
        datain1 = 32'h40200000;  // 2.5
        datain2 = 32'h40400000;  // 3.0
        datain_valid = 1;
        @(posedge clk);
        datain_valid = 0;

        wait (dataout_valid == 1);
        $display("T%0t: Test1 Result = %h (Expected 40F00000), Overflow = %b", 
                  $time, dataout, overflow_flag);

        // === Delay 10 clock cycles ===
        repeat(10) @(posedge clk);

        // === Test 2: Overflow case ===
        // Example: very large * very large = overflow
        datain1 = 32'h7F7FFFFF;  // Largest normal number (~3.4e38)
        datain2 = 32'h7F7FFFFF;
        datain_valid = 1;
        @(posedge clk);
        datain_valid = 0;

        wait (dataout_valid == 1);
        $display("T%0t: Test2 Overflow Result = %h, Overflow = %b", 
                  $time, dataout, overflow_flag);

        // === Delay 10 clock cycles ===
        repeat(10) @(posedge clk);

        // === Test 3: datain_valid gi? trong 2 chu k? ===
        datain1 = 32'h3FC00000;  // 1.5
        datain2 = 32'h40000000;  // 2.0
        datain_valid = 1;
        @(posedge clk);  // gi? thêm 1 chu k? n?a
        @(posedge clk);
        datain_valid = 0;

        wait (dataout_valid == 1);
        $display("T%0t: Test3 (datain_valid 2 cycles) = %h (Expected 40400000), Overflow = %b", 
                  $time, dataout, overflow_flag);

        #50;
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("T%0t | valid=%b | ready=%b | out_valid=%b | dataout=%h | overflow=%b",
                 $time, datain_valid, datain_ready, dataout_valid, dataout, overflow_flag);
    end

    // Waveform dump
    initial begin
        $dumpfile("top_module.vcd");
        $dumpvars(0, tb_top_module);
    end

endmodule





