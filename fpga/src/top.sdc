create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}] -add

create_generated_clock -name clk108 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -add [get_nets {clk108}]
create_generated_clock -name clk108p -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -duty_cycle 50 -phase 180 -add [get_nets {clk108p}]

////////////// SMS
create_generated_clock -name clk135 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 5 -add [get_nets {clk135}]
create_generated_clock -name clk54 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 2 -add [get_nets {clk54}]
create_clock -name clk_audio -period 22727.273 -waveform {0 11363.637} [get_nets {clk_audio}] -add
////////////////

create_clock -name clkcpu -period 69.832 -waveform {0 34.916} [get_ports {clock}] -add
create_clock -name clkhcpu -period 139.665 -waveform {0 69.832} [get_regs {ff_hclock_s0}] -add

