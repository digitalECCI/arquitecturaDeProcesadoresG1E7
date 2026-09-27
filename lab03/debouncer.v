module debouncer #(
    parameter FREQ_CLK = 50_000_000, // Frecuencia de la FPGA en Hz (ej. 50 MHz)
    parameter DELAY_MS = 10          // Tiempo de filtro en milisegundos
)(
    input  wire clk,
    input  wire rst,
    input  wire btn_in,      // Botón físico (con rebotes)
    output reg  btn_out,     // Estado del botón filtrado y limpio
    output reg  pulse_out    // Pulso de 1 ciclo de reloj al presionar (para 'init')
);

    // Cálculo del número de ciclos necesarios para 10 ms
    localparam COUNT_MAX = (FREQ_CLK / 1000) * DELAY_MS;
    localparam BITS = $clog2(COUNT_MAX);

    reg [BITS-1:0] counter;
    reg btn_sync_0, btn_sync_1; // Sincronizador de 2 etapas (evita metaestabilidad)
    reg btn_out_prev;

    // 1. Sincronizador de entrada asíncrona
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_sync_0 <= 1'b1; // Inicia en 1 asumiendo botón Activo en Bajo (Pull-up)
            btn_sync_1 <= 1'b1;
        end else begin
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // 2. Contador de filtro anti-rebote
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            btn_out <= 1'b1;
        end else begin
            if (btn_sync_1 != btn_out) begin
                counter <= counter + 1'b1;
                if (counter >= COUNT_MAX - 1) begin
                    btn_out <= btn_sync_1;
                    counter <= 0;
                end
            end else begin
                counter <= 0;
            end
        end
    end

    // 3. Generador de pulso de 1 ciclo al presionar el botón (Flanco de bajada)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_out_prev <= 1'b1;
            pulse_out    <= 1'b0;
        end else begin
            btn_out_prev <= btn_out;
            // Si el botón es activo en bajo (pasa de 1 a 0), genera el pulso de 1 ciclo
            pulse_out <= (btn_out_prev == 1'b1) && (btn_out == 1'b0);
        end
    end

endmodule