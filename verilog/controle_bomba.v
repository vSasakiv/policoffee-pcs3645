module controle_bomba (
    input clock,
    input reset,
    input [1:0] modo,
    input liga_bomba,
    output reg bomba,
    output reg fim_bomba
);
    
parameter [1:0] pequeno = 2'b01;
parameter [1:0] grande  = 2'b10;

reg conta_grande;
reg conta_pequeno;
wire fim_pequeno;
wire fim_grande;
wire fim_bombeamento;

assign fim_bombeamento = fim_pequeno | fim_grande;

contador_m #(
    .M(625000000), // 12,5 seg
    .N(30)
) contador_grande (
    .clock   (clock),
    .zera_as (1'b0),
    .zera_s  (reset),
    .conta   (conta_grande),
    .fim     (fim_grande),
    .Q       (),
    .meio    ()
);

contador_m #(
    .M(312500000), // 6,25 seg
    .N(29)
) contador_pequeno (
    .clock   (clock),
    .zera_as (1'b0),
    .zera_s  (reset),
    .conta   (conta_pequeno),
    .fim     (fim_pequeno),
    .Q       (),
    .meio    ()
);

always @(posedge clock) begin
    if (reset) begin
        conta_pequeno <= 1'b0;
        conta_grande <= 1'b0;
        bomba <= 1'b0;
        fim_bomba <= 1'b0;
    end
    else if (liga_bomba) begin
        bomba <= 1'b1;
        if (modo == pequeno) conta_pequeno <= 1'b1;
        else if (modo == grande) conta_grande <= 1'b1;
    end
    else if (fim_bombeamento) begin
        conta_pequeno <= 1'b0;
        conta_grande <= 1'b0;
        bomba <= 1'b0;
        fim_bomba <= 1'b1;
    end
    else fim_bomba <= 1'b0;
end

endmodule