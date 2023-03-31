library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB_ADDER is
end TB_ADDER;

architecture TB_ADDER_BODY of TB_ADDER is

component AS8 is
    port 
    (
        -- inputs
        A, B : in  STD_LOGIC_VECTOR (7 downto 0);
        SUB  : in  STD_LOGIC;   -- subtraction signal
        
        -- outputs
        SUM  : out STD_LOGIC_VECTOR (8 downto 0)       
     );
    
end component;

signal TB_A, TB_B   : STD_LOGIC_VECTOR (7 downto 0);
signal TB_SUB       : STD_LOGIC;
signal TB_SUM       : STD_LOGIC_VECTOR (8 downto 0);

begin


DUT : AS8
    port map
     (
        A => TB_A,
        B => TB_B,
        SUB => TB_SUB,
        SUM => TB_SUM
     );


GENPROC : process
    begin
        TB_A <= (others => '0');
        TB_B <= (others => '0');
        TB_SUB <= '0';
        for I in 0 to 4 loop
            for J in 0 to 4 loop
                TB_A <= STD_LOGIC_VECTOR(TO_SIGNED(I, 8));
                TB_B <= STD_LOGIC_VECTOR(TO_SIGNED(J, 8));
                wait for 5 ns;
            end loop;
        end loop;
                       
    end process;
    
    

end TB_ADDER_BODY ;
