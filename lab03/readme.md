
# Lab03 - multiplicador secuencial

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
En este laboratorio nuestra misión es contruir una maquina de estados para realizar la multiplicación de dos entradas de 3 bits cada una usando una logica secuencial.
Dicha multiplicación se hara con productos parciales y desplazamientos, entendido el funcionamiento de esta logica sintetizaremos la maquina de estados en lenguaje HDL verilog e implementaremos en la fpga.


**Funcionamiento:**
**Multiplicación secuencial**

En la multiplicación secuencial, los operandos se procesan bit a bit a lo largo de varios ciclos de reloj. A cada ciclo se realiza una operación parcial (suma o desplazamiento), acumulando el resultado hasta obtener el producto final.

El módulo diseñado multiplica dos operandos de 3 bits (Multiplicando: MD, Multiplicador: MR). El resultado se acumula en un registro de productos parciales (pp) de 6 bits. Una señal de control (done) indica cuándo la operación ha finalizado.

**Máquina de Estados Algorítmica (ASM)**

Una Máquina de Estados Algorítmica (ASM) es un modelo de computación secuencial en el que el sistema puede encontrarse en un estado a la vez y cambia de estado en respuesta a una entrada o evento, típicamente sincronizado con un reloj.

En este diseño, la ASM se encarga de coordinar:

*La carga de operandos.

*La generación de productos parciales.

*El desplazamiento y acumulación del resultado.

*La finalización del proceso de multiplicación.

Este enfoque ordenado facilita el diseño modular y el control explícito de cada etapa del algoritmo.

**Descripción del multiplicador secuencial y su funcionamiento**

La descripción HDL implementa un multiplicador secuencial de 3 bits utilizando una máquina de estados algorítmica (ASM) para controlar el proceso de multiplicación basado en el algoritmo de productos parciales.Interfaz del módulo:

Entradas:

-MD ($m$ bits / 3 bits): Multiplicando.

-MR ($m$ bits / 3 bits): Multiplicador.

-INIT: Señal de inicio del proceso de multiplicación.

-CLK: Señal de reloj.

-Salidas:PP ($2m$ bits / 6 bits): Producto Parcial (resultado final acumulado).

-DONE: Señal que indica la finalización de la multiplicación.

**Funcionamiento:**

El módulo multiplicador realiza la multiplicación de dos números de 3 bits cada uno (MR y MD) de forma secuencial, donde los productos parciales se suman y desplazan a lo largo de varios ciclos de reloj a partir de cierta condición; al cargar los valores a las entradas A y B un condicional pregunta si el bit menos significativo de la entrada B es 0, si es así él va a realizar un corrimiento de un bit a la izquierda en A y un bit a la derecha en B, Si el bit menos significativo de B es 1 realizara una suma del pp con A para luego hacer el corrimiento indicado anteriormente. Después de esto el algoritmo nos muestra otro condicional el cual nos pregunta si B es total a 0 si es así el resultado final se almacena en pp (producto parcial de 6 bits) y la señal done indica que la multiplicación finalizó si no es así vuelve a hacer las iteraciones necesarias hasta cumplir con la condición.

La multiplicación secuencial implica que el módulo procesa los bits de los operandos uno a uno, acumulando los productos parciales y desplazándolos hasta obtener el resultado final. Cada ciclo de reloj corresponde a una operación específica, como sumar un producto parcial o desplazar los registros involucrados.

**Unidad de Control del Bloque Multiplicador (Máquina de Estados)**

La máquina de estados cuenta con 5 estados:

**START:**

Salidas de control: DONE = 0, RESET = 1, SH = 0, ADD = 0.

Transición: Permanecer en START mientras INIT = 0. Si INIT = 1, pasa a CHECK.

**CHECK:**

Salidas de control: DONE = 0, RESET = 0, SH = 0, ADD = 0.

Transición: Si $LSB\_B = 1$, pasa a ADD. Si $LSB\_B = 0$, pasa a SHIFT.

**ADD:**

Salidas de control: DONE = 0, RESET = 0, SH = 0, ADD = 1.

Transición: Pasa directamente a SHIFT.

**SHIFT:**

Salidas de control: DONE = 0, RESET = 0, SH = 1, ADD = 0.

Transición: Si $Z = 0$, vuelve a CHECK. Si $Z = 1$, pasa a END.

**END:**

Salidas de control: DONE = 1, RESET = 0, SH = 0, ADD = 0.

Transición: Regresa a START si está en estado END y Init es 1.

#### 1.2 Diagramas
<img width="1917" height="1017" alt="image" src="https://github.com/user-attachments/assets/23288c9d-ced4-4284-b6d1-c6846eec662e" />

Bloque del multiplicador instanciado con el multiplexor y el double dabble para su muestra en display 7 segmentos.
<img width="1613" height="420" alt="image" src="https://github.com/user-attachments/assets/c774599e-7a20-4a6b-a0be-8988bf692ee0" />

Modulo del multiplicador.
<img width="1215" height="620" alt="image" src="https://github.com/user-attachments/assets/e8c01552-e1e7-47d0-bd31-179be4ad2d67" />

Maquina de estados (FMS).
<img width="625" height="523" alt="image" src="https://github.com/user-attachments/assets/cc20cbbf-9d89-42c9-860a-6083967631b5" />

Diagrama de flujo Multiplicador.
<img width="626" height="567" alt="image" src="https://github.com/user-attachments/assets/a56e03af-452b-4c19-8303-483da69c2e39" /> 

Maquina de estados como unidad de control.







## Simulaciones 
<img width="1911" height="888" alt="image" src="https://github.com/user-attachments/assets/d2a26e92-646f-4f31-b8fe-d892ecfc78ba" />
Simulación en GTKwave.


#### 1.1 Descripción

#### 1.2 Diagrama

## Evidencias de implementación


## Conclusiones
En conclusión, el desarrollo de esta práctica permitió comprender e implementar un multiplicador secuencial de 3 bits mediante el uso de una Máquina de Estados Algorítmica (ASM) descrita en HDL. A diferencia de las soluciones combinacionales, el enfoque secuencial optimiza el uso de recursos de hardware al realizar operaciones de suma y desplazamiento a lo largo de varios ciclos de reloj. La máquina de estados coordinó correctamente la carga de operandos, la generación de productos parciales y la señalización de finalización con la bandera DONE. Finalmente, la simulación y el procedimiento de implementación permitieron validar la lógica del sistema y continuar con la construcción modular de la ALU.
## Referencias
guia de laboratorio 3 arquitectura de procesadores
