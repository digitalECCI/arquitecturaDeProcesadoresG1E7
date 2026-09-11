
module sumador_restador_4b (

    input [3:0] a_4b,
    input [3:0] b_4b,
    input sel,
    output [3:0] s_4b,
    output cout
);
    wire c1,c2,c3;
    wire [3:0] bXOr; // b modificado según la operación
    wire [3:0] s_raw;
    wire cout_raw;
   
// instancias del sumador de 1 bit con s_raw y cout_raw

    assign s_4b = (sel && !cout_raw) ? (~s_raw + 1) : s_raw;
    assign cout = cout_raw; 

    assign bXOr [0] = b_4b[0] ^ sel;
    assign bXOr [1] = b_4b[1] ^ sel;
    assign bXOr [2] = b_4b[2] ^ sel;
    assign bXOr [3] = b_4b[3] ^ sel;

    // Instancia 1: bit menos significativo
    sumador1b uut0(
        .A(a_4b[0]),
        .B(bXOr[0]),
        .Ci(sel),
        .S(s_raw[0]),
        .Co(c1)
    );

    // Instancia 2: segundo bit
    sumador1b uut1(
        .A(a_4b[1]),
        .B(bXOr[1]),
        .Ci(c1),
        .S(s_raw[1]),
        .Co(c2)
    );

    // Instancia 3: tercer bit
    sumador1b uut2(
        .A(a_4b[2]),
        .B(bXOr[2]),
        .Ci(c2),
        .S(s_raw[2]),
        .Co(c3)
    );

    // Instancia 4: bit más significativo
    sumador1b uut3(
        .A(a_4b[3]),
        .B(bXOr[3]),
        .Ci(c3),
        .S(s_raw[3]),
        .Co(cout_raw)
    );

   
  
    endmodule