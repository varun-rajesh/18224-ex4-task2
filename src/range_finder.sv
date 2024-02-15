`default_nettype none

// Range Finder Implementation
module RangeFinder
    #(  parameter   WIDTH=16)
    (   input       logic [WIDTH-1:0]   data_in,
        input       logic               clock, reset,
        input       logic               go, finish,
        output      logic [WIDTH-1:0]   range,
        output      logic               debug_error);

    logic [WIDTH-1:0] min;
    logic [WIDTH-1:0] max;

    typedef enum logic[2:0] {ERROR, RUN, IDLE} states;
    states curr_state, next_state;

    logic [WIDTH-1:0] finish_min;
    logic [WIDTH-1:0] finish_max;

    assign debug_error = (next_state == ERROR);

    always_comb begin
        finish_min = min;
        finish_max = max;
        range = 0;
        if (finish) begin
            if (data_in < finish_min) finish_min = data_in;
            if (data_in > finish_max) finish_max = data_in;

            range = finish_max - finish_min;
        end
    end

    always_ff @ (posedge clock, posedge reset) begin
        if (reset) begin
            min <= '1;
            max <= '0;
            curr_state <= IDLE;
        end else begin
            if (curr_state == RUN | go) begin
                min <= data_in < min ? data_in : min;
                max <= data_in > max ? data_in : max;
            end
            curr_state <= next_state;
        end
    end

    always_comb begin
        case (curr_state)
            IDLE: begin
                if (finish)     next_state = ERROR;
                else if (go)    next_state = RUN;
                else            next_state = IDLE;
            end

            RUN: begin
                if (finish & go)    next_state = ERROR;
                else if (finish)    next_state = IDLE;
                else                next_state = RUN;
            end

            ERROR: begin
                if (go & ~finish) next_state = RUN;
                else    next_state = ERROR;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end


endmodule : RangeFinder
