create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}] -add

create_generated_clock -name clk108 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -add [get_nets {clk108}]

create_generated_clock -name clk108p -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 4 -duty_cycle 50 -phase 180 -add [get_nets {clk108p}]

////////////// SMS
create_generated_clock -name clk135 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 5 -add [get_nets {clk135}]

create_generated_clock -name clk54 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 2 -add [get_nets {clk54}]

create_clock -name clk_audio -period 22675.73696 -waveform {0 11337.86848} [get_nets {clk_audio}] -add
////////////////

create_clock -name clock -period 69.832 -waveform {0 34.916} [get_ports {clock}] -add

create_clock -name clk_sound -period 1417.23356 -waveform {0 708.61678} [get_nets {clk_sound}] -add

// OPLL
create_clock -name clk_opll -period 279.36 -waveform {0 139.68} [get_nets {clk_opll}] -add

// PSG
create_clock -name hclock -period 558.72 -waveform {0 279.36} [get_nets {hclock}] -add

//set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {clock}] -group [get_clocks {clk108 clk108p}] -group [get_clocks {clk135 clk54 clk_audio}] -group [get_clocks {clk_sound clk_opll}]