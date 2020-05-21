library IEEE;
use IEEE.std_logic_1164.all; 

entity control_unit is
	port(
		clock	: in std_logic; 
		reset	: in std_logic;
		write   : out std_logic;
		
		IR_Load	: out std_logic;
		IR	: in std_logic_vector(7 downto 0);

		MAR_Load: out std_logic; 

		PC_Load	: out std_logic; 
		PC_Inc	: out std_logic;

		A_Load	: out std_logic;
		
		B_Load 	: out std_logic;
		
		ALU_Sel	: out std_logic_vector(2 downto 0);

		CCR_Result: in std_logic_vector(3 downto 0);
		CCR_Load : out std_logic; 

		Bus2_Sel : out std_logic_vector(1 downto 0);
		Bus1_Sel : out std_logic_vector(1 downto 0)
		
	);
end entity;


architecture control_unit_arch of control_unit is 
constant LDA_IMM	: std_logic_vector(7 downto 0):= x"86";
constant LDA_DIR	: std_logic_vector(7 downto 0):= x"87";
constant STA_DIR	: std_logic_vector(7 downto 0):= x"96";
constant BRA		: std_logic_vector(7 downto 0):= x"20";

type state_type is (
		S_FETCH_0, S_FETCH_1, S_FETCH_2,
		S_DECODE_3,
		S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6,
		S_LDA_DIR_4, S_LDA_DIR_5, S_LDA_DIR_6, S_LDA_DIR_7, S_LDA_DIR_8,
		S_STA_DIR_4, S_STA_DIR_5, S_STA_DIR_6, S_STA_DIR_7,
		S_BRA_4, S_BRA_5, S_BRA_6 
		);

signal current_state, next_state : state_type;

begin 
	state_memory : process(clock,reset)
	begin
		if(reset = '0') then
			current_state <= S_FETCH_0;
		elsif(rising_edge(clock)) then
			current_state <= next_state;
		end if;
	end process;

	next_state_logic : process(current_state,IR,CCR_Result)
	begin
		if(current_state = S_FETCH_0)then
			next_state <= S_FETCH_1;
		elsif(current_state = S_FETCH_1)then
			next_state <= S_FETCH_2;
		elsif(current_state = S_FETCH_2)then
			next_state <= S_DECODE_3;
		elsif(current_state = S_DECODE_3)then
-- Instruction set branch off of decode. --------------------------
			if(IR = LDA_IMM)then
				next_state <= S_LDA_IMM_4;
			elsif(IR = LDA_DIR)then
				next_state <= S_LDA_DIR_4;
			elsif(IR = STA_DIR)then
				next_state <= S_STA_DIR_4;
			elsif(IR = BRA)then
				next_state <= S_BRA_4;
			else
				next_state <= S_FETCH_0;
			end if;

		elsif(current_state <= S_LDA_IMM_4) then --Load_IMM
			next_state <= S_LDA_IMM_5;
		elsif(current_state <= S_LDA_IMM_5) then
			next_state <= S_LDA_IMM_6;
		elsif(current_state <= S_LDA_IMM_6) then
			next_state <= S_FETCH_0;


		elsif(current_state <= S_LDA_DIR_4) then --Load_DIR
			next_state <= S_LDA_DIR_5;
		elsif(current_state <= S_LDA_DIR_5) then
			next_state <= S_LDA_DIR_6;
		elsif(current_state <= S_LDA_DIR_6) then
			next_state <= S_LDA_DIR_7;
		elsif(current_state <= S_LDA_DIR_7) then
			next_state <= S_LDA_DIR_8;
		elsif(current_state <= S_LDA_DIR_8) then
			next_state <= S_FETCH_0;

		elsif(current_state <= S_STA_DIR_4) then --STA_DIR
			next_state <= S_STA_DIR_5;
		elsif(current_state <= S_STA_DIR_5) then
			next_state <= S_STA_DIR_6;
		elsif(current_state <= S_STA_DIR_6) then
			next_state <= S_STA_DIR_7;
		elsif(current_state <= S_STA_DIR_7) then
			next_state <= S_FETCH_0;


		elsif(current_state <= S_BRA_4) then --BRA
			next_state <= S_BRA_5;
		elsif(current_state <= S_BRA_5) then
			next_state <= S_BRA_6;
		elsif(current_state <= S_BRA_6) then
			next_state <= S_FETCH_0;

		end if;
	end process;

	output_logic: process(current_state)
	begin
		case(current_state) is
			when S_FETCH_0 => -- Put PC onto MAR to provide address of Opcode
				IR_Load 	<= '0';
				MAR_Load 	<= '1';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "01"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_FETCH_1 => --Inc PC, Opcode comes next state.
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '1';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "00"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_FETCH_2 => --Put Opcode into IR.
				IR_Load 	<= '1';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "10"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_DECODE_3 => -- No outputs just finding which command to run.
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "00"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
-- ----------------------------------------------------------------------------------------------------------
--		LDA_IMM
--------------------------------------------------------------------------------------------------------------
			when S_LDA_IMM_4 => -- Put PC on MAR
				IR_Load 	<= '0';
				MAR_Load 	<= '1';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "01"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_LDA_IMM_5 => -- Inc PC
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '1';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "00"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_LDA_IMM_6 => --Load into A from memory.
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '1';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "10"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
-- ----------------------------------------------------------------------------------------------------------
--		LDA_DIR
--------------------------------------------------------------------------------------------------------------
			when S_LDA_DIR_4 => -- 
				IR_Load 	<= '0';
				MAR_Load 	<= '1';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "01"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_LDA_DIR_5 => -- INC PC
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '1';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "00"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_LDA_DIR_6 => -- Read from memory
				IR_Load 	<= '0';
				MAR_Load 	<= '1';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "10"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_LDA_DIR_7 => -- Give time to get from memory
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "00"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_LDA_DIR_8 => -- Put the contents into A on next state.
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '1';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "10"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
-- ----------------------------------------------------------------------------------------------------------
--		STA_DIR
--------------------------------------------------------------------------------------------------------------
			when S_STA_DIR_4 => --
				IR_Load 	<= '0';
				MAR_Load 	<= '1';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "01"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_STA_DIR_5 => -- PC Inc
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '1';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "00"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_STA_DIR_6 => -- operand brought in
				IR_Load 	<= '0';
				MAR_Load 	<= '1';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "10"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_STA_DIR_7 => -- Put A into memory at address
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "01"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "00"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '1';
-- ----------------------------------------------------------------------------------------------------------
--		BRA
--------------------------------------------------------------------------------------------------------------
			when S_BRA_4 => --
				IR_Load 	<= '0';
				MAR_Load 	<= '1';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "01"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_BRA_5 => -- Wait one cycle.
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "00"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
			when S_BRA_6 => -- 
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '1';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "10"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
----------------------------------------------------------------------------------------------------------------
--		Others
-----------------------------------------------------------------------------------------------------------------
			when others => --when anything else
				IR_Load 	<= '0';
				MAR_Load 	<= '0';
				PC_Load 	<= '0';
				PC_Inc 		<= '0';
				A_Load 		<= '0';
				B_Load 		<= '0';
				ALU_Sel		<= "000";
				CCR_Load	<= '0';
				Bus1_Sel 	<= "00"; -- "00"=PC, 	"01"=A,		"10"=B
				Bus2_Sel 	<= "00"; -- "00"=ALU, 	"01"=Bus1,	"10"=from_memory
				write 		<= '0';
		end case;
	end process;
end architecture; 