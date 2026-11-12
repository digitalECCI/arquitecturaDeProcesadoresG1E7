module tb_ALU;

    // Entradas hacia la ALU
    reg [3:0] A;
    reg [3:0] B;
    reg [2:0] selop;
    reg       Cin;
    reg       init;
    reg       clk;
    reg       reset;

    // Salidas de la ALU
    wire       done;
    wire [7:0] result;
    wire       flag;

    // Variables de control
    integer i, j, k;
    integer total_tests;
    integer error_count;

    reg [7:0] expected_result;
    reg       expected_flag;
    reg [3:0] temp_4b;

    // Instancia de la ALU bajo prueba
    ALU uut (
        .A(A),
        .B(B),
        .selop(selop),
        .Cin(Cin),
        .init(init),
        .clk(clk),
        .reset(reset),
        .done(done),
        .result(result),
        .flag(flag)
    );

    // Generador de reloj de 50 MHz (Periodo de 20 ns)
    always #10 clk = ~clk;

    initial begin
        $dumpfile("tb_ALU.vcd");
        $dumpvars(0, tb_ALU);

        // Inicialización
        clk         = 0;
        reset       = 1;
        Cin         = 0;
        init        = 0;
        A           = 0;
        B           = 0;
        selop       = 0;
        total_tests = 0;
        error_count = 0;

        #50 reset = 0;
        #20;

        $display("=========================================================");
        $display("      INICIO DE VERIFICACION EXHAUSTIVA DE LA ALU        ");
        $display("=========================================================");

        // Recorrido de los 2048 casos posibles
        for (k = 0; k < 8; k = k + 1) begin
            for (i = 0; i < 16; i = i + 1) begin
                for (j = 0; j < 16; j = j + 1) begin

                    selop = k[2:0];
                    A     = i[3:0];
                    B     = j[3:0];

                    if (selop == 3'b010) begin
                        // Se maneja init en el flanco de BAJADA para evitar carreras con la FSM
                        @(negedge clk);
                        init = 1'b1;
                        @(negedge clk);
                        init = 1'b0;     // ya cargo A y B: la FSM esta en CHECK y done=0

                        wait(done == 1'b1);   // ahora si es el 'done' de ESTA multiplicacion
                        @(negedge clk);
                    end else begin
                        #20;
                    end

                    case (selop)
                        3'b000: begin temp_4b = A + B;            expected_result = {4'b0000, temp_4b}; end
                        3'b001: begin temp_4b = A - B;            expected_result = {4'b0000, temp_4b}; end
                        3'b010: begin                             expected_result = A * B;               end
                        3'b011: begin temp_4b = (A >= B) ? A : B; expected_result = {4'b0000, temp_4b}; end
                        3'b100: begin temp_4b = A >> B;           expected_result = {4'b0000, temp_4b}; end
                        3'b101: begin temp_4b = A & B;            expected_result = {4'b0000, temp_4b}; end
                        3'b110: begin temp_4b = A | B;            expected_result = {4'b0000, temp_4b}; end
                        3'b111: begin temp_4b = A ^ B;            expected_result = {4'b0000, temp_4b}; end
                        default: expected_result = 8'b0;
                    endcase

                    expected_flag = (expected_result == 8'b00000000) ? 1'b1 : 1'b0;

                    if (result !== expected_result || flag !== expected_flag) begin
                        $display("[FALLO] selop=%b | A=%d, B=%d | Obtenido: Res=%d, Flag=%b | Esperado: Res=%d, Flag=%b",
                                 selop, A, B, result, flag, expected_result, expected_flag);
                        error_count = error_count + 1;
                    end

                    total_tests = total_tests + 1;
                end
            end
        end

        $display("=========================================================");
        $display("                RESUMEN DE VERIFICACION                  ");
        $display("=========================================================");
        $display(" Casos probados totales : %d", total_tests);
        $display(" Total de errores       : %d", error_count);

        if (error_count == 0) begin
            $display(" RESULTADO: >>> LA ALU PASO EL 100%% DE LAS PRUEBAS <<<");
        end else begin
            $display(" RESULTADO: >>> SE DETECTARON %d ERRORES EN LA ALU <<<", error_count);
        end
        $display("=========================================================");

        $finish;
    end

endmodule