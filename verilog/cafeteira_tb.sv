`timescale 1ns/1ns

module cafeteira_tb;

    reg clock_in = 0;
    reg reset_in = 0;
    reg preparar_in = 0;
    reg rx_esp_in = 1;
    reg echo_agua_in = 0;
    reg echo_xicara_in = 0;
    reg fim_temperatura_in = 0;

    wire trigger_agua_out;
    wire trigger_xicara_out;
    wire bomba_out;
    wire ebulidor_out;
    wire valvula_out;
    wire erro_sem_agua_out;
    wire erro_sem_xicara_out;

    cafeteira DUT (
        .clock (clock_in),
        .reset (reset_in),
        .preparar (preparar_in),
        .rx_esp (rx_esp_in),
        .echo_agua (echo_agua_in),
        .echo_xicara (echo_xicara_in),
        .fim_temperatura (fim_temperatura_in),

        .trigger_agua(trigger_agua_out),
        .trigger_xicara(trigger_xicara_out),
        .bomba(bomba_out),
        .ebulidor (ebulidor_out),
        .valvula (valvula_out),
        .erro_sem_agua (erro_sem_agua_out),
        .erro_sem_xicara (erro_sem_xicara_out)
    );

    // Configurações do clock
    parameter clockPeriod = 20; // clock de 50MHz
    // Gerador de clock
    always #(clockPeriod/2) clock_in = ~clock_in;


    initial begin
        $display ("inicio testes");

        // Reset
        #(2*clockPeriod);
        reset_in = 1;
        #(2_000);
        reset_in = 0;
        @(negedge clock_in);

        // Espera de 100us
        #(100_000); // 100 us
        @(negedge clock_in)
        preparar_in = 1;

    end

endmodule