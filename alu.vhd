library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.NUMERIC_STD.ALL;
entity alu is 
	port(
		A,B	: in std_logic_vector(7 downto 0);
		ALU_Sel	: in std_logic_vector(2 downto 0);
		NZVC	: out std_logic_vector(3 downto 0);
		ALU_Result	: out std_logic_vector(7 downto 0) := "00000000"
	);
end entity;

architecture alu_arch of alu is 

begin

	ALU_Process: process(A,B,ALU_Sel)
	begin
		ALU_Result <= "00000000";		
	end process;
end architecture; 