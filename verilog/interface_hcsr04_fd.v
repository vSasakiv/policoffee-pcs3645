/* --------------------------------------------------------------------------
 *  Arquivo   : interface_hcsr04_fd.v
 * --------------------------------------------------------------------------
 *  Descricao : Código do fluxo de dados do circuito de interface  
 *              com sensor ultrassonico de distancia
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao parcial em Verilog
 *      15/09/2024  2.0     Rodrigo Marcolin  versao final em Verilog
 * --------------------------------------------------------------------------
 */
 
module interface_hcsr04_fd (
    input wire         clock,
    input wire         pulso,
    input wire         zera,
    input wire         gera,
    input wire         registra,
    output wire        fim_medida,
    output wire        trigger,
    output wire        fim,
    output wire [11:0] distancia
);

    // Sinais internos
    wire [11:0] s_medida;

    // (U1) pulso de 10us => 500 clk , dado que 1clk = 20ns 
    gerador_pulso #(
        .largura(500) 
    ) U1 (
        .clock (clock  ),
        .gera  (gera),
        .para  (0), 
        .reset (zera),
        .pulso (trigger),
        .pronto()
    );

    // (U2) medida em mm (R=2941 clocks)
    contador_cm #(
        .R(294), 
        .N(9)
    ) U2 (
        .clock  (clock         ),
        .pulso  (pulso),
        .reset  (zera),
        .digito2(s_medida[11:8]),
        .digito1(s_medida[7:4] ),
        .digito0(s_medida[3:0] ),
        .fim    (fim),
        .pronto (fim_medida)
    );

    // (U3) registrador
    registrador_n #(
        .N(12)
    ) U3 (
        .clock  (clock    ),
        .clear  (zera),
        .enable (registra),
        .D      (s_medida ),
        .Q      (distancia)
    );

endmodule
