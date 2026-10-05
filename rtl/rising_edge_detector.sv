// Rising Edge Detector
// The output signal `rise` is asserted immediately when input signal `sig_in`
// transitions from low to high, and deasserted when `sig_in` becomes low OR
// when the next rising edge of the clock captures the `sig_in` high signal,
// whichever comes first.
//
// Parameters:
//   None
//
// Ports:
//   clk:       - Clock Input
//   sig_in:    - Input Signal
//   rise:      - Output Signal, a singular pulse within one clock cycle
//
// Local Variables:
//   prev:      - The State that captures the previous value of `sig_in`
//   next_prev: - Transitional state that captures the current
//                value of `sig_in`

`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  logic prev = 1'b0;  // State
  logic next_prev;

  // Flip-Flip
  always_ff @(posedge clk) begin
    prev <= next_prev;
  end

  // Next-State Logic
  assign next_prev = sig_in;

  // Output Logic
  assign rise = (!prev && sig_in);

endmodule
