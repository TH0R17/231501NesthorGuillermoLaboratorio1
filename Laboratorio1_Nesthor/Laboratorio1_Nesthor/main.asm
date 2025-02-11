;
; Laboratorio1_Nesthor.asm
;
.include "M328PDEF.inc"

.cseg
.org 0x0000

    LDI R16, 0x00     ; Cargar 0 en R16
    STS UCSR0B, R16   ; Deshabilitar 

//Configuración de pila //0x08FF
LDI R16, LOW(RAMEND) // Cargar 0xFF a R16
OUT SPL, R16 // Cargar 0xFF a SPL
LDI R16, HIGH(RAMEND)
OUT SPH, R16 // Cargar 0x08 a SPH


//Predeterminado
main:
		LDI R16, 0x00
		OUT DDRC,R16 // Declaramos el puerto C en entrada
		LDI R16, 0xFF
		OUT PORTC, R16 //Declaramos pull-ups
		
		// Configurar Puerto D como salida 
		LDI R16, 0xFF
		OUT DDRD, R16 // Declaramos como salida
		LDI R16, 0x00
		OUT PORTD, R16 //El puerto D conduce cero logico.

		// Configurar Puerto B como salida 
		LDI R16, 0xFF
		OUT DDRB, R16 // Declaramos puerto B como salida
		LDI R16, 0x00
		OUT PORTB, R16 //El puerto B conduce cero logico.

		// Iniciamos estas direcciones en 0
		LDI R17, 0x7F 
		LDI R18, 0x00 
		LDI R19, 0x00 
		LDI R20, 0x00 
		 
Inicio:

		IN R16,PINC //Leer PUERTO C
		CP R17,R16 //Comparar el estado anterior de los botones con el estado actual.
		BREQ Inicio //Si son iguales regresa al inicio.
		CALL DELAY
		IN R16,PINC
		CP R17,R16 //Comparar si realmente se pulso el boton
		BREQ Inicio 
		MOV R17, R16
		//¿Qué boton se presiono?
		SBRS R16, 0
		CALL AU1 //Aumentar el contador 1
		SBRS R16, 1 
		CALL DE1 //Aumentar el contador 1
		SBRS R16, 2 
		CALL AU2 //Aumentar el contador 1
		SBRS R16, 3
		CALL DE2 //Aumentar el contador 1
		SBRS R16, 4 
		CALL SUM
		RJMP Inicio


AU1:

		CPI R18, 0x0F
		BREQ REI1
		INC R18
		OUT PORTD, R18
		RET
REI1:
		LDI R18, 0x00
		OUT PORTD, R18
		RET

DE1:

		CPI R18, 0x00
		BREQ REI2
		DEC R18
		OUT PORTD, R18
		RET
REI2:
		LDI R18, 0x0F
		OUT PORTD, R18
		OUT PORTB, R19
		RET


//Contador 2
AU2:

		CPI R18, 0x0F
		BREQ REI3
		INC R18
		OUT PORTB, R18
		RET
REI3:
		LDI R18, 0x00
		OUT PORTB, R18
		RET

DE2:

		CPI R18, 0x00
		BREQ REI4
		DEC R18
		OUT PORTB, R18
		RET
REI4:
		LDI R18, 0X0F
		OUT PORTB, R18
		RET


SUM:
	MOV R20, R18
	ADD R20, R19
	//Comparar que bits estan encendidos
	SBRC R20, 0 
	SBR R18, (1 << 4) 
	SBRC R20, 1 
	SBR R18, (1 << 5) 
	SBRC R20, 2 
	SBR R18, (1 << 6) 
	SBRC R20, 3
	SBR R18, (1 << 7)
	SBRC R20, 4 
	SBR R19, (1 << 4) 
	OUT PORTB, R19
	OUT PORTD, R18
	RET

//Tiempo de espera
DELAY:
		LDI R31, 0xFF
		LOOP_DELAY:
		DEC R31
		CPI R31, 0
		BRNE LOOP_DELAY
		RET