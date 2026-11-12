// Formateador ASCII en DECIMAL: convierte (addr, dato) en "A:DDD\r\n" (7 bytes)
// y los entrega uno a uno al uart_tx. Ejemplo: addr=2, dato=143 -> 2:143<CR><LF>
module uart_fmt (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,       // pulso de 1 ciclo: captura addr y dato
    input  wire [2:0] addr,
    input  wire [7:0] data,
    input  wire       tx_busy,     // desde uart_tx
    output wire       tx_start,    // hacia uart_tx
    output reg  [7:0] tx_data,     // hacia uart_tx
    output wire       busy
);
    localparam IDLE = 2'd0, SEND = 2'd1, WAIT = 2'd2;

    reg [1:0] state;
    reg [2:0] idx;                 // 0..6
    reg [2:0] addr_r;
    reg [7:0] data_r;

    // Digitos decimales del dato (0..255), siempre 3 digitos (008, 143, 255)
    wire [3:0] d_cen = data_r / 8'd100;
    wire [3:0] d_dec = (data_r % 8'd100) / 8'd10;
    wire [3:0] d_uni = data_r % 8'd10;

    always @(*) begin
        case (idx)
            3'd0:    tx_data = 8'h30 + addr_r;       // '0'..'7'
            3'd1:    tx_data = 8'h3A;                // ':'
            3'd2:    tx_data = 8'h30 + d_cen;        // centenas
            3'd3:    tx_data = 8'h30 + d_dec;        // decenas
            3'd4:    tx_data = 8'h30 + d_uni;        // unidades
            3'd5:    tx_data = 8'h0D;                // CR
            default: tx_data = 8'h0A;                // LF
        endcase
    end

    assign tx_start = (state == SEND);
    assign busy     = (state != IDLE);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; idx <= 0; addr_r <= 0; data_r <= 0;
        end else begin
            case (state)
                IDLE: if (start) begin
                    addr_r <= addr;
                    data_r <= data;
                    idx    <= 0;
                    state  <= SEND;
                end
                SEND: state <= WAIT;             // la UART acepta el byte en este ciclo
                WAIT: if (!tx_busy) begin        // termino el byte actual
                    if (idx == 3'd6) state <= IDLE;
                    else begin idx <= idx + 1'b1; state <= SEND; end
                end
            endcase
        end
    end
endmodule
