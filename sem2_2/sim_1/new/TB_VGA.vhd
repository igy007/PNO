library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_VGA is
end TB_VGA;

architecture TB_VGA_BODY of TB_VGA is


constant CLK_PERIOD : time := 20 ns;


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
end component;

signal  TB_Y         : std_logic_vector (7 downto 0);
signal  TB_VGA_RED   : std_logic;
signal  TB_VGA_GREEN : std_logic;
signal  TB_VGA_BLUE  : std_logic;
signal  TB_VGA_HSYNC : std_logic;
signal  TB_VGA_VSYNC : std_logic;
signal  TB_CLK       : std_logic;
signal  TB_RESET     : std_logic;


begin

TB_Y <= "00000100";

DUT : VGA 
port map 
   (
      Y         => TB_Y,
      VGA_RED   => TB_VGA_RED,
      VGA_GREEN => TB_VGA_GREEN,
      VGA_BLUE  => TB_VGA_BLUE,
      VGA_HSYNC => TB_VGA_HSYNC,
      VGA_VSYNC => TB_VGA_VSYNC,
      CLK       => TB_CLK,
      RESET     => TB_RESET
   );



CLK_GEN : process
begin
   TB_CLK <= '0';
   wait for CLK_PERIOD/2;
   TB_CLK <= '1';
   wait for CLK_PERIOD/2;
end process;



end TB_VGA_BODY;
