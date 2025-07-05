module top_module (
    input         clk,
    input         reset,    
    input         datain_valid,
    input  [31:0] datain1,
    input  [31:0] datain2,
    output reg [31:0] dataout,
    output        datain_ready,
    output  reg      dataout_valid,
    output  reg      overflow_flag
);  
    wire         start;
    wire         fifo_write_en;
    wire         fifo_read_en;
    wire         fifo_full;
    wire         out_valid;
    wire [31:0]  dout1;
    wire [31:0]  dout2;
    wire [63:0]  dout;
    wire [63:0]  din = {datain1, datain2};
    wire [31:0] result_mul;
    wire overflow_flag_reg;
    // === FIFO Instance ===
    fifo_generator_0 fifo_inst (
        .clk    (clk),
        .srst   (reset),
        .wr_en  (fifo_write_en),
        .rd_en  (fifo_read_en),
        .din    (din),
        .dout   (dout),
        .full   (fifo_full),
        .empty  ()
    );

    // Split FIFO output into 2 operands
    assign dout1 = dout[63:32];
    assign dout2 = dout[31:0];

    // === Floating Point Multiplier ===
    bo_mul_floatingpoint mul_unit (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A(dout1),
        .B(dout2),
        .result(result_mul),
        .overflow_flag(overflow_flag_reg)
    );
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            overflow_flag <= 1'b0;
            dataout <= 32'd0;
            dataout_valid <= 1'b0;
        end else begin
            if (out_valid) begin
                overflow_flag <= overflow_flag_reg;
                dataout <= result_mul;
                dataout_valid <= 1'b1;
            end else begin
                overflow_flag <= 1'b0;
                dataout <= 32'd0;
                dataout_valid <= 1'b0;
            end
        end 
    end

    // === Control Unit ===
    control control_inst (
        .clk(clk),
        .reset(reset),
        .datain_valid(datain_valid),
        .fifo_full(fifo_full),
        .fifo_write_en(fifo_write_en),
        .fifo_read_en(fifo_read_en),
        .datain_ready(datain_ready),
        .out_valid(out_valid),
        .start(start)
    );

endmodule


