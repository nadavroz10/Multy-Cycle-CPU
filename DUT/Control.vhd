LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;
-----------------------------------------------------
ENTITY Control IS
	PORT ( 	ena, clk, rst: IN STD_LOGIC;
			status: in std_logic_vector(status_vec_size-1 downto 0);
			Control: out std_logic_vector(control_vec_size-1 downto 0);
			done_out: OUT STD_LOGIC);
END Control;
-----------------------------------------------------
ARCHITECTURE state_machine OF Control IS
	
	
	TYPE state IS (state0, state1, state2, state3, state4, state6, state7, state8, state9, state10, state11, state12, state13);
	SIGNAL pr_state, nx_state: state;
	SIGNAL temp: std_logic_vector(control_vec_size-1 downto 0);
BEGIN
---------- Lower section: ------------------------
  PROCESS (rst, clk)
  BEGIN
	IF (rst='1') THEN
		pr_state <= state13;     -- RESET
		
	ELSIF (clk'EVENT AND clk='1') THEN
		if(ena = '1') then
			Control <= temp;
			pr_state <= nx_state;
		END IF;
	END IF;
  END PROCESS;
---------- Upper section: ------------------------
  PROCESS (pr_state, status)
  BEGIN
	CASE pr_state IS
		WHEN state0 =>
				nx_state <= state1;
				temp(RFaddr_1 downto RFaddr_0) <= "01";
				temp(RFout) <= '1';
				temp(RFin) <= '0';
				temp(Cout) <= '0';
				temp(Ain) <= '1';
				temp(Mem_out) <= '0';
				temp(Imm1_in) <= '0';
				temp(Imm2_in) <= '0';
				temp(IRin) <= '0';
				temp(PCin) <= '0';
		WHEN state1 =>
			if((status(jmp)='1') or (status(jc)='1') or (status(jnc)='1') or (status(jn)='1')) then --jmp
				if ((status(jmp)='1') or ((status(jc)='1') and (status(Cflag)='1')) or ((status(jnc)='1') and (not status(Cflag)='1')) or ((status(jn)='1') and (status(Nflag)='1'))) then -- jump succeeded
					nx_state <= state2;
					temp(PCin)<='1';
					temp(PCsel_1 downto PCsel_0)<= "01";
					temp(RFaddr_1 downto RFaddr_0) <= "00";
					temp(RFout) <= '0';
					temp(Ain) <= '0';
					temp(Cin)<= '0';
			    else  ---elsif (((status(jc)='1') and (status(Cflag)='0')) or ((status(jnc)='1') and (not status(Cflag)='0'))) then--jump didnt succeeded
					nx_state <= state3;
					temp(PCin)<='1';
					temp(Cin)<= '0';
					temp(PCsel_1 downto PCsel_0)<= "00";
					temp(RFaddr_1 downto RFaddr_0) <= "00";
					temp(RFout) <= '0';
					temp(Ain) <= '0';
				end if;
				elsif(status(mov)='1')	THEN
					temp(Imm1_in) <= '1';
					temp(Imm2_in) <= '0';
					temp(RFin)<='1';
					temp(RFaddr_1 downto RFaddr_0) <= "00";
					temp(RFout) <= '0';
					temp(Ain) <= '0';
					temp(Mem_out)<='0';
					temp(cout)<='0';
					temp(PCin)<='1';
					temp(PCsel_1 downto PCsel_0)<= "00";
					nx_state <= state4;
				elsif((status(ld)='1') or (status(st)='1')) THEN  -- ld or st
					nx_state <= state6;
					temp(OPC_3 downto OPC_0)<= "0000";
					temp(Cin)<= '1';
					temp(Imm2_in) <= '1';
					temp(Cout) <= '0';
					temp(Imm1_in) <= '0';
					temp(RFout) <= '0';
					temp(Mem_out) <= '0';
					temp(Ain) <= '0';
					temp(IRin)<='0';
					temp(PCin)<='0';
				elsif ((status(add)='1') or (status(subb)='1') or (status(nop)='1')) then -- Rtype
					temp(RFaddr_1 downto RFaddr_0) <= "10"; --reg c out
					temp(RFout) <= '1';
					temp(RFin) <= '0';
					temp(Cout) <= '0';
					temp(Ain) <= '0';
					temp(Imm1_in) <= '0';
					temp(Imm2_in) <= '0';
					temp(Cin)<= '1';
					temp(Mem_out)<='0';
					temp(PCin)<='0';
					if(status(subb)='1') THEN --sub
						nx_state <= state7;
						temp(OPC_3 downto OPC_0)<= "0001";
					elsif((status(add)='1') or (status(nop)='1')) then --add or nop
						nx_state <= state8;
						temp(OPC_3 downto OPC_0)<= "0000";
						
					end if;
			END IF;
		WHEN state2 =>
			nx_state <= state0;
			temp <= (IRin=> '1', others=>'0');
		WHEN state3 =>
			nx_state <= state0;
			temp <= (IRin=> '1', others=>'0');
		WHEN state4 =>
			nx_state <= state0;
			temp <= (IRin=> '1', others=>'0');
		WHEN state6 =>
			temp(RFout)<='0';
			temp(Mem_out)<='0';
			temp(Imm2_in)<='0';
			temp(PCin)<='0';
			temp(RFaddr_1 downto RFaddr_0)<="00";
			if (status(ld)='1') then -- ld
				nx_state <= state10;
				temp(Cout) <= '1';
				temp(Imm1_in) <= '0';
				temp(RFout) <= '0';
				temp(Mem_out) <= '0';
				temp(Ain) <= '0';
				temp(IRin)<='0';
				temp(Cin) <= '0';
				temp(OPC_3 downto OPC_0)<= "0000";
			elsif  (status(st)='1') then -- st
				nx_state <= state11;
				temp(Imm2_in) <= '0';
				temp(Cout) <= '1';
				temp(Imm1_in) <= '0';
				temp(RFout) <= '0';
				temp(Mem_out) <= '0';
				temp(Ain) <= '0';
				temp(IRin)<='0';
				temp(Cin) <= '0';
				temp(Mem_in) <= '1';
				temp(OPC_3 downto OPC_0)<= "0000";
			end if;	
		WHEN state7 =>
			nx_state <= state9;
			temp(Cin)<= '0';
			temp(Cout)<= '1';
			temp(OPC_3 downto OPC_0)<= "0000";
			temp(RFin)<='1';
			temp(RFout)<='0';
			temp(Mem_out)<='0';
			temp(Imm2_in)<='0';
			temp(PCin)<='1';
			temp(RFaddr_1 downto RFaddr_0) <= "00";
			temp(PCsel_1 downto PCsel_0)<= "00";
		WHEN state8 =>
			nx_state <= state9;
			temp(RFaddr_1 downto RFaddr_0) <= "00";
			temp(RFout) <= '0';
			temp(RFin) <= '1';
			temp(Cin) <= '0';
			temp(Cout) <= '1';
			temp(Ain) <= '0';
			temp(Imm1_in) <= '0';
			temp(Imm2_in) <= '0';
			temp(PCin)<='1';
			temp(PCsel_1 downto PCsel_0)<= "00";
		WHEN state9 =>
			nx_state <= state0;
			temp <= (IRin=> '1', others=>'0');
		WHEN state10 =>
			nx_state <= state12;
			temp(Mem_out)<='1';
			temp(cout)<='0';
			temp(Imm1_in)<='0';
			temp(Imm2_in)<='0';
			temp(RFin)<='1';
			temp(RFaddr_1 downto RFaddr_0)<="00";
			temp(PCin)<='1';
			temp(PCsel_1 downto PCsel_0)<= "00";
		WHEN state11 =>
			nx_state <= state13;
			temp(Cout)<='0';
			temp(RFout)<='1';
			temp(Mem_wr)<='1';
			temp(PCin)<='1';
			temp(Mem_in)<='0';
			temp(PCsel_1 downto PCsel_0)<= "00";
		WHEN state12 =>
			nx_state <= state0;
			temp <= (IRin=> '1', others=>'0');
		WHEN state13 =>
			nx_state <= state0;
			temp <= (IRin=> '1', others=>'0');
		
		--WHEN rst_state =>    -- Reset PSAUDO state (not part of the FSM)
			--nx_state <= state0;
			--temp <= (IRin=> '1', others=>'0');
			--temp(PCsel_1 downto PCsel_0)<= "10";      --"0...0" to PC
			
	END CASE;
  END PROCESS;
  
  
  done_out <= status(done); -- done
  
END state_machine;


