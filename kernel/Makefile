### Add these lines to Nextor kenrnel makefile: source\kernel\Makefile and put the Tang folder inside kernel\drivers folder
### and use: make tang
### flash the Nextor-$(VERSION).WonderTANG.ROM using gowin programmer at adrdess 0x1000000, using external flash and exFlash C Bin option and Generic Flash



### Tang

tang: drivers/Tang/Nextor-$(VERSION).WonderTANG.ROM

drivers/Tang/Nextor-$(VERSION).WonderTANG.ROM: \
	nextor_base.dat \
	drivers/Tang/driver.bin \
	drivers/Tang/chgbnk.bin \
	256.bytes

	cat 256.bytes drivers/Tang/driver.bin > drivers/Tang/_driver.bin
	$(MKNEXROM) nextor_base.dat $@ /d:drivers/Tang/_driver.bin /m:drivers/Tang/chgbnk.bin
	$(call copy_to_bin,$@)

drivers/Tang/chgbnk.bin: \
	drivers/Tang/chgbnk.mac

	$(call assemble,drivers/Tang/chgbnk.mac,--build-type abs --output-file-extension bin)

drivers/Tang/driver.bin: \
	drivers/Tang/driver.mac

	$(call assemble,drivers/Tang/driver.mac,--build-type abs --output-file-extension bin)

