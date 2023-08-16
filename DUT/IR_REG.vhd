library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity IR_reg is
generic(IR_size: integer:= 16);
port( 
	  clk : in std_logic;
	  input:in std_logic_vector(IR_size-1 downto 0);
	  IRin:in std_logic;
	  OPC:out std_logic_vector(3 downto 0);
	  ra:out std_logic_vector(3 downto 0);
	  rb:out std_logic_vector(3 downto 0);
	  rc:out std_logic_vector(3 downto 0);
	  immediate1:out std_logic_vector(7 downto 0);
	  immediate2:out std_logic_vector(3 downto 0);
	  offset_addr:out std_logic_vector(4 downto 0)
);
end IR_reg;
--------------------------------------------------------------
architecture IR_reg_arc of IR_reg is
signal IR_data: std_logic_vector(IR_size-1 downto 0);    -- Writing to register
begin			   
  process(clk)
	begin
		if (clk'event and clk='1') then
			if (IRin = '1') then
				IR_data <= input;
			end if;
		end if;
	end process;

OPC <= IR_data(15  downto  12);                                     -- reading from register
ra <= IR_data(11  downto  8);
rb <= IR_data(7  downto  4);
rc <= IR_data(3  downto  0);
immediate1 <= IR_data(7  downto  0);
immediate2 <= IR_data(3  downto  0);
offset_addr <= IR_data(4  downto  0);
end IR_reg_arc;
