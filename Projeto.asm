;;--- Mapeamento de Hardware (8051) ---
    RS      equ     P3.0    ;Reg Select ligado em P3.0
    EN      equ     P3.1    ;Enable ligado em P3.1
	cafe equ p0.3
	expresso equ p0.4
	cappu equ p0.5
	latte equ p0.6
	luz_standby equ p1.0
	luz_resistencia equ p1.1
	luz_motor equ p1.2
	luz_pronto equ p1.3
	motor equ p3.6
	direcao_motor equ p3.7

org 0000h
	LJMP START

; Verifica escolha do usuario
org 0003h
int_ext0:
	clr ie0
	call delay
	jnb latte, e_modo_latte
	jnb cappu, e_modo_cappu
	jnb cafe, e_modo_cafe
	jnb expresso, e_modo_expresso
	setb ie0
	reti

;
org 0020h
e_modo_cafe:
	ljmp modo_cafe
e_modo_expresso:
	ljmp modo_expresso
e_modo_cappu:
	ljmp modo_cappu
e_modo_latte:
	ljmp modo_latte

; Mensagens 
org 0040h
mensagem_1:
DB "3 para Cafe"
DB 00h
mensagem_2:
DB "4 para Expresso"
DB 00h
mensagem_3:
DB "5 para Cappucino"
DB 00h
mensagem_4:
DB "6 para Latte"
DB 00h
pronto:
DB "Cafe pronto"
DB 00h
pronto_cappu:
DB "Cappu pronto"
DB 00h
pronto_latte:
DB "Latte pronto"
DB 00h
pronto_expr:
DB "Expresso pronto"
DB 00h
preparando:
DB "Preparando..."
DB 00h
; Fim de Mensagens

;MAIN
org 0100h
START:

; loop que fica imprimindo
; as opcoes ate o usuario escolher
main:
	setb luz_resistencia
	setb luz_motor
	setb luz_pronto
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
	call delay
	ACALL clearDisplay
	mov a, #00h
	ACALL posicionaCursor
	MOV DPTR,#mensagem_3            
  ACALL escreveStringROM
	MOV A, #40h
  ACALL posicionaCursor
	MOV DPTR,#mensagem_4            
  ACALL escreveStringROM
	ACALL clearDisplay
	JMP main

; se foi escolhido 3
modo_cafe:
	cpl luz_standby
	cpl luz_resistencia
	acall clearDisplay           
	MOV A, #00h         
	ACALL posicionaCursor
	MOV DPTR, #PREPARANDO
	ACALL escreveStringROM	
	mov a, #70 ; esquenta agua
	ACALL delay_  
	cpl luz_resistencia
	cpl p3.6
	mov a, #50 ; motor filtro
	cpl luz_motor
	acall delay_
	cpl P3.6   
	ACALL clearDisplay  
	cpl luz_motor 
	MOV A, #00h
	ACALL posicionaCursor
	MOV DPTR,#pronto      
	cpl luz_pronto    
	ACALL escreveStringROM
	mov a, #100
	ACALL delay_
	setb ie0
	reti
; fim 3

; se foi escolhido 4
modo_expresso:
	acall faz_expresso      
	ACALL clearDisplay
	MOV A, #00h
	ACALL posicionaCursor
	MOV DPTR,#pronto_expr
	cpl luz_pronto        
	ACALL escreveStringROM
	mov a, #100
	ACALL delay_
	ljmp main
; fim 4

; se foi escolhido 5
modo_cappu:
	clr luz_resistencia
	mov a, #70 ; esquenta leite
	ACALL delay_  
	setb luz_resistencia
	cpl direcao_motor
	clr luz_motor
	mov a, #50 ; motor p/leite
	acall delay_
	setb luz_motor
	cpl direcao_motor
	acall faz_expresso  
 	ACALL clearDisplay  
	cpl luz_motor 
	MOV A, #00h
	ACALL posicionaCursor
	MOV DPTR,#pronto_cappu      
	cpl luz_pronto    
	ACALL escreveStringROM
	mov a, #100
	ACALL delay_
	ljmp main
; fim 5

; se foi escolhido 6
modo_latte:
	cpl luz_resistencia
	mov a, #70 ; esquenta leite
	ACALL delay_  
	cpl luz_resistencia
	cpl motor
	cpl direcao_motor
	mov a, #50 ; motor p/leite
	acall delay_
	cpl luz_motor
	cpl motor
	cpl direcao_motor
	acall faz_expresso  
 	ACALL clearDisplay  
	cpl p1.2 
	MOV A, #00h
	ACALL posicionaCursor
	MOV DPTR,#pronto_latte    
	cpl p1.3    
	ACALL escreveStringROM
	mov a, #100
	ACALL delay_
	ljmp main
; fim 6

; funcao para fazer expresso
; pois latte, cappu e expresso
; usam expresso
faz_expresso:
	cpl luz_resistencia
	acall clearDisplay           
	MOV A, #00h         
	ACALL posicionaCursor
	MOV DPTR, #PREPARANDO
	ACALL escreveStringROM
	mov a, #35 ; esquenta agua
	ACALL delay_  
	cpl luz_resistencia
	cpl motor
	mov a, #25
	cpl luz_motor
	acall delay_
	cpl motor 
	cpl luz_motor
	ret


escreveStringROM:
  MOV R1, #00h
	; Inicia a escrita da String no Display LCD
loop:
  MOV A, R1
	MOVC A,@A+DPTR 	 ;lÃª da memÃ³ria de programa
	JZ finish		; if A is 0, then end of data has been reached - jump out of loop
	ACALL sendCharacter	; send data in A to LCD module
	INC R1			; point to next piece of data
   MOV A, R1
	JMP loop		; repeat
finish:
	RET
	

; inicializa o display
lcd_init:
	CLR RS		; clear RS - indica que instruÃ§Ãµes estÃ£o sendo enviadas ao mÃ³dulo

; function set	
	CLR P2.7		; |
	CLR P2.6		; |
	SETB P2.5		; |
	CLR P2.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | borda negativa no E

	CALL delay		; aguarda o Busy Flag limpar
					; funÃ§Ã£o set enviada pela primeira vez - diz ao mÃ³dulo para entrar no modo de 4 bits

	SETB EN		; |
	CLR EN		; | borda negativa no E
					; mesma funÃ§Ã£o set high nibble enviada novamente

	SETB P2.7		; low nibble set (apenas P2.7 mudou)

	SETB EN		; |
	CLR EN		; | borda negativa no E
				; funÃ§Ã£o set low nibble enviada
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
	SETB RS  		; setb RS - indica que dados estÃ£o sendo enviados ao mÃ³dulo
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
