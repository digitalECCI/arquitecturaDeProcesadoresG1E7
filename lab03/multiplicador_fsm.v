module multiplicador_fsm (
    input  wire       clk,
    input  wire       rst,       // Reset asíncrono principal
    input  wire       init,      // Señal INIT del diagrama
    input  wire [2:0] MD,        // Multiplicando (3 bits)
    input  wire [2:0] MR,        // Multiplicador / B (3 bits)
    output wire       done,      // Señal DONE
    output wire [5:0] product    // Producto final PP (6 bits)
);

    // =========================================================================
    // 1. Codificación de Estados (FSM)
    // =========================================================================
    localparam START = 3'b000;
    localparam CHECK = 3'b001;
    localparam ADD   = 3'b010;
    localparam SHIFT = 3'b011;
    localparam END   = 3'b100;

    reg [2:0] state, next_state;

    // =========================================================================
    // 2. Registros e Interconexiones de la Ruta de Datos (Datapath)
    // =========================================================================
    reg [5:0] PP;  // Producto Parcial (acumulador de 6 bits)
    reg [5:0] A;   // Multiplicando expandido a 6 bits para desplazamientos
    reg [2:0] B;   // Multiplicador de 3 bits

    // Banderas de condición para la FSM
    wire LSB_B;
    wire Z;

    // Controladores de la FSM hacia el Datapath
    wire reset_dp; // RESET interno (activa carga inicial)
    wire add_dp;   // Controla la suma PP = PP + A
    wire sh_dp;    // Controla los desplazamientos A << 1 y B >> 1

    // =========================================================================
    // 3. Transición de Estados
    // =========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= START;
        else
            state <= next_state;
    end

    // =========================================================================
    // 4. Lógica del Siguiente Estado (FSM)
    // =========================================================================
    always @(*) begin
        case (state)
            START: begin
                if (init)
                    next_state = CHECK;
                else
                    next_state = START;
            end

            CHECK: begin
                if (LSB_B)// LSB_B=0?
                    next_state = ADD;
                else
                    next_state = SHIFT; // corrimiento
            end

            ADD: begin
                next_state = SHIFT;
            end

            SHIFT: begin
                if (Z)
                    next_state = END;
                else
                    next_state = CHECK;
            end

            END: begin
					if (init)
				next_state = CHECK; // Si se presiona init de nuevo, reinicia el cálculo
					else
				next_state = END;   // Se mantiene en END reteniendo 'done' y el resultado
end

            default: next_state = START;
        endcase
    end

    // =========================================================================
    // 5. Salidas de Control de la FSM
    // =========================================================================
    assign done     = (state == END);
    assign reset_dp = (state == START) || ((state == END) && init);
    assign add_dp   = (state == ADD);
    assign sh_dp    = (state == SHIFT);

    // =========================================================================
    // 6. Lógica de la Ruta de Datos (Datapath)
    // =========================================================================
    // Banderas evaluadas por la FSM
    assign LSB_B = B[0];
    assign Z     = ((B >> 1) == 3'b000); // Evalúa si B será 0 tras el desplazamiento

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PP <= 6'b000000;
            A  <= 6'b000000;
            B  <= 3'b000;
        end else if (reset_dp) begin
            // Carga inicial según el diagrama de flujo
            PP <= 6'b000000;
            A  <= {3'b000, MD};
            B  <= MR;
        end else begin
            // Operación de Suma
            if (add_dp) begin
                PP <= PP + A;
            end
            
            // Operación de Desplazamiento
            if (sh_dp) begin
                A <= A << 1;
                B <= B >> 1;
            end
        end
    end

    // Asignación continua de la salida
    assign product = PP;

endmodule