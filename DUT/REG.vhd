library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity reg is
generic(size: integer:= 16);
port( 
	  clk : in std_logic;
	  input:in std_logic_vector(size-1 downto 0);
	  ena:in std_logic;
	  output:out std_logic_vector(size-1 downto 0)
);
end reg;
--------------------------------------------------------------
architecture reg_arc of reg is
signal data: std_logic_vector(size-1 downto 0);    -- Writing to register
begin			   
  process(clk)
	begin
		if (clk'event and clk='1') then
			if (ena = '1') then
				data <= input;
			end if;
		end if;
	end process;

output <= data;                                     -- reading from register

end reg_arc;
