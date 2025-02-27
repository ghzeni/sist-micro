; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 19/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
; ========================
; Defini��es dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
; Defini��es dos Ports
; PORT J
GPIO_PORTJ_AHB_LOCK_R    	EQU    0x40060520
GPIO_PORTJ_AHB_CR_R      	EQU    0x40060524
GPIO_PORTJ_AHB_AMSEL_R   	EQU    0x40060528
GPIO_PORTJ_AHB_PCTL_R    	EQU    0x4006052C
GPIO_PORTJ_AHB_DIR_R     	EQU    0x40060400
GPIO_PORTJ_AHB_AFSEL_R   	EQU    0x40060420
GPIO_PORTJ_AHB_DEN_R     	EQU    0x4006051C
GPIO_PORTJ_AHB_PUR_R     	EQU    0x40060510	
GPIO_PORTJ_AHB_DATA_R    	EQU    0x400603FC
GPIO_PORTJ               	EQU    2_000000100000000
; PORT F
GPIO_PORTF_AHB_LOCK_R    	EQU    0x4005D520
GPIO_PORTF_AHB_CR_R      	EQU    0x4005D524
GPIO_PORTF_AHB_AMSEL_R   	EQU    0x4005D528
GPIO_PORTF_AHB_PCTL_R    	EQU    0x4005D52C
GPIO_PORTF_AHB_DIR_R     	EQU    0x4005D400
GPIO_PORTF_AHB_AFSEL_R   	EQU    0x4005D420
GPIO_PORTF_AHB_DEN_R     	EQU    0x4005D51C
GPIO_PORTF_AHB_PUR_R     	EQU    0x4005D510	
GPIO_PORTF_AHB_DATA_R    	EQU    0x4005D3FC
GPIO_PORTF               	EQU    2_000000000100000	
; PORT N
GPIO_PORTN_LOCK_R    	EQU    0x40064520
GPIO_PORTN_CR_R      	EQU    0x40064524
GPIO_PORTN_AMSEL_R   	EQU    0x40064528
GPIO_PORTN_PCTL_R    	EQU    0x4006452C
GPIO_PORTN_DIR_R     	EQU    0x40064400
GPIO_PORTN_AFSEL_R   	EQU    0x40064420
GPIO_PORTN_DEN_R     	EQU    0x4006451C
GPIO_PORTN_PUR_R     	EQU    0x40064510	
GPIO_PORTN_DATA_R    	EQU    0x400643FC
GPIO_PORTN_DATA_BITS_R  EQU    0x40064000
GPIO_PORTN               	EQU    2_001000000000000	


GPIO_PORTJ_AHB_IM_R		EQU		0x40060410
GPIO_PORTJ_AHB_IS_R		EQU		0x40060404	
GPIO_PORTJ_AHB_IBE_R	EQU		0x40060408
GPIO_PORTJ_AHB_IEV_R	EQU		0x4006040C
GPIO_PORTJ_AHB_ICR_R 	EQU		0x4006041C
GPIO_PORTJ_AHB_RIS_R 	EQU		0x40060414
NVIC_EN1_R  EQU		0xE000E104
NVIC_PRI12_R 	EQU		0xE000E430	
	
BIT0	EQU 2_0001
BIT1	EQU 2_0010
	
	
TIMER2_ICR_R 	EQU		0x40032024
TIMER2_CTL_R	EQU		0x4003200C
TIMER2_CFG_R	EQU		0x40032000
TIMER2_TAMR_R	EQU		0x40032004
TIMER2_TAILR_R	EQU		0x40032028
TIMER2_TAPR_R	EQU		0x40032038
TIMER2_IMR_R 	EQU		0x40032018
	
SYSCTL_RCGCTIMER_R	EQU		0x400FE604
SYSCTL_PRTIMER_R 	EQU		0x400FEA04
	
NVIC_PRI5_R			EQU		0xE000E414
NVIC_EN0_R			EQU		0xE000E100
	
SYSCTL_RCGCUART_R   EQU 	0x400FE618
SYSCTL_PRUART_R   	EQU		0x400FEA18
	

UART0_CTL_R 		EQU		0x4000C030
UART0_IBRD_R        EQU		0x4000C024
UART0_FBRD_R        EQU		0x4000C028
UART0_LCRH_R        EQU		0x4000C02C
UART0_CC_R          EQU		0x4000CFC8
	
GPIO_PORTA          EQU    	2_1	
GPIO_PORTA_AHB_AMSEL_R  	EQU		0x40058528
GPIO_PORTA_AHB_PCTL_R   	EQU		0x4005852C
GPIO_PORTA_AHB_AFSEL_R  	EQU		0x40058420
GPIO_PORTA_AHB_DEN_R    	EQU		0x4005851C
; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        PRESERVE8
		;IMPORT inverte
			
		AREA DATA,ALIGN=2
		EXPORT INICIAR [DATA,SIZE=4]
INICIAR		SPACE 4
	
		AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		EXPORT PortF_Output			; Permite chamar PortN_Output de outro arquivo
		;EXPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
		EXPORT PortN_Output							
		EXPORT GPIOPortJ_Handler
		;EXPORT Timer2A_Handler
		
		
;--------------------------------------------------------------------------------
; Fun��o GPIO_Init
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
GPIO_Init
;=====================
; 1. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; ap�s isso verificar no PRGPIO se a porta est� pronta para uso.
; enable clock to GPIOF at clock gating register
            LDR     R0, =SYSCTL_RCGCGPIO_R  		;Carrega o endere�o do registrador RCGCGPIO
			MOV		R1, #GPIO_PORTF                 ;Seta o bit da porta F
			ORR     R1, #GPIO_PORTJ					;Seta o bit da porta J, fazendo com OR
			ORR     R1, #GPIO_PORTA
			
			
			ORR     R1, #GPIO_PORTN
	
			STR     R1, [R0]						;Move para a mem�ria os bits das portas no endere�o do RCGCGPIO
 
            LDR     R0, =SYSCTL_PRGPIO_R			;Carrega o endere�o do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR     R1, [R0]						;L� da mem�ria o conte�do do endere�o do registrador
			MOV     R2, #GPIO_PORTF                 ;Seta os bits correspondentes �s portas para fazer a compara��o
			ORR     R2, #GPIO_PORTJ                 ;Seta o bit da porta J, fazendo com OR
            ORR     R2, #GPIO_PORTA  ;r1
			
			ORR     R2, #GPIO_PORTN   ;;r1
			TST     R1, R2							;ANDS de R1 com R2
            BEQ     EsperaGPIO					    ;Se o flag Z=1, volta para o la�o. Sen�o continua executando
 
; 2. Limpar o AMSEL para desabilitar a anal�gica
            MOV     R1, #0x00						;Colocar 0 no registrador para desabilitar a fun��o anal�gica
            LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R     ;Carrega o R0 com o endere�o do AMSEL para a porta J
            STR     R1, [R0]						;Guarda no registrador AMSEL da porta J da mem�ria
            LDR     R0, =GPIO_PORTF_AHB_AMSEL_R		;Carrega o R0 com o endere�o do AMSEL para a porta F
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta F da mem�ria
            LDR     R0, =GPIO_PORTA_AHB_AMSEL_R		;Carrega o R0 com o endere�o do AMSEL para a porta N
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta N da mem�ria
 
			LDR     R0, =GPIO_PORTN_AMSEL_R			;Carrega o R0 com o endere�o do AMSEL para a porta N
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta N da mem�ria
 
 
; 3. Limpar PCTL para selecionar o GPIO
            MOV     R1, #0x00					    ;Colocar 0 no registrador para selecionar o modo GPIO
            LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		;Carrega o R0 com o endere�o do PCTL para a porta J
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta J da mem�ria
            LDR     R0, =GPIO_PORTF_AHB_PCTL_R      ;Carrega o R0 com o endere�o do PCTL para a porta F
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta F da mem�ria
			MOV     R1, #0x11   
            LDR     R0, =GPIO_PORTA_AHB_PCTL_R      	;Carrega o R0 com o endere�o do PCTL para a porta N
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta N da mem�ria
			
			
			LDR     R0, =GPIO_PORTN_PCTL_R      	;Carrega o R0 com o endere�o do PCTL para a porta N
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta N da mem�ria

; 4. DIR para 0 se for entrada, 1 se for sa�da
            LDR     R0, =GPIO_PORTF_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta F
			MOV     R1, #2_00010001 ;#2_00010001					;PF4 & PF0 para LED
            STR     R1, [R0]						;Guarda no registrador
			; O certo era verificar os outros bits da PF para n�o transformar entradas em sa�das desnecess�rias
            LDR     R0, =GPIO_PORTJ_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta J
            MOV     R1, #0x00               		;Colocar 0 no registrador DIR para funcionar com sa�da
            STR     R1, [R0]						;Guarda no registrador PCTL da porta J da mem�ria
			STR     R1, [R0]						;Guarda no registrador
			
			LDR     R0, =GPIO_PORTN_DIR_R			;Carrega o R0 com o endere�o do DIR para a porta N
			MOV     R1, #2_0011		;#2_0010					;PN1
            STR     R1, [R0]						;Guarda no registrador
			
; 5. Limpar os bits AFSEL para 0 para selecionar GPIO 
;    Sem fun��o alternativa
            MOV     R1, #0x00						;Colocar o valor 0 para n�o setar fun��o alternativa
            LDR     R0, =GPIO_PORTF_AHB_AFSEL_R		;Carrega o endere�o do AFSEL da porta F
            STR     R1, [R0]						;Escreve na porta
            LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R     ;Carrega o endere�o do AFSEL da porta J
            STR     R1, [R0]                        ;Escreve na porta
			
		LDR     R0, =GPIO_PORTN_AFSEL_R			;Carrega o endere�o do AFSEL da porta N
            STR     R1, [R0]						;Escreve na porta
          
			MOV     R1, #0x3
			LDR     R0, =GPIO_PORTA_AHB_AFSEL_R		;Carrega o endere�o do AFSEL da porta N
            STR     R1, [R0]						;Escreve na porta
          
; 6. Setar os bits de DEN para habilitar I/O digital
            LDR     R0, =GPIO_PORTF_AHB_DEN_R			;Carrega o endere�o do DEN
            MOV     R1, #2_0010001 ;#2_00010001                    ;Ativa os pinos PF0 e PF4 como I/O Digital
            STR     R1, [R0]							;Escreve no registrador da mem�ria funcionalidade digital 
 
            LDR     R0, =GPIO_PORTJ_AHB_DEN_R			;Carrega o endere�o do DEN
			MOV     R1, #2_00000011                     ;Ativa os pinos PJ0 e PJ1 como I/O Digital      
            STR     R1, [R0]                            ;Escreve no registrador da mem�ria funcionalidade digital
			
			LDR     R0, =GPIO_PORTA_AHB_DEN_R			    ;Carrega o endere�o do DEN
           MOV     R1, #2_00000011                     
            STR     R1, [R0]							;Escreve no registrador da mem�ria funcionalidade digital 
			
			 LDR     R0, =GPIO_PORTN_DEN_R			    ;Carrega o endere�o do DEN
            MOV     R1, #2_00000011; #2_00000010                     ;N1
            STR     R1, [R0]							;Escreve no registrador da mem�ria funcionalidade digital 
 
; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
			LDR     R0, =GPIO_PORTJ_AHB_PUR_R			;Carrega o endere�o do PUR para a porta J
			MOV     R1, #2_00000011						;Habilitar funcionalidade digital de resistor de pull-up 
                                                        ;nos bits 0 e 1
            STR     R1, [R0]							;Escreve no registrador da mem�ria do resistor de pull-up
            
; 8. Desabilita a interrup no IM

			LDR R0,=GPIO_PORTJ_AHB_IM_R	
			MOV R1,#2_00
			STR R1,[R0]
;9. Config. tipo interrup IS

			LDR R0,=GPIO_PORTJ_AHB_IS_R
			MOV R1,#2_00
			STR R1,[R0]
;10. Config Borda IBE	
			LDR R0,=GPIO_PORTJ_AHB_IBE_R
			MOV R1,#2_00
			STR R1,[R0]
;11. Config IEV
			LDR R0,=GPIO_PORTJ_AHB_IEV_R
			MOV R1,#2_10
			STR R1,[R0]
;12. Config ICR
			LDR R0,=GPIO_PORTJ_AHB_ICR_R
			MOV R1,#2_11
			STR R1,[R0]
			
	;;teste		
			;LDR R0,=GPIO_PORTJ_AHB_RIS_R
			;MOV R1,#2_00
			;STR R1,[R0]
			
;13.Habilita interrup no IM
			LDR R0,=GPIO_PORTJ_AHB_IM_R	
			MOV R1,#2_11
			STR R1,[R0]
;    
;14. Setar prioridade NVIC

			LDR R0,=NVIC_PRI12_R
			MOV R1,#6
			LSL	R1,R1,#29
			STR R1,[R0]
;Habilitar interrup NVIC

			LDR	R0,=NVIC_EN1_R
			MOV R1,#1
			LSL R1,R1,#19
			STR R1,[R0]
			
;			
			LDR R0,=SYSCTL_RCGCTIMER_R
			MOV R1,#2_100
			STR R1,[R0]
			
			LDR     R0, =SYSCTL_PRTIMER_R			;Carrega o endere�o do PRGPIO para esperar os GPIO ficarem prontos
EsperaTIMER LDR     R1, [R0]						;L� da mem�ria o conte�do do endere�o do registrador
			MOV     R2, #2_100
			TST     R1, R2							;ANDS de R1 com R2
            BEQ     EsperaTIMER					    ;Se o flag Z=1, volta para o la�o. Sen�o continua executando
 
			
			LDR R0,=TIMER2_CTL_R
			MOV R1,#2_0
			STR R1,[R0]
			
			
			LDR R0,=TIMER2_CFG_R
			MOV R1,#2_000
			STR R1,[R0]
			
			LDR R0,=TIMER2_TAMR_R
			MOV R1,#2_01
			STR R1,[R0]
			
			LDR R0,=TIMER2_TAILR_R
			MOV R1,#0x31F
			;MOV R1,#0x7DFF
			;MOVT R1,#0x356
			STR R1,[R0]
			
			
			LDR R0,=TIMER2_TAPR_R
			MOV R1,#0
			STR R1,[R0]
			
			LDR R0,=TIMER2_ICR_R
			MOV R1,#2_1
			STR R1,[R0]
			
			LDR R0,=TIMER2_IMR_R
			MOV R1,#2_1
			STR R1,[R0]
			
			
			
			LDR R0,=NVIC_PRI5_R
			MOV R1,#5
			LSL	R1,R1,#29
			STR R1,[R0]
			
			
			LDR	R0,=NVIC_EN0_R
			MOV R1,#1
			LSL R1,R1,#23
			STR R1,[R0]
			
			LDR     R0, =SYSCTL_RCGCUART_R  		
			MOV		R1, #BIT0                
			STR     R1, [R0]
			LDR     R0, =SYSCTL_PRUART_R			
EsperaUART  LDR     R1, [R0]						
			MOV     R2, #2_001
			TST     R1, R2							
            BEQ     EsperaUART					    
 
			MOV     R1, #0x00					    
            LDR     R0, =UART0_CTL_R
			STR     R1, [R0]

			MOV     R1, #520				;9600 Baud Rate	    
            LDR     R0, =UART0_IBRD_R
			STR     R1, [R0] 
			
			MOV     R1, #53					    
            LDR     R0, =UART0_FBRD_R
			STR     R1, [R0] 
			
			
			MOV     R1, #0x60					    
            LDR     R0, =UART0_LCRH_R
			STR     R1, [R0]
			
			MOV     R1, #2_0
			LDR     R0, =UART0_CC_R 
			STR     R1, [R0]
			
			MOV     R1, #2_1100000001
			LDR     R0, =UART0_CTL_R
			STR     R1, [R0] 
;retorno            
		
			LDR R1, =TIMER2_CTL_R
			MOV R0, #1
			STR R0, [R1]
			BX      LR


	

GPIOPortJ_Handler

	PUSH{LR}
	
	
	;MOV R0,#0
	;BL PortN_Output
	
	;MOV R0,#17
	;BL PortF_Output
	LDR R1,=GPIO_PORTJ_AHB_RIS_R
	LDR R0,[R1]
	AND R0,R0,#2_01
	CMP R0,#2_01
	BEQ	sw1
	LDR R1,=GPIO_PORTJ_AHB_ICR_R
	MOV R0,#2_11
	STR R0,[R1]
	POP{LR}
	BX LR
sw1
	;MOV R0,#3
	;BL PortN_Output
	
	;MOV R0,#0
	;BL PortF_Output
	LDR R1,=GPIO_PORTJ_AHB_ICR_R
	MOV R0,#2_1
	STR R0,[R1]
	
	LDR R2, =INICIAR
	MOV R1,#0
	STR R1,[R2]
	
	POP{LR}
	BX LR
	
;Timer2A_Handler
;	LDR R1, =TIMER2_ICR_R
;	MOV R0, #1
;	STR R0, [R1]
;	PUSH {LR}
;	BL inverte  ;Chama a rotina que faz um toggle no led
	
;	LDR R0,=TIMER2_CTL_R
;	MOV R1,#2_1
;	STR R1,[R0]
;	
;	POP {LR} ; retorno da interrup��o
;	BX LR
	
; -------------------------------------------------------------------------------
; Fun��o PortF_Output
; Par�metro de entrada: R0 --> se os BIT4 e BIT0 est�o ligado ou desligado
; Par�metro de sa�da: N�o tem
PortF_Output
	PUSH{LR}
	LDR	R1, =GPIO_PORTF_AHB_DATA_R		    ;Carrega o valor do offset do data register
	;Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #2_00010001                      ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11101110
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o par�metro de entrada
	STR R0, [R1]                            ;Escreve na porta F o barramento de dados dos pinos F4 e F0
	
	POP{LR}
	BX LR									;Retorno

; -------------------------------------------------------------------------------
; Fun��o PortN_Output
; Par�metro de entrada: R0 --> se o BIT1 est� ligado ou desligado
; Par�metro de sa�da: N�o tem
PortN_Output
	PUSH{LR}
	LDR	R1, =GPIO_PORTN_DATA_R		    ;Carrega o valor do offset do data register
	;Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #2_00011                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11111101
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o par�metro de entrada
	STR R0, [R1]                            ;Escreve na porta N o barramento de dados do pino N1
	
	POP{LR}
	BX LR									;Retorno



    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo