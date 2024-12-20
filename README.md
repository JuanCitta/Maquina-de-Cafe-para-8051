# Maquina-de-Cafe-para-8051

Projeto para Arquitetura de Computadores - CE4411

**Materiais:**

	-4 LEDs
 
	-Input de 4 botões
 
	-Display LCD
 
	-Motor do edsim

**Fluxograma:**
![image](https://github.com/user-attachments/assets/0c321c43-abc6-4c3a-b114-c6d490ad68dd)


**Funcionamento:**
Ao ligar a máquina, será aceso o LED vermelho da posição 0 e também será mostrado uma mensagem das opções de café que podem ser escolhidas.
As mensagems são: 

	- "3 para cafe"
	- "4 para Expresso"
	- "5 para Cappucino"
	- "6 para Latte"

![image](https://github.com/user-attachments/assets/f39d947c-5366-4612-b8c6-73a9fed3fda9)

A escolha deve ser feita apertando um botão dos números de 3 - 6 como indicado pelo LCD.
Após a escolha será ligado o LED laranja da posição 1 e será mostrado a mensagem "Preparando..."

![image](https://github.com/user-attachments/assets/f5d294f2-4b51-4746-8b15-d21472e3cd11)

Após um tempo (esta dependendo da escolha) o LED azul da posição 2 e o motor serão ligados, estes representam a água sendo despejada no filtro. 

![image](https://github.com/user-attachments/assets/373fe21d-9dad-4e92-bff0-e181eaa030d8)

Se a escolha for alguma com Leite, será feito um passo a mais, ligando o motor para rotar pro lado hórario e o LED laranja da posição 1 será aceso. 

![image](https://github.com/user-attachments/assets/48324f04-79d7-4ae7-99bd-1b5d0239f465)

Após a água terminar de passar pelo filtro. O LED verde da posição 3 será ligado, e será mostrada a mensagem de café pronto.

![image](https://github.com/user-attachments/assets/9e0de189-0e0d-4138-ab39-2be1f2846704)


**Dificuldades**
Tivemos dificuldade no início do projeto, pois tentamos usar duas interrupções que levavam as rotinas, que fariam o processo do café.
Mas ao querermos adicionar novos tipos de café, tentamos adaptar o projeto e ter apenas uma interrupção, que confirmaria a seleção do usuário.
Isso gerou diferentes problemas, o mais notável sendo o retorno da interrupção. O programa apenas regsitrava a primeira seleção e após vários testes, decidimos 
tirar a interrupção e manter o loop de verificação de input do usuário que já existia dentro da interrupção.

**Mudanças de Pinos e configuração do EDsim:**
Mudamos alguns Pinos do EDsim51, para o funcionamento do programa os pinos devem estar iguais:

![image](https://github.com/user-attachments/assets/9f7e3138-7f0c-40fa-9cf2-ebdb57740dfc)


Além disso, mudamos a cor do LED 2 para azul e LED 3 para verde.
