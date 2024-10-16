/* --------------------------------------------------------------------------
 *  Arquivo   : contador_cm_uc.v
 * --------------------------------------------------------------------------
 *  Descricao : unidade de controle do componente contador_cm
 *              
 *              incrementa contagem de cm a cada sinal de tick enquanto
 *              o pulso de entrada permanece ativo
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao parcial em Verilog
 *      15/09/2024  2.0     Rodrigo Marcolin  versao final_sensor em Verilog
 * --------------------------------------------------------------------------
 */

module contador_cm_uc (
    input wire clock,
    input wire reset,
    input wire pulso,
    input wire tick,
    output reg zera_tick,
    output reg conta_tick,
    output reg zera_bcd,
    output reg conta_bcd,
    output reg pronto
);
    // Tipos e sinais
    reg [2:0] Eatual, Eprox; // 3 bits são suficientes para os estados
    // Parâmetros para os estados
    parameter inicial = 3'b000;
    parameter preparacao = 3'b001;
    parameter espera_tick = 3'b010;
    parameter tick_impar = 3'b101;
    parameter tick_par = 3'b011;
    parameter incrementa = 3'b111;
    parameter final_sensor = 3'b100;

    // Memória de estado
    always @(posedge clock, posedge reset) begin
        if (reset)
            Eatual <= inicial;
        else
            Eatual <= Eprox;
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            inicial: Eprox = pulso ? preparacao : inicial;
            preparacao: Eprox = espera_tick;
            espera_tick: Eprox = tick ? incrementa : pulso ? espera_tick : final_sensor;
            incrementa: Eprox = pulso ? tick_impar : final_sensor;
            tick_impar: Eprox = tick ? tick_par : pulso ? tick_impar : final_sensor;
            tick_par: Eprox = pulso ? espera_tick : final_sensor;
            final_sensor: Eprox = inicial;
            default: Eprox = inicial;
        endcase
    end

    // Lógica de saída (Moore)
    always @(*) begin
        zera_tick = 1'b0;
        conta_tick = 1'b0;
        zera_bcd = 1'b0;
        conta_bcd = 1'b0;
        pronto = 1'b0;

        case (Eatual)
            inicial: begin
                zera_tick = 1'b1;
                zera_bcd = 1'b1;
            end
            preparacao: begin
                zera_tick = 1'b1;
            end
            espera_tick: begin
                conta_tick = 1'b1;
            end
            incrementa: begin
                zera_tick = 1'b1;
                conta_bcd = 1'b1;
            end
            tick_impar: begin
                conta_tick = 1'b1;
            end
            tick_par: begin
                zera_tick = 1'b1;
            end
            final_sensor: begin
                pronto = 1'b1;
            end
            default: begin
            end
        endcase
    end
endmodule