
;*******************************************************************
;	TITLE:	Timer1 - Simple timer program using a time-waste loop
;	AUTHOR:	Richard Shotbolt, LJ Technical Systems 
;	DATE:	10/10/97
;*******************************************************************

;This program checks a push-button connected to RB0. When it is
;pushed down, an LED lights for 5 seconds.

;This program introduces the use of a 'time-waste loop' to achieve a
;delay in the program.


;Connections:

;RA0 to L0

;RB0 to B0

;Instructions:

;Build project, program PIC then run hardware. The LED will
;light for 5 scoends when the button is pressed.

;*********************************************************************
;			DEFINITIONS
;*********************************************************************

	list    P=PIC16F84A, R=D	;Define PIC type and radix
	include "P16F84A.INC"		;register definition file

;****** REGISTER USAGE ******

temp1	equ	0Ch		;Temporary register 1
temp2	equ	0Dh		;Temporary register 2
count	equ	0Eh		;count register
temp3	equ	0Fh		;Temporary register 3

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


;****** TIME-WASTE ROUTINE FOR 5-SECOND DELAY ******

sec	movlw	50		;do 0.1s delay 50 times
	movwf	temp3
hndms	movlw	100		;do 1ms delay 100 times
	movwf	temp2
onems	movlw	248		;1ms delay
	movwf	temp1
dly	nop			;time-waste for <temp1> * 4 microsec
	decfsz	temp1
	goto	dly
	nop
	decfsz	temp2		;has 1ms delay been done 100 times 
	goto	onems
	decfsz	temp3		;has 0.1ms delay been done 50 times 
	goto	hndms
	return



;*********************************************************************
;			MAIN PROGRAM
;*********************************************************************

;****** INITIALIZATION ******

start	bsf	STATUS,RP0	;select special register set

	movlw	b'00000'	;set port A data dir to 'all outputs'
	movwf	TRISA
	movlw	b'11111111'	;set port B data dir to 'all inputs'
	movwf	TRISB
	
	bcf	STATUS,RP0	;select normal register set
	

;****** MAIN PROGRAM ******	

main	clrf	PORTA		
	btfsc	PORTB,0		;B0 been pressed ?
	goto	main
	bsf	PORTA,0		;light led L0
	call	sec		;call 5 second delay routine

        END			;all programs must end with this

