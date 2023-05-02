
;*******************************************************************
;	TITLE:	Interrupt demonstration program
;	AUTHOR:	Richard Shotbolt, LJ Technical Systems 
;	DATE:	26/01/98
;*******************************************************************

;This program will turn LED L0 on and off every 1/4 second.
;when an interrupt occurs fro RB0 or port change another LED wil light.


;Connections:

;RA0 to L0
;RA3 to L3
;RA4 to L4
;B0 to RB0
;B1 to RB4
;RB5..RB7 to S5.S7

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
temp3	equ	11h		;Temporary register 3
itemp1	equ	12h
itemp2	equ	13h
itemp3	equ	14h


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
;			SUBROUTINES
;*********************************************************************

;****** TIME-WASTE ROUTINE FOR 1/4-SECOND DELAY ******

delay	movlw	10		;do 0.1s delay 10 times
	movwf	temp3
hndms	movlw	25		;do 1ms delay 25 times
	movwf	temp2
onems	movlw	248		;1ms delay
	movwf	temp1
dly	nop			;time-waste for <temp1> * 4 microsec
	decfsz	temp1
	goto	dly
	nop
	decfsz	temp2		;has 1ms delay been done 25 times 
	goto	onems
	decfsz	temp3		;has 0.1ms delay been done 12 times 
	goto	hndms
	return

;****** DEDICATED INTERRUPT TIME-WASTE ROUTINE FOR 1-SECOND DELAY ******

idelay	movlw	10		;do 0.1s delay 10 times
	movwf	itemp3
ihndms	movlw	100		;do 1ms delay 100 times
	movwf	itemp2
ionems	movlw	248		;1ms delay
	movwf	itemp1
idly	nop			;time-waste for <temp1> * 4 microsec
	decfsz	itemp1
	goto	idly
	nop
	decfsz	itemp2		;has 1ms delay been done 100 times 
	goto	ionems
	decfsz	itemp3		;has 0.1ms delay been done 50 times 
	goto	ihndms
	return


;*********************************************************************
;			MAIN PROGRAM
;*********************************************************************

;****** INITIALIZATION ****** 

;The initialization section now includes setup for the timer TMR0
;and the interrupts.

start	bsf	STATUS,RP0	;select special register set

	movlw	b'00000'	;set port A to 'all outputs'
	movwf	TRISA
	movlw	b'11111111'	;set port B data dir to 'all inputs'
	movwf	TRISB


	bcf	STATUS,RP0	;select normal register set

	;set RB0, port change interrupt and global interrupt enable bits in 
	;INTCON
	
	movlw	b'10011000'	;allow interrupts from RB0 and PORT Change
	movwf	INTCON

	clrf	PORTA
	
;****** MAIN PROGRAM ******	

main	bsf	PORTA,0		;turn on LED
	call	delay
	bcf	PORTA,0		;turn off LED
	call	delay
	goto	main		;main program just loops
	
;*********************************************************************
;			INTERRUPT SERVICE ROUTINE
;*********************************************************************
	
;The interupt service routine below shows the Microchip recommended
;method for saving and restoring register during an interrupt

	;save registers
inter	movwf	tempw		;save W register
	swapf	STATUS,w	;save status with nibbles switched
	movwf	temps

trb1	btfss	INTCON,INTF	;interrupt from RB0/INT ?
	goto	level		;no, try level change

	;process RB0 interrupt
	bcf	INTCON,INTF	;clear RB0/INT flag
	bsf	PORTA,3		;turn on LED L3
	call	idelay
	bcf	PORTA,3		;turn off LED L3
	goto	xint

level	btfss	INTCON,RBIF	;interrupt from level change ?
	goto	xint		;no, exit

	;process level change interrupt
	movfw	PORTB
	bcf	INTCON,RBIF	;clear level change flag
	bsf	PORTA,4		;turn on LED L4
	call	idelay
	bcf	PORTA,4		;turn off LED L4

	;restore registers
xint	swapf	temps,w		;retrieve status register
	movwf	STATUS
	swapf	tempw,f		;retrieve W
	swapf	tempw,w
	retfie			;return from interrupt
	
	
        END			;all programs must end with this

