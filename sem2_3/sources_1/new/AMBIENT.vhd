----------------------------------------------------------------------------------
-- Company:  CTU in Prague, Faculty of Information Technology
-- Engineer: Jakub Zahradnik
-- 
-- Description: Model for pmod ambient light sensor (ALS)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity AMBIENT is
   port (
      CS     : out std_logic;                       -- SPI chip select
      SDO    : in  std_logic;                       -- SPI data MISO kanál
      SCK    : out std_logic;                       -- SPI clock
      Y      : out std_logic_vector (7 downto 0);   -- hodnota vyctena ze snimace
      CLK    : in  std_logic;                       -- 100 MHz
      RESET  : in  std_logic                        -- reset
   );
end AMBIENT;


architecture AMBIENT_BODY of AMBIENT is

-- pocet hodinovych taktu pro odpojeni signalu CS po predchozi transakci
constant CS_INACTIVE_CLKS                : integer      := 100;
-- pocet hodinovych taktu potrebnych pro preklopeni hodin z log 0 do log 1 a naopak 
constant CLK_TICKS_FOR_ONE_HALF_SCK_TICK : integer      := 49;      -- (POCET_TAKTU_CLK_PRO_PERIODU_SCK / 2) - 1
-- pocet preklopeni log 0 a log 1 pro cteni ze sensoru
constant SCK_CLOCK_CYCLES                : integer      := 32;      -- (POCET_PERIOD_SCK * 2) - 1

-- pomocne signaly
signal CLK_CNT              : unsigned(6 downto 0)      := (others => '0');
signal PULSE_CNT            : unsigned(5 downto 0)      := (others => '0');
signal DATA                 : unsigned(15 downto 0)     := (others => '0');
signal VALUE                : std_logic                 := '1';
signal CS_ACTIVE            : std_logic                 := '0';

begin

    CS <= not(CS_ACTIVE);
    SCK <= VALUE;
    
    -- proces generujici hodiny SCK (1 MHz) pomoci counteru, nastavujici CS na stav pripojeno/odpojeno
    TIMING : process (CLK)
    begin
        if CLK'event and CLK = '1' then
            if RESET = '1' then
                CLK_CNT <= (others =>'0');
                VALUE <= '1';                                       -- default pro SCK (odpojeno)
            elsif CS_ACTIVE = '1' then                              -- pokud bezi transakce
                if CLK_CNT = CLK_TICKS_FOR_ONE_HALF_SCK_TICK then   -- pokud probehlo CLK_TICKS_FOR_ONE_HALF_SCK_TICK + 1 taktu FPGA hodin
                    CLK_CNT <= (others =>'0');
                    VALUE <= not(VALUE);                            -- proved opacnou hranu a zustan v tom stavu
                    if PULSE_CNT = SCK_CLOCK_CYCLES then            -- pokud probehla transakce
                        CS_ACTIVE <= '0';                           -- odpoj CS
                        VALUE <= '1';                               -- odpoj SCK
                    end if;                             
                else
                    CLK_CNT <= CLK_CNT + 1;
                end if;    
            else                                                    -- CS odpojen
                if CLK_CNT = CS_INACTIVE_CLKS - 1 then              -- pokud probehlo cekani po predchozi transakci
                    CLK_CNT <= (others =>'0');
                    CS_ACTIVE <= '1';                               -- pripoj CS
                else
                    CLK_CNT <= CLK_CNT + 1;
                end if;    
            end if;
        end if;    
    end process TIMING;
    
    -- precte data z SPI kanalu MISO
    READ_DATA : process (CLK) 
    begin
        if CLK'event and CLK = '1' then
            if RESET = '1' then
                DATA <= (others => '0');
            elsif CLK_CNT = CLK_TICKS_FOR_ONE_HALF_SCK_TICK then    -- pokud je nejaka hrana na SCK
                if PULSE_CNT mod 2 = 1 then                         -- pokud je hrana SCK nabezna
                    DATA <= DATA(14 downto 0) & SDO;                -- posun data a nacti novy bit zprava
                end if;
            end if;
        end if;    
    end process READ_DATA;
    
    -- proces zapise data na vystup
    WRITE_DATA : process (CLK) 
    begin
        if CLK'event and CLK = '1' then
            if RESET = '1' then
                Y <= (others => '0');
                PULSE_CNT <= (others =>'0');
            elsif CS_ACTIVE = '1' then                              -- pokud bezi transakce
                if CLK_CNT = CLK_TICKS_FOR_ONE_HALF_SCK_TICK then   -- pokud je nejaka hrana na SCK
                    if PULSE_CNT = SCK_CLOCK_CYCLES then            -- pokud probeho 16 taktu SCK (prenasi se 16 bitu)
                        PULSE_CNT <= (others => '0');
                        Y <= std_logic_vector(255 - UNSIGNED(std_logic_vector(DATA(12 downto 5))));   -- zapis hodnotu z DATA na vystup Y
                                                                    -- (dle dokumentace se prenese 16 bitu - 3x '0', MSB value, 4x '0', 1x 'Z')
                    else
                        PULSE_CNT <= PULSE_CNT + 1;
                    end if;
                end if;
            end if;
        end if;    
    end process WRITE_DATA;

end AMBIENT_BODY;
