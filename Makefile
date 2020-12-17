COMPILE=../xForth/src/compile

AVRDUDE=sudo avrdude -c avrispmkII -p atmega328p -P usb

all: image

clean:
	-rm -f image

upload: image
	$(AVRDUDE) -U flash:w:image:r

fuses: efuse hfuse lfuse
	$(AVRDUDE) -U efuse:r:efuse:h -U hfuse:r:hfuse:h -U lfuse:r:lfuse:h
	$(AVRDUDE) -U lfuse:w:0xFF:m

disassemble: image
	avr-objdump -D -z -b binary -m avr image

image: xmas.fth
	$(COMPILE) $< $@
