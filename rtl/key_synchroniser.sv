// Key Synchroniser
// Digital Inputs require debouncing and sychronisation. DE1-SoC push buttons
// are debounced in hardware. Only sychronisation is required.
// DE1-SoC push buttons are Active-LOW, meaning LOW when pressed and HIGH
// when released. This module synchronises and inverts them to Active-HIGH
// for use in the rest of the circuit.
//
// Parameters:
//    None
//
// Ports:
//    clk:            - Clock input
//    [3:0] key_n:    - Input Signal from DE1-SoC KEY[3:0] ports, ACTIVE-LOW
//    [3:0] key_sync: - Output Signal for circuit, ACTIVE-HIGH
//
// Local Variables:
//    key_mid: - Intermediary Net to help mitigate metastability
//              initialised with 4'b1111 to initialise `key_sync` with 4'b0000

`timescale 1ns / 1ps

module key_synchroniser (
    input  logic       clk,
    input  logic [3:0] key_n,              // active-low, asynchronous
    output logic [3:0] key_sync = 4'b0000  // active-high, synchronised
);

  logic [3:0] key_mid = 4'b1111;

  always_ff @(posedge clk) begin
    key_mid  <= key_n;
    key_sync <= ~key_mid;
  end

endmodule
