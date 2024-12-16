/* --------------------------------------------------------------------------
 *  Arquivo   : gerador_pulso.v
 * --------------------------------------------------------------------------
 *  Descricao : componente parametrizado para geracao de pulso de largura
 *              especificada pelo parametro (em periodos do clock)
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao em Verilog
 * --------------------------------------------------------------------------
 */

module gerador_pulso #(
    parameter largura = 25
) (
    input wire clock,
    input wire reset,
    input wire gera,
    input wire para,
    output reg pulso,
    output reg pronto
);

    // Tipos e sinais
    reg [1:0] reg_estado, prox_estado;
    reg [31:0] reg_cont, prox_cont; // usando 32 bits para acomodar valores maiores de largura

    // Parâmetros para os estados
    localparam parado       = 2'b00;
    localparam contagem     = 2'b01;
    localparam final_pulso  = 2'b10;

    // Lógica de estado e contagem
    always @(posedge clock, posedge reset) begin
        if (reset) begin
            reg_estado <= parado;
            reg_cont <= 0;
        end else begin
            reg_estado <= prox_estado;
            reg_cont <= prox_cont;
        end
    end

    // Lógica de próximo estado e contagem
    always @(*) begin
        pulso = 0;
        pronto = 0;
        prox_cont = reg_cont;

        case (reg_estado)
            parado: begin
                if (gera) begin
                    prox_estado = contagem;
                end else begin
                    prox_estado = parado;
                end
                prox_cont = 0;
            end

            contagem: begin
                if (para) begin
                    prox_estado = parado;
                end else begin
                    if (reg_cont == largura - 1) begin
                        prox_estado = final_pulso;
                    end else begin
                        prox_estado = contagem;
                        prox_cont = reg_cont + 1;
                    end
                end
                pulso = 1;
            end

            final_pulso: begin
                prox_estado = parado;
                pronto = 1;
            end
        endcase
    end

endmodule