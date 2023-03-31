library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity AMBIENT is
   port (
      CS     : out std_logic;                       -- SPI rozhrani
      SDO    : in  std_logic;
      SCK    : out std_logic;
      Y      : out std_logic_vector (7 downto 0);   -- hodnota vyctena ze snimace
      CLK    : in  std_logic;                       -- 100 MHz
      RESET  : in  std_logic
   );
end AMBIENT;

architecture AMBIENT_BODY of AMBIENT is


signal TE        : STD_LOGIC; -- Transfer Enable                     
signal DATA_BUFF : STD_LOGIC_VECTOR (15 downto 0);   -- 16-bit DATA buffer

  
begin


-- just passing the clock signal back to testbench
SCK_GEN : process ( CLK, TE )
begin
    
    if TE = '1' then   -- if Transmit Enabled
        SCK <= CLK;    -- share the clock signal
    else
        SCK <= '1';    -- default SCK state
    end if;
    
end process;


-- Request Data 
REQ_DATA : process
variable RESULT : STD_LOGIC_VECTOR (7 downto 0);
begin
    
    wait for 200 ns;    -- wait for 200ns before demanding another scoop of data
    
    DATA_BUFF <= (others => '0');

    CS <= '0';          -- bring CS low to prepare Pmod for communicatin
    wait for 20 ns;     -- Pmod needs time to prepare for transfer (at least 10ns)
    TE <= '1';          -- start generating clock on the SCK port
    
    for I in 0 to 15 loop  
    
        wait until CLK = '0'; -- data being prepared for sending
        wait until CLK = '1'; -- data being valid
    
        DATA_BUFF <= DATA_BUFF(14 downto 0) & SDO;
    
    end loop;
    
    TE <= '0'; -- stop generating clock
    CS <= '1'; -- end of comm
    
     
    RESULT := STD_LOGIC_VECTOR( UNSIGNED(DATA_BUFF(11 downto 4)) );
    
    Y <= RESULT;
    
 end process;




end AMBIENT_BODY;
