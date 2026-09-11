//`include "sumador1b.v"
`timescale 1s/1s

module sumador_restador(
    input [3:0] A,
    input [3:0] B,
    input Sel,       // Selector: 0 para Sumar, 1 para Restar
    output [3:0] S,  // Mostrará la magnitud en positivo (ej. 2)
    output Co        // Quedará en 0 cuando el resultado sea negativo
);

// Cables internos para propagar el acarreo
wire c1, c2, c3;

// Cables para la XOR y para guardar el resultado crudo antes de corregirlo
wire [3:0] B_xor;
wire [3:0] S_interno; 

// Compuertas XOR
assign B_xor[0] = B[0] ^ Sel;
assign B_xor[1] = B[1] ^ Sel;
assign B_xor[2] = B[2] ^ Sel;
assign B_xor[3] = B[3] ^ Sel;

// --- Instancias de los sumadores ---
// Nota que ahora la salida se guarda en S_interno en lugar de S

sumador1b bit1(
    .A(A[0]),
    .B(B_xor[0]), 
    .Ci(Sel),     
    .S(S_interno[0]), 
    .Co(c1)
);

sumador1b bit2(
    .A(A[1]),
    .B(B_xor[1]),
    .Ci(c1),
    .S(S_interno[1]),
    .Co(c2)
);

sumador1b bit3(
    .A(A[2]),
    .B(B_xor[2]),
    .Ci(c2),
    .S(S_interno[2]),
    .Co(c3)
);

sumador1b bit4(
    .A(A[3]),
    .B(B_xor[3]),
    .Ci(c3),
    .S(S_interno[3]),
    .Co(Co) // Co se calcula normal. Si es resta y da 0, es negativo.
);

// --- Corrección final del resultado ---

// Detectamos si es negativo: Ocurre si estamos restando (Sel=1) Y el acarreo final es 0
wire es_negativo = Sel & ~Co;

// Si es negativo, a S le asignamos el complemento a 2 de S_interno (~S_interno + 1).
// Si es positivo, a S le asignamos S_interno tal como salió de los sumadores.
assign S = (es_negativo) ? (~S_interno + 1'b1) : S_interno;

endmodule