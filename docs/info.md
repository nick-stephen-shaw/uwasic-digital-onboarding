
## How it works

This design implements an SPI-controlled PWM peripheral. An external SPI master writes to five 8-bit configuration registers, which control which of the 16 output pins drive, which of them are PWM-modulated, and at what duty cycle

## SPI Interface

The SPI peripheral operatoes in mode 0, MSB first, and is write-only. Each transaction is 16 bits. 
nCS falling marks the start of transaction and clears the receive shift register. nCS rising marks the end. The write commits only if exactly 16 bits were received and the R/W bit indicates a write. 
SCLK runs at aproximately 100 kHz while the system clock is 10 MHz. Rather than treating SCLK as a clock, this design oversampmles it. SCLK, COPI, and cCS each pass through a two-flop synchroniser to prevent metastabilty from propagating, and edge detection on the synchronised SCLK produces a single-cycle strobe used to shift data in, keeping the entire design in a single clock domain. 

## How to test

Run the cocotb testbench:

```
make -C test
```

'test_spi' drives SPI transactions against the design and checks that valid writes reach the correct registers, and that invalid addresses and read transactions leave the registers unchanged. 

To exercise it on hardware, connect an SPI master to ui[0] (SCLK), ui[1] (COPI), and ui[2] (nCS), then write 0xFF to address 0x00 to enable all eight uo_out pins, 0xFF to address 0x02 to put them in PWM mode, and a value to address 0x04 to set the duty cycle. The outputs should show a ~3 kHz square wave at the corresponding duty. 
## External hardware

An SPI master such as a microcontroller or a logic analyser with SPI output. No other external hardware is required; outputs can be observed on an oscilloscope or with LEDs. 