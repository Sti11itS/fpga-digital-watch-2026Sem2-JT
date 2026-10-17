// Cascade Counter
// Consists of three cascading Modulo N Counters that syncs three sets of
// counters together, where the rollover of initial counter performs the tick
// for the next counter.
//
// Parameters:
//    N2:   - Max 'length' value for Counter N2
//    N1:   - Max 'length' value for Counter N1
//    N0:   - Max 'length' value for Counter N0
//    W2:   - Output port bit width of `N2-1` value
//    W1:   - Output port bit width of `N1-1` value
//    W0:   - Output port bit width of `N0-1` value
//
// Ports:
//    clk:              - Clock input
//    rst:              - Asynchronous reset input
//    enable:           - When HIGH, module is enabled
//    [W2-1:0] count2:  - Output Signal of counter N2 (0 to N2-1)
//    [W1-1:0] count1:  - Output Signal of counter N1 (0 to N1-1)
//    [W0-1:0] count0:  - Output Signal of counter N0 (0 to N0-1)
//
// Local Variables:
//    CountN2, CountN1, CountN1: - To hold their respective parameter values
//                                 (N2-1), (N1-1), (N0-1) with their correct
//                                 bit widths
//    enable1:  - HIGH only when N0 rolls over and enable is HIGH
//    enable2:  - HIGH only when N1 rolls over and enable1 is HIGH

`timescale 1ns / 1ps

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2-1:0] count2,
    output logic [W1-1:0] count1,
    output logic [W0-1:0] count0
);

  localparam logic [W2-1:0] CountN2 = (W2)'(N2) - 1;
  localparam logic [W1-1:0] CountN1 = (W1)'(N1) - 1;
  localparam logic [W0-1:0] CountN0 = (W0)'(N0) - 1;
  logic enable1, enable2;

  mod_n_counter #(
      .N(CountN0 + 1),
      .WIDTH(W0)
  ) u_count_N0 (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count0)
  );

  mod_n_counter #(
      .N(CountN1 + 1),
      .WIDTH(W1)
  ) u_count_N1 (
      .clk(clk),
      .rst(rst),
      .enable(enable1),
      .count(count1)
  );

  mod_n_counter #(
      .N(CountN2 + 1),
      .WIDTH(W2)
  ) u_count_N2 (
      .clk(clk),
      .rst(rst),
      .enable(enable2),
      .count(count2)
  );

  always_comb begin
    if (count0 == CountN0 && enable) enable1 = 1'b1;
    else enable1 = 1'b0;
    if (count1 == CountN1 && enable1) enable2 = 1'b1;
    else enable2 = 1'b0;
  end

endmodule
