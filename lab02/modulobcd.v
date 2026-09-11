module modulobcd (
    input [4:0] binario,       // Tu entrada de 5 bits
    output reg [3:0] decenas,  // Nibble alto para display 1
    output reg [3:0] unidades  // Nibble bajo para display 2
);

    // Registros intermedios para simular cada paso del algoritmo
    reg [12:0] paso0, paso1, paso2, paso3, paso4, paso5;

    always @(*) begin
        // PASO 0: Inicializar el registro con ceros en BCD y el valor binario
        paso0 = {8'b0, binario};

        // PASO 1: Primer desplazamiento (Nunca se suma 3 en el paso 1 porque el valor máximo es 1)
        paso1 = paso0 << 1;

        // PASO 2: Revisar unidades y desplazar
        if (paso1[8:5] >= 5) paso1[8:5] = paso1[8:5] + 3;
        paso2 = paso1 << 1;

        // PASO 3: Revisar unidades y desplazar
        if (paso2[8:5] >= 5) paso2[8:5] = paso2[8:5] + 3;
        paso3 = paso2 << 1;

        // PASO 4: Revisar unidades y decenas, luego desplazar
        if (paso3[8:5] >= 5)   paso3[8:5] = paso3[8:5] + 3;
        if (paso3[12:9] >= 5)  paso3[12:9] = paso3[12:9] + 3;
        paso4 = paso3 << 1;

        // PASO 5: Última revisión y desplazamiento final
        if (paso4[8:5] >= 5)   paso4[8:5] = paso4[8:5] + 3;
        if (paso4[12:9] >= 5)  paso4[12:9] = paso4[12:9] + 3;
        paso5 = paso4 << 1;

        // RESULTADO: Extraer los nibbles finales del último paso
        decenas  = paso5[12:9];
        unidades = paso5[8:5];
    end

endmodule