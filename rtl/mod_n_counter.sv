// Modulo N Counter
// This module implements a modulo N counter that counts from 0 to N-1 and wraps
// around to 0 when it reaches N. The counter can be reset asynchronously and is
// enabled by an input signal.
//
// Parameters:
//   N      - Maximum count value (default: 4).
//   WIDTH  - Width of the count output (default: 2).
//
// Ports:
//   clk    - Clock input.
//   rst    - Asynchronous reset input.
//   enable - When high, the counter is enabled.
//   count  - Output count value (0 to N-1).
//

`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count = WIDTH'(0)
);

  // Declare local parameters and signals
  // Cast input `N` parameter to local `Max` parameter
  localparam logic [WIDTH-1:0] Max = WIDTH'(N - 1);
  logic [WIDTH-1:0] next_count;

  // State, and Output Logic
  always_ff @(posedge clk) begin
    if (rst) count <= WIDTH'(0);  // Asynchronous reset to 0
    else if (enable) count <= next_count;
  end

  // Next-State Logic
  always_comb begin
    if (count < Max) next_count = count + WIDTH'(1);
    else next_count = WIDTH'(0);  // Wrap to 0 when Max
  end

endmodule
