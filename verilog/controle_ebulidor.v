module controle_ebulidor (
    input clock,
    input reset,
    input liga_ebulidor,
    input fim_temperatura,

    output reg ebulidor,
    output reg fim_ebulidor,
    output wire timeout
);
    
    reg conta_timeout;

    contador_m #(
        .M(4200000000), 
        .N(32)
    ) contador_timeout (
        .clock   (clock),
        .zera_as (1'b0),
        .zera_s  (reset),
        .conta   (conta_timeout),
        .fim     (timeout),
        .Q       (),
        .meio    ()
    );

    always @(posedge clock) begin
        if (liga_ebulidor) begin
            conta_timeout <= 1'b1;
            ebulidor <= 1'b1;
        end
        else if (fim_temperatura) begin
            conta_timeout <= 1'b0;
            ebulidor <= 1'b0;
            fim_ebulidor <= 1'b1;
        end
        else if (reset) begin
            conta_timeout <= 1'b0;
            ebulidor <= 1'b0;
            fim_ebulidor <= 1'b0;
        end
        else begin
            fim_ebulidor <= 1'b0;
        end
    end

endmodule