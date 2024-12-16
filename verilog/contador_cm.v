/* --------------------------------------------------------------------------
 *  Arquivo   : contador_cm.v
 * --------------------------------------------------------------------------
 *  Descricao : componente de contagem de cm 
 *
 *              componente parametrizado em funcao de clocks/cm
 *            
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */
 
module contador_cm #(
    parameter R = 10,  // razão de clocks por cm
    parameter N = 4    // teto(log2(R))
) (
    input wire        clock,
    input wire        reset,
    input wire        pulso,
    output wire [3:0] digito0,
    output wire [3:0] digito1,
    output wire [3:0] digito2,
    output wire       fim,
    output wire       pronto
);

    // Sinais internos
    wire s_zera_tick;
    wire s_conta_tick;
    wire s_zera_bcd;
    wire s_conta_bcd;
    wire s_tick;

    // Instanciação do contador_cm_fd
    contador_cm_fd #(
        .R(R), 
        .N(N)
    ) FD (
        .clock     (clock       ),
        .pulso     (pulso       ),
        .zera_tick (s_zera_tick ),
        .conta_tick(s_conta_tick),
        .zera_bcd  (s_zera_bcd  ),
        .conta_bcd (s_conta_bcd ),
        .tick      (s_tick      ),
        .digito0   (digito0     ),
        .digito1   (digito1     ),
        .digito2   (digito2     ),
        .fim       (fim         )
    );

    // Instanciação do contador_cm_uc
    contador_cm_uc UC (
        .clock     (clock       ),
        .reset     (reset       ),
        .pulso     (pulso       ),
        .tick      (s_tick      ),
        .zera_tick (s_zera_tick ),
        .conta_tick(s_conta_tick),
        .zera_bcd  (s_zera_bcd  ),
        .conta_bcd (s_conta_bcd ),
        .pronto    (pronto      )
    );

endmodule