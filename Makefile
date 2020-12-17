COMPILE=../xForth/src/compile

AVRDUDE=sudo avrdude -c avrispmkII -p atmega328p -P usb

all: image

clean:
	-rm -f image

upload: image
	$(AVRDUDE) -U flash:w:image:r

disassemble: image
	avr-objdump -D -z -b binary -m avr image

image: xmas.fth
	$(COMPILE) $< $@
