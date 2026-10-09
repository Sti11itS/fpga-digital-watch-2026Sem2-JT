`timescale 1ns / 1ps
module user_wave_button_hold_detect;
  reg  clk = 0;
  reg  button = 0;
  wire held;

  button_hold_detect #(
      .HOLD_CYCLES(20)
  ) dut (
      .clk   (clk),
      .button(button),
      .held  (held)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("user_wave_button_hold_detect.vcd");
    $dumpvars(0, user_wave_button_hold_detect);

    // Button held long enough: held asserts after 5 cycles, then
    // deasserts immediately when button is released
    #30;
    button = 1;
    #300;
    button = 0;

    // Button released too early: held never asserts
    #20;
    button = 1;
    #30;
    button = 0;

    #20 $finish;
  end
endmodule
