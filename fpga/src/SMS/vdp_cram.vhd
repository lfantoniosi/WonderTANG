--
-- Multicore 2 / Multicore 2+
--
-- Copyright (c) 2017-2020 - Victor Trucco
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
		
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_cram is
	port (
		cpu_clk:	in  STD_LOGIC;
		cpu_WE:	in  STD_LOGIC;
		cpu_A:	in  STD_LOGIC_VECTOR (4 downto 0);
		cpu_D:	in  STD_LOGIC_VECTOR (11 downto 0);
		vdp_clk:	in  STD_LOGIC;
		vdp_A:	in  STD_LOGIC_VECTOR (4 downto 0);
		vdp_D:	out STD_LOGIC_VECTOR (11 downto 0));
end vdp_cram;

architecture Behavioral of vdp_cram is

	type t_ram is array (0 to 31) of std_logic_vector(11 downto 0);
	signal ram : t_ram := (others => "111111111111");
	
begin

	process (cpu_clk)
		variable i : integer range 0 to 31;
	begin
		if rising_edge(cpu_clk) then
			if cpu_WE='1'then
				i := to_integer(unsigned(cpu_A));
				ram(i) <= cpu_D;
			end if;
		end if;
	end process;

	process (vdp_clk)
		variable i : integer range 0 to 31;
	begin
		if rising_edge(vdp_clk) then
			i := to_integer(unsigned(vdp_A));
			vdp_D <= ram(i);
		end if;
	end process;

end Behavioral;

