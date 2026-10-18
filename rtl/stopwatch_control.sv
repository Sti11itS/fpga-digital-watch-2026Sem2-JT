// Stopwatch Control
// When in Stopwatch mode, input buttons KEY[1:0] control the state of
// the stopwatch
//
// Parameters:
//    None
//
// Ports:
//    clk:             - Clock input
//    rise_start_stop: - Input signal from KEY[0], assumed passed in as a
//                       pulse from a Rising Edge Detector module
//    rise_lap:        - Input signal from KEY[1], same assumption as above
//    counter_rst:     - Output signal, single one-cycle pulse of RESET state
//    counter_enable:  - Output signal, `enabled` state
//    counter_lap_hold:- Output signal, 'frozen display' state
//
// Local Variables:
//    state:      - Intermediary Variable to store state for output signals
//    next_state: - Intermediary Variable to store state for next rising edge
//    ss_only:    - Combinational Logic to ensure that if both buttons are
//    lap_only:       pressed, nothing happens

`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,  // Button[0]
    input  logic rise_lap,         // Button[1]
    output logic counter_rst,      // Reset Pulse
    output logic counter_enable,   // Running(1) or Stopped(0)
    output logic lap_hold          // Freeze(1) or Live(0)
);

  logic [2:0] state, next_state;
  initial state = 3'b000;

  wire ss_only = rise_start_stop && !rise_lap;
  wire lap_only = !rise_start_stop && rise_lap;

  always_ff @(posedge clk) begin
    state <= next_state;
  end

  assign next_state[1] = ss_only ? !state[1] : state[1];
  assign next_state[0] = ((counter_enable || lap_hold) && lap_only) ? !state[0] : state[0];

  // TODO: Fix this Latch!!!
  always_latch begin
    if (!(counter_enable || lap_hold)) begin
      next_state[2] = lap_only;
    end
  end

  assign counter_rst = state[2];
  assign counter_enable = state[1];
  assign lap_hold = state[0];

endmodule
