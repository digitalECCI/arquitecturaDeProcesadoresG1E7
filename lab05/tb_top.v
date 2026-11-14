`timescale 1ns/1ps
// Testbench del procesador: ejecuta el programa de la ROM, recibe la linea
// enviada por UART y revisa los registros al llegar a HALT.
module tb_top;
    reg        clk = 0;
    reg        rst_n = 0;
    wire       tx;
    wire [9:0] LEDR;

    localparam SIM_BAUD = 1000000;   // 1 Mbaud solo en simulacion (hardware real: 9600)
    top #(.BAUD_RATE(SIM_BAUD)) dut (.clk(clk), .rst_n(rst_n), .tx(tx), .LEDR(LEDR));

    always #10 clk = ~clk;           // 50 MHz

    localparam BIT_T = (50000000/SIM_BAUD)*20;   // duracion de 1 bit UART en ns
    integer errors = 0;
    reg [7:0]  rx_byte;
    reg [55:0] rx_str;

    task uart_rx;
        integer n;
        begin
            @(negedge tx);
            #(BIT_T/2);
            for (n = 0; n < 8; n = n + 1) begin
                #(BIT_T);
                rx_byte[n] = tx;
            end
            #(BIT_T);
            if (tx !== 1'b1) begin
                $display("[FALLO] bit de stop invalido");
                errors = errors + 1;
            end
        end
    endtask

    task uart_rx_line;
        integer k;
        begin
            rx_str = 0;
            for (k = 0; k < 7; k = k + 1) begin
                uart_rx;
                rx_str = {rx_str[47:0], rx_byte};
            end
        end
    endtask

    task check_line;
        input [2:0] r; input [7:0] v;
        reg [55:0] esp;
        reg [7:0] cen, dec, uni;
        begin
            cen = v / 100; dec = (v % 100) / 10; uni = v % 10;
            esp = {8'h30 + r, 8'h3A, 8'h30 + cen, 8'h30 + dec, 8'h30 + uni, 8'h0D, 8'h0A};
            if (rx_str !== esp) begin
                $display("[FALLO] UART esperado=%h recibido=%h", esp, rx_str);
                errors = errors + 1;
            end else
                $display("[OK]    UART -> \"%c:%c%c%c\"", rx_str[55:48], rx_str[39:32], rx_str[31:24], rx_str[23:16]);
        end
    endtask

    task check_reg;
        input [2:0] r; input [7:0] v;
        begin
            if (dut.inst_banco.registros[r] !== v) begin
                $display("[FALLO] R%0d = %0d, esperado %0d", r, dut.inst_banco.registros[r], v);
                errors = errors + 1;
            end else
                $display("[OK]    R%0d = %0d", r, v);
        end
    endtask

    // Traza de ejecucion: una linea por instruccion buscada y por escritura en registro
    always @(posedge clk) begin
        if (rst_n && dut.ir_load)
            $display("t=%0t  FETCH  PC=%0d  instr=%h", $time, dut.pc, dut.rom_data);
        if (rst_n && dut.reg_we)
            $display("t=%0t  WRITE  R%0d <= %0d", $time, dut.rd, dut.wr_data);
        if (rst_n && dut.out_start)
            $display("t=%0t  OUT    R%0d = %0d", $time, dut.rs, dut.rs_data);
    end

    initial begin
        $dumpfile("tb_top.vcd"); $dumpvars(0, tb_top);
        repeat (5) @(posedge clk);
        @(negedge clk) rst_n = 1;

        uart_rx_line;                 // el programa hace un solo OUT
        check_line(3'd4, 8'd40);

        wait (LEDR[9] == 1'b1);       // HALT
        repeat (5) @(posedge clk);
        $display("t=%0t  HALT", $time);

        check_reg(3'd1, 8'd5);
        check_reg(3'd2, 8'd3);
        check_reg(3'd3, 8'd8);
        check_reg(3'd4, 8'd40);
        if (LEDR[7:0] !== 8'd40) begin
            $display("[FALLO] LEDR[7:0] = %0d, esperado 40", LEDR[7:0]);
            errors = errors + 1;
        end else
            $display("[OK]    LEDR[7:0] = 40");

        $display("TOTAL ERRORES: %0d", errors);
        $finish;
    end

    initial begin                     // por si el programa nunca llega a HALT
        #5000000;
        $display("[FALLO] timeout");
        $finish;
    end
endmodule
