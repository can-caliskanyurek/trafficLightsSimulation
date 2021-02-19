library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trafficLightsTB is
    end trafficLightsTB;

architecture arch of trafficLightsTB is
    -- we're slowing down the clock to speed up simulation time --
    constant clockFrequency : integer := 100; -- 100 Hz
    constant clockPeriod    : time    := 1000 ms/ clockFrequency;
    constant dataWidth      : integer := 6;

    signal clk         : std_logic := '1';
    signal nRst        : std_logic := '0';
    signal vLights     : std_logic_vector(0 to dataWidth-1);

    begin
        -- the device under test (DUT) --
        i_TrafficLights : entity work.trafficLights(rtl)
        generic map(clockFrequency => clockFrequency,
                    dataWidth      => dataWidth)
        port map(
            clk     => clk,
            nRst    => nRst,
            vLights => vLights
        );

        -- process for generating the clock --
        clk <= not clk after clockPeriod / 2;

        -- testbench sequence --
        process is
            begin
                wait until rising_edge(clk);
                wait until rising_edge(clk);

                -- take the DUT out of reset --
                nRst <= '1';

                wait;
            end process;
    end architecture;