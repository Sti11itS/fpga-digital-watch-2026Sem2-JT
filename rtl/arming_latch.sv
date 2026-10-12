// Arming Latch
// Module that tracks status of itself via output `armed` by inputs `arm`
// and `disarm`. Port names reflect intended use rather that specific
// implementation to allow reusability.
//
// Parameters:
//      None
//
// Ports:
//    clk:      - Clock input
//    arm:      - Input signal to prime the Output signal `armed`
//    disarm:   - Input signal to clear the Output signal `armed`
//    armed:    - Output signal to reflect the status of the module

`timescale 1ns / 1ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed = 1'b0
);

  always_ff @(posedge clk) begin
    if (disarm) begin
      armed <= 1'b0;
    end else if (arm) begin
      armed <= 1'b1;
    end
  end

endmodule
