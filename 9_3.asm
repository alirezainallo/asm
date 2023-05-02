
;*******************************************************************
;	TITLE:	Simple counter with debounce
;	AUTHOR:	Richard Shotbolt, LJ Technical Systems 
;	DATE:	18/01/01
;	Version 2
;*******************************************************************

;This program checks a push-button connected to RA4, and increments a
;counter each time it is pressed. Delays are introduced to
;eliminate switch contact bounce. The counter value is shown on one
;seven-segment display.

;Connections:

;RA0 to display anode AN3
;RB0..RB7 to display cathodes KA..KDP
;RA4 to push button B02

;Instructions:

;Build project, program PIC then run hardware. The 7-segment display
;should display the counter value in hexadecimal. The value should
;increment each time the push-button is pressed.

;*********************************************************************
;			DEFINITIONS
;*********************************************************************

	list    P=PIC16F84A, R=D	;Define PIC type and radix
	include "P16F84A.INC"		;register definition file

;****** REGISTER USAGE ******

temp1	equ	0Ch		;temporary register 1
temp2	equ	0Dh		;temporary register 2
count	equ	0Eh		;counter register
flags	equ	10h		;used for key-press flags
togl	equ	0		;display digit toggle flag
prsd	equ	1		;button pressed flag


;*********************************************************************
;			VECTORS
;*********************************************************************

;The PIC16C84 vectors live at the bottom of memory (0000h-0007h)

	org	0000h		;<reset> vector for 16C84 is at 0000h
        goto    start		;go to main program start
	org	0008h		;first location available to programs

;*********************************************************************
;			SUBROUTINES
;*********************************************************************

;****** SEVEN-SEGMENT FONT TABLE ******

;These are the segment codes corresponding to each hex number 0..F
;Enter with number 00h..0Fh in W
;Exit with corresponnding segment code in W

font	andlw	b'00001111'	;clear top 4 bits
	addwf	PCL,f		;add W to the program counter
	retlw	b'00111111'	;'0'
	retlw	b'00000110'	;'1'
	retlw	b'01011011'	;'2'
	retlw	b'01001111'	;'3'
	retlw	b'01100110'	;'4'
	retlw	b'01101101'	;'5'
	retlw	b'01111101'	;'6'
	retlw	b'00000111'	;'7'
	retlw	b'01111111'	;'8'
	retlw	b'01101111'	;'9'
	retlw	b'01110111'	;'A'
	retlw	b'01111100'	;'b'
	retlw	b'00111001'	;'C'
	retlw	b'01011110'	;'d'
	retlw	b'01111001'	;'E'
	retlw	b'01110001'	;'F'

;****** DISPLAY SUBROUTINE ******

;Enter with number to be displayed in W
;Decimal point for first display is on.

displ	clrf	PORTB		;clear old display segments
	bcf	PORTA,0		;and digit drivers
	call	font		;get 7-seg code for lower digit
	xorlw	b'11111111'	;invert	as display is common-anode
	movwf	PORTB		;send to segments
	bsf	PORTA,0		;lower digit anode high
	return			;return
	
;****** TIME-WASTE FOR W MILLISECONDS ******

delay	movwf	temp2
onems	movlw	248		;1ms delay
	movwf	temp1
dly	nop			;time-waste for <temp1> * 4 microsec
	decfsz	temp1
	goto	dly
	nop
	decfsz	temp2		;repeat 1ms delay
	goto	onems
	return


;*********************************************************************
;			MAIN PROGRAM
;*********************************************************************

;****** INITIALIZATION ******

start	bsf	STATUS,RP0	;select special register set
	clrf	PORTA		;clears port A
	clrf	PORTB		;clears port B
	movlw	b'11000'	;RA0..2 o/p, RA3..4 i/p
	movwf	TRISA
	movlw	b'00000000'	;RB0..7 all o/p
	movwf	TRISB	

	bcf	STATUS,RP0	;select normal register set

	clrf	count		;start with counter clear
	clrf	flags		;clear key flags


;****** MAIN PROGRAM ******	

;RA4 is low when button pressed, high when released

main	btfsc	PORTA,4		;button pressed ?
	goto	hi		;no
	movlw	2		;yes, wait 2ms
	call	delay
	btfsc	PORTA,4		;still pressed ?
	goto	disp		;no, keep scanning
	btfsc	flags,prsd	;yes, previous keypress been released ?
	goto	disp		;no, dont increment	
	bsf	flags,prsd	;and set <prsd> flag
	incf	count,f		;increment count
	bcf	count,4		;limit to values 0..0Fh
	goto	disp
hi	movlw	2		;button released
	call	delay		;2ms delay
	btfsc	PORTA,4		;still released ?
	bcf	flags,prsd	;yes, so clear flag
disp	movfw	count		;get count
	call	displ		;display offset
	goto	main		;keep looping

        END			;all programs must end with this

