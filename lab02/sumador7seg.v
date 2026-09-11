module sumador7seg (
    input [3:0] A,              // Número A positivo (0 a 15)
    input [3:0] B,              // Número B positivo (0 a 15)
    input selector,             // 0 = Suma (A + B), 1 = Resta (A - B)
    output [6:0] unidad,
    output [6:0] decena,
    output signo_menos          // Controla el display del signo menos
);

    wire [3:0] disp_decenas;
    wire [3:0] disp_unidades;

    wire [3:0] suma_4bits;
    wire Cout;
    wire es_negativo;

    // 1. Instancia del sumador/restador (S ya viene con la magnitud absoluta)
    sumador_restador SEG7(
        .A(A),
        .B(B),
        .Sel(selector),
        .S (suma_4bits),
        .Co(Cout)
    );

    // 2. Detección de número negativo (Resta Y sin acarreo)
    assign es_negativo = selector && (Cout == 1'b0);

    // 3. Control del signo para Ánodo Común (0 = Encendido, 1 = Apagado)
    assign signo_menos = ~es_negativo;

    // 4. Conexión directa a 5 bits para el módulo BCD
    // Suma (!selector): {Cout, suma_4bits} permite valores hasta 30
    // Resta (selector): {1'b0, suma_4bits} la magnitud máxima es 15
    wire [4:0] valor_absoluto;
    assign valor_absoluto = (!selector) ? {Cout, suma_4bits} : {1'b0, suma_4bits};

    // 5. Convertidor BCD
    modulobcd BCD (
        .binario(valor_absoluto),
        .decenas(disp_decenas),
        .unidades(disp_unidades)
    );

    // 6. Decodificadores a 7 segmentos
    mulplex decenas (
        .suma(disp_decenas),
        .salida(decena)
    );

    mulplex unidades (
        .suma(disp_unidades),
        .salida(unidad)
    );

endmodule