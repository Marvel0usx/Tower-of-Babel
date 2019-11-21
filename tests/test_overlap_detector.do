# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)

vlog -timescale 1ns/1ns overlap_detector.v

# Load simulation using mux as the top level simulation module.

vsim overlap_detector

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# Set input values using the force command, signal names need to be in {} brackets.

# Set Clock
force {clk} 0 0ns, 1 10ns -repeat 20ns

# Reset, active low
force {resetn} 0
run 20ns

# Test omitted
force {resetn} 1
run 40ns

# Passing curr_x_position >= prev_x_position
force {resetn} 1
force {curr_x_position} 8'b1 0ns, 8'b1 20ns, 8'b1010 40ns, 8'b1011 60ns
force {prev_x_position} 8'b0 0ns, 8'b1 20ns, 8'b0 40ns, 8'b0 60ns
run 80ns

# Reset, active low
force {resetn} 0
run 20ns

# Passing curr_x_position <= prev_x_position
force {resetn} 1
force {curr_x_position} 8'b0 0ns, 8'b1 20ns, 8'b0 40ns, 8'b0 60ns
force {prev_x_position} 8'b1 0ns, 8'b1 20ns, 8'b1010 40ns, 8'b1011 60ns
run 80ns

# Reset, active low
force {resetn} 0
run 20ns
