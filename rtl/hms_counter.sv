// HMS Counter
// This module implements a Hours-Minutes-Seconds (HMS) counter using three
// up-down counters. The counter increments the seconds, minutes, and hours
// based on the enable signal and rolls over when reaching the maximum values.
//
// The hours, minutes and seconds are `ticked up` by the up_down_counter
// modules which are instantiated for each time unit. The up_down_counter
// modules are the ones that handle the wrap back to 0 when the maximum value
// is reached, as determined by the MAX parameter argument that was passed.
// into it. Up is always up.
// The rollover is handled here, at the Next-State Logic section, which
// checks if the seconds or minutes have reached their maximum values and sets
// the corresponding rollover signals accordingly.
//
// Parameters:
//   N_HOURS:             - Number of hours (default: 24).
//   N_MINUTES:           - Number of minutes (default: 60).
//   N_SECONDS:           - Number of seconds (default: 60).
//   W_HOURS:             - Width of the hours output (default: 5).
//   W_MINUTES:           - Width of the minutes output (default: 6).
//   W_SECONDS:           - Width of the seconds output (default: 6).
//
// Ports:
//   clk:                     - Clock input.
//   enable:                  - When high, the counter is enabled.
//   hours [W_HOURS-1:0]:     - Output for hours   (0 to N_HOURS-1).
//   minutes [W_MINUTES-1:0]: - Output for minutes (0 to N_MINUTES-1).
//   seconds [W_SECONDS-1:0]: - Output for seconds (0 to N_SECONDS-1).
//

`timescale 1ns / 1ps

module hms_counter #(
    parameter int N_HOURS   = 24,  // number of hours
    parameter int N_MINUTES = 60,  // number of minutes
    parameter int N_SECONDS = 60,  // number of seconds

    // Output Port Widths
    parameter int W_HOURS   = 5,  // bit length 5'b for hours (0-23)
    parameter int W_MINUTES = 6,  // bit length 6'b for minutes (0-59)
    parameter int W_SECONDS = 6   // bit length 6'b for seconds (0-59)
) (
    input  logic                 clk,
    input  logic                 enable,
    output logic [  W_HOURS-1:0] hours,    // = W_HOURS'(0),
    output logic [W_MINUTES-1:0] minutes,  // = W_MINUTES'(0),
    output logic [W_SECONDS-1:0] seconds   // = W_SECONDS'(0)
);

  // Declare Local Parameters and Signals
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);
  logic second_rollover, minute_rollover;

  // State Logic
  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(clk),
      .enable(minute_rollover),
      .up(1'b1),
      .count(hours)
  );

  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .enable(second_rollover),
      .up(1'b1),
      .count(minutes)
  );

  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );

  // Next-State Logic
  always_comb begin
    if (enable && minutes == MaxMinutes && seconds == MaxSeconds) minute_rollover = 1'b1;
    else minute_rollover = 1'b0;
    if (enable && seconds == MaxSeconds) second_rollover = 1'b1;
    else second_rollover = 1'b0;
  end

endmodule
