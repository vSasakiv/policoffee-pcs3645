`timescale 1ns/1ns

module uart_rx_tb;

    // sinais de entrada para o circuito em teste
    reg clk_in;
    reg rxd_in;
    reg reset_in;
    reg [7:0] msg = "V";
    wire [7:0] data_out;
    wire finished_out;

    localparam BAUD_RATE = 9600;
    localparam CLOCK_HZ = 50_000_000;
    localparam STOP_BITS = 1;
    localparam N_BITS = 8;
    // unidade em teste
    uart_rx # (
        .BAUD_RATE ( BAUD_RATE ),
        .CLOCK_HZ  ( CLOCK_HZ ),
        .STOP_BITS ( STOP_BITS ),
        .N_BITS    ( N_BITS )
    ) dut (
        .clk      (clk_in),
        .rxd      (rxd_in),
        .reset    (reset_in),
        .data     (data_out),
        .finished (finished_out)
    );

    localparam CLOCK_PERIOD = 20; // f = 50MHz
    // Bits enviados por nano segundo
    localparam BITS_PNS = 1_000_000_000 * 1/BAUD_RATE;
    // Periodo do sinal de clock em nano segundos
    localparam CLK_PNS = 1_000_000_000 * 1/CLOCK_HZ;
    // Numeros de ciclos de clock por bit de dados
    localparam CLK_P_BIT = BITS_PNS / CLK_PNS;

    // Gerador de clock
    always #(CLOCK_PERIOD/2) clk_in = ~clk_in;

    integer i = 0;

    initial begin
        $display("inicio da simulacao");

        // Condicoes iniciais
        clk_in   = 0;
        rxd_in   = 1;
        reset_in = 0;
        @(negedge clk_in); // espera borda de descida
        // gera sinal de reset
        reset_in = 1;
        #(CLOCK_PERIOD);
        reset_in = 0;
        #(5 * CLOCK_PERIOD);

        @(negedge clk_in);
        // envia start bit
        rxd_in = 0;
        // espera uart receber start bit
        #(CLK_P_BIT * CLOCK_PERIOD);
    

        for (; i < 8; i = i + 1) begin
            @(negedge clk_in);
            // envia bit
            rxd_in = msg[i];
            // espera uart receber 
            #(CLK_P_BIT * CLOCK_PERIOD);
        end

        #( CLK_P_BIT * CLOCK_PERIOD);

        $display("fim da simulacao");
        $stop;
    end
endmodule