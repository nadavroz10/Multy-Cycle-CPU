library IEEE;
use ieee.std_logic_1164.all;

package aux_package is
---constants---
	
	--status--
	constant jn : integer := 13;
	constant mov : integer := 12;
	constant done : integer := 11;
	constant nop : integer := 10;
	constant jnc: integer := 9;
	constant jc : integer := 8;
	constant jmp : integer := 7;
	constant subb : integer := 6;
	constant add : integer := 5;
	constant ld : integer := 4;
	constant st : integer := 3;
	constant Nflag : integer := 2;
	constant Zflag : integer := 1;
	constant Cflag : integer := 0;

	--control--
	constant Mem_wr : integer := 19;
	constant Mem_out : integer := 18;
	constant Mem_in : integer := 17;
	constant Cout : integer := 16;
	constant Cin : integer := 15;
	constant OPC_3 : integer := 14; --not sync with OPC_len
	constant OPC_0 : integer := 11;
	constant Ain : integer := 10;
	constant RFin: integer := 9;
	constant RFout : integer := 8;
	constant RFaddr_1 : integer := 7;
	constant RFaddr_0 : integer := 6;
	constant IRin : integer := 5;
	constant PCin : integer := 4;
	constant PCsel_1 : integer := 3;
	constant PCsel_0 : integer := 2;
	constant Imm1_in : integer := 1;
	constant Imm2_in : integer := 0;
	
	--tb--
	constant tb_PdataIN_msb : integer := 52;    --- not synchronized with n
	constant tb_PdataIN_0 : integer := 37;
	constant tb_Pwriteaddr_msb : integer := 36;
	constant tb_Pwriteaddr_0 : integer := 31;
	constant tb_Pwena : integer := 30;
	constant tb_DdataIN_msb : integer := 29;    --- not synchronized with n
	constant tb_DdataIN_0 : integer := 14;
	constant tb_Dreadaddr_msb : integer := 13;
	constant tb_Dreadaddr_0 : integer := 8;
	constant tb_Dwriteaddr_msb : integer := 7;
	constant tb_Dwriteaddr_0 : integer := 2;
	constant tb_Dwena : integer := 1;
	constant TBactive : integer := 0;
	
	--general--
	constant BUSwidth: integer:=16;    --- BUS WIDTH (N)
	constant ARegwidth: integer:=4;    --- REGISTERS ADDRESS WIDTH
	constant Awidth: integer:=6;    --- MEMORY ADDRESS WIDTH
	constant dept:   integer:=64;
	constant dataIn_tb_size:integer := 53;  -- size of tb data in vector 
	constant control_vec_size: integer:=20;
	constant status_vec_size: integer:= 14;
	constant opc_size: integer := 4;
-------------------components-------------------------------------------------------
component top is  					-- top entity (DUT)
	generic(n: integer:= 16; 
			m: integer:= 4;  -- k=log2(n)
			k: integer:= 8  -- m=2^(k-1)
			);
	PORT ( 	ena, clk, rst: IN STD_LOGIC;
			dataIn_tb: in std_logic_vector( dataIn_tb_size-1 downto 0);
			done_out: OUT STD_LOGIC;
			dataOut_tb: out std_logic_vector( n-1 downto 0)
			);
	
	END component;
------------------------------------------------
component Control IS    			--control
	PORT ( 	ena, clk, rst: IN STD_LOGIC;
			status: in std_logic_vector(status_vec_size-1 downto 0);
			Control: out std_logic_vector(control_vec_size-1 downto 0);
			done_out: OUT STD_LOGIC);
end component;
------------------------------------------------
component Datapath is				-- dataPath
	generic(n: integer:= 16; 
			m: integer:= 4;  -- k=log2(n)
			k: integer:= 8  -- m=2^(k-1)
			);
	port ( 
	control:in std_logic_vector(control_vec_size-1 downto 0);
	rst, clk: in std_logic;
	dataIn_tb: in std_logic_vector( dataIn_tb_size-1 downto 0);  --tb vector
	status: out std_logic_vector(status_vec_size -1 downto 0);
	dataOut_tb: out std_logic_vector( n-1 downto 0)  --tb vector
	);
	end component;
------------------------------------------------
component BidirPin is                        --- BUS port
	generic( width: integer:=16 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
end component;

-------------------------------------------------
component reg is							--- Register
generic(size: integer:= 16);
port( 
	  clk : in std_logic;
	  input:in std_logic_vector(size-1 downto 0);
	  ena:in std_logic;
	  output:out std_logic_vector(size-1 downto 0)
);
end component;

--------------------------------------------------
component IR_reg is							---IR Register
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
end component;
--------------------------------------------
component RF is							---Register File
	generic( Dwidth: integer:=16;
		 Awidth: integer:=4);
	port(clk,rst,WregEn: in std_logic;	
		WregData:	in std_logic_vector(Dwidth-1 downto 0);
		WregAddr,RregAddr:	
					in std_logic_vector(Awidth-1 downto 0);
		RregData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
-----------------------------------------
component ProgMem is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64);
port(	clk,memEn: in std_logic;	
		WmemData:	in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr:	
					in std_logic_vector(Awidth-1 downto 0);
		RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
-----------------------------------------
component dataMem is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64);
port(	clk,memEn: in std_logic;	
		WmemData:	in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr:	
					in std_logic_vector(Awidth-1 downto 0);
		RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
----------------------------------------
component PC_reg is
generic(size: integer:= 16);
port( 
	  rst, clk : in std_logic;
	  input:in std_logic_vector(size-1 downto 0);
	  ena:in std_logic;
	  output:out std_logic_vector(size-1 downto 0)
);
end component;

end aux_package;