include target/avr/uart.fth

hex

code set-output
   FF # r16 ldi,
   04 r16 out, \ DDRB
   FF # r16 ldi,
   07 r16 out, \ DDRC
   ret,
end-code

code !portb
   05 r26 out,
   ' drop rjmp,
end-code

code !portc
   08 r26 out,
   ' drop rjmp,
end-code

code sk6812-bit
   0 # 8 sbi,
   r26 rol,
   nop,
   nop,
   here 4 + brcs,
   0 # 8 cbi,
   nop,
   nop,
   nop,
   nop,
   nop,
   here 4 + brcc,
   0 # 8 cbi,
   ret,
end-code

: sk6812-byte ( c -- )
  sk6812-bit sk6812-bit sk6812-bit sk6812-bit 
  sk6812-bit sk6812-bit sk6812-bit sk6812-bit drop ;
\ : bang   00 sk6812-byte 80 sk6812-byte 00 sk6812-byte
\          80 sk6812-byte 00 sk6812-byte 00 sk6812-byte
\          00 sk6812-byte 00 sk6812-byte 80 sk6812-byte
\          00 sk6812-byte 80 sk6812-byte 00 sk6812-byte
\          80 sk6812-byte 00 sk6812-byte 00 sk6812-byte
\          00 sk6812-byte 00 sk6812-byte 80 sk6812-byte ;
: bang   [ decimal ] 50 [ hex ] begin dup sk6812-byte dup sk6812-byte dup sk6812-byte 1- dup 0= until drop ;

: more ( x -- x' ) dup 40 = if drop 1 then ;
: cycle ( x -- x' ) dup dup + swap !portc more ;

variable n
variable x

: setup  setup-uart set-output  200 n !  100 x ! ;
: delay   begin 1- dup 0= until drop ;
: led-on   01 !portb 300 delay ;
: led-off   0 !portb 300 delay ;
\ Jump here from COLD.
: warm   then setup 
         begin led-off key drop bang led-on key drop again ;
