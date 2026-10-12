// Edit Mode Selector
// Long-pressing the button brings the watch into Edit Mode with 'seconds' as
// first editable mode. Short press once brings it to 'minutes' mode and once
// more into 'hours' mode. Subsequent short presses does nothing.
//
// Parameters:
//    HOLD_CYCLES:   - Number of clock cycles to check against to determine
//                     HIGH (default: 50_000_000)
//
// Ports:
//    clk:               - Clock input
//    button:            - Input button signal
//    [2:0] mode_enable: - Output signal as One-Hot Encoding States
//                         3'b000 = Not in Edit Mode
//                         3'b001 = Edit Seconds
//                         3'b010 = Edit Minutes
//                         3'b100 = Edit Hours
//
// Local Variables:
//    long_press:     - A HIGH pulse when the button is held for HOLD_CYCLES
//    press:          - A HIGH pulse when button is pressed, LOW when held
//    armed:          - HIGH when watch is in Edit State
//    disarm:         - HIGH when 'hours' mode and button pressed
//    reset_counter:  - Signal to reset Mod_N_Counter module
//    enable_counter: - Signal to enable Mod_N_Counter module
//    [1:0] count:    - Signal to increment `mode_enable` by shiftwise left

`timescale 1ns / 1ps

module edit_mode_selector #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic [2:0] mode_enable
);

  logic long_press;
  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(long_press)
  );

  logic press;
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)
  );

  logic armed;
  logic disarm;
  arming_latch u_latch (
      .clk(clk),
      .arm(long_press),
      .disarm(disarm),
      .armed(armed)
  );

  logic reset_counter;
  logic enable_counter;
  logic [1:0] count;
  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk(clk),
      .rst(reset_counter),
      .enable(enable_counter),
      .count(count)
  );

  // Counter runs only while armed; resets when disarmed
  assign enable_counter = (armed && (long_press || press));
  assign reset_counter = disarm;

  // Disarm on the press that steps past the last mode
  assign disarm = (count == 2'b10) && (press);

  // Output logic
  assign mode_enable = armed ? (3'b001 << count) : 3'b000;

endmodule
