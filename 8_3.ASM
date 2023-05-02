
;*******************************************************************
;	TITLE:	OR gate
;	AUTHOR:	Richard Shotbolt, LJ Technical Systems 
;	DATE:	10/10/97
;*******************************************************************

;This program ORs RB0 with RB1 and shows the result on LED L0 

;Connections:

;RB0 to S0
;RB1 to S1

;RA0 to L0

;Instructions:

;Build project, program PIC then run hardware.

;*********************************************************************
;			DEFINITIONS
;*********************************************************************

	list    P=PIC16F84A, R=D	;Define PIC type and radix
	include "P16F84A.INC"		;register definition file

;****** REGISTER USAGE ******

;For PIC16C84, user RAM starts at 0Ch. The following three definitions
;(the names are arbitrary) will be found useful in many programs.

temp1	equ	0Ch		;temporary register 1
temp2	equ	0Dh		;temporary register 2
count	equ	0Eh		;counter register

;*********************************************************************
;			VECTORS
;*********************************************************************

;The PIC16C84 vectors live at the bottom of memory (0000h-0007h)

	org	0000h		;<reset> vector for 16C84 is at 0000h
        goto    start		;go to main program start

	org	0008h		;first location available to programs

;*********************************************************************
;			MAIN PROGRAM
;*********************************************************************

;****** INITIALIZATION ******

;Before using the I/O ports, the data direction registers must be set
;up. Bit RP0 in the status register selects either the normal register
;set when 0, or the special register set when 1. The data direction
;registers TRISA and TRISB live in the special register set. A '1' in
;these registers sets the corresponding port line to an Input, and
;a '0' makes the corresponding line an output.

start	bsf	STATUS,RP0	;select special register set

	;note use of binary (b'xxxxxxxx') rather than hex

	movlw	b'00000'	;set port A data dir to 'all outputs'
	movwf	TRISA
	movlw	b'11111111'	;set port B data dir to 'all inputs'
	movwf	TRISB
	
	bcf	STATUS,RP0	;select normal register set

;****** MAIN PROGRAM ******	

;The code for the main program goes here

main	rrf	PORTB,w		;moves bit1 of PORTB to bit0 position
	iorwf	PORTB,w		;ORs existing PORT with working register
	andlw	b'00000001'	;only interested in RB0 and RB1
	movwf	PORTA		;output result on PORTA
	goto	main		;keep looping
	
        END			;all programs must end with this

