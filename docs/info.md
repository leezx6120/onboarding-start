<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project uses SPI commands to control 16 digital outputs. The system receives commands through three inputs: SCLK for timing, COPI to carry the command bits, and nCS to select the chip when it is low. Each command contains a one-bit write flag, a 7-bit address, and an 8-bit value to store. Each of the 16 outputs can stay low, stay high, or follow a shared PWM signal with an adjustable duty cycle. The system clock is set to 10 MHz and generates a PWM frequency of approximately 3 kHz. Reset clears all settings so the outputs start low.

## How to test

I use Cocotb with the Icarus Verilog simulator to test the project. The tests check SPI register writes, PWM frequency on output channel 0, and duty cycles of 0%, 50%, and 100% on this channel. 

## External hardware

No external hardware is required for the simulation tests.