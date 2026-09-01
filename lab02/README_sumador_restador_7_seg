# Lab02 - Sumador/Restador de 4 bits + 7seg

# Integrantes
* [Sergio Luis Sandoval Briceño](https://github.com/chesan36) 
* [Kevinn ferney Mora Moreno](https://github.com/kevinfemoramo-gif) 
* [Kevin Steeven Blanco Montealegre](https://github.com/kevinstblancomo-gif) 
# Informe

Indice:

1. [Documentación](#documentación-de-los-circuitos-implementados-implementado)
2. [Simulaciones](#simulaciones)
3. [Evidencias de implementación](#evidencias-de-implementación)
4. [Preguntas](#preguntas)
5. [Conclusiones](#conclusiones)
6. [Referencias](#Referencias)

## Documentación del diseño implementado
Este es el primer laboratorio de la materia de arquitectura de procesadores, el objetivo principal es realizar un sumador restador en el "lenguaje de programación" verilog.
teniendo en cuenta las entradas, los acarreo de entrada y salida, y la salida. 

### 1. Sumador/Restador

#### 1.1 Descripción
    input [3:0] a_4b,
    input [3:0] b_4b,
    input sel,
    output [3:0] s_4b,
    output cout

Un sumador restador en una FPGA lo podemos realizar como un circuito aritmético combinacional, que es capaz de realizar tanto una suma como una resta, de dos números binarios, que son nuestras entradas A y B, para escoger si es una suma o una resta se decide mediante una señal en este caso, una entrada llama sel de un bit.
La genialidad de este circuito radica en las matemáticas binarias: en lugar de construir un circuito complejo dedicado exclusivamente a restar, el procesador transforma la resta en una suma utilizando el "Complemento a 2". (Gemini).
usamos la regla matemática 

    A-B=A+(-B)

En binario, el negativo de un numero por ejemplo (-B) se obtiene invirtiendo todos sus bits (complemento a 1) y sumándole un 1 en binario al resultado final. 
el sumador restador hace esto por hardware o sea por medio de compuertas. 
La operación básica que usamos para hacer posible este circuito son las siguientes operaciones.

**DESCRIPCION SUMADOR DE UN BIT**

    assign cout = b&cin | a&cin | a&b;
    assign s = a ^ (b ^ cin);
Usando compuertas como and (&), or (|), y xor (^). esta configuracion la podemos encontrar en el modulo principal del sumador de un bit.

  <img width="300" height="300" alt="image" src="https://github.com/user-attachments/assets/077f0233-6402-422e-81e5-418988884932" />

**DESCRIPCION SUMADOR DE CUATRO BITs:**

Para crear un sumador de 4 bits, se utilizan cuatro sumadores de 1 bit conectados en serie. Así, el acarreo de salida de un sumador de 1 bit se convierte en el acarreo de entrada del siguiente sumador. Cada bit de los dos números que se están sumando se procesa de manera paralela.
tomando como punto de partida el sumador de bit debemos instanciar varios módulos del sumador de 1 bit y conectar sus entradas y salidas de manera que manejen el acarreo entre cada bit.

<img width="2000" height="700" alt="image" src="https://github.com/user-attachments/assets/7891c301-2449-43c7-89ca-8b5ad095910f" />

**Funcionamiento:**

-Cada instancia del sumador de 1 bit toma 1 bits de las entradas A y B, y un acarreo de entrada Ci. Calcula la suma de estos bits y produce una suma de un bit So y un acarreo de salida Co.

-El acarreo de salida de un sumador de 1 bit se usa como acarreo de entrada para el siguiente sumador de 1 bit en la cadena.

-El sumador de 4 bits produce una salida final So de 4 bits y un acarreo de salida final Co.

**DESCRIPCION SUMADOR RESTADOR**

Para lograr la configuración de este circuito necesitamos tres cosas:

**Sumadores Completos (Full Adders)**: Es la cadena principal que realiza la suma matemática. Cada bloque suma un bit de **A**, un bit de **B**, y un bit de acarreo de entrada **Cin**, entregando un bit de resultado y un acarreo de salida.

**Compuertas XOR:** Se colocan exclusivamente en las entradas del operando $B$. Actúan como "inversores condicionales".
-Si una de las entradas de la compuerta XOR es 0, el bit de $B$ pasa intacto.
-Si la entrada es 1, el bit de $B$ se invierte (se niega).

**Señal de Control (SELECTOR):** Es el bit que define la operación. Se conecta a todas las compuertas XOR y también al Acarreo de entrada inicial **Cin** del primer sumador.
-Si selector = 0 (Suma): Las XOR dejan pasar a $B$ normal. El **Cin** inicial es 0. El circuito hace  $A + B + 0$.
-Si selector = 1 (Resta): Las XOR invierten a **B** (complemento a 1). El **Cin** inicial es 1. El circuito hace  **A + \bar{B} + 1**, logrando mágicamente el complemento a 2 y efectuando la resta.

Uno de los problemas que tuvimos, que personalmente fue el mas relevante; fue a la hora de implementar en el código el algoritmo para invertir la suma binaria para mostrar el resultado en la resta, ya que en un inicio no invertía este resultado final. 

#### 1.2 Diagramas
<img width="1600" height="1177" alt="image" src="https://github.com/user-attachments/assets/cea781c7-f9e5-4d30-82e5-806990b379bf" />
<img width="1600" height="1190" alt="image" src="https://github.com/user-attachments/assets/367dfc2d-d06d-459a-a379-65581a480c30" />


## Simulaciones 

### 1. Simulación del sumador/restador
<img width="1920" height="1128" alt="image" src="https://github.com/user-attachments/assets/ca0c2bae-4232-413f-9e42-20c91f91d1de" />
<img width="1920" height="1128" alt="image" src="https://github.com/user-attachments/assets/4d7f07b3-503a-46c8-b560-9c0a9c46273e" />

#### 1.1 Descripción
Para realizar las simulaciones de cada uno de los circuitos mencionados anteriormente usamos el programa llamado icarus verilog.
una vez escrito el codigo en visual studio code utilizabamos el comando gtkwave para mostrar la simulacion. 
mostando asi las entradas en sus respectivas posiciones y la respuesta de la salida a las ditintas combinaciones 

#### 1.2 Diagrama
<img width="1771" height="888" alt="ChatGPT Image 1 sept 2026, 13_28_11" src="https://github.com/user-attachments/assets/5511a232-d08f-4bb6-ad8e-66b54db58ae6" />

## Evidencias de implementación


## Conclusiones
En conclusión, durante el desarrollo de esta actividad se logró implementar y comprobar el funcionamiento de un sumador/restador de 4 bits utilizando Verilog, comprendiendo cómo un circuito combinacional puede realizar ambas operaciones mediante el uso del complemento a 2. A partir del sumador completo de 1 bit se construyó una estructura de cuatro etapas conectadas mediante sus acarreos, incorporando compuertas XOR para modificar la entrada B según la señal de selección y utilizar el acarreo inicial para realizar la resta. Las simulaciones realizadas con Icarus Verilog y GTKWave permitieron verificar que las diferentes combinaciones de las entradas producen los resultados esperados, incluyendo la propagación de los acarreos. Además, la actividad permitió comprender de una manera práctica la relación entre las expresiones lógicas, las compuertas digitales y su implementación mediante código Verilog, así como identificar y corregir errores durante el proceso de desarrollo, fortaleciendo los conocimientos sobre lógica digital, circuitos aritméticos y diseño de hardware mediante HDL.

## Referencias
guia de laboratorio 1 arquitectura de procesadores
