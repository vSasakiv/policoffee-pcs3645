module controle_valvula (
    input clock,
    input reset,
    input liga_valvula,

    output reg valvula,
    output reg fim_valvula
);

    reg conta_valvula;
    wire s_fim_valvula;
    
    contador_m #(
        .M(3000000000), // 60 seg
        .N(32)
    ) contador_valvula (
        .clock   (clock),
        .zera_as (1'b0),
        .zera_s  (reset),
        .conta   (conta_valvula),
        .fim     (s_fim_valvula),
        .Q       (),
        .meio    ()
    );

    always @(posedge clock) begin
        if (liga_valvula) begin
            conta_valvula <= 1'b1;
            valvula <= 1'b1;
        end
        else if (s_fim_valvula) begin
            conta_valvula <= 1'b0;
            valvula <= 1'b0;
            fim_valvula <= 1'b1;
        end
        else if (reset) begin
            conta_valvula <= 1'b0;
            valvula <= 1'b0;
            fim_valvula <= 1'b0;
        end
        else begin
            fim_valvula <= 1'b0;
        end
    end
endmodule