// Editable Counter
// This module will be used to represent the Hours, Minutes and Seconds of
// the Watch.
//
// Parameters:
//    N:                - Maximum value for the counter
//    WIDTH:            - Bitwise length of number N
//
// Ports:
//    clk:              - Clock input
//    tick:             - Input signal to pulse the `tick_event` when not in
//                        `edit_mode`
//    edit_mode:        - Input signal to represent State whether module is
//                      - in edit mode
//    inc:              - Input signal to pulse the `inc_event` in `edit_mode`
//    dec:              - Input signal to pulse the `dec_event` in `edit_mode`
//    [WIDTH-1:0] count:- Output signal to count a number between 0 to N-1
//
// Local Variables:
//    inc_event:  - Signal representing incrementing STATE when
//                  `inc` is HIGH AND `dec` is LOW while in `edit_mode`
//    dec_event:  - Signal representing decrementing STATE when
//                  `dec` is HIGH AND `inc` is LOW while in `edit_mode`
//    tick_event: - Signal representing NOT in `edit_mode` running according
//                  to `tick` pulses
//    up:         - Direction of counting: HIGH = upwards, LOW = downwards
//    enable:     - Enable the Up_Down_Counter when correct conditions are met

`timescale 1ns / 1ps

module editable_counter #(
    parameter int N = 60,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic tick,  // Count increments on tick when edit_mode is LOW
    input logic edit_mode,
    input logic inc,  // Count increments by one when edit_mode is HIGH
    input logic dec,  // Count decrements by one when edit_mode is LOW
    output logic [WIDTH-1:0] count
);

  logic enable;
  logic up;
  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  assign up = inc_event || !dec_event || tick_event;
  assign enable = tick_event || (dec_event || inc_event);

endmodule
