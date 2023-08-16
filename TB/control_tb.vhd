library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
USE work.ALU_aux_package.all;
------------------------------------
entity control_tb is
	constant status_len : integer := 14;
	constant Controls_num : integer := 20;   -- k=log2(n)
	
end control_tb;

----------------------------------------------
architecture rtb of control_tb is
signal ena, clk, rst, done_out: std_logic;
signal status: std_logic_vector (status_len -1 downto 0); -- ld ;
signal control_vec: std_logic_vector (Controls_num -1 downto 0);
begin
connection: Control generic map (status_len, Controls_num) port map (ena, clk, rst, status, control_vec, done_out);

gen_clk : process
        begin
		  clk <= '0';
		  wait for 25 ns;
		  clk <= not clk;
		  wait for 25 ns;
        end process;

gen_rst: process
	begin
	rst <= '1';
	wait for 50 ns;
	rst <= '0';
	wait;
	end process;

gen_ena: process
	begin
	ena <= '0';
	wait for 50 ns;
	ena <= '1';
	wait;
	end process;
	
gen_status: process
	begin
	--wait for 500 ns;
	status <= (5=> '1',others => '0'); --add	
	wait;
	end process;
	
	
end rtb;