----------------------------------------------------------------------------------
-- Company:  CTU in Prague, Faculty of Information Technology
-- Engineer: Jakub Zahradnik & Dominik Igersky
-- 
-- Description: Top level entity over VGA controller and ambient light sensor
--              that moves with the square up and down at screen
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TOP_LEVEL is
    port (
        Y         : out std_logic_vector (7 downto 0);  -- 8 bit value from ALS
        CS        : out std_logic;                      -- SPI chip select
        SDO       : in  std_logic;                      -- SPI data MISO kanál
        SCK       : out std_logic;                      -- SPI clock
        VGA_RED   : out std_logic;                      -- red channel of VGA
        VGA_GREEN : out std_logic;                      -- green channel of VGA
        VGA_BLUE  : out std_logic;                      -- blue channel of VGA
        VGA_HSYNC : out std_logic;                      -- vertical synchronisation 
        VGA_VSYNC : out std_logic;                      -- horizontal synchronisation
        CLK       : in  std_logic;                      -- 100 MHz
        RESET     : in  std_logic                       -- reset
    );
end entity TOP_LEVEL;




architecture TOP_LEVEL_BODY of TOP_LEVEL is


------------------
--- COMPONENTS ---
------------------


component VGA is
    port 
    (
        Y         : in  std_logic_vector (7 downto 0);    -- Y
        VGA_RED   : out std_logic;
        VGA_GREEN : out std_logic;
        VGA_BLUE  : out std_logic;
        VGA_HSYNC : out std_logic;
        VGA_VSYNC : out std_logic;
        CLK       : in  std_logic;                        -- 100 MHz
        RESET     : in  std_logic
    ); 
end component VGA;


component AMBIENT is
    port 
    (
        CS     : out std_logic;                       -- SPI chip select
        SDO    : in  std_logic;                       -- SPI data MISO kanál
        SCK    : out std_logic;                       -- SPI clock
        Y      : out std_logic_vector (7 downto 0);   -- hodnota vyctena ze snimace
        CLK    : in  std_logic;                       -- 100 MHz
        RESET  : in  std_logic                        -- reset
    );
end component AMBIENT;
    
    
-----------------
---- SIGNALS ----
-----------------
       
        
signal Y_BUS   : std_logic_vector (7 downto 0);
    
    
-------------------
---- PROCESSES ----
-------------------
    
begin

    Y <= Y_BUS;

VGA_CONTROLLER : VGA
port map
(
    Y         => Y_BUS,
    VGA_RED   => VGA_RED,
    VGA_GREEN => VGA_GREEN,
    VGA_BLUE  => VGA_BLUE,
    VGA_HSYNC => VGA_HSYNC,
    VGA_VSYNC => VGA_VSYNC,
    CLK       => CLK,
    RESET     => RESET
 );

PMOD_ALS : AMBIENT
port map
(
    CS     => CS,
    SDO    => SDO,
    SCK    => SCK,
    Y      => Y_BUS,
    CLK    => CLK,
    RESET  => RESET
);

end architecture TOP_LEVEL_BODY;
