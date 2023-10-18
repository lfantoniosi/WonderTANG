/*  This file is part of JT89.

    JT89 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT89 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT89.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: December, 1st 2018
   
    */

module jt89_mixer #(parameter bw=9)(
    input            rst,
    input            clk,
    input            clk_en,
    input            cen_16,
    input   [bw-1:0] ch0,
    input   [bw-1:0] ch1,
    input   [bw-1:0] ch2,
    input   [bw-1:0] noise,
	 input      [7:0] mux,
    output reg signed [bw+1:0] soundL,
    output reg signed [bw+1:0] soundR
);

reg signed [bw+1:0] freshR,freshL;

always @(*)
    freshR = 
        (mux[0] ? { {2{ch0[bw-1]}}, ch0     } : {bw+1{1'b0}})+
        (mux[1] ? { {2{ch1[bw-1]}}, ch1     } : {bw+1{1'b0}})+
        (mux[2] ? { {2{ch2[bw-1]}}, ch2     } : {bw+1{1'b0}})+
        (mux[3] ? { {2{noise[bw-1]}}, noise } : {bw+1{1'b0}});

always @(posedge clk) soundR <= freshR;

always @(*)
    freshL = 
        (mux[4] ? { {2{ch0[bw-1]}}, ch0     } : {bw+1{1'b0}})+
        (mux[5] ? { {2{ch1[bw-1]}}, ch1     } : {bw+1{1'b0}})+
        (mux[6] ? { {2{ch2[bw-1]}}, ch2     } : {bw+1{1'b0}})+
        (mux[7] ? { {2{noise[bw-1]}}, noise } : {bw+1{1'b0}});

always @(posedge clk) soundL <= freshL;

endmodule 