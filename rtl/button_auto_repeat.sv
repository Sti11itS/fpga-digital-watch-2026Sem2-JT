// Button Auto Repeat
// When the button is first pressed, a pulse is sent. As long as the button
// remains pressed for at least HOLD_CYCLES, a pulse is sent every
// REPEAT_CYCLES starting from the end of HOLD_CYCLES.
//
// Parameters:
//    HOLD_CYCLES:   - Number of clock cycles to check against to determine
//                     HIGH (default: 50_000_000)
//    REPEAT_CYCLES: - Number of clock cycles to pass to pulse a HIGH
//                     (default: 5_000_000)
//
// Ports:
//    clk:           - Clock input
//    button:        - Input button signal
//    pulse:         - Output signal, HIGH when button is initially pressed
//                     OR while the button is pressed for at least HOLD_CYCLES
//                     send out a HIGH pulse every REPEAT_CYCLES
//
// Local Variables:
//    rise:          - pulse signal for initial press
//    held:          - signal to signify button being held
//    pulse_train:   - waves of pulses repeating every REPEAT_CYCLES as long as
//                     `held` is HIGH


`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic pulse_train;

  // Sends out a pulse when the button is initially pressed
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  // Want the pulse to 'tick' upon reaching the HOLD_CYCLE but `pulse_train`
  // only 'ticks' AFTER completing one full REPEAT_CYCLE. So need to offset
  // the starting line by REPEAT_CYCLE
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  // Repeat Rate = REPEAT_CYCLES
  // pulse_train only ticks when REPEAT_CYCLES is reached only AFTER held
  // is passed in as true
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_1khz_gen (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );

  assign pulse = rise | (button & pulse_train);

endmodule
