// Button Hold Detect
// When the button is pressed for a specified number of clock cycles, returns
// HIGH as long as the button remains pressed.
//
// Parameters:
//    HOLD_CYCLES: - Number of clock cycles to check against to determine HIGH
//                   (default: 50_000_000)
//
// Ports:
//    clk:         - Clock input
//    button:      - Input button signal
//    held:        - Output signal, HIGH when button is HIGH for at least one
//                 - HOLD_CYCLES clock cycles, LOW otherwise
//
// Local Variables:
//    CountMax:       - To hold parameter value (HOLD_CYCLES - 1)
//    CountWidth:     - Bit width of CountMax
//    count_rst:      - Reset signal for `mod_n_counter` u_counter
//    count_enable:   - Enable signal for `mod_n_counter` u_counter
//    count:          - Count output of `mod_n_counter` u_counter
//    held_qualifier: - HIGH when count reaches CountMax, LOW otherwise

`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held = 1'b0
);

  localparam int CountMax = HOLD_CYCLES - 1;
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;
  logic [CountWidth-1:0] count;
  logic held_qualifier;

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  // Next-State Logic
  assign count_rst = !button;
  assign count_enable = button;
  assign held_qualifier = (count == CountWidth'(CountMax));

  // Flip-Flop, Next-State Logic, and Output Logic
  always_ff @(posedge clk) begin
    if (button && held_qualifier) begin
      held <= 1'b1;
    end else if (button && held) begin
      held <= 1'b1;
    end else begin
      held <= 1'b0;
    end
  end

endmodule
