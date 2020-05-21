library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.NUMERIC_STD.ALL; 
entity rom_128x8_sync is
	port(
		address : in std_logic_vector(7 downto 0);
		clock	: in std_logic;
		data_out: out std_logic_vector(7 downto 0)
	);
end entity;

architecture rom_128x8_sync_arch of rom_128x8_sync is
constant LDA_IMM	: std_logic_vector(7 downto 0):= x"86";
constant LDA_DIR	: std_logic_vector(7 downto 0):= x"87";
constant STA_DIR	: std_logic_vector(7 downto 0):= x"96";
constant BRA		: std_logic_vector(7 downto 0):= x"20";

type rom_type is array(0 to 127) of std_logic_vector(7 downto 0);
constant ROM: rom_type :=  (
			0 => LDA_IMM,
			1 => x"AA",
			2 => LDA_DIR,
			3 => x"F0",
			4 => STA_DIR,
			5 => x"E0",
			6 => BRA,
			7 => x"00",
			others => x"00"
			);
signal EN : std_logic := '0';
begin
	enable: process(address)
		begin
		if((to_integer(unsigned(address)) >= 0) and (to_integer(unsigned(address)) <= 127)) then
			EN <='1';
		else
			EN<='0';
		end if;
	end process;

	memory : process(clock)
	begin
		if(rising_edge(clock)) then
			if(EN ='1') then
				data_out <= ROM(to_integer(unsigned(address)));
			end if;
		end if;
	end process;

end architecture; 