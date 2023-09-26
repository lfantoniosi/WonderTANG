create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}] -add

create_generated_clock -name clk135 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 5 -add [get_nets {clk135}]
create_generated_clock -name clk108 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -add [get_nets {clk108}]
create_generated_clock -name clk108p -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -duty_cycle 50 -phase 180 -add [get_nets {clk108p}]

//create_generated_clock -name clk54 -source [get_nets {clk108}] -master_clock clk108 -divide_by 2 -multiply_by 1 -add [get_nets {clk54}]
create_generated_clock -name clk54 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 2 -add [get_nets {clk54}]
//create_generated_clock -name clk54p -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 2 -duty_cycle 50 -phase 180 -add [get_nets {clk54p}]

//create_clock -name clk25 -period 40 -waveform {0 20} [get_ports {clk_pll0}] -add
//create_clock -name clk125 -period 8 -waveform {0 4} [get_ports {clk_pll1}] -add

create_clock -name clkcpu -period 139.665 -waveform {0 69.832} [get_ports {clock}] -add
create_clock -name clkhcpu -period 279.33 -waveform {0 139.665} [get_regs {ff_hclock_s0}] -add
create_clock -name clk_audio -period 22727.273 -waveform {0 11363.637} [get_nets {clk_audio}] -add

//create_clock -name clk358 -period 279.33 -waveform {0 139.665} [get_nets {clk358}] -add
//create_clock -name clk179 -period 558.659 -waveform {0 279.329} [get_regs {ff_hclock_s0}] -add