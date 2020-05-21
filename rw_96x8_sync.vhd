library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.NUMERIC_STD.ALL;
entity rw_96x8_sync is
	port(
		address : in std_logic_vector(7 downto 0);
		clock	: in std_logic;
		write	: in std_logic;
		data_in : in std_logic_vector(7 downto 0);
		data_out: out std_logic_vector(7 downto 0)
	);
end entity;

architecture rw_96x8_sync_arch of rw_96x8_sync is
type rw_type is array (128 to 223) of std_logic_vector(7 downto 0);
signal RW: rw_type;
signal EN: std_logic := '0';

begin

	enable: process(address)
		begin
		if((to_integer(unsigned(address)) >= 128) and (to_integer(unsigned(address)) <= 223)) then
			EN <='1';
		else
			EN<='0';
		end if;
	end process;

	memory : process(clock)
	begin
		if(rising_edge(clock)) then
			if(EN ='1') then
				if(write = '1') then
					RW(to_integer(unsigned(address))) <=data_in;
				else -- if write is 0	
					data_out <= RW(to_integer(unsigned(address)));
				end if;
			end if;
		end if;
	end process;

end architecture; 