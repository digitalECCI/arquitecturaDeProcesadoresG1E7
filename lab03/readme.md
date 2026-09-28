
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
Multiplicación secuencial
En la multiplicación secuencial, los operandos se procesan bit a bit a lo largo de varios ciclos de reloj. A cada ciclo se realiza una operación parcial (suma o desplazamiento), acumulando el resultado hasta obtener el producto final.
El módulo diseñado multiplica dos operandos de 3 bits (Multiplicando: MD, Multiplicador: MR). El resultado se acumula en un registro de productos parciales (pp) de 6 bits. Una señal de control (done) indica cuándo la operación ha finalizado.
Máquina de Estados Algorítmica (ASM)
Una Máquina de Estados Algorítmica (ASM) es un modelo de computación secuencial en el que el sistema puede encontrarse en un estado a la vez y cambia de estado en respuesta a una entrada o evento, típicamente sincronizado con un reloj.

En este diseño, la ASM se encarga de coordinar:

La carga de operandos.

La generación de productos parciales.

El desplazamiento y acumulación del resultado.

La finalización del proceso de multiplicación.

Este enfoque ordenado facilita el diseño modular y el control explícito de cada etapa del algoritmo.
#### 1.2 Diagramas


## Simulaciones 


#### 1.1 Descripción

#### 1.2 Diagrama

## Evidencias de implementación


## Conclusiones

## Referencias
guia de laboratorio 3 arquitectura de procesadores
