library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 8-bit adder / subtractor
entity AS8 is
    port 
    (
        -- inputs
        A, B : in  STD_LOGIC_VECTOR (6 downto 0); -- 7-bit
        SUB  : in  STD_LOGIC;   -- subtraction signal
        
        -- outputs
        SUM  : out STD_LOGIC_VECTOR (7 downto 0)
     );
    
end entity AS8;

architecture AS8_BODY of AS8 is
    
begin

   
    ADDER : process ( A, B, SUB ) 
    variable TMP : UNSIGNED(7 downto 0);
    begin
          if SUB = '0' then
            TMP := UNSIGNED( '0' & A ) + UNSIGNED( '0' & B  );
           else
            TMP := UNSIGNED( '0' & A ) + UNSIGNED( '0' & not(B) );
           end if;
           
          if SUB = '1' then
            TMP := TMP + 1;
          end if;
          SUM <= STD_LOGIC_VECTOR(TMP);
    end process;

    
end architecture;