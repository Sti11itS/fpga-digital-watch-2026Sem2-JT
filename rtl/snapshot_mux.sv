// Snapshot Multiplexer
// Output `q` takes `d` when `hold` is LOW. When `hold` is HIGH, q takes last
// known `d` during `hold`'s last LOW that crossed the rising edge.
//
// Parameters:
//    WIDTH:  - Bit width of input `d` and output `q`.
//
// Ports:
//    clk:            - Clock input
//    hold:           - Input Signal representing the Mux Switch's `sel`.
//    [WIDTH-1:0] d:  - Input Signal, D-FlipFlop `d` input
//    [WIDTH-1:0] q:  - Output Signal, D-FlipFlop `q` output
//
// Local Variables:
//    [WIDTH-1:0] prev_d: - Intermediary Signal, stores `d` at `hold`'s last
//                          LOW signal

`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  logic [WIDTH-1:0] prev_d = WIDTH'(0);

  always_ff @(posedge clk) begin
    if (!hold) prev_d <= d;
  end

  always_comb begin
    if (!hold) q = d;
    else q = prev_d;
  end

endmodule
