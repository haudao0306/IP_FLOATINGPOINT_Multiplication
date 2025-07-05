module control (
    input        clk,
    input        reset,
    input        datain_valid,
    input        fifo_full,
    output reg   fifo_write_en,
    output reg   fifo_read_en,
    output reg   datain_ready,
    output reg   out_valid,
    output reg   start
);

    // Các tr?ng thái FSM (dùng 4-bit ?? ch?a giá tr? ??n 8)
    parameter IDLE              = 4'd0;
    parameter READY_ONE_CYCLE   = 4'd1;
    parameter WRITE_FIFO        = 4'd2;
    parameter READ_FIFO         = 4'd3;
    parameter WAIT_READ_DELAY   = 4'd4;
    parameter WAIT_MUL_RESULT1  = 4'd5;
    parameter WAIT_MUL_RESULT2  = 4'd6;
    parameter WAIT_MUL_RESULT3  = 4'd7;
    parameter OUT_VALID         = 4'd8;

    reg [3:0] state, next_state;

    // C?p nh?t tr?ng thái
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM ?i?u khi?n
    always @(*) begin
        // M?c ??nh
        fifo_write_en  = 0;
        fifo_read_en   = 0;
        datain_ready   = 0;
        out_valid      = 0;
        next_state     = state;
        start          = 0;
        case (state)
            IDLE: begin
                if (datain_valid && !fifo_full)
                    next_state = READY_ONE_CYCLE;
            end

            READY_ONE_CYCLE: begin
                datain_ready = 1;
                next_state = WRITE_FIFO;
            end

            WRITE_FIFO: begin
                fifo_write_en = 1;
                next_state = READ_FIFO;
            end

            READ_FIFO: begin
                fifo_read_en = 1;
                next_state = WAIT_READ_DELAY;
            end

            WAIT_READ_DELAY: begin
                start = 1; 
                next_state = WAIT_MUL_RESULT1;
            end

            WAIT_MUL_RESULT1: begin
                next_state = WAIT_MUL_RESULT2;
            end

            WAIT_MUL_RESULT2: begin
                next_state = WAIT_MUL_RESULT3;
            end
            
            WAIT_MUL_RESULT3: begin
                next_state = OUT_VALID;
            end 
            
            OUT_VALID: begin
                out_valid = 1;
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule



