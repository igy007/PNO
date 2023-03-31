----------------------------------------------------------------------------------
-- Company:     CTU in Prague, Faculty of Information Technology
-- Engineer:    Martin Novotny
--
-- Description: Displays 16 bit DATA on 4 digit 7segment display 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- zobrazi 4 hexa cislice (DATA) na 4 mistnem 7segmentovem displeji (SEGMENT, DP, DIGIT)
entity HEX2SEG is
   port (
      DATA     : in  STD_LOGIC_VECTOR (15 downto 0);   -- vstupni data k zobrazeni (4 sestnactkove cislice)
      CLK      : in  STD_LOGIC;
      SEGMENT  : out STD_LOGIC_VECTOR (6 downto 0);    -- 7 segmentu displeje
      DP       : out STD_LOGIC;                        -- desetinna tecka
      DIGIT    : out STD_LOGIC_VECTOR (3 downto 0)     -- 4 cifry displeje
   );
end entity HEX2SEG;

architecture HEX2SEG_BODY of HEX2SEG is

   constant PRESCALER_WIDTH : integer := 16;

   signal PRESCALER : UNSIGNED (PRESCALER_WIDTH-1 downto 0);
   signal SEL       : STD_LOGIC_VECTOR (1 downto 0);
   signal HEX       : STD_LOGIC_VECTOR (3 downto 0);

begin

   -- hodinovy kmitocet 100 MHz vydelime pomoci 16 bitoveho citace
   -- tim ziskame obnovovaci kmitocet displeje
   P_PRESCALER : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         PRESCALER <= PRESCALER + 1;
      end if;
   end process;

   -- nejvyssi 2 bity citace slouzi k prepinani 4 cifer displeje
   SEL <= STD_LOGIC_VECTOR(PRESCALER(PRESCALER_WIDTH-1 downto PRESCALER_WIDTH-2));

   -- binarni kod prevedeme do kodu 1 z N
   -- cifra I je aktivni, jestlize DIGIT(I) = '0'
   SEL_DIGIT : process (SEL)
   begin
      case SEL is
         when "00"   => DIGIT <= "1110";   -- 0. cifra
         when "01"   => DIGIT <= "1101";   -- 1. cifra
         when "10"   => DIGIT <= "1011";   -- 2. cifra
         when others => DIGIT <= "0111";   -- 3. cifra
      end case;
   end process;

   -- a zaroven vybereme prislusnou ctverici bitu (sestnactkovou cifru) k zobrazeni
   SEL_INPUT : process (SEL, DATA)
   begin
      case SEL is
         when "00"   => HEX <= DATA( 3 downto  0);  -- 0. sestnactkova cifra
         when "01"   => HEX <= DATA( 7 downto  4);  -- 1. sestnactkova cifra
         when "10"   => HEX <= DATA(11 downto  8);  -- 2. sestnactkova cifra
         when others => HEX <= DATA(15 downto 12);  -- 3. sestnactkova cifra
      end case;
   end process;

   -- ctverici bitu (sestnactkovou cifru) prevedeme na sedmici segmentu
   -- segement J sviti, pokud SEGMENT(J) = '0'
   HEX_2_7SEG : process (HEX)
   begin
      case HEX is
         --                      -- abcdefg
         when "0000" => SEGMENT <= "0000001"; -- 0
         when "0001" => SEGMENT <= "1001111"; -- 1
         when "0010" => SEGMENT <= "0010010"; -- 2
         when "0011" => SEGMENT <= "0000110"; -- 3
         when "0100" => SEGMENT <= "1001100"; -- 4
         when "0101" => SEGMENT <= "0100100"; -- 5
         when "0110" => SEGMENT <= "0100000"; -- 6
         when "0111" => SEGMENT <= "0001111"; -- 7
         when "1000" => SEGMENT <= "0000000"; -- 8
         when "1001" => SEGMENT <= "0000100"; -- 9
         when "1010" => SEGMENT <= "0001000"; -- A
         when "1011" => SEGMENT <= "1100000"; -- b
         when "1100" => SEGMENT <= "0110001"; -- C
         when "1101" => SEGMENT <= "1000010"; -- d
         when "1110" => SEGMENT <= "0110000"; -- E
         when others => SEGMENT <= "0111000"; -- F
      end case;
   end process;

   -- desetinna tecka bude stale zhasnuta
   DP <= '1';

end architecture HEX2SEG_BODY;