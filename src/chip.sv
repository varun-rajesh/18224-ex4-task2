`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);
    
    logic[9:0]  data_in;
    logic       go;
    logic       finish;

    logic[9:0]  range;
    logic       debug_error;

    assign data_in  = io_in[9:0];
    assign go       = io_in[10];
    assign finish   = io_in[11];

    assign io_out[9:0]  = range;
    assign io_out[10]   = debug_error;
    assign io_out[11]   = 1'b0; 

    RangeFinder # (10) inst (
        .data_in,
        .clock,
        .reset,
        .go,
        .finish,
        .range,
        .debug_error
    );

endmodule
