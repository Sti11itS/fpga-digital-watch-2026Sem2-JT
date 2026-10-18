// Editable Countdown
// Same as the Editable Counter module but with `clr`, counts down and extra
// output signal `borrow_out`
//
// Parameters:
//    MAX
//    WIDTH
//
// Ports:
//    clk:              - Clock input
//    clr:              - Asynchronous reset
//    tick:             - Input signal to pulse the `tick_event` when not in
//                        `edit_mode`
//    edit_mode:        - Input signal to represent State whether module is
//                      - in edit mode
//    inc:              - Input signal to pulse the `inc_event` in `edit_mode`
//    dec:              - Input signal to pulse the `dec_event` in `edit_mode`
//    [WIDTH-1:0] count:- Output signal to count a number between 0 to N-1
//    borrow_out:       - Output signal to pulse rollovers
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

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out
);

  logic enable;
  logic up;
  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_up_down_counter_rst (
      .clk(clk),
      .rst(clr),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec && !clr;
  wire dec_event = edit_mode && dec && !inc && !clr;
  wire tick_event = !edit_mode && tick && !clr;

  always_comb begin
    if (edit_mode) up = inc_event || !dec_event;
    else up = !tick_event;
  end

  assign enable = tick_event || (dec_event || inc_event);

  assign borrow_out = tick_event && (count == 0);

endmodule
