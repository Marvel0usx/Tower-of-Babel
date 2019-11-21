# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)

vlog -timescale 1ms/10ns general_counter.v

# Load simulation using mux as the top level simulation module.

vsim general_counter

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# Set input values using the force command, signal names need to be in {} brackets.

# Set Clock
force {clk} 0 0ns, 1 10ns -repeat 20ns

# Load value
# actually 20-bit
force {delay} 26'b11001110111001100001

# Reset, active low
force {resetn} 0
run 20ns

force {resetn} 1
force {enable} 1

run 1000ms