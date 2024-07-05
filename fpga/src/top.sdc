create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}] -add

create_generated_clock -name clk108 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -add [get_nets {clk108}]
create_generated_clock -name clk108p -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -duty_cycle 50 -phase 180 -add [get_nets {clk108p}]
create_generated_clock -name clk_pa -source [get_ports {clk}] -master_clock clk -divide_by 18 -multiply_by 1 -add [get_nets {clk_pa}]

////////////// SMS
create_generated_clock -name clk135 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 5 -add [get_nets {clk135}]
create_generated_clock -name clk54 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 2 -add [get_nets {clk54}]
create_clock -name clk_audio -period 22727.273 -waveform {0 11363.637} [get_nets {clk_audio}] -add
////////////////

create_clock -name clock -period 279.36 -waveform {0 139.68} [get_ports {clock}] -add

// PSG
create_generated_clock -name hclock -source [get_ports {clock}] -master_clock clock -divide_by 2 -multiply_by 1 -add [get_nets {hclock}]
// OPLL
//create_clock -name clk_opll -period 279.36 -waveform {0 139.68} [get_nets {clk_opll}] -add

