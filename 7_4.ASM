
;*******************************************************************
;	TITLE:	Button Press 
;	AUTHOR:	Richard Shotbolt, LJ Technical Systems 
;	DATE:	10/10/97
;*******************************************************************

;This program reads the state of the buttons B0 and B1 and
;lights a corresponding LED if pressed. 

;Connections:

;RA0 to L0
;RA1 to L1

;RB0 to B0
;RB1 to B1

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

main	bcf	PORTA,0		;turn off LED L0
	btfss	PORTB,0		;button B0 pressed?
	bsf	PORTA,0		;yes, light LED L0

	bcf	PORTA,1		;turn off LED L1
	btfss	PORTB,1		;button B1 pressed?
	bsf	PORTA,1		;yes, light LED L1

	goto	main		;keep looping
	
        END			;all programs must end with this

