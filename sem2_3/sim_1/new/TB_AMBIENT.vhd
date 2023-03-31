library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TB_AMBIENT is
end TB_AMBIENT;




architecture TB_AMBIENT_BODY of TB_AMBIENT is

component AMBIENT is
   port
   (
      CS     : out std_logic;                       -- SPI rozhrani
      SDO    : in  std_logic;
      SCK    : out std_logic;
      Y      : out std_logic_vector (7 downto 0);   -- hodnota vyctena ze snimace
      CLK    : in  std_logic;                       -- 100 MHz : this is generated using testbench
      RESET  : in  std_logic
   );
end component AMBIENT;

  constant CLK_PERIOD : time := 10 ns;   -- perioda hodin

  signal  TB_CS     :  STD_LOGIC;
  signal  TB_SDO    :  STD_LOGIC;
  signal  TB_SCK    :  STD_LOGIC;       -- the same clock generated in testbench
  signal  TB_Y      :  STD_LOGIC_VECTOR (7 downto 0);
  signal  TB_CLK    :  STD_LOGIC;       -- artificial clock signal for master
  signal  TB_RESET  :  STD_LOGIC;
                        
begin


DUT : AMBIENT 
port map 
(
    CS      => TB_CS,
    SDO     => TB_SDO, 
    SCK     => TB_SCK,
    Y       => TB_Y,
    CLK     => TB_CLK,
    RESET   => TB_RESET
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



-- Value Generator
VAL_GEN : process
variable TMP        : STD_LOGIC_VECTOR(7 downto 0);
variable EXPECTED_Y : STD_LOGIC_VECTOR(7 downto 0);
begin


    for I in 255 downto 0 loop
         
        TMP := STD_LOGIC_VECTOR(TO_UNSIGNED(I, 8));
        
        wait until TB_CS = '0';     -- if CS is 0 = Master is requesting data
        
        
        ----------------------------------!!!!-----------------------------------
        -- simulating tCSSU from datasheet PAGE 7 
        -- https://hwlab.fit.cvut.cz/_media/pripravky/fpga/pmodals/adc081s021.pdf
        wait for 10ns;     
        -------------------------------------------------------------------------
        
        
        -- send 3 leading zeros
        for A in 0 to 2 loop
            wait until TB_SCK = '0';
            TB_SDO <= '0';    
            wait until TB_SCK = '1';
        end loop;
    
        -- send DATA 
        for B in 7 downto 0 loop
            wait until TB_SCK = '0';
            TB_SDO <= TMP(7);             -- send MSB
            TMP := TMP(6 downto 0) & '0'; -- shift to the left
            wait until TB_SCK = '1';
        end loop;
    
        -- send 4 trailing zeros
        for C in 0 to 3 loop
            wait until TB_SCK = '0';
            TB_SDO <= '0';    
            wait until TB_SCK = '1';
        end loop;
        
        -- entering High Impedance state
        wait until TB_CS = '1';
                
        EXPECTED_Y := STD_LOGIC_VECTOR( 255 - TO_UNSIGNED(I,8) );
        
        assert TB_Y = EXPECTED_Y
            report "CHYBICKA: Ocekavam: " & integer'image( I ) & " Prislo mi: " & integer'image(TO_INTEGER(UNSIGNED(TB_Y)))
        severity failure;
         
  end loop;
 
  -- konec
      assert FALSE report "KONEC SIMULACE" severity failure;
      
end process;

end TB_AMBIENT_BODY;
