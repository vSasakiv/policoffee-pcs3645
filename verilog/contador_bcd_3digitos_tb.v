/* --------------------------------------------------------------------------
 *  Arquivo   : contador_bcd_3digitos_tb.v
 * --------------------------------------------------------------------------
 *  Descricao : testbench basico para o contador BCD de 3 digitos
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */
 
`timescale 1ns/1ns

module contador_bcd_3digitos_tb;

    // Sinais para o DUT (Device Under Test)
    reg        clock;
    reg        zera;
    reg        conta;
    wire [3:0] digito0;
    wire [3:0] digito1;
    wire [3:0] digito2;
    wire       fim;

    // Instanciação do DUT
    contador_bcd_3digitos dut (
        .clock  (clock  ),
        .zera   (zera   ),
        .conta  (conta  ),
        .digito0(digito0),
        .digito1(digito1),
        .digito2(digito2),
        .fim    (fim    )
    );

    // Clock
    parameter CLOCK_PERIOD = 20; // Período de clock em unidades de tempo (ns)
    always #(CLOCK_PERIOD/2) clock = ~clock;

    // Estímulos
    initial begin
        // Inicialização
        clock = 0;
        zera  = 1;     // Zera o contador inicialmente
        conta = 0;
        #CLOCK_PERIOD; // Aguarda um ciclo de clock

        // Libera o reset e habilita a contagem
        zera  = 0;
        conta = 1;
        #(1005 * CLOCK_PERIOD); // Conta por 1005 ciclos de clock

        // Fim da simulação
        $stop;
    end

endmodule
