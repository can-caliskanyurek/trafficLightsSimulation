-- Traffic Lights -- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trafficLights is
    generic(clockFrequency : integer;
            dataWidth      : integer);
    port(
        clk         : in std_logic;
        nRst        : in std_logic;
        vLights     : out std_logic_vector(dataWidth-1 downto 0)
    );
    end trafficLights;

architecture rtl of trafficLights is
    type t_State is (northNext, startNorth, north, stopNorth,
                     westNext,  startWest,  west,  stopWest);

    signal state : t_State;

    signal counter : integer range 0 to clockFrequency * 60;

    begin
        process(clk) is
            procedure updateState(newState : t_State;
                                  minutes  : integer := 0;
                                  seconds  : integer := 0) is
                variable totalSeconds : integer;
                variable clockCycles  : integer;

                begin
                    totalSeconds := seconds + minutes * 60;
                    clockCycles  := totalSeconds * clockFrequency - 1;

                    if counter = clockCycles then
                        counter <= 0;
                        state   <= newState;
                    end if ;
                end procedure;

            begin
                -- if the negative reset signal is active --
                if rising_edge(clk) then
                    if nRst = '0' then
                        -- reset values --
                        state   <= northNext;
                        counter <= 0;

                        vLights <= (others => '0');
                        vLights(0) <= '1'; -- ns red
                        vLights(3) <= '1'; -- we red
                    else
                        vLights <= (others => '0');

                        counter <= counter + 1;

                        case state is
                            -- red in all directions --
                            when northNext =>
                                vLights(0) <= '1';
                                vLights(3) <= '1';
                                updateState(startNorth, seconds => 30);

                            -- red and yellow in north/south direction --
                            when startNorth =>
                                vLights(0) <= '1';
                                vLights(1) <= '1';
                                vLights(3) <= '1';
                                updateState(north, seconds => 5);
                                
                            -- green in north/south direction --
                            when north =>
                                vLights(2) <= '1';
                                vLights(3) <= '1';
                                updateState(stopNorth, minutes => 1);

                            -- red in all directions --
                            when stopNorth =>
                                vLights(0) <= '1';
                                vLights(3) <= '1';
                                updateState(westNext, seconds => 30);

                            -- red in all directions --
                            when westNext =>
                                vLights(0) <= '1';
                                vLights(3) <= '1';
                                updateState(startWest, seconds => 30);

                            -- red and yellow in west/east direction --
                            when startWest =>
                                vLights(0) <= '1';
                                vLights(3) <= '1';
                                vLights(4) <= '1';
                                updateState(west, seconds => 5);

                            -- green in west/east direction --
                            when west =>
                                vLights(0) <= '1';
                                vLights(5) <= '1';
                                updateState(stopWest, minutes => 1);

                            -- red in all directions --
                            when stopWest =>
                                vLights(0) <= '1';
                                vLights(3) <= '1';
                                updateState(northNext, seconds => 30);
                        end case;
                    end if ;
                end if ;
            end process;
    end architecture;