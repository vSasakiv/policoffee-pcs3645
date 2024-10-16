/* -----------------Laboratorio Digital-----------------------------------
 *  Arquivo   : registrador_n.v
 * -----------------------------------------------------------------------
 *  Descricao : registrador com numero de bits N como parametro
 *              com clear assincrono e carga sincrona
 * 
 *              baseado no codigo vreg16.v do livro
 *              J. Wakerly, Digital design: principles and practices 5e
 *
 * -----------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      11/01/2024  1.0     Edson Midorikawa  criacao
 * -----------------------------------------------------------------------
 */
 
module registrador_n #(parameter N = 8) (
    input          clock,
    input          clear,
    input          enable,
    input  [N-1:0] D,
    output [N-1:0] Q
);

    reg [N-1:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule
