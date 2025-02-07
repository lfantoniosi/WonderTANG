create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}] -add
create_clock -name pll0 -period 9.259 -waveform {0 4.630} [get_ports {pll0}] -add // pll_clk O0=108M
create_clock -name pll1 -period 27.937 -waveform {0 13.968} [get_ports {pll1}] -add // pll_clk O1=35795K
create_clock -name pll2 -period 141.723 -waveform {0 70.862} [get_ports {pll2}] -add // pll_clk O2=7056K

create_generated_clock -name clk54 -source [get_ports {pll0}] -master_clock pll0 -divide_by 2 -multiply_by 1 -add [get_nets {clk54}]
create_generated_clock -name clk108 -source [get_ports {pll0}] -master_clock pll0 -divide_by 1 -multiply_by 1 -add [get_nets {clk108}]
create_generated_clock -name clk108p -source [get_ports {pll0}] -master_clock pll0 -divide_by 1 -multiply_by 1 -duty_cycle 50 -phase 180 -add [get_nets {clk108p}]

create_generated_clock -name clk135 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 5 -add [get_nets {clk135}]
//create_generated_clock -name clk27 -source [get_ports {clk}] -master_clock clk -divide_by 1 -multiply_by 1 -add [get_nets {clk}]

//create_clock -name clk27 -period 37.037 -waveform {0 18.518} [get_nets {clk27}] -add
create_clock -name clk_opll -period 279.369 -waveform {0 139.685} [get_nets {clk_opll}] -add
create_clock -name clk_psg -period 558.737 -waveform {0 279.369} [get_nets {clk_psg}] -add
create_clock -name clk_sound -period 1417.234 -waveform {0 708.617} [get_nets {clk_sound}] -add
create_clock -name clk_audio -period 22675.737 -waveform {0 11337.869} [get_nets {clk_audio}] -add

//set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {pll0 clk108 clk108p clk135 clk54}] -group [get_clocks {pll1}] -group [get_clocks {pll2}] -group [get_clocks {clk27}] -group [get_clocks{clk_opll clk_psg}]

create_clock -name clock -period 37.037 -waveform {0 18.518} [get_ports {clock}] -add

set_clock_groups -asynchronous -group [get_clocks {clk clk135}] -group [get_clocks {clk108 clk108p clk54}] -group [get_clocks {pll0}] -group [get_clocks {pll1}] -group [get_clocks {pll2}]
//set_clock_groups -asynchronous -group [get_clocks {clk }] -group [get_clocks {clk108 clk108p}] -group [get_clocks {pll0}] -group [get_clocks {pll1}] -group [get_clocks {pll2}]

//set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {pll0}] -group [get_clocks {pll1}] -group [get_clocks {pll2}]

