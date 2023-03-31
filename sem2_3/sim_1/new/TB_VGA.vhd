----------------------------------------------------------------------------------
-- Company:  CTU in Prague, Faculty of Information Technology
-- Engineer: Jakub Zahradnik
-- 
-- Description: Testbench for VGA
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_VGA is
end TB_VGA;

architecture TB_VGA_BODY of TB_VGA is

    constant CLK_PERIOD         : time      := 10 ns;   -- perioda hodin
    constant DISPLAY_WIDTH      : integer   := 640;     -- sirka displeje v pixelech
    constant DISPLAY_HEIGHT     : integer   := 480;     -- vyska displeje v pixelech
    constant PULSE_WIDTH_H      : integer   := 96;      -- pocet taktu pro puls horizontalni synchronizace
    constant FRONT_PORCH_H      : integer   := 16;      -- pocet taktu pred pulsem pro horizontalni synchronizaci
    constant BACK_PORCH_H       : integer   := 48;      -- pocet taktu po pulsu pro horizontalni synchronizaci
    constant PULSE_WIDTH_V      : integer   := 2;       -- pocet taktu pro puls vertikalni synchronizace
    constant FRONT_PORCH_V      : integer   := 10;      -- pocet taktu pred pulsem pro vertikalni synchronizaci
    constant BACK_PORCH_V       : integer   := 33;      -- pocet taktu po pulsu pro vertikalni synchronizaci
    constant CLOCK_FCY_CMP      : integer   := 4;       -- frekvence hodin na basys 3 je 100 MHz a my to potrebujeme namapovat na 25 MHz pixel clock
    constant X                  : integer   := 310;     -- Xova souradnice kde zacina ctverec
    constant SIZE               : integer   := 20;      -- velikost hrany ctverce v pixelech
    constant NUMBER_OF_LINES    : integer   := 525;     -- celkovy pocet radek vcetne nezobrazovacich
    constant Y_RAND             : integer   := 33;      -- nahodna hodnota Y pro test


    component VGA is
        port (
            Y         : in  std_logic_vector (7 downto 0); -- vstup Y
            VGA_RED   : out std_logic;
            VGA_GREEN : out std_logic;
            VGA_BLUE  : out std_logic;
            VGA_HSYNC : out std_logic;
            VGA_VSYNC : out std_logic;
            CLK       : in  std_logic;                     -- 100 MHz
            RESET     : in  std_logic
        );
    end component VGA ;

    -- signaly pro testbench
    SIGNAL TB_Y         : std_logic_vector (7 downto 0);
    SIGNAL TB_VGA_RED   : std_logic;
    SIGNAL TB_VGA_GREEN : std_logic;
    SIGNAL TB_VGA_BLUE  : std_logic;
    SIGNAL TB_VGA_HSYNC : std_logic;
    SIGNAL TB_VGA_VSYNC : std_logic;
    SIGNAL TB_CLK       : std_logic;                     
    SIGNAL TB_RESET     : std_logic; 
        
begin

    DUT : VGA port map (
        Y         => TB_Y,
        VGA_RED   => TB_VGA_RED,
        VGA_GREEN => TB_VGA_GREEN,
        VGA_BLUE  => TB_VGA_BLUE,
        VGA_HSYNC => TB_VGA_HSYNC,
        VGA_VSYNC => TB_VGA_VSYNC,
        CLK       => TB_CLK,
        RESET     => TB_RESET
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
        variable Y_TESTED_VALUE : integer   := 0;       -- testovana hodnota Y, netestujeme vsechny kvuli casove narocnosti, ale prvni, posledni a Y_RAND
    begin
        wait until TB_RESET = '1';
        wait until TB_RESET = '0';
        wait for 33 ns;

        -- pockame na zacatek casovani
        wait until TB_VGA_VSYNC'event and TB_VGA_VSYNC = '0';

        wait for 20 ns;
        -- kontrolujeme snimek pro hodnoty 0, 255, Y_RAND
        for I in 0 to 2 loop

            if I = 1 then
                Y_TESTED_VALUE := 255;
            elsif I = 2 then
                Y_TESTED_VALUE := Y_RAND;        
            end if;    

            TB_Y <= STD_LOGIC_VECTOR(TO_UNSIGNED(Y_TESTED_VALUE,8));

            -- pro kazdy radek
            for K in 0 to NUMBER_OF_LINES - 1 loop
            
                -- DISPLAY TIME kontrola
                -- kontrola VSYNC a kontrola HSYNC prvnich BACK_PORCH_H * CLOCK_FCY_CMP taktu
                -- kontrola barev na vystupu
                for L in 0 to DISPLAY_WIDTH - 1 loop

                    -- horni a dolni strana ctverce bile pixely
                    if (K = PULSE_WIDTH_V + BACK_PORCH_V + Y_TESTED_VALUE + 1 or K = PULSE_WIDTH_V + BACK_PORCH_V + Y_TESTED_VALUE + SIZE)    -- radek horni nebo dolni strany
                        and L >= X and L < X + SIZE             -- pixely vymezujici stranu
                        then
                            assert TB_VGA_RED = '1' and TB_VGA_GREEN = '1' and TB_VGA_BLUE = '1'
                                report "CHYBA: TB_VGA_RED (1) je: " & std_logic'image(TB_VGA_RED)
                                            & " TB_VGA_GREEN (1) je: " & std_logic'image(TB_VGA_GREEN)
                                            & " TB_VGA_BLUE (1) je: " & std_logic'image(TB_VGA_BLUE)
                                severity error;
                    -- honri a dolni strana ctverce cerne pixely 
                    elsif K = PULSE_WIDTH_V + BACK_PORCH_V + Y_TESTED_VALUE + 1 or K = PULSE_WIDTH_V + BACK_PORCH_V + Y_TESTED_VALUE + SIZE then
                        assert TB_VGA_RED = '0' and TB_VGA_GREEN = '0' and TB_VGA_BLUE = '0'    
                            report "CHYBA: TB_VGA_RED (0) je: " & std_logic'image(TB_VGA_RED)
                                        & " TB_VGA_GREEN (0) je: " & std_logic'image(TB_VGA_GREEN)
                                        & " TB_VGA_BLUE (0) je: " & std_logic'image(TB_VGA_BLUE)
                            severity error;
                    
                    -- postranni strany ctverce bile pixely
                    elsif K > PULSE_WIDTH_V + BACK_PORCH_V + Y_TESTED_VALUE + 1 and K < PULSE_WIDTH_V + BACK_PORCH_V + Y_TESTED_VALUE + SIZE  -- radky ctverce bez prvniho a posledniho
                        and (L = X or L = X + SIZE - 1) -- pixel na prave strane ctverce
                        then
                        assert TB_VGA_RED = '1' and TB_VGA_GREEN = '1' and TB_VGA_BLUE = '1'
                            report "CHYBA: TB_VGA_RED (1) je: " & std_logic'image(TB_VGA_RED)
                                        & " TB_VGA_GREEN (1) je: " & std_logic'image(TB_VGA_GREEN)
                                        & " TB_VGA_BLUE (1) je: " & std_logic'image(TB_VGA_BLUE)
                            severity error;
                    -- mimo ctverec cerne pixely
                    else
                        assert TB_VGA_RED = '0' and TB_VGA_GREEN = '0' and TB_VGA_BLUE = '0'
                            report "CHYBA: TB_VGA_RED (0) je: " & std_logic'image(TB_VGA_RED)
                                        & " TB_VGA_GREEN (0) je: " & std_logic'image(TB_VGA_GREEN)
                                        & " TB_VGA_BLUE (0) je: " & std_logic'image(TB_VGA_BLUE)
                            severity error;
                    end if;                

                    -- kontrola VSYNC a kontrola HSYNC
                    assert TB_VGA_HSYNC = '1'
                        report "CHYBA: HSYNC (1) je: " & std_logic'image(TB_VGA_HSYNC)
                        severity error;
                    if K < PULSE_WIDTH_V then
                        assert TB_VGA_VSYNC = '0'
                            report "CHYBA: VSYNC (0) je: " & std_logic'image(TB_VGA_VSYNC)
                            severity error;
                    else
                        assert TB_VGA_VSYNC = '1'
                            report "CHYBA: VSYNC (1) je: " & std_logic'image(TB_VGA_VSYNC)
                            severity error;
                    end if;        
                    wait for CLK_PERIOD * CLOCK_FCY_CMP;
                end loop;
                
                -- FRONT PORCH kontrola
                -- kontrola VSYNC a kontrola HSYNC prvnich FRONT_PORCH_H * CLOCK_FCY_CMP taktu
                for L in 0 to FRONT_PORCH_H - 1 loop
                    assert TB_VGA_HSYNC = '1'
                        report "CHYBA: HSYNC (1) je: " & std_logic'image(TB_VGA_HSYNC)
                        severity error;
                    if K < PULSE_WIDTH_V then
                        assert TB_VGA_VSYNC = '0'
                            report "CHYBA: VSYNC (0) je: " & std_logic'image(TB_VGA_VSYNC)
                            severity error;
                    else
                        assert TB_VGA_VSYNC = '1'
                            report "CHYBA: VSYNC (1) je: " & std_logic'image(TB_VGA_VSYNC)
                            severity error;
                    end if;        
                    wait for CLK_PERIOD * CLOCK_FCY_CMP;
                end loop;
                
                -- PULSE WIDTH kontrola
                -- kontrola VSYNC a kontrola HSYNC prvnich PULSE_WIDTH_H * CLOCK_FCY_CMP taktu
                for L in 0 to PULSE_WIDTH_H - 1 loop
                    assert TB_VGA_HSYNC = '0'
                        report "CHYBA: HSYNC (0) je: " & std_logic'image(TB_VGA_HSYNC)
                        severity error;
                    if K < PULSE_WIDTH_V then
                        assert TB_VGA_VSYNC = '0'
                            report "CHYBA: VSYNC (0) je: " & std_logic'image(TB_VGA_VSYNC)
                            severity error;
                    else
                        assert TB_VGA_VSYNC = '1'
                            report "CHYBA: VSYNC (1) je: " & std_logic'image(TB_VGA_VSYNC)
                            severity error;
                    end if;        
                    wait for CLK_PERIOD * CLOCK_FCY_CMP;
                end loop;

                -- BACK PORCH kontrola
                -- kontrola VSYNC a kontrola HSYNC prvnich BACK_PORCH_H * CLOCK_FCY_CMP taktu
                for L in 0 to BACK_PORCH_H - 1 loop
                    assert TB_VGA_HSYNC = '1'
                        report "CHYBA: HSYNC (1) je: " & std_logic'image(TB_VGA_HSYNC)
                        severity error;
                    if K < PULSE_WIDTH_V then
                        assert TB_VGA_VSYNC = '0'
                            report "CHYBA: VSYNC (0) je: " & std_logic'image(TB_VGA_VSYNC)
                            severity error;
                    else
                        assert TB_VGA_VSYNC = '1'
                            report "CHYBA: VSYNC (1) je: " & std_logic'image(TB_VGA_VSYNC)
                            severity error;
                    end if;        
                    wait for CLK_PERIOD * CLOCK_FCY_CMP;
                end loop;
            end loop;
        end loop;
        
        -- konec
        assert FALSE report "KONEC SIMULACE" severity failure;
        
    end process STIMULI_GEN;


end architecture TB_VGA_BODY;