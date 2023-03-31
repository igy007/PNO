library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CONTROLLER is
   port 
   (
      BTN0, BTN1, BTN2  : in STD_LOGIC;
      CLK, RST          : in STD_LOGIC;
      CARRY, SIGN       : in STD_LOGIC;     -- ADD/SUB next-state transition
      
      LOAD_A, LOAD_B    : out STD_LOGIC;
      OP, NO, SAV       : out STD_LOGIC;    -- signals for adder/subtractor; result register 
      OVERFLOW          : out STD_LOGIC
   );
end entity;

architecture CONTROLLER_BODY of CONTROLLER is
   
   type T_STATE is 
   ( 
        RLS_BTN0,     -- wait until desired BTN gets released 
        WAIT_A,       -- wait for switches to represent A value
        WAIT_B,       -- wait for switches to represent B value
        WAIT_OP,      -- switches loaded, decide if add/sub
        ADD, SUB,
        V_ADD, V_SUB, -- verify the ADD/SUB result
        FINISH,       -- if we managed to successfully conduct the operation
        NORM,         -- if subtracting and oveflow not present - normalize the result
        OVER          -- if there was an overflow resulting from the operation
    );
    
   signal STATE, NEXT_STATE : T_STATE := WAIT_A;  -- FSM essentials

begin


TRANSITIONS : process ( STATE, BTN0, BTN1, BTN2, SIGN, CARRY )  
   begin
   
      case STATE is
      
         when WAIT_A   => if BTN0 = '1' then
                             NEXT_STATE <= RLS_BTN0;
                          else 
                             NEXT_STATE <= STATE;
                          end if;
                          
         when RLS_BTN0 => if BTN0 = '0' then
                             NEXT_STATE <= WAIT_B;
                          else 
                             NEXT_STATE <= STATE;   
                          end if;
                          
         when WAIT_B   => if BTN0 = '1' then
                                NEXT_STATE <= WAIT_OP;
                             else 
                                NEXT_STATE <= STATE;   
                          end if;
        
         when WAIT_OP  => if BTN1 = '1' then
                                if SIGN = '1' then      -- both signs are the same
                                    NEXT_STATE <= ADD;
                                else 
                                    NEXT_STATE <= SUB;
                                end if;
                          elsif BTN2 = '1' then
                                if SIGN = '1' then
                                    NEXT_STATE <= SUB;
                                else
                                    NEXT_STATE <= ADD;
                                end if;
                          else 
                                NEXT_STATE <= STATE;        
                          end if;
                
         when ADD       => NEXT_STATE <= V_ADD;
         
         when SUB       => NEXT_STATE <= V_SUB;       
                          
         when V_ADD      => if CARRY = '1' then 
                                NEXT_STATE <= OVER;     -- overflow
                            else
                                NEXT_STATE <= FINISH;   -- we're done
                          end if;
                             
         
         when V_SUB      => if CARRY = '1' then         
                                NEXT_STATE <= FINISH;   -- we're done
                            else
                                NEXT_STATE <= NORM;     -- normalise
                            end if;
         
         when NORM     => NEXT_STATE <= FINISH;
         
         -- terminal states
         when FINISH   => NEXT_STATE <= WAIT_A;
         when OVER     => NEXT_STATE <= WAIT_A;
          
      end case;
   end process TRANSITIONS; 


OUTPUTS : process (STATE)        -- Moore => v citlivostnim seznamu je jen STAV
   begin
      ---------------------------------
      LOAD_A <= '0';
      LOAD_B <= '0';  
      OP     <= '0';
      NO     <= '0';
      SAV    <= '0';
      ---------------------------------
      case STATE is 
                          
         when RLS_BTN0    => LOAD_A    <= '1';
         
         when WAIT_OP     => LOAD_B    <= '1';
             
         when ADD         => SAV       <= '1';                   
                             
         when SUB         => OP        <= '1'; 
                             SAV       <= '1';  
                                     
         when V_SUB       => OP        <= '1';
                             SAV       <= '1'; 
        
         when NORM        => NO        <= '1';
                             OP        <= '1';
                             SAV       <= '1';
     
         when others      => null;
                           
      end case;
   end process;
   
   
REG_STATE : process (CLK)
   begin
      if CLK = '1' and CLK'event then
         if RST = '1' then
            STATE <= FINISH;
         else
            STATE <= NEXT_STATE;
         end if;
      end if;
   end process; 
   
   
REG_OVRFLW: process (CLK)
   begin    
     if CLK = '1' and CLK'event then
        case STATE is
            when FINISH => OVERFLOW <= '0';   -- if the add/sub operation was successful
            when OVER   => OVERFLOW <= '1';   -- if overflow happened as a result of add/sub
            when others => null;
        end case;
     end if;
   end process;


end architecture;