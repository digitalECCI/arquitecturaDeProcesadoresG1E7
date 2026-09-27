`timescale 1ns / 1ps

module tb_multiplicador_fsm;

    // Entradas
    reg        clk;
    reg        rst;
    reg        init;
    reg  [2:0] MD;
    reg  [2:0] MR;

    // Salidas
    wire       done;
    wire [5:0] product;

    // Variables para los bucles y control de errores
    integer i, j;
    integer errores;

    // Instancia de la FSM
    multiplicador_fsm UUT (
        .clk(clk),
        .rst(rst),
        .init(init),
        .MD(MD),
        .MR(MR),
        .done(done),
        .product(product)
    );

    // Reloj de 50 MHz (20 ns)
    always #10 clk = ~clk;

    initial begin
        $dumpfile("tb_multiplicador_fsm.vcd");
        $dumpvars(0, tb_multiplicador_fsm);

        // Inicialización
        clk     = 0;
        rst     = 1;
        init    = 0;
        MD      = 0;
        MR      = 0;
        errores = 0;

        #40;
        rst = 0; // Liberar reset
        #20;

        $display("\n===========================================");
        $display("   INICIANDO SIMULACION DE LOS 64 CASOS   ");
        $display("===========================================\n");

        // Bucle para iterar Multiplicando (0 a 7) y Multiplicador (0 a 7)
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                MD = i[2:0];
                MR = j[2:0];

                #20;
                init = 1; // Genera el pulso de inicio
                #20;
                init = 0;

                // Espera a que la FSM complete la multiplicación
                wait(done == 1'b1);
                #10; // Margen de estabilización de las señales

                // Verificación de la respuesta obtenida
                if (product !== (i * j)) begin
                    $display("[ERROR] %0d x %0d = %0d | Esperado: %0d", i, j, product, i * j);
                    errores = errores + 1;
                end else begin
                    $display("[OK]    %0d x %0d = %0d", i, j, product);
                end

                #20; // Pausa antes de la siguiente prueba
            end
        end

        // Reporte final en consola
        $display("\n===========================================");
        if (errores == 0) begin
            $display(" EXITO: Se probaron los 64 casos correctamente!");
        end else begin
            $display(" FALLO: Se encontraron %0d errores en total.", errores);
        end
        $display("===========================================\n");

        $finish;
    end

endmodule