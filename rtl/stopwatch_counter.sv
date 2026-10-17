// Stopwatch Counter
// A module that counts (99) minutes, (59) seconds and (99) centiseconds using
// the Restartable Rate Generator that ticks per 1/10th of CYCLES_PER_SECOND
// and the Cascade Counter that drives the Output Signals.
//
// Parameters:
//    CYCLES_PER_SECOND: - Number of cycles per second
//
// Ports:
//    clk:                - Clock input
//    rst:                - Asynchronous reset input
//    enable:             - When HIGH, module is enabled
//    [6:0] minutes:      - Output Signal for 7'd99 minutes
//    [5:0] seconds:      - Output Signal for 6'd59 seconds
//    [6:0] centiseconds: - Output Signal for 7'd99 centiseconds
//
// Local Variables:
//    gen_run:  - HIGH *only* when `rst`:LOW and `enable`:HIGH
//    tick:     - HIGH when u_centisecond_counter completes a cycle
//    tick_centisecond: - HIGH only when `tick`:HIGH and `enable`:HIGH

`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,  // Takes priority over enable
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundredths of a second
);

  logic gen_run;
  logic tick;
  logic tick_centisecond;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)
  ) u_centisecond_counter (
      .clk (clk),
      .run (gen_run),
      .tick(tick)
  );

  cascade_counter #(
      .N0(100),
      .N1(60),
      .N2(100),
      .W0(7),
      .W1(6),
      .W2(7)
  ) u_stopwatch_counter (
      .clk(clk),
      .rst(rst),
      .enable(tick_centisecond),
      .count0(centiseconds),
      .count1(seconds),
      .count2(minutes)
  );

  always_comb begin
    if (rst || !enable) begin
      gen_run = 1'b0;
      tick_centisecond = 1'b0;
    end else begin
      gen_run = 1'b1;
      tick_centisecond = tick;
    end
  end

endmodule
