module mulplex (
    input [3:0] suma,
    output reg [6:0] salida
);  
// Lógica de decodificación para el display de 7 segmentos
always @(suma) begin
case(suma)
4'b0000: salida= ~7'b0111111; // 0
4'b0001: salida = ~7'b0000110; // 1
4'b0010: salida = ~7'b1011011; // 2
4'b0011: salida = ~7'b1001111; // 3
4'b0100: salida = ~7'b1100110; // 4
4'b0101: salida = ~7'b1101101; // 5
4'b0110: salida = ~7'b1111101; // 6
4'b0111: salida = ~7'b0000111; // 7
4'b1000: salida = ~7'b1111111; // 8
4'b1001: salida = ~7'b1101111; // 9

default: salida = 7'b1111111;
endcase
end
endmodule