library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--use ieee.numeric_std.all;
USE work.ALU_aux_package.all;
--------------------------------------------------------------

entity Datapath is
	generic(n: integer:= BUSwidth; 
			m: integer:= 4;  -- k=log2(n)
			k: integer:= 8 -- m=2^(k-1)
			);
	port ( 
	control:in std_logic_vector(control_vec_size-1 downto 0);
	rst, clk: in std_logic;
	dataIn_tb: in std_logic_vector( dataIn_tb_size-1 downto 0);  --tb vector
	status: out std_logic_vector(status_vec_size -1 downto 0);
	dataOut_tb: out std_logic_vector( n-1 downto 0)  --tb vector
	);
	end Datapath;

architecture Datapath_arch of Datapath is
	--constant sub : integer := 6;
	signal bus_sig,from_DMEM_vec, to_DMEM_vec, imm1_sign_extend, DMEM_WAddr_inner: std_logic_vector(n - 1 downto 0);
	signal imm2_sign_extend, RF_out_vec, RF_in_vec: std_logic_vector(n - 1 downto 0);
	signal A_out_vec, ALU_out_vec, C_out_vec, PMEM_out_data: std_logic_vector(n - 1 downto 0);
	signal Pmem_dataIn, Dmem_dataIn: std_logic_vector(n - 1 downto 0);
	signal PMEM_Write_adress, DMEM_Write_adress, DMEM_read_adress: std_logic_vector(Awidth - 1 downto 0);
	signal Cflag_sig, Nflag_sig, Zflag_sig, wren_p, wren_d: std_logic;
	signal opc, IR_opc, IR_ra, IR_rb, IR_rc, IR_imm2, W_R_regAddr: std_logic_vector(ARegwidth - 1 downto 0);
	signal ALUFN, IR_offset_addr: std_logic_vector(4 downto 0);
	signal PC_in_vec, PC_out_vec: std_logic_vector(Awidth - 1 downto 0);
	signal IR_imm1: std_logic_vector(7 downto 0);
	begin
	----------------------COMPONENTS CONNECTIONS-------------------------------------------------------------------------
	    ---Writing connections to BUS ---
		Immediate1_conn : BidirPin generic map (n) port map(imm1_sign_extend, control(imm1_in), open, bus_sig);
		Immediate2_conn : BidirPin generic map (n) port map(imm2_sign_extend, control(imm2_in), open, bus_sig);
		RF_out_conn: BidirPin generic map (n) port map(RF_out_vec, control(RFout), bus_sig);
		Data_MEM_out_conn: BidirPin generic map (n) port map(from_DMEM_vec, control(Mem_out),to_DMEM_vec , bus_sig);
		C_out_conn: BidirPin generic map (n) port map(C_out_vec, control(Cout), open, bus_sig);
		
		---ALU connections---
		A_reg: reg generic map(n) port map (clk, bus_sig, control(Ain), A_out_vec);  -- reg A reads from BUS
		C_reg: reg generic map(n) port map (clk, ALU_out_vec, control(Cin), C_out_vec);
		ALU_conn: ALU generic map(n,m,k) port map(A_out_vec, bus_sig, ALUFN, ALU_out_vec, Nflag_sig, Cflag_sig, Zflag_sig);
		
		---Register File connections---
		RF_conn: RF generic map(n,m) port map (clk, rst, control(RFin),bus_sig , W_R_regAddr, W_R_regAddr, RF_out_vec);
		
		---IR connections ---
		IR_reg_conn: IR_reg generic map(n) port map (clk,PMEM_out_data, control(IRin),IR_opc, IR_ra, IR_rb, IR_rc, IR_imm1, IR_imm2, IR_offset_addr );
		
		--- PC connections --- 
		 PC_reg_conn: PC_reg generic map(Awidth) port map (rst, clk, PC_in_vec, control(PCin), PC_out_vec);
		
		---Program memory connections---
		PMEM_conn: ProgMem generic map (n,Awidth,dept) port map (clk, wren_p, Pmem_dataIn, PMEM_Write_adress, PC_out_vec, PMEM_out_data  );
		
		---Data memory connections ---
		DMEM_conn: dataMem generic map(n,Awidth,dept) port map (clk, wren_d, Dmem_dataIn ,DMEM_Write_adress, DMEM_read_adress, from_DMEM_vec );
		dataIN_reg: reg generic map(n) port map (clk, bus_sig, control(Mem_in), DMEM_WAddr_inner); 
		
		
	
	--------------------------LOGIC CONNECTIONS------------------------------------------------------------------------------------------------------------------------------------------------------
		
		------sign extensions for immidiates ----
		imm1_sign_extend(7 downto 0) <=IR_imm1;
		sign_extend1: for i in n -1 downto 8 generate
			imm1_sign_extend(i) <= IR_imm1(7);
			end generate;
	
		imm2_sign_extend(3 downto 0) <=IR_imm2;           --- We regard Immidiate2 as unsigned - for Data memory's address space
		sign_extend2: for i in n -1 downto 4 generate
			imm2_sign_extend(i) <= '0';
			end generate;
		
		
		---- ALU adaption ---
		with control(OPC_3 downto OPC_0) select
		ALUFN <= "01001" when "0001",    --- for sub
				 "01000" when others;  --- for add (default)
				 
		---Ra, Rb, Rc----
		with control(RFaddr_1 downto RFaddr_0) select
		W_R_regAddr <= IR_ra when "00",
					IR_rb when "01",
					IR_rc when "10",
					unaffected when others; 
		
		---PC MUX ------
		with control(PCsel_1 downto PCsel_0) select
		PC_in_vec <= conv_std_logic_vector(((conv_integer(unsigned(PC_out_vec)) + 1)), Awidth ) when "00",
					conv_std_logic_vector(((conv_integer(unsigned(PC_out_vec))+ conv_integer(signed(IR_offset_addr))+ 1)), Awidth) when "01",
					(others => '0') when "10",
					unaffected when others;
		
						
		----Decoding OPCCODE----						
		with IR_opc select
		  status(jn downto st) <= (add => '1',others => '0') when "0000", -- constant add :=5
					(subb => '1',others => '0') when "0001", -- constant sub=6
					(nop => '1',others => '0') when "0010", -- constant nop :=10
					(jmp => '1',others => '0') when "0100", -- constant jmp := 7
					(jc => '1',others => '0') when "0101", -- constant jc := 8
					(jnc => '1',others => '0') when "0110", -- constant jnc := 9
					(mov => '1',others => '0') when "1000", -- constant mov := 12
					(ld => '1',others => '0') when "1001", -- constant ld := 4
					(st => '1',others => '0') when "1010", -- constant st :=3
					(jn => '1',others => '0') when "0111", -- constant jn :=13
					(done => '1',others => '0') when "1011", -- constant done :=11
					unaffected when others;

	
	 with control(Cin) select
		status(Cflag)<= Cflag_sig when '1', -- flags should change only when we want to load C register
		unaffected when others;
	
	 with control(Cin) select
		status(Zflag)<= Zflag_sig when '1', -- flags should change only when we want to load C register
		unaffected when others;
	 
	 with control(Cin) select
		status(Nflag)<= Nflag_sig when '1', -- flags should change only when we want to load C register
		unaffected when others;
	
	

----Pmem test bench ---	
	wren_p <= dataIn_tb(tb_Pwena);
	Pmem_dataIn <= dataIn_tb(tb_PdataIN_msb downto tb_PdataIN_0);
	PMEM_Write_adress <= dataIn_tb(tb_Pwriteaddr_msb downto tb_Pwriteaddr_0);

---Dmem test bench/bus select---
    with dataIn_tb(TBactive) select
			wren_d <= 	control(Mem_wr) when '0',
						dataIn_tb(tb_DWena) when '1',
						unaffected when others;
			
	with dataIn_tb(TBactive) select		
			Dmem_dataIn <= bus_sig when '0',
						dataIn_tb(tb_DdataIN_msb downto tb_DdataIN_0) when '1',
						unaffected when others;
			
	with dataIn_tb(TBactive) select		
			DMEM_Write_adress <= DMEM_WAddr_inner(Awidth -1 downto 0) when '0',      --DMEM_WAddr_inner is the buffer register's output
						dataIn_tb(tb_Dwriteaddr_msb downto tb_Dwriteaddr_0) when '1',
						unaffected when others;
	
	with dataIn_tb(TBactive) select		
			DMEM_read_adress <= bus_sig(Awidth -1 downto 0) when '0',
						dataIn_tb(tb_Dreadaddr_msb downto tb_Dreadaddr_0) when '1',
						unaffected when others;	
		
	
	dataOut_tb <= from_DMEM_vec; --- Data memory read to tb
	
	end Datapath_arch;
    