/* --------------------------------------------------------------------------
 *  Arquivo   : interface_hcsr04_uc.v
 * --------------------------------------------------------------------------
 *  Descricao : Código da unidade de controle do circuito de 
 *              interface com sensor ultrassonico de distancia
 *              
 * --------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      07/09/2024  1.0     Edson Midorikawa  versao parcial em Verilog
 *      15/09/2024  2.0     Rodrigo Marcolin  versao final em Verilog
 * --------------------------------------------------------------------------
 */
 
module interface_hcsr04_uc (
    input wire       clock,
    input wire       reset,
    input wire       medir,
    input wire       echo,
    input wire       fim_medida,
    output reg       zera,
    output reg       gera,
    output reg       registra,
    output reg       pronto,
    output reg [3:0] db_estado 
);

    // Tipos e sinais
    reg [2:0] Eatual, Eprox; // 3 bits são suficientes para 7 estados

    // Parâmetros para os estados
    parameter inicial       = 3'b000;
    parameter preparacao    = 3'b001;
    parameter envia_trigger = 3'b010;
    parameter espera_echo   = 3'b011;
    parameter medida        = 3'b100;
    parameter armazenamento = 3'b101;
    parameter final_medida  = 3'b110;

    // Estado
    always @(posedge clock, posedge reset) begin
        if (reset) 
            Eatual <= inicial;
        else
            Eatual <= Eprox; 
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            inicial: begin
                if (medir) begin
                    Eprox = preparacao;
                end else begin
                    Eprox = inicial;
                end
            end
                
            preparacao: begin
                Eprox = envia_trigger;
            end

            envia_trigger: begin
                Eprox = espera_echo;
            end

            espera_echo: begin
                if (echo) begin
                    Eprox = medida;
                end else begin
                    Eprox = espera_echo;
                end
            end 

            medida: begin
                if (fim_medida) begin
                    Eprox = armazenamento;
                end else begin
                    Eprox = medida;
                end
            end 

            armazenamento: begin
                Eprox = final_medida;
            end

            final_medida: 
                Eprox = inicial;

            default: 
                Eprox = inicial;
        endcase
    end

    // Saídas de controle
    always @(*) begin
        zera    = (Eatual == preparacao) ? 1'b1 : 1'b0;
        gera = (Eatual == envia_trigger) ? 1'b1 : 1'b0;
        registra = (Eatual == armazenamento) ? 1'b1 : 1'b0;
        pronto   = (Eatual == final_medida) ? 1'b1 : 1'b0;

        case (Eatual)
            inicial:       db_estado = 4'b0000;
            preparacao:    db_estado = 4'b0001;
            envia_trigger: db_estado = 4'b0010;
            espera_echo:   db_estado = 4'b0011;
            medida:        db_estado = 4'b0100;
            armazenamento: db_estado = 4'b0101;
            final_medida:  db_estado = 4'b1111;
            default:       db_estado = 4'b1110;
        endcase
    end

endmodule
