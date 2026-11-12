module top_system #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 9600      // en simulacion se puede subir para acelerar
) (
    input  wire       clk,           // 50 MHz DE10-Lite
    input  wire [1:0] KEY,           // KEY[0]: reset, KEY[1]: disparo
    input  wire [3:0] ext_A,
    input  wire [3:0] ext_B,
    input  wire [2:0] ext_selop,
    input  wire [2:0] ext_addr,
    input  wire       ext_write_en,
    input  wire       ext_read_en,
    output wire       tx,
    output wire [2:0] LEDR
);
    wire rst     = ~KEY[0];
    wire btn_act = ~KEY[1];

    reg btn_d1, btn_d2;
    always @(posedge clk or posedge rst) begin
        if (rst) begin btn_d1 <= 1'b0; btn_d2 <= 1'b0; end
        else     begin btn_d1 <= btn_act; btn_d2 <= btn_d1; end
    end
    wire btn_pulse = btn_d1 && !btn_d2;

    wire       alu_done, alu_flag;
    wire [7:0] alu_result, reg_data_out;

    wire is_mult        = (ext_selop == 3'b010);
    wire alu_init_pulse = is_mult && btn_pulse;

    reg pending_mult_wr;
    always @(posedge clk or posedge rst) begin
        if (rst)                                              pending_mult_wr <= 1'b0;
        else if (btn_pulse && ext_write_en && is_mult)  pending_mult_wr <= 1'b1;
        else if (pending_mult_wr && alu_done)                 pending_mult_wr <= 1'b0;
    end

    wire write_trigger = (ext_write_en && btn_pulse && !is_mult) ||
                         (pending_mult_wr && alu_done);
    wire read_trigger  = ext_read_en && btn_pulse;

    reg read_d;                         // el banco entrega data_out 1 ciclo despues
    always @(posedge clk or posedge rst) begin
        if (rst) read_d <= 1'b0;
        else     read_d <= read_trigger;
    end

    ALU inst_alu (
        .A(ext_A), .B(ext_B), .selop(ext_selop), .Cin(1'b0),
        .init(alu_init_pulse), .clk(clk), .reset(rst),
        .done(alu_done), .result(alu_result), .flag(alu_flag)
    );

    banco_registro inst_banco (
        .clk(clk), .rst(rst),
        .data_in(alu_result), .addr(ext_addr),
        .write_en(write_trigger), .read_en(read_trigger),
        .data_out(reg_data_out)
    );

    // Formateador ASCII + UART
    wire       uart_start, uart_busy, fmt_busy;
    wire [7:0] uart_data;

    uart_fmt inst_fmt (
        .clk(clk), .rst(rst),
        .start(read_d), .addr(ext_addr), .data(reg_data_out),
        .tx_busy(uart_busy), .tx_start(uart_start), .tx_data(uart_data),
        .busy(fmt_busy)
    );

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) inst_uart_tx (
        .clk(clk), .rst(rst),
        .tx_data(uart_data), .tx_start(uart_start),
        .tx(tx), .tx_busy(uart_busy)
    );

    assign LEDR[0] = alu_flag;
    assign LEDR[1] = alu_done;
    assign LEDR[2] = fmt_busy;
endmodule
