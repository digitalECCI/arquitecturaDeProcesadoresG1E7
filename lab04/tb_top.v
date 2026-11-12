`timescale 1ns/1ps
module tb_top;
    reg        clk = 0;
    reg  [1:0] KEY = 2'b11;
    reg  [3:0] ext_A = 0, ext_B = 0;
    reg  [2:0] ext_selop = 0, ext_addr = 0;
    reg        ext_write_en = 0, ext_read_en = 0;
    wire       tx;
    wire [2:0] LEDR;

    localparam SIM_BAUD = 1000000;   // 1 Mbaud solo en simulacion (hardware real: 9600)
    top_system #(.BAUD_RATE(SIM_BAUD)) dut (
        .clk(clk), .KEY(KEY), .ext_A(ext_A), .ext_B(ext_B),
        .ext_selop(ext_selop), .ext_addr(ext_addr),
        .ext_write_en(ext_write_en), .ext_read_en(ext_read_en),
        .tx(tx), .LEDR(LEDR)
    );

    always #10 clk = ~clk;           // 50 MHz

    localparam BIT_T = (50000000/SIM_BAUD)*20;   // duracion de 1 bit UART en ns
    integer errors = 0;
    reg [7:0] rx_byte;

    task press;
        begin
            KEY[1] = 0; repeat (4) @(posedge clk);
            KEY[1] = 1; repeat (4) @(posedge clk);
        end
    endtask

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

    reg [55:0] rx_str;
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

    function [55:0] expected_line;
        input [2:0] addr; input [7:0] v;
        reg [7:0] cen, dec, uni;
        begin
            cen = v / 100;
            dec = (v % 100) / 10;
            uni = v % 10;
            expected_line = {8'h30 + addr, 8'h3A, 8'h30 + cen, 8'h30 + dec, 8'h30 + uni, 8'h0D, 8'h0A};
        end
    endfunction

    task check_line;
        input [2:0] addr; input [7:0] v;
        begin
            if (rx_str !== expected_line(addr, v)) begin
                $display("[FALLO] addr=%0d esperado=%h UART=%h", addr, expected_line(addr, v), rx_str);
                errors = errors + 1;
            end else
                $display("[OK]    UART -> \"%c:%c%c%c\" (addr=%0d, valor=%0d)", rx_str[55:48], rx_str[39:32], rx_str[31:24], rx_str[23:16], addr, v);
        end
    endtask

    function [7:0] model;
        input [2:0] op; input [3:0] a, b;
        reg [3:0] t;
        begin
            case (op)
                3'b000: model = {4'b0, a + b};
                3'b001: model = {4'b0, a - b};
                3'b010: model = a * b;
                3'b011: begin t = (a >= b) ? a : b; model = {4'b0, t}; end
                3'b100: model = {4'b0, a >> b};
                3'b101: model = {4'b0, a & b};
                3'b110: model = {4'b0, a | b};
                default: model = {4'b0, a ^ b};
            endcase
        end
    endfunction

    // Escribe resultado de la ALU en 'addr' y luego lo lee por UART
    task test_op;
        input [2:0] op; input [3:0] a, b; input [2:0] addr;
        reg [7:0] exp;
        begin
            exp = model(op, a, b);
            ext_selop = op; ext_A = a; ext_B = b; ext_addr = addr;
            ext_write_en = 1; ext_read_en = 0;
            press;
            repeat (80) @(posedge clk);          // tiempo para la multiplicacion
            ext_write_en = 0; ext_read_en = 1;
            fork press; uart_rx_line; join
            ext_read_en = 0;
            $write("op=%b A=%0d B=%0d  ", op, a, b);
            check_line(addr, exp);
            repeat (200) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_top.vcd"); $dumpvars(0, tb_top);
        KEY[0] = 0; repeat (5) @(posedge clk); KEY[0] = 1; repeat (5) @(posedge clk);

        test_op(3'b000, 4'd5,  4'd3,  3'd0);   // suma
        test_op(3'b001, 4'd9,  4'd4,  3'd1);   // resta
        test_op(3'b001, 4'd3,  4'd9,  3'd2);   // resta con resultado negativo (mod 16)
        test_op(3'b010, 4'd13, 4'd11, 3'd3);   // multiplicacion 143
        test_op(3'b010, 4'd15, 4'd15, 3'd4);   // multiplicacion 225 (segunda seguida)
        test_op(3'b011, 4'd7,  4'd12, 3'd5);   // comparador
        test_op(3'b100, 4'd8,  4'd2,  3'd6);   // corrimiento
        test_op(3'b101, 4'd12, 4'd10, 3'd7);   // AND
        test_op(3'b110, 4'd12, 4'd10, 3'd0);   // OR (sobrescribe addr 0)
        test_op(3'b111, 4'd12, 4'd10, 3'd1);   // XOR

        // Releer addr 3 sin reescribir: debe conservar el producto 143
        ext_addr = 3'd3; ext_write_en = 0; ext_read_en = 1;
        fork press; uart_rx_line; join
        ext_read_en = 0;
        check_line(3'd3, 8'd143);
        repeat (200) @(posedge clk);

        $display("TOTAL ERRORES: %0d", errors);
        $finish;
    end
endmodule
