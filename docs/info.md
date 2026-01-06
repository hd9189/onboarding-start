<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements an SPI‑controlled PWM peripheral intended for Tiny Tapeout. A 10 MHz system clock drives two main blocks:

SPI Peripheral. Incoming SPI signals (SCLK, nCS, COPI) are first synchronized into the system clock domain using 2‑stage flip‑flop CDC. Each SPI transaction is exactly 16 clock cycles long and follows SPI Mode 0 (sample on rising edge). The peripheral decodes 1 bit (R/W) where only write are honoured, 7 bit register address, 8 bit data load.

PWM Peripheral. A clock divider derives a ~3 kHz PWM time base from the 10 MHz clock. A shared 8‑bit duty‑cycle register defines the PWM high‑time for all enabled channels. Sixteen outputs are supported ({uio_out[7:0], uo_out[7:0]}), each controlled by an Output Enable bit (forces low when cleared), and a PWM Enable bit (selects between static high or PWM when enabled). Output enable has priority. If it is cleared, the output is always 0. If enabled and PWM is disabled, the output is held at logic 1. If both are enabled, the output follows the PWM waveform.

## How to test

Simulation:
Run the provided Cocotb SPI testbench to verify register writes, address handling, and correct output behavior on uo_out and uio_out.
Run the PWM testbench.


## External hardware

No external hardware is required