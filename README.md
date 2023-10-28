# WonderTANG
 TangNano 20K cartridge for MSX computers

This cartridge allows any MSX computer to host a Sipeed Tang Nano 20K. The current fpga core implements:

- MicroSD Nextor 2.1 Drive
- 4MB Memory Mapper
- 2MB Super Mega RAM SCC+
- FM OPLL + MSX Music ROM
- Sega Master System VDP + PSG to allow running SMS roms from SofaRun

The Super Mega RAM SCC+ is a different ACVS-like MegaRam that support different mappers:

- Konami4 (2MB)
- Konami5 SCC+ (512KB)
- ASCII8 (2MB)
- ASCII16 (2MB)

Use the utility SMRAM.COM to allow using different mappers as well activating the SCC+, otherwise it will just work like an ordinary MegaRAM 2MB.

You need to flash the fpga/src/roms/Nextor-2.1.1.WonderTANG.ROM.bin into Tang Nano 20k flash memory using the programmer and selecting exFlash C Bin,Erase and Program at the address 0x100000 and set the flash as Generic Flash.

![image](https://github.com/lfantoniosi/WonderTANG/assets/8690515/991bf115-c866-4e1e-bcf9-e331cb8217ef)

