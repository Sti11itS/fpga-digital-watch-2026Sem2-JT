`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,  // Button[0]
    input  logic rise_lap,         // Button[1]
    output logic counter_rst,      // Reset Pulse
    output logic counter_enable,   // Running(1) or Stopped(0)
    output logic lap_hold          // Freeze(1) or Live(0)
);

  logic [2:0] state = 3'b000;
  logic [2:0] next_state;

  wire ss_only = rise_start_stop && !rise_lap;
  wire lap_only = !rise_start_stop && rise_lap;

  always_ff @(posedge clk) begin
    state <= next_state;
  end

  assign next_state[1] = ss_only ? !state[1] : state[1];
  assign next_state[0] = (counter_enable && lap_only) ? !state[0] : state[0];

  always_comb begin
    if (!counter_enable && lap_hold && lap_only) begin
      next_state[0] = !lap_hold;
    end
    if (!counter_enable && !lap_hold && lap_only) begin
      next_state[2] = !counter_rst;
    end else if (counter_rst) begin
      next_state[2] = !counter_rst;
    end
  end

  assign counter_rst = state[2];
  assign counter_enable = state[1];
  assign lap_hold = state[0];

endmodule
