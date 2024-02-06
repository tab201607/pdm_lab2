;******************************************************************************
; Universidad del Valle de Guatemala 
; 1E2023: Programacion de Microcontroladores 
; main.asm 
; Autor: Jacob Tabush 
; Proyecto: PreLaboratorio 2
; Hardware: ATMEGA328P 
; Creado: 5/02/2024 
; Ultima modificacion: 6/02/2024 
;*******************************************************************************

.include "M328PDEF.inc"

.def counter=R18 ; reservamos un register para el contador


.cseg
.org 0x00

; STACK POINTER

LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17


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

CALL Timer

Loop:

LDI R17, 10 ; Loop exterior
miniloop:
SBIS TIFR0, 0
RJMP miniloop

LDI R16, 246 ; Cargamos 100 al contador = aproximadamente 10ms
OUT TCNT0, R16

SBI TIFR0, 0 ; Colocamos un 0 TV0 para reiniciar el timer
DEC R17
BRNE miniloop

 

INC counter ; Incrementamos el contador
SBRC counter, 4
LDI counter, 0x00 ; Aseguramos que no haya pasado de los 4 bits

LDI R17, 4 ; Utilizamos left shift para desplegar contador 1 en PD4-7
MOV R16, counter
shift:
LSL R16
DEC R17
BRNE shift

OUT PORTD, R16

RJMP Loop 

Timer: 

LDI R16, (1 << CS02) | (1 << CS00)
OUT TCCR0B, R16 ; prescaler de 1024

LDI R16, 246 ; Cargamos 246 al contador = aproximadamente 10ms
OUT TCNT0, R16 

RET


