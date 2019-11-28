# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)

vlog -timescale 10ns/10ns testFSM.v

# Load simulation using mux as the top level simulation module.

vsim testFSM

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# Set input values using the force command, signal names need to be in {} brackets.

# Set Clock
force {clk} 0 0ns, 1 10ns -repeat 20ns

# load x
force {resetn} 1
force {new_x} 10'b1
force {ld_x} 1
run 10ns

# enable
force {ld_x} 0
force {enable} 1
run 200ns

# resetn
force {resetn} 0
run 20ns
