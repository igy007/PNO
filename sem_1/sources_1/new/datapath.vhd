library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DATAPATH is
    port
     (
        -- inputs (generic + CONTROLLER)
        INPUT           : in STD_LOGIC_VECTOR (7 downto 0);
        LOAD_A, LOAD_B  : in STD_LOGIC; -- controller STATE operators
        OP, NO, SAV     : in STD_LOGIC; -- controller operators
        CLK, RST        : in STD_LOGIC; -- generic signals
        
        -- outputs
        OUTPUT          : out STD_LOGIC_VECTOR (15 downto 0);
        CPY_A, CPY_B    : out STD_LOGIC_VECTOR (7  downto 0);
        SIGN, CARRY     : out STD_LOGIC
     );
end DATAPATH;


architecture DATAPATH_BODY of DATAPATH is

    signal A, B            : STD_LOGIC_VECTOR (7 downto 0);   -- input registers ( 8-bit )
    signal TMP             : STD_LOGIC_VECTOR (7 downto 0);   -- temporary result register ( 7-bit ) 
    signal A_IN, B_IN      : STD_LOGIC_VECTOR (6 downto 0);   -- multiplexers
    signal AS_OUT          : STD_LOGIC_VECTOR (6 downto 0);   -- ADDER/SUBTRACTOR output
      
    -- adder/subtractor component declaration 
    component AS8
        port 
         (
            -- inputs
            A, B : in  STD_LOGIC_VECTOR (6 downto 0);
            SUB  : in  STD_LOGIC;   -- subtraction signal
        
            -- outputs
            SUM  : out STD_LOGIC_VECTOR (7 downto 0)          
         );
     end component;
     -- end of declaration
     
     
begin


-- adder / subtractor component initiation
ADD_SUB : AS8 
    port map 
     ( 
        A => A_IN, 
        B => B_IN, 
        SUB => OP,
        SUM (7) => CARRY, 
        SUM (6 downto 0) => AS_OUT (6 downto 0)
     ); 



--
--- processes 
--


-- if NOrmalize bit is set, result is subtracted from 0  (1/2)
MUX_A : process (NO, A)
begin
    if NO = '1' then
        A_IN <= "0000000";
    else
        A_IN <= A ( 6 downto 0 );
    end if;    
end process;



-- if NOrmalize bit is set, result is subtracted from 0  (2/2)
MUX_B : process (NO, B, TMP)
begin
    if NO = '1' then
        B_IN <= TMP ( 6 downto 0 );
    else
        B_IN <=  B ( 6 downto 0 );
    end if;   
end process;



REG_A : process (CLK)
begin
    if CLK = '1' and CLK'event then
        if RST = '1' then
            A     <= ( others => '0' );
            CPY_A <= ( others => '0' );     
        elsif LOAD_A = '1' then   
            A     <= INPUT;          
            CPY_A <= INPUT;
        end if;
    end if;
end process;



REG_B : process (CLK)
begin
    if CLK = '1' and CLK'event then
        if RST = '1' then
            B     <= ( others => '0' );
            CPY_B <= ( others => '0' );  
        elsif LOAD_B = '1' then
            B     <= INPUT; 
            CPY_B <= INPUT;
        end if;
    end if;
end process;



REG_RES : process (CLK)
begin
    if CLK = '1' and CLK'event then
        if RST = '1' then
            TMP <= ( others => '0' );     
        elsif SAV = '1' then
        
            if NO = '1' then
                TMP(7) <= not(A(7));
            else
                TMP(7) <= A(7); 
            end if;   
                
            TMP (6 downto 0) <= AS_OUT (6 downto 0);
        end if;
    end if;
end process;



-- this is the output register
-- result is passed into it once all operations 
-- have been accomplished
REG_OUT : process (CLK)
begin
    if CLK = '1' and CLK'event then
        if RST = '1' then
            OUTPUT <= ( others => '0' );
        else         
            OUTPUT (15 downto 8) <= "00000000";
            OUTPUT (7 downto 0)  <= TMP (7 downto 0);
        end if;
    end if;
end process; 



SIGN_PROC : process ( A, B )
begin
    SIGN <= (A(7) and B(7)) or ( (not A(7)) and (not B(7)) ); -- XAND
end process;

end DATAPATH_BODY;
