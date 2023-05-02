
;*******************************************************************
;	TITLE:	Keypad1 - Telephone keypad scanner
;	AUTHOR:	Richard Shotbolt, LJ Technical Systems 
;	DATE:	31/12/97
;*******************************************************************

;This program shows a simple method for scanning a telephone-style
;keypad which has a matrix of 8 rows and 2 columns. A logic '0' is
;placed on each key row output in turn. With each row value, the
;three column inputs are checked. When a '0' is found, the row and
;column information is combined to form a unique keycode. The raw
;keycode is then converted to a proper key value. 

;Connections:

;RA0..RA2 to keypad columns KD0..KD2
;RB0..RB6 to display cathodes KA..KG
;RB0..RB7 to keypad rows KD0..KD7 (use stacking plugs)
;RA3 to display anode AN3

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
count	equ	0Eh		;counter register
kbase	equ	0Fh		;base value 0 or 8 for raw key code
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

;These are the segment codes corresponding to each hex number 0..F
;Enter with number 00h..0Fh in W
;Exit with corresponnding segment code in W

font	addwf	PCL,f		;add W to the program counter
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

;****** GET KEY ROW CODE ******

;converts values 0..7 to key row select codes 

kyrow	addwf	PCL,f
	retlw	b'11111110'
	retlw	b'11111101'
	retlw	b'11111011'
	retlw	b'11110111'
	retlw	b'11101111'
	retlw	b'11011111'
	retlw	b'10111111'
	retlw	b'01111111'
	
;****** CONVERT KEY CODE TO VALUE ******

;converts raw keycodes to correct key values

kyval	addwf	PCL,f
	retlw	0
	retlw	1
	retlw	2
	retlw	3
	retlw	4
	retlw	5
	retlw	6
	retlw	7
	retlw	8
	retlw	9
	retlw	10
	retlw	11
	retlw	12
	retlw	13
	retlw	14
	retlw	15
	retlw	16

;****** DISPLAY SUBROUTINE ******

;Enter with number to be displayed in W

displ	call	font		;convert value to 7-seg code
	xorlw	b'11111111'	;invert b0..7 for common cathode disp
	movwf	PORTB		;output to port B
	bsf	PORTA,3
	movlw	2		;2ms delay
	call	delay
	clrf	PORTB		;clear port
	bcf	PORTA,3
	return

;****** KEYPAD SCAN ROUTINE ******

kypad	clrf	count		;clear row count	
nrow	movfw	count		;get row code
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
	movlw	0		;yes, key base value = 0
	btfss	PORTA,1		;column 1 ?
	movlw	8		;yes, key base value = 8
;	btfss	PORTA,2		;column 2 ?
;	movlw	16		;yes, key base value = 16
	movwf	kbase
	btfss	kbase,7		;base value = FFh ?
	goto	dcod		;no, key pressed so decode it
	incf	count,f		;yes, try next row
	btfss	count,4		;row index = 0..7 only
	goto	nrow
	return			;no key found, return with FFh in W
dcod	movfw	kbase		;key pressed, get base value
	addwf	count,w		;add row index to get raw keycode
	call	kyval		;convert to proper key value
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

	movlw	b'00111'	;RA0..2 all i/p, RA3..RA4 o/p
	movwf	TRISA
	movlw	b'00000000'	;RB0..7 all o/p
	movwf	TRISB	
	bcf	STATUS,RP0	;select normal register set

	clrf	PORTA

;****** MAIN PROGRAM ******	

;RA4 is low when button pressed, high when released

main	call	kypad		;scan keypad
	btfss	kcode,7		;any key down ?
	call	displ		;yes, display it
	goto	main		;repeat

        END			;all programs must end with this

