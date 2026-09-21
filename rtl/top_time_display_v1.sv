// Top Time Display V1
// Top Level Module to diplay the time in HH:MM:SS with 2 Switches controlling
// 4 clock speeds.
//
// Parameters:
//    CYCLES_PER_SECOND:        - Clock Rate (default = 50MHz)
//
// Ports:
//    CLOCK_50:                 - DE1-SoC CLOCK_50 (PIN_AF14)
//    SW [1:0]:                 - DE1-SoC SW[1] (PIN_AC12) and SW[0] (PIN_AB12)
//    HEX5 [6:0]:               - DE1-SoC HEX5
//    HEX4 [6:0]:               - DE1-SoC HEX4
//    HEX3 [6:0]:               - DE1-SoC HEX3
//    HEX2 [6:0]:               - DE1-SoC HEX2
//    HEX1 [6:0]:               - DE1-SoC HEX1
//    HEX0 [6:0]:               - DE1-SoC HEX0
//
// Local Signals:
//    selector:                 - Mux Switch Selector, uses SW[1:0]
//    tick_pulse_1hz:           - pulses at 1 Hz
//    tick_pulse_25hz:          - pulses at 25 Hz
//    tick_pulse_1khz:          - pulses at 1 Hz
//    pulse:                    - pulses according to selected mux switch
//    [4:0] hours:                      - 24 hours in binary (00-23)
//    [5:0] minutes, seconds:           - 60 minutes/seconds in binary (00-59)
//    [3:0] hours_tens, hours_ones:     - BCD hours for SSEG display
//    [3:0] minutes_tens, minutes_ones: - BCD minutes for SSEG display
//    [3:0] seconds_tens, seconds_ones: - BCD seconds for SSEG display

`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  // Declare Local Parameters and Signals
  logic [1:0] selector;
  logic tick_pulse_1hz, tick_pulse_25hz, tick_pulse_1khz;
  logic pulse;
  logic [4:0] hours;
  logic [5:0] minutes, seconds;
  logic [3:0] hours_tens, hours_ones;
  logic [3:0] minutes_tens, minutes_ones;
  logic [3:0] seconds_tens, seconds_ones;

  // Assign the Mux Selector switch with SW[1:0]
  assign selector = SW;

  // The restartable rate generators need to align to the same clock
  // while at the same time ticking to their assigned clock rate
  // Clock Rate = 1 Hz
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1)
  ) u_1hz_gen (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_pulse_1hz)
  );
  // Clock Rate = 25 Hz
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_25hz_gen (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_pulse_25hz)
  );
  // Clock Rate = 1 kHz
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1_000)
  ) u_1khz_gen (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_pulse_1khz)
  );

  // The Mux Switch to select the Clock Rate using the SW[1:0]
  // 2'b00 = 1Hz, 2'b01 = 25Hz, 2'b10 = 1kHz, 2'b11 and default = 50MHz
  always_comb
    unique case (selector)
      2'b00:   pulse = tick_pulse_1hz;
      2'b01:   pulse = tick_pulse_25hz;
      2'b10:   pulse = tick_pulse_1khz;
      2'b11:   pulse = 1'b1;
      default: pulse = 1'b1;
    endcase

  // Run the clock with the selected Clock Rate
  hms_counter u_hms_counter (
      .clk(CLOCK_50),
      .enable(pulse),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  // Binary-Coded Decimal conversions for HH:MM:SS
  binary_to_bcd u_bcd_hours (
      .bin ({2'b0, hours}),
      .tens(hours_tens),
      .ones(hours_ones)
  );
  binary_to_bcd u_bcd_minutes (
      .bin ({1'b0, minutes}),
      .tens(minutes_tens),
      .ones(minutes_ones)
  );
  binary_to_bcd u_bcd_seconds (
      .bin ({1'b0, seconds}),
      .tens(seconds_tens),
      .ones(seconds_ones)
  );

  // Display the digits on the Seven Segment Display HEX[5:0]
  seven_segment u_seg_hours_tens (
      .digit(hours_tens),
      .blank(1'b0),
      .segments(HEX5)
  );
  seven_segment u_seg_hours_ones (
      .digit(hours_ones),
      .blank(1'b0),
      .segments(HEX4)
  );
  seven_segment u_seg_minutes_tens (
      .digit(minutes_tens),
      .blank(1'b0),
      .segments(HEX3)
  );
  seven_segment u_seg_minutes_ones (
      .digit(minutes_ones),
      .blank(1'b0),
      .segments(HEX2)
  );
  seven_segment u_seg_seconds_tens (
      .digit(seconds_tens),
      .blank(1'b0),
      .segments(HEX1)
  );
  seven_segment u_seg_seconds_ones (
      .digit(seconds_ones),
      .blank(1'b0),
      .segments(HEX0)
  );

endmodule
