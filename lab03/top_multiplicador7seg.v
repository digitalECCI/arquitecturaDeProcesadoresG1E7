module top_multiplicador7seg (
    input  wire       clk,        // Reloj principal (ej. 50 MHz)
    input  wire       rst_n,      // Reset físico activo en bajo (pulsador/switch)
    input  wire       btn_init,   // Botón físico para iniciar (con rebotes)
    input  wire [2:0] MD,         // Multiplicando de 3 bits (Switches)
    input  wire [2:0] MR,         // Multiplicador de 3 bits (Switches)
    output wire       done,       // LED indicador de fin de cálculo
    output wire [6:0] decena,     // Display de 7 segmentos para Decenas
    output wire [6:0] unidad      // Display de 7 segmentos para Unidades
);

    // =========================================================================
    // Cables de Interconexión Interna
    // =========================================================================
    wire       rst;          // Reset activo en alto para los submódulos
    wire       init_clean;   // Pulso de 1 ciclo filtrado por el debouncer
    wire [5:0] producto;     // Resultado de 6 bits de la FSM (rango 0 a 49)
    wire [3:0] disp_decenas;  // Nibble BCD para decenas (0 a 4)
    wire [3:0] disp_unidades; // Nibble BCD para unidades (0 a 9)

    // Adaptación del Reset físico (Activo en bajo) a la lógica interna (Activo en alto)
    assign rst = 1'b0;

    // =========================================================================
    // 1. Módulo Anti-rebote (Debouncer)
    // =========================================================================
    // Filtra el ruido mecánico de 'btn_init' y genera un único pulso de 1 ciclo de reloj
    debouncer #(
        .FREQ_CLK(50_000_000), // Ajustar a 10_000_000 si usas el reloj de 10 MHz
        .DELAY_MS(10)          // Tiempo de filtrado de 10 ms
    ) DEBOUNCE_INIT (
        .clk(clk),
        .rst(rst),
        .btn_in(btn_init),
        .btn_out(),            // No se requiere estado sostenido
        .pulse_out(init_clean) // Dispara el estado CHECK en la FSM
    );

    // =========================================================================
    // 2. Multiplicador Secuencial (FSM + Datapath)
    // =========================================================================
    multiplicador_fsm MULT (
        .clk(clk),
        .rst(rst),
        .init(init_clean),
        .MD(MD),
        .MR(MR),
        .done(done),
        .product(producto)
    );

    // =========================================================================
    // 3. Convertidor Binario a BCD (Double Dabble 6 bits)
    // =========================================================================
    BCD6 BCD (
        .binario(producto),
        .decenas(disp_decenas),
        .unidades(disp_unidades)
    );

    // =========================================================================
    // 4. Decodificadores BCD a 7 Segmentos
    // =========================================================================
    mulplex dec_decenas (
        .suma(disp_decenas),
        .salida(decena)
    );

    mulplex dec_unidades (
        .suma(disp_unidades),
        .salida(unidad)
    );

endmodule