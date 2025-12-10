-- Christian Okyere

-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timerExtension is

	port(
		clk		 : in	std_logic;
		reset	 : in	std_logic;
		start	 : in	std_logic;
		react	 : in	std_logic;
		mstime	 : out	std_logic_vector(7 downto 0);
		randomDisplay : out	std_logic_vector(3 downto 0);
		threegreens : out	std_logic_vector(2 downto 0)
	);

end entity;

architecture rtl of timerExtension is

	-- Build an enumerated type for the state machine
	type state_type is (sIdle, sWait, sCount);

	-- Register to hold the current state
	signal state   : state_type;
	signal count   : unsigned (27 downto 0);
	signal randomtime : unsigned(3 downto 0) := (others => '1');

begin

	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '0' then
			randomtime <= (others => '1');
			count <= (others => '0');
			state <= sIdle;		
		elsif (rising_edge(clk)) then
			if start = '0' then
				randomtime <= randomtime(2 downto 0) & (randomtime(3) xor randomtime(2));
			end if;		
			case state is
				when sIdle=>
					if start = '0' then
						state <= sWait;
						count <= (others => '0');
					else
						state <= sIdle;
					end if;			
				when sWait=>
					if count(27 downto 24) = randomtime then
						state <= sCount;
						count <= (others => '0');
					elsif react = '0' then
						count <= (others => '1');
						state <= sIdle;
					else
						count <= count + "1";
					end if;
				when sCount=>
					if react = '0' then
						state <= sIdle;
					else
						count <= count + "1";
					end if;		
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	
	process (state)
	begin
		case state is
			when sIdle =>
				threegreens <= "001";
				mstime <= std_logic_vector(count(27 downto 20));
				randomDisplay <= std_logic_vector(randomtime(3 downto 0));	
			when sWait =>
				threegreens <= "010";
				mstime <= "00000000";
			when sCount =>
				threegreens <= "100";
				mstime <= std_logic_vector(count(27 downto 20));
				randomDisplay <= std_logic_vector(randomtime(3 downto 0));	
		end case;
	end process;

end rtl;