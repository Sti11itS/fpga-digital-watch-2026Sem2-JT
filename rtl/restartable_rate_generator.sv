// Restartable Rate Generator
// Generates a Mod-N counter that produces a tick at a specified rate when
// enabled. The rate is defined by the CYCLE_COUNT parameter. The generated
// Mod_CYCLE_COUNT counter can be restarted by deasserting and reasserting
// the run signal.
//
// Parameters:
//   CYCLE_COUNT: - Number of clock cycles per tick (default: 2).
//
// Ports:
//   clk:         - Clock input.
//   run:         - When high, the generated Mod_CYCLE_COUNT instant is
//                  enabled and produces ticks after successfully reaching
//                  each full cycle.
//   tick:        - Output tick signal, high when both run is high and the
//                  tick_qualifier is high.
//
// Local Variables:
//   CountWidth:    - Bit width of the generated Mod_CYCLE_COUNT counter.
//   rst_count:     - Reset signal for the generated Mod_CYCLE_COUNT counter.
//   enable_count:  - Enable signal for the generated Mod_CYCLE_COUNT counter.
//   count:         - Count output of the generated Mod_CYCLE_COUNT counter.
//   tick_qualifier:- High when the generated Mod_CYCLE_COUNT counter reaches
//                    its maximum value, indicating a tick should be generated.
//   running:       - Indicates whether the rate generator is currently running

`timescale 1ns / 1ps

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  // Declare Local Parameters and Signals
  // Get required bit width for the counter based on CYCLE_COUNT
  localparam int CountWidth = $clog2(CYCLE_COUNT);

  // Becomes high at the end of each cycle
  logic tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general
      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;
      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      assign rst_count = !run;
      assign enable_count = run;
      assign tick_qualifier = (count == CountWidth'(CYCLE_COUNT - 1));
    end else begin : g_special
      assign tick_qualifier = 1'b1;
    end
  endgenerate

  // Running state logic
  logic running = 1'b0;
  always_ff @(posedge clk) running <= run;

  // Output Logic
  assign tick = running && tick_qualifier;

endmodule
