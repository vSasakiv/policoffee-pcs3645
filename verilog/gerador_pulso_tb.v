/* --------------------------------------------------------------------------
 *  Arquivo   : gerador_pulso_tb.v
 * --------------------------------------------------------------------------
 *  Descricao : testbench basico para o gerador de pulso parametrizado
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */

`timescale 1ns/1ns

module gerador_pulso_tb;

    // Sinais para o DUT
    reg  clock;
    reg  reset;
    reg  gera;
    reg  para;
    wire pulso;
    wire pronto;

    // Instanciação do DUT
    gerador_pulso #(
        .largura(25) // Largura do pulso (ajuste conforme necessário)
    ) dut (
        .clock (clock ),
        .reset (reset ),
        .gera  (gera  ),
        .para  (para  ),
        .pulso (pulso ),
        .pronto(pronto)
    );

    // Clock com período de 20ns
    parameter CLOCK_PERIOD = 20;
    always #(CLOCK_PERIOD/2) clock = ~clock;

    // Estímulos
    initial begin
	
	    $display("Inicio da simulacao\n");

        // Inicialização
        clock = 0;
        reset = 1;
        gera  = 0;
        para  = 0;
        #CLOCK_PERIOD; // Aguarda um ciclo de clock para o reset surtir efeito

        // Libera o reset e aguarda 10 ciclos de clock
	    $display("gera reset\n");

        // gera pulso de reset
        @(negedge clock);
        reset = 0;
        #(10 * CLOCK_PERIOD);

        // Gera o pulso
        gera = 1;
        #CLOCK_PERIOD; // Aguarda um ciclo para o sinal ser reconhecido
        gera = 0;

        // Aguarda até que o pulso seja gerado (pronto = 1)
        @(posedge pronto);
        #(10 * CLOCK_PERIOD);

        // Fim da simulação
        $display("Fim da simulacao\n");
        $stop;
    end

endmodule