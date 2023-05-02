
;*******************************************************************
;	TITLE:	Music1 - Musical Scale program with table access
;	AUTHOR:	Richard Shotbolt, LJ Technical Systems 
;	DATE:	10/10/97
;*******************************************************************

;This program checks a push-button connected to RA0, and plays the
;next musical note in sequence each time it is
;pressed.

;It uses table access and interrupts to generate accurate delays.

;Connections:

;RA0 to upper push button, rising edge
;RA1 to lower push-button, rising edge

;RB0 to PZ piezo sounder

;Instructions:

;Build project, program PIC then run hardware. The program should play
;a musical scale when the upper button is pressed repeatedly. If the
;lower button is pressed, the sound should stop.

;*********************************************************************
;			DEFINITIONS
;*********************************************************************

	list    P=PIC16F84A, R=D	;Define PIC type and radix
	include "P16F84A.INC"		;register definition file

;****** REGISTER USAGE ******

;Port A bits given symbolic names 
lbtn	equ	0		;lower button on RA0
ubtn	equ	1		;upper button on RA1

temp1	equ	0Ch		;temporary register 1
temp2	equ	0Dh		;temporary register 2
count	equ	0Eh		;counter register

flags	equ	0Fh		;used for key-press flags

;Flag bits given symbolic names
prsd	equ	0		;bit 0 used to store <key pressed>
play	equ	1		;bit 1 used for <play> status

tempw	equ	10h		;temp for W during interrupt
temps	equ	11h		;temp for status during interrupt


;*********************************************************************
;			VECTORS
;*********************************************************************

;The PIC16C84 vectors live at the bottom of memory (0000h-0007h)

	org	0000h		;<reset> vector for 16C84 is at 0000h
        goto    start		;go to main program start

	org	0004h		;<int> vector for 16C84 is at 0004h
	goto	inter		;go to start of interrupt service

	org	0008h		;first location available to programs

;*********************************************************************
;			SUBROUTINES
;*********************************************************************

;****** NOTE SEQUENCE TABLE ******

;Subroutine to fetch a value from memory, using the W register as an
;index. The value is used to load TMR0.

notes	addwf	PCL,f		;add W to the program counter
	retlw	32		;timer values for scale
	retlw	58
	retlw	81
	retlw	92
	retlw	111
	retlw	129
	retlw	144
	retlw	150

;*********************************************************************
;			MAIN PROGRAM
;*********************************************************************

;****** INITIALIZATION ******

start	bsf	STATUS,RP0	;select special register set

	movlw	b'11111'	;set port A data dir to 'all inputs'
	movwf	TRISA
	movlw	b'00000000'	;set port B data dir to 'all outputs'
	movwf	TRISB

	;bits 0..2 of the option reg are a prescaler for timer TMR0

	clrf	OPTION_REG	;TMR0 prescale of 1:2
	
	bcf	STATUS,RP0	;select normal register set

	;set TMR0 interrupt and global interrupt enable bits in
	;<INTCON>
	
	movlw	b'10100000'	;allow interrupts from TMR0
	movwf	INTCON
	
	clrf	count		;start with counter clear
	clrf	flags		;clear key flags

;****** MAIN PROGRAM ******	

main	btfsc	PORTA,lbtn	;lower button pressed ?
	goto	nocl		;no
	clrf	count		;yes, clear note index
	clrf	flags		;and flags
	goto	main
nocl	btfsc	PORTA,ubtn	;upper button pressed ?
	goto	lo		;no, display old pattern
	btfsc	flags,prsd	;yes, previous keypress been released ?
	goto	main		;no, dont increment
	btfsc	flags,play	;<play> flag clear ?
	incf	count,f		;yes, increment counter
	bsf	flags,play	;set <play> flag
	bcf	count,3		;count goes from 0..7
	bsf	flags,prsd	;set <pressed> flag
	goto	main
lo	bcf	flags,prsd	;upper button released, so clear flag
	goto	main		;keep looping

;*********************************************************************
;			INTERRUPT SERVICE ROUTINE
;*********************************************************************

;The interrupt service routine below shows the Microchip recommended
;method for saving and restoring registers during an interrupt.

;There is an interrupt 'latency' of about 15us between TMR0 time-out and
;re-loading on line 154 - this was taken into account when calculating
;the values for the note table.

	;save registers
inter	movwf	tempw		;save W register
	swapf	STATUS,w	;save status with nibbles swapped
	movwf	temps		;(swaps don't corrupt status reg!)

	;process TMR0 interrupt
	movfw	count		;get counter into W
	call	notes		;get timer value for note
	movwf	TMR0		;reload timer
	bcf	INTCON,T0IF	;clear TMR0 interrupt flag
	btfsc	flags,play	;<play> flag set ?
	incf	PORTB,f		;yes, increment port B for sq wave

	;restore registers
xint	swapf	temps,w		;retrieve status register
	movwf	STATUS
	swapf	tempw,f		;retrieve W
	swapf	tempw,w		;swaps don't corrupt status reg
	retfie			;return from interrupt
	
        END			;all programs must end with this

