// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------

`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  assign led = clk ? sw : ~sw;

  logic ss, lap;
  logic counter_rst, counter_enable, lap_hold;
  logic [6:0] minutes, minutes_hold;
  logic [5:0] seconds, seconds_hold;
  logic [6:0] centiseconds, centiseconds_hold;

  rising_edge_detector u_red_ss (
      .clk(clk),
      .sig_in(button[0]),
      .rise(ss)
  );

  rising_edge_detector u_red_lap (
      .clk(clk),
      .sig_in(button[1]),
      .rise(lap)
  );

  stopwatch_control u_stopwatch_control (
      .clk(clk),
      .rise_start_stop(ss),
      .rise_lap(lap),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_minutes_mux (
      .clk(clk),
      .hold(lap_hold),
      .d(minutes),
      .q(minutes_hold)
  );

  snapshot_mux #(
      .WIDTH(6)
  ) u_snapshot_seconds_mux (
      .clk(clk),
      .hold(lap_hold),
      .d(seconds),
      .q(seconds_hold)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_centiseconds_mux (
      .clk(clk),
      .hold(lap_hold),
      .d(centiseconds),
      .q(centiseconds_hold)
  );

  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_stopwatch_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(minutes),
      .seconds(seconds),
      .centiseconds(centiseconds)
  );

  assign hours_disp = (lap_hold) ? minutes_hold : minutes;
  assign minutes_disp = (lap_hold) ? {1'b0, seconds_hold} : {1'b0, seconds};
  assign seconds_disp = (lap_hold) ? centiseconds_hold : centiseconds;

  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;

endmodule
