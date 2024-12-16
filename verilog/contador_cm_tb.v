/* --------------------------------------------------------------------------
 *  Arquivo   : contador_cm_tb.v
 * --------------------------------------------------------------------------
 *  Descricao : testbench basico para o componente de contagem de cm
 *
 *              possui 4 casos de teste, com truncamento e arredondamento
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */

`timescale 1ns/1ns

module contador_cm_tb;

    // Declaração de sinais
    reg        clock_in = 0;
    reg        reset_in = 0;
    reg        pulso_in = 0;
    wire [3:0] digito0_out;
    wire [3:0] digito1_out;
    wire [3:0] digito2_out;
    wire       fim_out;
    wire       pronto_out;

    // Componente a ser testado (Device Under Test -- DUT)
    contador_cm #(
        .R(2941), 
        .N(12  )
    ) dut (
        .clock  (clock_in   ),
        .reset  (reset_in   ),
        .pulso  (pulso_in   ),
        .digito0(digito0_out),
        .digito1(digito1_out),
        .digito2(digito2_out),
        .fim    (fim_out    ),
        .pronto (pronto_out )
    );

    // Configurações do clock
    parameter clockPeriod = 20; // clock de 50MHz
    // Gerador de clock
    always #(clockPeriod/2) clock_in = ~clock_in;

    // Array de casos de teste (estrutura equivalente em Verilog)
    reg [31:0] casos_teste [0:3]; // Usando 32 bits para acomodar o tempo
    integer caso;

    // Largura do pulso
    reg [31:0] larguraPulso; // Usando 32 bits para acomodar tempos maiores


    // Geração dos sinais de entrada (estímulos)
    initial begin
        $display("Inicio das simulacoes...");

        // Inicialização do array de casos de teste
        casos_teste[0] = 5882;   // 5882us (100cm)
        casos_teste[1] = 5899;   // 5899us (100,29cm) truncar para 100cm
        casos_teste[2] = 4353;   // 4353us (74cm)
        casos_teste[3] = 4399;   // 4399us (74,79cm) arredondar para 75cm

        // Valores iniciais
        pulso_in = 0;

        // Reset
        caso=0; 
        #(2*clockPeriod);
        reset_in = 1;
        #(2_000); // 2 us
        reset_in = 0;
        @(negedge clock_in);

        // Espera de 100us
        #(100_000); // 100 us

        // Loop pelos casos de teste
        for (caso = 1; caso < 5; caso = caso + 1) begin
            // 1) Determina a largura do pulso do caso de teste
            $display("Caso de teste %0d: %0dus", caso, casos_teste[caso-1]);
            larguraPulso = casos_teste[caso-1]*1000; // 1us=1000

            // 2) Espera por 400us (tempo entre trigger e echo)
            #(400_000); // 400 us

            // 3) Gera pulso de entrada
            pulso_in = 1;
            #(larguraPulso);
            pulso_in = 0;

            // 5) Espera final da medida
            wait (pronto_out == 1'b1);
            $display("Fim do caso %0d", caso);

            // 6) Espera entre casos de teste
            #(100_000); // 100 us
        end

        // Fim da simulação
        $display("Fim das simulacoes");
        caso=99; 
        $stop;
    end

endmodule