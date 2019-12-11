COMPILE=../xForth/src/compile

all: image

clean:
	-rm -f image

upload: image
	sudo avrdude -c avrispmkII -p atmega328p -U flash:w:image:r -P usb

disassemble: image
	avr-objdump -D -z -b binary -m avr image

image: xmas.fth
	$(COMPILE) $< $@
