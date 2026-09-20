// Binary to Binary-Coded Decimal (BCD) Converter
// Displaying hours, minutes, and seconds on seven-segement displays
// requires a binary to binary-coded decimal (BCD) converter.
// This module converts a 7-bit binary input (0-99) into two
// 4-bit BCD outputs representing the tens and ones digits.
//
// Note: Module allows conversion up to d'127 even though the
// maximum expected input is d'99. The BCD outputs will be d'12 and
// d'7 for an input of d'127.
//
// Parameters:
//   None
//
// Ports:
//   bin       [6:0]   - Binary input b'(0-110_0011) for d'(0-99).
//   tens      [3:0]   - BCD output for the tens digit.
//   ones      [3:0]   - BCD output for the ones digit.
//

`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,   // binary input, b'(0-110_0011)
    output logic [3:0] tens,  // decimal tens digit (BCD)
    output logic [3:0] ones   // decimal ones digit (BCD)
);

  assign tens = 4'(bin / 7'd10);  // Calculate the tens digit
  assign ones = 4'(bin % 7'd10);  // Calculate the ones digit

endmodule
