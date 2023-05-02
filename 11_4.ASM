
;*******************************************************************
;	TITLE:	Timer2 - Timer program using interrupts time-waste loop
;	AUTHOR:	Richard Shotbolt, LJ Technical Systems 
;	DATE:	10/10/97
;*******************************************************************

;This program wil light LED L0 every time TMR0 overflows.



;Connections:

;RA0 to L0



;*********************************************************************
;			DEFINITIONS
;*********************************************************************

	list    P=PIC16F84A, R=D	;Define PIC type and radix
	include "P16F84A.INC"		;register definition file


;****** REGISTER USAGE ******

temp1	equ	0Ch		;Temporary register 1
temp2	equ	0Dh		;Temporary register 2
count	equ	0Eh		;count register
tempw	equ	0Fh		;temp for W register during interrupt
temps	equ	10h		;temp for status register during interrupt


;*********************************************************************
;			VECTORS
;*********************************************************************

;The PIC16C84 vectors live at the bottom of memory (0000h-0007h)

	org	0000h		;<reset> vector for 16C84 is at 0000h
        goto    start		;go to main program start

	org	0004h		;<interrupt> vector for 16C84 is at 0004h
        goto    inter		;go to ISR


	org	0008h		;first location available to programs
	
;*********************************************************************
;			MAIN PROGRAM
;*********************************************************************

;****** INITIALIZATION ****** 

;The initialization section now includes setup for the timer TMR0
;and the interrupts.

start	bsf	STATUS,RP0	;select special register set

	movlw	b'11110'	;set RA0 to output'
	movwf	TRISA
	movlw	b'00000000'	;set port B data dir to 'all outputs'
	movwf	TRISB

	;bits 0..2 of the option register are a prescaler for timer TMR0 

	movlw	b'00000111'	;TMR0 prescaler value to 8
	movwf	OPTION_REG

	bcf	STATUS,RP0	;select normal register set

	;set TMR0 interrupt and global interrupt enable bits in 
	;INTCON
	
	movlw	b'10100000'	;allow interrupts from TMR0
	movwf	INTCON


;****** MAIN PROGRAM ******	

main	goto	main		;main program just loops
	
;*********************************************************************
;			INTERRUPT SERVICE ROUTINE
;*********************************************************************
	
;The interupt service routine below shows the Microchip recommended
;method for saving and restoring register during an interrupt

	;save registers
inter	movwf	tempw		;save W register
	swapf	STATUS,w	;save status with nibbles switched
	movwf	temps

	;process TMR0 interrupt
	bcf	INTCON,T0IF	;clear TMR0 interrupt flag
	movlw	1
	xorwf	PORTA,f		;Light LED

	;restore registers
xint	swapf	temps,w		;retrieve status register
	movwf	STATUS
	swapf	tempw,f		;retrieve W
	swapf	tempw,w
	retfie			;return from interrupt
	
	
        END			;all programs must end with this

