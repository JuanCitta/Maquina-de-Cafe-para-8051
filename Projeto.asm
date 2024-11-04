;;--- Mapeamento de Hardware (8051) ---
    RS      equ     P3.0    ;Reg Select ligado em P3.0
    EN      equ     P3.1    ;Enable ligado em P3.1
	cafe equ P0.3
	expresso equ P0.4
	cappu equ P0.5
	latte equ P0.6
	luz_standby equ P1.0
	luz_resistencia equ P1.1
	luz_motor equ P1.2
	luz_pronto equ P1.3
	motor equ P3.6
	direcao_motor equ P3.7

org 0000h
	LJMP START

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
esquenta:
DB "Esquentando"
DB 00h
; Fim de Mensagens

; MAIN
org 0100h
START:

; loop que imprime
; as opções que o usuário
; pode escolher
main:
	setb luz_resistencia ; da set no bit da luz em 1 (apagado)
	setb luz_motor ; da set no bit da luz em 1 (apagado)
	setb luz_pronto ; da set no bit da luz em 1 (apagado)
	setb ea  ; habilita interrupções externas
	clr p1.0 ; coloca bit da luz em 0 (ligado)
	ACALL lcd_init ; inicializa o LCD
	mov A, #00h
	ACALL posicionaCursor
	mov DPTR,#mensagem_1          
	ACALL escreveStringROM ; Mostra opção cafe
	mov A, #40h
  	ACALL posicionaCursor
	mov DPTR,#mensagem_2            
  	ACALL escreveStringROM ; Mostra opção expresso
	ACALL delay
	ACALL clearDisplay
	mov A, #00h
	ACALL posicionaCursor
	mov DPTR,#mensagem_3            
	ACALL escreveStringROM ; Mostra opção cappuccino
	mov A, #40h
	ACALL posicionaCursor
	mov DPTR,#mensagem_4            
	ACALL escreveStringROM ; Mostra opção latte

; Loop para verificar a escolha do usuário
verifica:
	jnb latte, e_modo_latte
	jnb cappu, e_modo_cappu
	jnb cafe, e_modo_cafe
	jnb expresso, e_modo_expresso
	JMP verifica ; Verifica novamente

e_modo_cafe:
	ljmp modo_cafe
e_modo_expresso:
	ljmp modo_expresso
e_modo_cappu:
	ljmp modo_cappu
e_modo_latte:
	ljmp modo_latte

; Se foi escolhido 3
modo_cafe:
	setb luz_standby  ; desliga luz p1.0
	cpl luz_resistencia ; liga luz p1.1
	ACALL clearDisplay ; limpa lcd          
	mov A, #00h ; valor onde cursor deve ser colocado        
	ACALL posicionaCursor
	mov DPTR, #PREPARANDO ;
	ACALL escreveStringROM	
	mov a, #70 ; esquenta agua
	ACALL delay_  
	cpl luz_resistencia ; desliga luz p1.1
	cpl motor ; liga o motor
	mov a, #50 ; motor filtro
	cpl luz_motor ; liga p1.2
	ACALL delay_
	cpl motor ; desliga o motor  
	ACALL clearDisplay  
	cpl luz_motor ; desliga p1.2
	mov A, #00h
	ACALL posicionaCursor
	mov DPTR,#pronto      
	cpl luz_pronto ; liga p1.3   
	ACALL escreveStringROM
	mov a, #100
	ACALL delay_
	cpl luz_pronto ; desliga p1.3
	ACALL clearDisplay
	LJMP START
	
; fim 3

; Se foi escolhido 4
modo_expresso:
	setb luz_standby ; desliga luz p1.0
	ACALL faz_expresso ; chama a função de fazer expresso   
	ACALL clearDisplay
	mov A, #00h
	ACALL posicionaCursor
	mov DPTR,#pronto_expr ; escolhe qual mensagem deve ser mostrada
	cpl luz_pronto ; liga a luz p1.3       
	ACALL escreveStringROM
	mov a, #100
	ACALL delay_
	cpl luz_pronto ; desliga a luz p1.3
	ACALL clearDisplay
	LJMP START
; fim 4

; Se foi escolhido 5
modo_cappu:
	setb luz_standby  ; desliga luz p1.0
	clr luz_resistencia ; liga luz p1.1
	ACALL clearDisplay  
	mov A, #00h
	ACALL posicionaCursor
	MOV DPTR,#esquenta ; escolhe da lista de mensagens
	ACALL escreveStringROM
	cpl luz_resistencia ; desliga luz p1.1
	cpl direcao_motor ; faz o motor rodar no sentido anti-horário
	clr luz_motor ; liga luz p1.2
	mov a, #50 ; esquenta leite
	ACALL delay_  
	mov a, #50 ; motor p/leite
	ACALL delay_
	cpl luz_motor ; desliga luz p1.2
	cpl direcao_motor ; retorna o motor pro sentido normal
	ACALL faz_expresso  
 	ACALL clearDisplay  
	mov A, #00h
	ACALL posicionaCursor
	mov DPTR,#pronto_cappu      
	cpl luz_pronto ; liga p1.3   
	ACALL escreveStringROM
	mov a, #100
	ACALL delay_
	cpl luz_pronto ; desliga a luz p1.3
	ACALL clearDisplay
	LJMP START
; fim 5

; Se foi escolhido 6
modo_latte:
	setb luz_standby  ; desliga luz p1.0
	clr luz_resistencia ; liga luz p1.1
	ACALL clearDisplay  
	mov A, #00h
	ACALL posicionaCursor
	MOV DPTR,#esquenta ; escolhe da lista de mensagens
	ACALL escreveStringROM
	cpl luz_resistencia ; desliga luz p1.1
	cpl direcao_motor ; faz o motor rodar no sentido anti-horário
	clr luz_motor ; liga luz p1.2
	mov a, #70 ; esquenta leite
	ACALL delay_  
	mov a, #50 ; motor p/leite
	ACALL delay_
	cpl luz_motor ; desliga luz p1.2
	cpl direcao_motor ; retorna o motor pro sentido normal
	ACALL faz_expresso  
 	ACALL clearDisplay  
	mov A, #00h
	ACALL posicionaCursor
	mov DPTR,#pronto_latte   
	cpl luz_pronto ; liga p1.3   
	ACALL escreveStringROM
	mov a, #100
	ACALL delay_
	cpl luz_pronto ; desliga a luz p1.3
	ACALL clearDisplay
	LJMP START
; fim 6

; Função para fazer expresso
; pois latte, cappu e expresso
; usam expresso
faz_expresso:
	clr luz_resistencia ; liga a luz p1.1
	ACALL clearDisplay           
	mov A, #00h         
	ACALL posicionaCursor
	mov DPTR, #PREPARANDO
	ACALL escreveStringROM
	mov a, #35 ; esquenta água
	ACALL delay_  
	setb luz_resistencia ; desliga a luz p1.1
	cpl motor ; liga motor
	mov a, #25
	clr luz_motor ; liga luz p1.2
	ACALL delay_
	cpl motor ; desliga motor
	setb luz_motor ; desliga luz p1.2
	ret

escreveStringROM:
	MOV R1, #00h
	; Inicia a escrita da String no Display LCD
loop:
	MOV A, R1
	MOVC A,@A+DPTR 	 ; lê da memória de programa
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

