
;*******************************************************************
;	TITLE:	Keypad1 - Telephone keypad scanner
;	AUTHOR:	Richard Shotbolt, LJ Technical Systems 
;	DATE:	18/01/01
;	Version 2
;*******************************************************************

;This program shows a simple method for scanning a telephone-style
;keypad which has a matrix of 4 rows and 3 columns. A logic '0' is
;placed on each key row output in turn. With each row value, the
;three column inputs are checked. When a '0' is found, the row and
;column information is combined to form a unique keycode. The raw
;keycode is then converted to a proper key value. 

;Connections:

;RA0..RA2 to keypad columns KD0..KD2
;RB0..RB6 to display cathodes KA..KG
;RB0..RB3 to keypad rows KD4..KD7 (use stacking plugs)
;RB7 to display anode AN3

;Instructions:

;Build project, program PIC then run hardware. The 7-segment display
;should mirror the value of a key while pressed.

;*********************************************************************
;			DEFINITIONS
;*********************************************************************

	list    P=PIC16F84A, R=D	;Define PIC type and radix
	include "P16F84A.INC"		;register definition file


;****** REGISTER USAGE ******

temp1	equ	0Ch		;temporary register 1
temp2	equ	0Dh		;temporary register 2
rowcode	equ	0Eh		;row register
colcode	equ	0Fh		;column code 0, 4 or 8 for raw key code
kcode	equ	10h		;decoded key value

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

;These are the segment codes corresponding to each hex number
;between 0..B (hex numbers C-F not required)
;Enter with number 00h..0Bh in W
;Exit with corresponnding segment code in W

font	andlw	b'00001111'	;clear top 4 bits
	addwf	PCL,f		;add W to the program counter
	retlw	b'01110111'	;'A'
	retlw	b'01100110'	;'4'
	retlw	b'00000111'	;'7'
	retlw	b'00000110'	;'1'
	retlw	b'00111111'	;'0'
	retlw	b'01101101'	;'5'
	retlw	b'01111111'	;'8'
	retlw	b'01011011'	;'2'
	retlw	b'01111100'	;'b'
	retlw	b'01111101'	;'6'
	retlw	b'01101111'	;'9'
	retlw	b'01001111'	;'3'


;****** GET KEY ROW CODE ******

;converts values 0..3 to key row select codes 

kyrow	addwf	PCL,f
	retlw	b'00000111'
	retlw	b'00001011'
	retlw	b'00001101'
	retlw	b'00001110'


;****** DISPLAY SUBROUTINE ******

;Enter with number to be displayed in W

displ	call	font		;convert value to 7-seg code
	xorlw	b'11111111'	;invert b0..7 for common cathode disp
	movwf	PORTB		;output to port B
	movlw	2		;2ms delay
	call	delay
	clrf	PORTB		;clear port
	return

;****** KEYPAD SCAN ROUTINE ******

kypad	clrf	rowcode		;clear row code	
nrow	movfw	rowcode		;get row code
	call	kyrow
	movwf	PORTB		;output to rows
	nop			;5us delay
	nop
	nop
	nop
	nop
	movlw	0ffh		;check key column inputs
	movwf	kcode
	btfss	PORTA,0		;column 0 ?
	movlw	0		;yes, column code = 0
	btfss	PORTA,1		;column 1 ?
	movlw	4		;yes, column code = 4
	btfss	PORTA,2		;column 2 ?
	movlw	8		;yes, column code = 8
	movwf	colcode
	btfss	colcode,7	;column code = FFh ?
	goto	dcod		;no, key pressed so decode it
	incf	rowcode,f	;yes, try next row
	btfss	rowcode,2	;row code = 0..3 only
	goto	nrow
	return			;no key found, return with FFh in W
dcod	movfw	colcode		;key pressed, get column value
	addwf	rowcode,w	;add row code to get raw keycode
	movwf	kcode
	return			;return with key value in W
	
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

	movlw	b'11111'	;RA0..4 all i/p
	movwf	TRISA
	movlw	b'00000000'	;RB0..7 all o/p
	movwf	TRISB	
	bcf	STATUS,RP0	;select normal register set


;****** MAIN PROGRAM ******	

;RA4 is low when button pressed, high when released

main	call	kypad		;scan keypad
	btfss	kcode,7		;any key down?
	call	displ		;display number
	goto	main		;repeat

        END			;all programs must end with this

