library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TOP_LEVEL is
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




architecture TOP_LEVEL_BODY of TOP_LEVEL is

component DATAPATH is
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
end component;

component CONTROLLER is
   port 
   (
      BTN0, BTN1, BTN2  : in STD_LOGIC;
      CLK, RST          : in STD_LOGIC;
      CARRY, SIGN       : in STD_LOGIC;     -- ADD/SUB next-state transition
      
      LOAD_A, LOAD_B    : out STD_LOGIC;
      OP, NO, SAV       : out STD_LOGIC;    -- signals for adder/subtractor; result register 
      OVERFLOW          : out STD_LOGIC
   );
end component; 

signal 
    LOAD_A, LOAD_B, OP, NO, CARRY, SIGN, SAV : STD_LOGIC;  


begin


DATA_INST : DATAPATH 
    port map 
    (
       INPUT    => INPUT,
       LOAD_A   => LOAD_A,
       LOAD_B   => LOAD_B,
       OP       => OP,       -- 1 = subtract
       NO       => NO,       -- NO = normalize
       SAV      => SAV,      -- SAVe he result to the display register
       CARRY    => CARRY,   
       SIGN     => SIGN,     -- are both A and B signs the same?
       OUTPUT   => OUTPUT,
       CPY_A    => CPY_A,
       CPY_B    => CPY_B,
       CLK      => CLK,
       RST      => RST 
    );   
           
           
CNTR_INST : CONTROLLER 
    port map  
    (
       BTN0      => BTN0,
       BTN1      => BTN1,
       BTN2      => BTN2,
       LOAD_A    => LOAD_A,
       LOAD_B    => LOAD_B,
       OP        => OP,
       NO        => NO,
       SAV       => SAV,
       CARRY     => CARRY,
       SIGN      => SIGN,
       CLK       => CLK,
       RST       => RST,
       OVERFLOW  => OVERFLOW
    );   



end TOP_LEVEL_BODY;



