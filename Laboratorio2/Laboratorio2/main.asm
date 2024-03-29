;******************************************************************************
; Universidad del Valle de Guatemala 
; 1E2023: Programacion de Microcontroladores 
; main.asm 
; Autor: Jacob Tabush 
; Proyecto: Laboratorio 2
; Hardware: ATMEGA328P 
; Creado: 7/02/2024 
; Ultima modificacion: 7/02/2024 
;*******************************************************************************

.include "M328PDEF.inc"

.def counter1=R18 ; reservamos un register para el contador




.cseg
.org 0x00

; STACK POINTER

LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17

; nuestra tabla de valores del 7 seg, con pin0 = a, pin1 = b...
tabla7seg: .DB  0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67, 0x77, 0x7C, 0x58, 0x5E, 0x79, 0x71

; ///////////////////////////////////////////////////////
; Configuracion
; ///////////////////////////////////////////////////////

Setup:

;  prescaler

LDI R16, 0b1000_0000
STS CLKPR, R16

LDI R16, 0b0000_0011 ;1 MHz
STS CLKPR, R16 

LDI R16, 0xFF
OUT DDRD, R16 ;Ponemos a todo D como salidas
LDI R16, 0x00
OUT PORTD, R16 ; Apagamos todas las salidas

LDI R16, 0b0111_1111
OUT DDRC, R16 ; Ponemos a C0-C5 como salidas
LDI R16, 0x00
OUT PORTC, R16 ; Apagamos todas estas

LDI R16, 0b0010_0000
OUT DDRB, R16 ; Ponemos a todo B (menos a PB5) como entradas
LDI R16, 0x1F
OUT PORTB, R16 ; hablitamos pullups en todo B (menos a PB5)

LDI R16, 0x00
STS UCSR0B, R16 ; deshablitamos el serial en pd0 y pd1

LDI counter1, 0x00

Loop:
 
 SBIS PINB, PB0 ;Saltamos a increment si PB0 esta en 0 (recordar pullup)
CALL increment1

SBIS PINB, PB1 ;Saltamos a decrement si PB1 esta en 0 (recordar pullup)
CALL decrement1

LDI ZL, LOW(tabla7seg << 1) ; Seleccionamos el ZL para encontrar al bit bajo en el flash
LDI ZH, HIGH(tabla7seg << 1) ; Seleccionamos el ZH para ecnontar al bit alto en el flash

ADD ZL, counter1 ; Le agreagamos el valor del counter1, para ir al valor especifico de la tabla
LPM R16, Z ; Cargamos el valor del tabla a R16

OUT PORTD, R16 ; Cargar el valor a PORTD

RJMP Loop 


; ///////////////////////////////
; Modulos de incremento, decremento y delay
; //////////////////////////////

increment1: ; Modulo para incrementar en el contador 1
CALL delay

	SBIS PINB, PB0 ; confirmamos que esta en 0
	RJMP increment1

	INC counter1
	SBRC counter1, 4 ; revisamos que no aumenta mas de los 4 bits
	LDI counter1, 0x0F

	RET

decrement1: ;  Modulo para decrementar en el contador 1
	CALL delay

	SBIS PINB, PB1 ; confirmamos que esta en 0
	RJMP decrement1

	DEC counter1
	SBRC counter1, 7 ; revisamos que no hace wraparound para estar de mas de 4 bits
	LDI counter1, 0x00

	RET

delay:
LDI R17, 5 ; loop externo
delayouter:
LDI R16, 250 ; loop interno
delayinner:
	DEC R16
	BRNE delayinner

	DEC R17
	BRNE delayouter

RET


