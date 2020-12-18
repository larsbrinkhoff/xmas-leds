include target/avr/uart.fth

decimal

60 constant length
create buf 3 60 * ram-allot

hex

\ Set port B and C to output.
code setup-output
   FF # r16 ldi,
   04 r16 out, \ DDRB
   FF # r16 ldi,
   07 r16 out, \ DDRC
   ret,
end-code

\ Write to port B.
code !portb ( c -- )
   05 r26 out,
   ' drop rjmp,
end-code

\ Write to port C.
code !portc ( c -- )
   08 r26 out,
   ' drop rjmp,
end-code

\ Send one bit.
code sk6812 ( c -- c' )
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

code 1>>
   r27 lsr,
   r26 ror,
   ret,
end-code

variable seed
: 7<<   2* 2* 2* 2* 2* 2* 2* ;
: 8<<   7<< 2* ;
: 9>>   1>> 1>> 1>> 1>> 1>> 1>> 1>> 1>> 1>> ;
: random ( -- u ) seed @  dup 7<< xor  dup 9>> xor  dup 8<< xor  dup seed ! ;

: setup  setup-uart setup-output  5555 seed ! ;

\ Turn debug LED on or off.
: led-on   01 !portb ;
: led-off   0 !portb ;

\ Send one byte.
: byte ( c -- )
  sk6812 sk6812 sk6812 sk6812 sk6812 sk6812 sk6812 sk6812 drop ;

: c@+ ( a -- a' c ) dup 1+ swap c@ ;
: c!+ ( c a -- a' ) dup >r c!  r> 1+ ;

: light ( a -- a' ) c@+ byte c@+ byte c@+ byte ;
: lights   buf length >r begin light r> 1- dup >r 0= until r> drop drop ;

: delay  0 emit 0 emit 0 emit 0 emit ;
: iteration    ( led-off ) lights ( led-on ) delay ;

variable counter

\ G R B
: x   random 1F and ;
: zero ( a -- a' ) x over c! 1+  x over c! 1+  x over c! 1+ ;
: buffer   buf length >r begin zero r> 1- dup >r 0= until r> drop drop ;

: new?   counter @ 003F and 0= ;
: ?new   new? if led-on buffer then ;

\ Jump here from COLD.
: warm   then setup buffer
         0 counter !
         begin iteration 1 counter +! ?new again ;
