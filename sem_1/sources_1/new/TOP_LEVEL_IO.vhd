library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TOP_LEVEL_IO is
    port
    (
      SWITCH     : in  STD_LOGIC_VECTOR (7 downto 0);
      BTN0       : in  STD_LOGIC;
      BTN1       : in  STD_LOGIC;
      BTN2       : in  STD_LOGIC;
      BTN3       : in  STD_LOGIC;    -- OUTPUT MUX
      SEGMENT    : out STD_LOGIC_VECTOR (6 downto 0);    -- 7 segmentu displeje
      DP         : out STD_LOGIC;                        -- desetinna tecka
      DIGIT      : out STD_LOGIC_VECTOR (3 downto 0);    -- 4 cifry displeje
      OVERFLOW   : out STD_LOGIC;
      CLK, RST   : in  STD_LOGIC
    );
end TOP_LEVEL_IO;



architecture TOP_LEVEL_IO_BODY of TOP_LEVEL_IO is

component TOP_LEVEL is
    port 
    (
      INPUT             : in  STD_LOGIC_VECTOR (7 downto 0);  
      BTN0, BTN1, BTN2  : in  STD_LOGIC;
      OUTPUT            : out STD_LOGIC_VECTOR (15 downto 0);
      CPY_A, CPY_B      : out STD_LOGIC_VECTOR (7 downto 0);  
      CLK, RST          : in  STD_LOGIC;
      OVERFLOW          : out STD_LOGIC
    );
end component;



component HEX2SEG is
    port 
    (
      DATA        : in    STD_LOGIC_VECTOR (15 downto 0);     -- vstupni data k zobrazeni (4 sestnactkove cislice)
      CLK         : in    STD_LOGIC;
      SEGMENT     : out   STD_LOGIC_VECTOR (6 downto 0);      -- 7 segmentu displeje
      DP          : out   STD_LOGIC;                          -- desetinna tecka
      DIGIT       : out   STD_LOGIC_VECTOR (3 downto 0)       -- 4 cifry displeje
    );
end component HEX2SEG;


   -- propojovaci draty
   signal CPY_A, CPY_B   : STD_LOGIC_VECTOR (7 downto 0);   -- kopie vstunich operandu
   signal OUTPUT, DATA   : STD_LOGIC_VECTOR (15 downto 0);  -- vysledek, data k zobrazeni



for ADD_SUB_INST : TOP_LEVEL use entity work.TOP_LEVEL(TOP_LEVEL_BODY) 
 port map 
    ( 
      INPUT      => INPUT,
      BTN0       => BTN0,
      BTN1       => BTN1,
      BTN2       => BTN2,
      OUTPUT     => OUTPUT,
      CPY_A      => CPY_A,
      CPY_B      => CPY_B,
      CLK        => CLK,
      RST        => RST,
      OVERFLOW   => OVERFLOW
    );


begin


ADD_SUB_INST : TOP_LEVEL
    port map 
    (
      INPUT     =>  SWITCH,  -- STD input
      BTN0      =>  BTN0,    -- STD input
      BTN1      =>  BTN1,    -- STD input
      BTN2      =>  BTN2,    -- STD input
      CLK       =>  CLK,     -- STD input
      RST       =>  RST,     -- STD input
      OUTPUT    =>  OUTPUT,  -- signal
      OVERFLOW  =>  OVERFLOW, -- overflow LED
      CPY_A     =>  CPY_A,   -- signal
      CPY_B     =>  CPY_B    -- signal
    );



DISP_INST : HEX2SEG 
    port map 
    (
      DATA     => DATA,
      CLK      => CLK,
      SEGMENT  => SEGMENT,
      DP       => DP,
      DIGIT    => DIGIT
    );




 --BTN3 ridi, co se zobrazi - zda vysledek (OUTPUT) nebo vstupni operandy (A a B)
DISPLAY_MUX : process (BTN3, OUTPUT, CPY_A, CPY_B)
begin
      if BTN3 = '0' then
         DATA <= OUTPUT;
      else
         DATA <= (CPY_A & CPY_B);
      end if; 
end process DISPLAY_MUX;




end TOP_LEVEL_IO_BODY;
