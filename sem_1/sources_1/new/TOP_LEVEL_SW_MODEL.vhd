library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TOP_LEVEL_SW_MODEL is
    port 
    (
      INPUT             : in  STD_LOGIC_VECTOR (7 downto 0);  
      BTN0, BTN1, BTN2  : in  STD_LOGIC; 
      CLK, RST          : in  STD_LOGIC;
      
      CPY_A, CPY_B      : out STD_LOGIC_VECTOR (7 downto 0); 
      OUTPUT            : out STD_LOGIC_VECTOR (15 downto 0);
      OVERFLOW          : out STD_LOGIC
     );
end entity;


architecture TOP_LEVEL_SW_MODEL_BODY of TOP_LEVEL_SW_MODEL is
 
 begin

SW_MODEL : process
      variable A, B : UNSIGNED (7 downto 0);  -- signed = two's complement representation
      variable RES  : UNSIGNED (7 downto 0);
      variable SUB  : bit := '0';
      variable SIGN : STD_LOGIC;
   begin
      wait until BTN0 = '1';
      A := UNSIGNED(INPUT);
      CPY_A <= INPUT;
      wait until BTN0 = '0';
      wait until BTN0 = '1';
      B := UNSIGNED(INPUT);
      CPY_B <= INPUT;
      
      -- decide if add or sub should happen
      wait until ( BTN1 = '1' or BTN2 = '1' );
      if BTN1 = '1' then
        if A(7) /= B(7) then
            SUB := '1';
        else 
            SUB := '0';
        end if;
        
      elsif BTN2 = '1' then
         if A(7) = B(7) then
            SUB := '1';
         else 
            SUB := '0';
         end if;
      end if;
         
      SIGN := A(7);   -- sign backup   
         
      if SUB = '0' then -- ADDITION
        A(7) := '0'; -- abs(A)
        B(7) := '0'; -- abs(B)
        RES  :=   A  +  B ;
            if RES(7) = '1' then     -- if overflow
                OVERFLOW <= '1';     -- then overflow
            else                     -- otherwise 
                OVERFLOW <= '0';     -- ..not overflow 
            end if;
        RES(7) := SIGN;
        
      else-- SUBTRACTION
        B    := not(B); -- invert B
        A(7) := '0';    -- abs(A)
        B(7) := '0';    -- abs(B)
        RES  :=  A  +  B  + 1 ; -- add inverted B along with the "hot one" to subtract
        if RES(7) = '0' then      -- if noverflow
            RES := not(RES);      -- 0 - RES (1/2)
            RES := RES + 1;       -- 0 - RES (2/2) 
            RES(7) := not(SIGN);   
        else
            RES(7) := SIGN;
        end if;
      end if;     
      
      OUTPUT <= STD_LOGIC_VECTOR( "00000000" & RES );
      
   
   end process;


end TOP_LEVEL_SW_MODEL_BODY;