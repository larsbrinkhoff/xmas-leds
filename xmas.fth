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

code sk6812
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
  sk6812 sk6812 sk6812 sk6812 sk6812 sk6812 sk6812 sk6812 drop ;

: 12rshift   2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ ;
: 4lshift   2* 2* 2* 2* ;
: d?   [ decimal ] 10 [ hex ] - 0< ;
: h.   dup 12rshift F and dup d? if [char] 0 else [char] 7 then + emit ;
: space   20 emit ;
: . ( u -- ) h. 4lshift h. 4lshift h. 4lshift h. drop space ;
: cr   [ decimal ] 13 emit 10 emit [ hex ] ;

variable offset
\ : lights   offset @ + sk6812-byte dup sk6812-byte 0 sk6812-byte ;
\ : bang   [ decimal ] 60 [ hex ] begin dup lights 1- dup 0= until drop ;
\ : bump   1 offset +!  offset c@ . ;

: lights   dup sk6812-byte 22 + dup sk6812-byte 11 + dup sk6812-byte ;
: bang   [ decimal ] 60 [ hex ] begin swap lights swap 1- dup 0= until drop ;
: bump   dup . dup . dup . dup . ; \ dup . dup . dup . dup . ;

: setup  setup-uart set-output ;
: led-on   01 !portb ;
: led-off   0 !portb ;
\ Jump here from COLD.
: warm   then setup 
         0 offset !
         cr
         1234 .
         0 begin led-off ( key drop ) bang led-on ( key drop ) bump again ;
