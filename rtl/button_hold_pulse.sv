// Button Hold Pulse
// When the button is pressed for a specified number of clock cycles, returns
// HIGH for only one clock cycle, returns LOW while button remains pressed,
// and when released.
//
// Parameters:
//    HOLD_CYCLES: - Number of clock cycles to check against to determine HIGH
//                   (default: 50_000_000)
//
// Ports:
//    clk:         - Clock input
//    button:      - Input button signal
//    pulse:       - Output signal, HIGH for one clock cycle when button is
//                   HIGH for at least one HOLD_CYCLES clock cycles.
//
// Local Variables:
//    held:        - Wire between output .held from `button_hold_detect` and
//                   input .sig_in of `rising_edge_detector`

`timescale 1ns / 1ps

module button_hold_pulse #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic held;

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(held),
      .rise(pulse)
  );

endmodule
