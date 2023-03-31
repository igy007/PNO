library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TB_ADDER_SUBTRACTOR is
end TB_ADDER_SUBTRACTOR;

architecture TB_ADDER_SUBTRACTOR_BODY of TB_ADDER_SUBTRACTOR is


component TOP_LEVEL is
    port 
    (
      INPUT             : in  STD_LOGIC_VECTOR (7 downto 0);  
      BTN0, BTN1, BTN2  : in  STD_LOGIC; 
      CLK, RST          : in  STD_LOGIC;
      CPY_A, CPY_B      : out STD_LOGIC_VECTOR (7 downto 0); 
      OUTPUT            : out STD_LOGIC_VECTOR (15 downto 0);
      OVERFLOW          : out STD_LOGIC
     );
end component;


component TOP_LEVEL_SW_MODEL is
    port 
    (
      INPUT             : in  STD_LOGIC_VECTOR (7 downto 0);  
      BTN0, BTN1, BTN2  : in  STD_LOGIC; 
      CLK, RST          : in  STD_LOGIC;
      
      CPY_A, CPY_B      : out STD_LOGIC_VECTOR (7 downto 0); 
      OUTPUT            : out STD_LOGIC_VECTOR (15 downto 0);
      OVERFLOW          : out STD_LOGIC
     );
end component;


-- signals here
   signal TB_INPUT              :  STD_LOGIC_VECTOR (7 downto 0);   -- datovy vstup (prepinace SWITCH)
   signal TB_BTN0               :  STD_LOGIC;
   signal TB_BTN1               :  STD_LOGIC;
   signal TB_BTN2               :  STD_LOGIC;
   signal TB_CLK                :  STD_LOGIC;
   signal TB_RESET              :  STD_LOGIC;
   signal TB_OVERFLOW_DUT       :  STD_LOGIC;
   signal TB_OVERFLOW_GOLDEN    :  STD_LOGIC;
   
   signal TB_OUTPUT_DUT    :  STD_LOGIC_VECTOR (15 downto 0);  -- vysledek
   signal TB_COPY_A_DUT    :  STD_LOGIC_VECTOR (7 downto 0);   -- kopie 1. operandu
   signal TB_COPY_B_DUT    :  STD_LOGIC_VECTOR (7 downto 0);   -- kopie 2. operandu
   
   signal TB_OUTPUT_GOLDEN :  STD_LOGIC_VECTOR (15 downto 0);  -- vysledek
   signal TB_COPY_A_GOLDEN :  STD_LOGIC_VECTOR (7 downto 0);   -- kopie 1. operandu
   signal TB_COPY_B_GOLDEN :  STD_LOGIC_VECTOR (7 downto 0);   -- kopie 2. operandu
   
   
constant CLK_PERIOD : time := 10 ns;


begin


 DUT : TOP_LEVEL
 port map
 (
    INPUT    => TB_INPUT,
    BTN0     => TB_BTN0,
    BTN1     => TB_BTN1,
    BTN2     => TB_BTN2,
    OUTPUT   => TB_OUTPUT_DUT,
    CPY_A    => TB_COPY_A_DUT,
    CPY_B    => TB_COPY_B_DUT,
    OVERFLOW => TB_OVERFLOW_DUT,
    CLK      => TB_CLK,
    RST      => TB_RESET
 );
 
 

GOLDEN : TOP_LEVEL_SW_MODEL
 port map
 (
    INPUT    => TB_INPUT,
    BTN0     => TB_BTN0,
    BTN1     => TB_BTN1,
    BTN2     => TB_BTN2,
    OUTPUT   => TB_OUTPUT_GOLDEN,
    CPY_A    => TB_COPY_A_GOLDEN,
    CPY_B    => TB_COPY_B_GOLDEN,
    OVERFLOW => TB_OVERFLOW_GOLDEN,
    CLK      => TB_CLK,
    RST      => TB_RESET
 );
 
 
 
CLK_GEN : process
 begin
      TB_CLK <= '0';
      wait for CLK_PERIOD/2;
      TB_CLK <= '1';
      wait for CLK_PERIOD/2;
 end process;
 
RESET_GEN : process
   begin
      wait for 30 ns;
      TB_RESET <= '0';   
      wait for 30 ns;
      TB_RESET <= '1';   
      wait for 30 ns;
      TB_RESET <= '0';
      wait;
   end process;


STIMULI_GEN : process
   begin
      wait until TB_RESET = '1';
      TB_BTN0 <= '0';
      TB_BTN1 <= '0';
      wait until TB_RESET = '0';
      wait for 20 ns;

      -- generujeme vsechny hodnoty vstupu      
      for A in 0 to 255 loop
         for B in 0 to 255 loop
            wait until TB_CLK = '1';
           
            
            TB_INPUT <= STD_LOGIC_VECTOR(TO_UNSIGNED(A,8));  -- zadame operand A
            wait for 23 ns;
            TB_BTN0 <= '1';
            wait for 33 ns;
            TB_BTN0 <= '0';

            wait for 55 ns;

            TB_INPUT <= STD_LOGIC_VECTOR(TO_UNSIGNED(B,8));  -- zadame operand B
            wait for 23 ns;
            TB_BTN0 <= '1';
            wait for 33 ns;
            TB_BTN0 <= '0';

            wait for 55 ns;
            
            TB_BTN1 <= '1';     -- addition ( replace BTN1 with BTN2 to SUBTRACT )
            wait for 33 ns;
            TB_BTN1 <= '0';     -- ( replace BTN1 with BTN2 to SUBTRACT )
            wait for 10*CLK_PERIOD;      --pockame na vysledek
            


            ---------------------------------------------------
            -- porovnavame vystupy naseho obvodu se zlatym standardem: 
            -- TB_OUTPUT_DUT = TB_OUTPUT_GOLDEN
            ---------------------------------------------------
            assert TB_OUTPUT_DUT = TB_OUTPUT_GOLDEN
               report "CHYBA: Vstupy: " & integer'image(A) & " "&integer'image(B) & ", Vystup: " & integer'image(TO_INTEGER(UNSIGNED(TB_OUTPUT_DUT))) & "; Ocekavam: " & integer'image(TO_INTEGER(UNSIGNED(TB_OUTPUT_GOLDEN))) 
               severity failure;
            ---------------------------------------------------
            
         end loop;
      end loop; 
      
      assert FALSE report "KONEC SIMULACE" severity failure;
      -- staci pouze:
      -- report "KONEC SIMULACE" severity failure;
      
   end process;

end TB_ADDER_SUBTRACTOR_BODY;
