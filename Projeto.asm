;;--- Mapeamento de Hardware (8051) ---
    RS      equ     P3.0    ;Reg Select ligado em P3.0
    EN      equ     P3.1    ;Enable ligado em P3.1
	

org 0000h
	LJMP START
org 0003h
int_ext0:
	setb p1.0
   ACALL modo_cafe 
	CLR IE0
	reti
org 0013h
int_ext1:
	setb p1.0
	ACALL modo_expresso
	clr IE1
	reti

org 0040h
; put data in ROM
mensagem_1:
	DB "1 para Cafe"
  DB 00h
mensagem_2:
  DB "2 para expresso"
  DB 00h
pronto:
DB "Cafe pronto"
DB 00h
pronto_expr:
DB "Expresso pronto"
DB 00h
preparando:
DB "Preparando..."
DB 00h



;MAIN
org 0100h
START:

main:
setb ea
	setb ex0
	setb ex1
	clr p1.0
	ACALL lcd_init
	MOV A, #00h
	ACALL posicionaCursor
	MOV DPTR,#mensagem_1          
	ACALL escreveStringROM
	MOV A, #40h
  ACALL posicionaCursor
	MOV DPTR,#mensagem_2            
  ACALL escreveStringROM
	ACALL clearDisplay
	JMP main

modo_cafe:
	cpl p1.1 ; luz resistencia
	acall clearDisplay           
	MOV A, #00h         
	ACALL posicionaCursor
	MOV DPTR, #PREPARANDO
	ACALL escreveStringROM
	mov a, #70 ; esquenta agua
	ACALL delay_  
	cpl p1.1
	cpl p3.6
	mov a, #50 ; motor filtro
	cpl p1.2
	acall delay_
	cpl P3.6   
 	ACALL clearDisplay  
	cpl p1.2 
	MOV A, #00h
	ACALL posicionaCursor
	MOV DPTR,#pronto      
	cpl p1.3    

	ACALL escreveStringROM

	mov a, #100
	ACALL delay_

modo_expresso:
	cpl p1.1 ; luz resistencia
	acall clearDisplay           
	MOV A, #00h         
	ACALL posicionaCursor
	MOV DPTR, #PREPARANDO
	ACALL escreveStringROM
	mov a, #35 ; esquenta agua
	ACALL delay_  
	cpl p1.1
	cpl p3.6
	mov a, #25 ; motor filtro
	cpl p1.2
	acall delay_
	cpl P3.6   
 	ACALL clearDisplay   
	cpl p1.2
	MOV A, #00h
	ACALL posicionaCursor
	MOV DPTR,#pronto_expr
	cpl p1.3
	          
	ACALL escreveStringROM

	mov a, #100
	ACALL delay_


escreveStringROM:
  MOV R1, #00h
	; Inicia a escrita da String no Display LCD
loop:
  MOV A, R1
	MOVC A,@A+DPTR 	 ;lê da memória de programa
	JZ finish		; if A is 0, then end of data has been reached - jump out of loop
	ACALL sendCharacter	; send data in A to LCD module
	INC R1			; point to next piece of data
   MOV A, R1
	JMP loop		; repeat
finish:
	RET
	

; inicializa o display
lcd_init:
	CLR RS		; clear RS - indica que instruções estão sendo enviadas ao módulo

; function set	
	CLR P2.7		; |
	CLR P2.6		; |
	SETB P2.5		; |
	CLR P2.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | borda negativa no E

	CALL delay		; aguarda o Busy Flag limpar
					; função set enviada pela primeira vez - diz ao módulo para entrar no modo de 4 bits

	SETB EN		; |
	CLR EN		; | borda negativa no E
					; mesma função set high nibble enviada novamente

	SETB P2.7		; low nibble set (apenas P2.7 mudou)

	SETB EN		; |
	CLR EN		; | borda negativa no E
				; função set low nibble enviada
	CALL delay		; aguarda o Busy Flag limpar


; entry mode set
	CLR P2.7		; |
	CLR P2.6		; |
	CLR P2.5		; |
	CLR P2.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | borda negativa no E

	SETB P2.6		; |
	SETB P2.5		; | low nibble set

	SETB EN		; |
	CLR EN		; | borda negativa no E

	CALL delay		; aguarda o Busy Flag limpar


; display on/off control
	CLR P2.7		; |
	CLR P2.6		; |
	CLR P2.5		; |
	CLR P2.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | borda negativa no E

	SETB P2.7		; |
	SETB P2.6		; |
	SETB P2.5		; |
	SETB P2.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | borda negativa no E

	CALL delay		; aguarda o Busy Flag limpar
	RET


sendCharacter:
	SETB RS  		; setb RS - indica que dados estão sendo enviados ao módulo
	MOV C, ACC.7		; |
	MOV P2.7, C			; |
	MOV C, ACC.6		; |
	MOV P2.6, C			; |
	MOV C, ACC.5		; |
	MOV P2.5, C			; |
	MOV C, ACC.4		; |
	MOV P2.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | borda negativa no E

	MOV C, ACC.3		; |
	MOV P2.7, C			; |
	MOV C, ACC.2		; |
	MOV P2.6, C			; |
	MOV C, ACC.1		; |
	MOV P2.5, C			; |
	MOV C, ACC.0		; |
	MOV P2.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | borda negativa no E

	CALL delay			; aguarda o Busy Flag limpar
	CALL delay			; aguarda o Busy Flag limpar
	RET

;Posiciona o cursor na linha e coluna desejada.
posicionaCursor:
	CLR RS	
	SETB P2.7		    ; |
	MOV C, ACC.6		; |
	MOV P2.6, C			; |
	MOV C, ACC.5		; |
	MOV P2.5, C			; |
	MOV C, ACC.4		; |
	MOV P2.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | borda negativa no E

	MOV C, ACC.3		; |
	MOV P2.7, C			; |
	MOV C, ACC.2		; |
	MOV P2.6, C			; |
	MOV C, ACC.1		; |
	MOV P2.5, C			; |
	MOV C, ACC.0		; |
	MOV P2.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | borda negativa no E

	CALL delay			; aguarda o Busy Flag limpar
	CALL delay			; aguarda o Busy Flag limpar
	RET


;Limpa o display
clearDisplay:
	CLR RS	
	CLR P2.7		; |
	CLR P2.6		; |
	CLR P2.5		; |
	CLR P2.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | borda negativa no E

	CLR P2.7		; |
	CLR P2.6		; |
	CLR P2.5		; |
	SETB P2.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | borda negativa no E

	MOV R6, #40
	rotC:
	CALL delay		; aguarda o Busy Flag limpar
	DJNZ R6, rotC
	RET


delay:
	MOV R0, #50
	DJNZ R0, $
	RET
delay_:
    MOV R6, A
    CLR A
delay_loop_modular:
    CALL delay
    DJNZ R6, delay_loop_modular
    RET


