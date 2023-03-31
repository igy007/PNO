--
--- VGA Controller 
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;


entity VGA is
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
end VGA ;

architecture VGA_BODY of VGA is

-------------------------------------------------------------
----------------------- INNER SIGNALS -----------------------
-------------------------------------------------------------


  signal PRINT    : STD_LOGIC := '0'; -- Box is white, therefore RGB is always the same
  signal px_CLK   : STD_LOGIC;        -- pixel clock ( different resolutions demand different clock speeds ) 

  constant ACTIVE : STD_LOGIC := '0'; -- H_SYNC and V_SYNC are active low

  constant WIDTH  : integer := 640;
  constant H_FP   : integer := 16;  -- H front porch width (pixels)
  constant H_PW   : integer := 96;  -- H sync pulse width  (pixels)
  constant H_MAX  : integer := 800; -- summ of all horizontal pixels
  
  constant HEIGHT : integer := 480;
  constant V_FP   : integer := 10;   -- V front porch width (lines)
  constant V_PW   : integer := 2;    -- V sync pulse width (lines)
  constant V_MAX  : integer := 525;  -- summ of all vertical lines
  
  
  signal H_COUNTER : STD_LOGIC_VECTOR( 9 downto 0 ) := ( others => '0' ); -- 10-bit horizontal position counter
  signal V_COUNTER : STD_LOGIC_VECTOR( 9 downto 0 ) := ( others => '0' ); -- 10-bit vertical position counter
  signal INPUT     : STD_LOGIC_VECTOR( 7 downto 0 ) := ( others => '0' ); -- 8-bit register to keep value while displaying



-------------------------------------------------------------
------------------------- COMPONENTS ------------------------
-------------------------------------------------------------


component CLK_DIVIDER_25MHz is
port
(
     CLK_IN  : in  STD_LOGIC;
     CLK_OUT : out STD_LOGIC
); 
end component;



-------------------------------------------------------------
begin -------------------- PORT MAP -------------------------
-------------------------------------------------------------


CLK_DIVIDER : CLK_DIVIDER_25MHz
port map
(
    CLK_IN => CLK,
    CLK_OUT => px_CLK
);


-------------------------------------------------------------
------------------------- PROCESSES -------------------------
-------------------------------------------------------------


PRINT_PROC : process ( PRINT )
begin
    VGA_RED   <= PRINT;
    VGA_GREEN <= PRINT;
    VGA_BLUE  <= PRINT;
end process;



POSITION_DEAMON : process ( px_CLK )
begin

if  px_CLK'event and px_CLK = '1' then
    if  RESET = '1' then
        H_COUNTER <= (others => '0');   -- we're at the zero pixel position
        V_COUNTER <= (others => '0');
        INPUT     <= (others => '0');
    else    
        if (H_COUNTER = (H_MAX - 1)) or RESET = '1' then
            H_COUNTER <= (others => '0');
        else    
            H_COUNTER <= H_COUNTER + 1;
        end if;
        
        if ((H_COUNTER = (H_MAX - 1)) and (V_COUNTER = (V_MAX - 1))) or RESET = '1' then
            V_COUNTER <= (others =>'0');
            INPUT     <= Y;
        elsif H_COUNTER = (H_MAX - 1) then
            V_COUNTER <= V_COUNTER + 1;
        end if;
    end if;    
end if;

end process;



-- if the position requirements met, 
-- pull the common color signal HIGH
DRAW_SQ : process ( px_CLK )
begin

if px_CLK'event and px_CLK = '1' then
   
    PRINT <= '0';   -- if no conditions met, draw nothing
    
    -- draw base ( a line )
    if ( V_COUNTER = INPUT ) or ( V_COUNTER - 19 = INPUT ) then
        if (H_COUNTER > 309) and (H_COUNTER < 330) then
            PRINT <= '1';
        end if;  
    end if;
    
    -- draw wall
    if ( H_COUNTER = 310 ) or ( H_COUNTER = 329 ) then
        if (V_COUNTER > INPUT) and (V_COUNTER < ('0'&INPUT ) + 19)  then
            PRINT <= '1';
        end if; 
    end if;

end if;

end process;



-------------------------
--  H-Sync and V-Sync  --
-------------------------

H_SYNC_PROC : process ( px_CLK )
begin
    if px_CLK'event and px_CLK = '1' then
        if (H_COUNTER > (H_FP + WIDTH) - 1) and (H_COUNTER < (H_FP + WIDTH + H_PW)) then
            VGA_HSYNC <= ACTIVE;
        else
            VGA_HSYNC <= not(ACTIVE);
        end if;
    end if;
end process;



V_SYNC_PROC : process ( px_CLK )
begin
    if px_CLK'event and px_CLK = '1' then
        if (V_COUNTER >= (V_FP + HEIGHT) - 1) and (V_COUNTER < (V_FP + HEIGHT + V_PW) - 1) then
            VGA_VSYNC <= ACTIVE;
        else
            VGA_VSYNC <= not(ACTIVE);
        end if;
    end if;
end process;





end VGA_BODY;
