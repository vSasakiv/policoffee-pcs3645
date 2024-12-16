/* --------------------------------------------------------------------------
 *  Arquivo   : contador_cm_fd
 * --------------------------------------------------------------------------
 *  Descricao : fluxo de dados do componente de contagem de cm 
 *
 *              componente parametrizado em funcao de clocks/cm
 *            
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */

module contador_cm_fd #(
    parameter R = 10,  // razão de clocks por cm
    parameter N = 4    // teto(log2(R)) 
) (
    input wire        clock,
    input wire        pulso,
    input wire        zera_tick,
    input wire        conta_tick,
    input wire        zera_bcd,
    input wire        conta_bcd,
    output wire       tick,
    output wire [3:0] digito0,
    output wire [3:0] digito1,
    output wire [3:0] digito2,
    output wire       fim
);

    // Gera tick do contador de cm a cada ciclo de R
    contador_m #(
        .M (R), 
        .N (N)
    ) U1 (
        .clock   (clock     ),
        .zera_as (1'b0      ),
        .zera_s  (zera_tick ),
        .conta   (conta_tick),
        .Q       (          ),  // s_resto (desconectado)
        .fim     (          ),  // fim (desconectado)
        .meio    (tick      )
    );

    // Contador de distância em cm
    contador_bcd_3digitos U2 (
        .clock   (clock    ),
        .zera    (zera_bcd ),
        .conta   (conta_bcd),
        .digito0 (digito0  ),
        .digito1 (digito1  ),
        .digito2 (digito2  ),
        .fim     (fim      )
    );

endmodule