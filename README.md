
# Arty Development Board

**Template project.**

This repository contains a very basic few files needed to setup a Vivado
project for the Arty board.

The main arifacts are:

- `rtl/impl_top.v` - This is a verilog *top* file with ports corresponding
  to each of the Arty pins. Designs can be instantiated within this module
  to be connected to the outside world.
- `constraints/defaults.xdc` - The constraints file which maps device pins
  onto the RTL signals in the *top* file.
