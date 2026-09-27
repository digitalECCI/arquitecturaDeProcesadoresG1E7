module BCD6 (
    input [5:0] binario,        // Entrada expandida a 6 bits (0 a 63)
    output reg [3:0] decenas,   // Nibble alto para display 1
    output reg [3:0] unidades   // Nibble bajo para display 2
);

    // Registro de 14 bits: [13:10] Decenas | [9:6] Unidades | [5:0] Binario
    reg [13:0] paso0, paso1, paso2, paso3, paso4, paso5, paso6;

    always @(*) begin
        // PASO 0: Cargar 8 bits en cero para BCD + 6 bits binarios
        paso0 = {8'b0, binario};

        // PASO 1: Primer desplazamiento
        paso1 = paso0 << 1;

        // PASO 2: Revisar unidades y desplazar
        if (paso1[9:6] >= 5) paso1[9:6] = paso1[9:6] + 3;
        paso2 = paso1 << 1;

        // PASO 3: Revisar unidades y desplazar
        if (paso2[9:6] >= 5) paso2[9:6] = paso2[9:6] + 3;
        paso3 = paso2 << 1;

        // PASO 4: Revisar unidades y decenas, luego desplazar
        if (paso3[9:6] >= 5)   paso3[9:6] = paso3[9:6] + 3;
        if (paso3[13:10] >= 5) paso3[13:10] = paso3[13:10] + 3;
        paso4 = paso3 << 1;

        // PASO 5: Revisar unidades y decenas, luego desplazar
        if (paso4[9:6] >= 5)   paso4[9:6] = paso4[9:6] + 3;
        if (paso4[13:10] >= 5) paso4[13:10] = paso4[13:10] + 3;
        paso5 = paso4 << 1;

        // PASO 6: Sexto y último desplazamiento por el sexto bit
        if (paso5[9:6] >= 5)   paso5[9:6] = paso5[9:6] + 3;
        if (paso5[13:10] >= 5) paso5[13:10] = paso5[13:10] + 3;
        paso6 = paso5 << 1;

        // RESULTADO: Extraer los nibbles finales
        decenas  = paso6[13:10];
        unidades = paso6[9:6];
    end

endmodule