# WonderTANG
## TangNano 20K cartridge for MSX computers

This cartridge allows any MSX computer to host a Sipeed Tang Nano 20K. The current fpga core implements:

- MicroSD Nextor 2.1 Drive
- 4MB Memory Mapper
- 2MB Super Mega RAM SCC+
- FM OPLL + MSX Music ROM
- Sega Master System VDP + PSG to allow running SMS roms from SofaRun

## The Super Mega RAM SCC+

The Super Mega RAM SCC+ is a different ACVS-like MegaRam that support different mappers:

- Konami4 (2MB)
- Konami5 SCC+ (512KB)
- ASCII8 (2MB)
- ASCII16 (2MB)

Use the utility SMRAM.COM to allow using different mappers as well activating the SCC+, otherwise it will just work like an ordinary MegaRAM 2MB.

## Bill of Materials

Please contribute with the author of the project ordering PCBs from the following link: https://www.pcbway.com/project/shareproject/TangNano_20K_Cartridge_for_MSX.html

A small part of the money will be donated to the author of the project.

The following table shows the basic components needed to build the cartridge:

| Reference                   | Value                      | Description                                          | Qty | Link        |
|-----------------------------|----------------------------|------------------------------------------------------|-----|-------------|
| C5, C6, C7, C8, C9, C10, C11, C12 | DIP-100NF                  | MLCC Monolithic Ceramic Capacitor DIP 100nF (104)     | 8   | AliExpress  |
| C2, C4                      | DIP-1UF                    | MLCC Monolithic Ceramic Capacitor DIP 1uF (105)      | 2   | AliExpress  |
| R2, R3                      | DIP-47R                    | Resistor PTH 47R                                     | 2   | AliExpress  |
| R1                          | DIP-330R                   | Resistor PTH 330R                                    | 1   | AliExpress  |
| R4                          | DIP-4.7K                   | Resistor PTH 4.7KR                                   | 1   | AliExpress  |
| R5                          | DIP-2.2K                   | Resistor PTH 2.2KR                                   | 1   |             |
| D1                          | LED-3MM                    | LED 3MM Red                                          | 1   | AliExpress  |
| D2                          | 1N5817                     | SCHOTTKY BARRIER RECTIFIER DIODE                    | 1   | AliExpress  |
| U1, U2, U3, U4, U6          | SOCKET-DIP-NARROW-20       | DIP Socket Narrow 20 pins                            | 5   | AliExpress  |
| U1, U2, U3, U4, U6          | SN74LVC245AN               | OCTAL BUS TRANSCEIVER WITH 3-STATE OUTPUTS           | 5   | AliExpress  |
| Q1                          | 2N3904                     | 2N3904 NPN switching Transistor                      | 1   | AliExpress  |
| J2                          | SJ1-3533NG                 | SJ1-3533NG Audio P4 3 Pin connector                  | 1   | AliExpress  |
| C1, C3, C13                 | ELEC-DIP-10UF-16V          | Electrolytic Capacitor DIP 10uF 16V                  | 3   | AliExpress  |
| J1, J3                      | PH-254-S-M-40-BLACK        | 2.54mm 1 x 40 Pin Male Single Row Pin Header Strip Black | 1 | AliExpress  |

## Building the Cartridge

Barebons PCBs can be ordered from PCBWay: 

<a href="https://www.pcbway.com/project/shareproject/WonderTANG_v1_01c_ba2c16ea.html"><img src="https://www.pcbway.com/project/img/images/frompcbway-1220.png" alt="PCB from PCBWay" /></a>

## How to Program the Tang Nano 20K

Install the Gowin Educative IDE or just the programmer if you want to just flash the files on your board. You can install it from https://www.gowinsemi.com/ by providing your personal data and registering. Please reboot your computer after installing the drivers.

Connect your TangNano board to the computer USB and open the Gowin Programmer software. Please note that we will be just programming the board, so you will not effectively use the IDE at this time. You should see the following message indicating that your board/cable was recognized. 

![Cable Detected](images/image-6-1024x546.png)

Click Add Device. You will see a new device on the list. Click on the Series and select GW2AR.

![Device Selection](images/image-7-1024x545.png)

Now double click the device on the list and set Access Mode = External Flash Mode, Operation = exFlash Erase, Program thru GAO-Bridge. Click the elipsis and select the WonderTANG.fs file. Select Generic Flash as the Device and make sure the address 0x000000 is selected. Click Save.

![Alt text](images/image-9-1024x547.png)

Click Add Device again. Set the Series to GW2AR. Double click on the device and set Access Mode = External Flash Mode, select Operation = exFlash C Bin Erase, Program thru GAO-Bridge. Click the elipsis and select the Nextor-2.1.1.WonderTANG.ROM.bin file. Select Generic Flash as the Device and make sure the address 0x100000 is selected. Click Save.

![Alt text](images/image-10-1024x547.png)

Now Enable just the first device on the list, go to the Edit menu and select Program/Configure (or click the program button).

<div style="display: flex; justify-content: space-between;">
    <img src="images/image-12-1024x547.png" alt="Alt text" width="400"/> &nbsp;
    <img src="images/image-13-1024x551.png" alt="Alt text" width="400"/>
</div>
&nbsp;

Repeat the steps now enabling just the second device on the list. That will save the BIOS on the flash.

<div style="display: flex; justify-content: space-between;">
    <img src="images/image-14-1024x550.png" alt="Alt text" width="400"/> &nbsp;
    <img src="images/image-15-1024x550.png" alt="Alt text" width="400"/>
</div>
&nbsp;

