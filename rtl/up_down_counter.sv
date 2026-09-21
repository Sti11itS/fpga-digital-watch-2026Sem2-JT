// Up_Down_Counter
// To act as a standard Counter, whose modulus value is determined by the
// MAX parameter argument that was passed into it. The counter will count up
// when the up input is high, and count down when the up input is low. The
// counter will wrap back to 0 when the maximum value is reached, and wrap
// back to the maximum value when the minimum value is reached for up and
// down counting, respectively.
//
// Parameters:
//   MAX    - Maximum count value (default: 2).
//   WIDTH  - Width of the count output (default: 2).
//
// Ports:
//   clk    - Clock input.
//   enable - When high, the counter is enabled.
//   up     - When high, the counter counts up; when low, counts down.
//

`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count = WIDTH'(0)
);

  // Declare local parameters and signals
  // Cast input `MAX` parameter to local `Max` parameter
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  logic [WIDTH-1:0] next_count;

  // State, and Output Logic
  always_ff @(posedge clk) if (enable) count <= next_count;

  // Next state logic
  always_comb begin
    if (up) begin  // up=1 -> Count up
      if (count < Max) next_count = count + WIDTH'(1);
      else next_count = WIDTH'(0);  // Wrap to 0 when Max
    end else begin  // else up=0 -> Count down
      if (count > WIDTH'(0)) next_count = count - WIDTH'(1);
      else next_count = Max;  // Wrap to Max when 0
    end
  end

endmodule
