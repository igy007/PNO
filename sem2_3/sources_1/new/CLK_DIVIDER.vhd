--
--- CLK DIVIDER for 25MHz Pixel Clock
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity CLK_DIVIDER_25MHz is
port
(
 CLK_IN  : in  STD_LOGIC;
 CLK_OUT : out STD_LOGIC
); 
end CLK_DIVIDER_25MHz;

architecture CLK_DIVIDER_BODY of CLK_DIVIDER_25MHz is

constant DIVIDER : integer := 2;

signal out_signal : STD_LOGIC := '1';    -- this will drive the output of the divider
signal CNT        : integer   :=  1;     -- input clock 

begin


CLK_GEN : process ( CLK_IN, out_signal )
begin

    if ( CLK_IN'event and CLK_IN = '1' ) then
        CNT <= CNT + 1;
        if CNT = DIVIDER then
            out_signal <= not(out_signal);
            CNT <= 1;
        end if;
    end if;

    CLK_OUT <= out_signal;
    
end process;



end CLK_DIVIDER_BODY;
