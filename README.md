

## Projekt 1: Úloha 1 - Sčítačka/odčítačka celých čísel v přímém kódu




### Implementační platforma

Digilent Basys 3.





### Popis chování

Sčítačka na vstupu přijme 2 osmibitové operandy.

Nejprve je třeba navolit první 8-bitový operand ( 7-bitové číslo + znaménko ) pomocí přepínačů (W13-V17). Volbu je poté nutné potvrdit levým tlačítkem (W19).

Stejným postupem se načte i druhý operand.

Zvolené operandy je možné zkontrolovat pomocí dolního tlačítka (U17).

Pro sečtení obou operandů stiskněte pravé tlačítko (T17), pro jejich odečtení stiskněte horní tlačítko (T18).

Výsledek se následně zobrazí na displeji a je možné celý proces opakovat.
V případě že dojde k přeplnění, rozsvítí se v pravém dolním rohu zelená LEDioda (U16).

V případě potřeby je možné sčítačku kdykoliv zresetovat pomocí prostředního tlačítka (U18).



### Blokové schéma datové cesty


<img src="https://user-images.githubusercontent.com/47743251/229141003-c946c7d4-6125-4e7c-88fc-1debf4b3f755.jpg"  width="600" height="420" />


### Graf přechodů a výstupů řadiče

<img src="https://user-images.githubusercontent.com/47743251/229141051-418d951b-a8f8-4d52-99d4-7537e9b02aef.jpg"  width="600" height="420" />


### Archiv se soubory

![semestralka.zip](https://github.com/igy007/PNO/blob/main/sem_1/semestralka.zip)

### Popis souborů
| Soubor  | Popis  |
| ------------ | ------------ |
| ![datapath.vhd](https://github.com/igy007/PNO/blob/main/sem_1/sources_1/new/datapath.vhd)  | datová cesta  |
| ![controller.vhd](https://github.com/igy007/PNO/blob/main/sem_1/sources_1/new/controller.vhd)  | řídící jednotka  |
|  ![ADDER_SUBTRACTOR.vhd](https://github.com/igy007/PNO/blob/main/sem_1/sources_1/new/ADDER_SUBTRACTOR.vhd) | jádro sčítačky   |
|  ![TOP_LEVEL.vhd](https://github.com/igy007/PNO/blob/main/sem_1/sources_1/new/TOP_LEVEL.vhd) |  top-level entita |
| ![TOP_LEVEL_SW_MODEL.vhd](https://github.com/igy007/PNO/blob/main/sem_1/sources_1/new/TOP_LEVEL_SW_MODEL.vhd)  | top-level softwareová entita (pro verifikaci)  |
| ![TOP_LEVEL_IO.vhd](https://github.com/igy007/PNO/blob/main/sem_1/sources_1/new/TOP_LEVEL_IO.vhd)  |  top-level entita pro implementaci do přípravku  |
| ![TB_ADDER.vhd](https://github.com/igy007/PNO/blob/main/sem_1/sim_1/new/TB_ADDER.vhd)  | testbench - kontrola funkčnosti sčítačky jako standalone komponenty  |
| ![TB_ADDER_SUBTRACTOR.vhd](https://github.com/igy007/PNO/blob/main/sem_1/sim_1/new/TB_ADDER_SUBTRACTOR.vhd)  | testbench - kontrola oproti zlatému standardu  |
| ![HEX2SEG.vhd](https://github.com/igy007/PNO/blob/main/sem_1/sources_1/new/HEX2SEG.vhd)  | převodník na sedmisegmentovky (Autor: Ing. Martin Novotný) |

<br>



## Projekt 2: Úloha 10 - VGA a Ambient Ligth Sensor


### Rozdělení rolí

| Teamy | Členové  |  |
| ------------ | ------------ | ------------ |
|  1. tým |  Jakub Zahradník | Ambient Light Sensor
| 2. tým  |  Dominik Igerský | VGA kontrolér






### Implementační platforma

Digilent Basys 3





### Popis chování

Přípravek periodicky vyčítá informaci o okolním osvětlení z ALS modulu za použití SPI rozhraní 
a tuto 8-bitovou hodnotu poté používá jako Y-ovou souřadnici bílého čtverce (20x20), 
který následně zobrazí na monitoru pomocí standardu VGA.

Pokud na ALS nedopadá žádné (nebo zanedbatelné) světlo, čtverec se nachází uprostřed obrazovky.
Čím více světla dopadá na modul, tím výš se čtverec nachází.

Pro implementační část bez ALS modulu slouží k posunu čtverce po svislé ose
kombinace osmi přepínačů na přípravku počínaje SW0 (LSB) konče SW7 (MSB).
Tyto přepínače simulují 8-bitovou hodnotu vyčtenou z ALS modulu.
POZOR: V tomto režimu se čtverec posouvá odzhora dolu! 
Čím vyšší je hodnota vyčtená z přepínačů, tím níž se bude čtverec nacházet.


### Archiv se soubory

![semestralka2.zip](https://github.com/igy007/PNO/blob/main/sem2_3/semestralka2.zip)

| Soubor  | Popis  |
| ------------ | ------------ |
| ![AMBIENT.vhd](https://github.com/igy007/PNO/blob/main/sem2_3/sources_1/new/AMBIENT.vhd)  | Mobul pro komunikaci s PModem (Autor: Zahradník Jakub)  |
| ![CLK_DIVIDER.vhd](https://github.com/igy007/PNO/blob/main/sem2_3/sources_1/new/CLK_DIVIDER.vhd)  | Hodinová dělička pro korektní VGA časování  |
|  ![TOP_LEVEL.vhd](https://github.com/igy007/PNO/blob/main/sem2_3/sources_1/new/TOP_LEVEL.vhd) |  Top Level entita spojující ALS a VGA  |
| ![VGA.vhd](https://github.com/igy007/PNO/blob/main/sem2_3/sources_1/new/VGA.vhd)  | VGA kontroler  |
| ![TB_AMBIENT.vhd](https://github.com/igy007/PNO/blob/main/sem2_3/sim_1/new/TB_AMBIENT.vhd)  | Testbench pro komunikaci s ALS modulem  |
| ![TB_VGA.vhd](https://github.com/igy007/PNO/blob/main/sem2_3/sim_1/new/TB_VGA.vhd)  | Testbench VGA kontroleru (Autor: Zahradník Jakub)  |
| ![abmient_vga.xdc](https://github.com/igy007/PNO/blob/main/sem2_3/constrs_1/new/ambient_vga.xdc)  |  mapování na IO Basys 3  |


<br>

### Videoukázka funkčního VGA kontroléru ovládaného skrze 8 přepínačů
<a href="https://youtube.com/shorts/SK32eEqqg_Y?feature=share"><img src="https://c3.primacdn.cz/sites/default/files/b/83/3923441-youtubelogonew.jpg"  width="120" height="48" /></a>

(videoukázkou funkčního celku spolu s Ambient Light Senzorem bohužel nedisponuji, jelikož ALS měl k dispozici pouze kolega Zahradník)

<br><br>
### Použité zdroje

    
	https://reference.digilentinc.com/learn/programmable-logic/tutorials/vga-display-congroller/start
	http://tinyvga.com/vga-timing/640x480@60Hz
    
