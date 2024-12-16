module sensor_agua (
    input clock,
    input reset,
    input medir,
    input echo,
    input [1:0] modo,

    output reg suficiente,
    output wire trigger,
    output wire timeout,
    output reg pronto
);

    wire pronto_sensor;
    reg conta_timeout;
    wire [11:0] s_medida;

    parameter [1:0] pequeno = 2'b01;
    parameter [1:0] grande  = 2'b10;
    parameter [11:0] limite_pequeno = 12'h070; // 7 cm
    parameter [11:0] limite_grande  = 12'h050; // 5 cm

    interface_hcsr04 sensor_agua (
        .clock     (clock),
        .reset     (reset),
        .medir     (medir),
        .echo      (echo),
        .trigger   (trigger),
        .medida    (s_medida),
        .pronto    (pronto_sensor),
        .db_reset  (),
        .db_medir  (),
        .db_estado ()
    );

    always @(posedge clock) begin
        if (pronto_sensor) begin
            // TROCAR POR VALORES REAIS DEPOIS
            conta_timeout <= 1'b0;
            pronto <= 1'b1;
            if (modo == grande) begin
                if (s_medida > limite_grande)
                    suficiente <= 0;
                else suficiente <= 1;
            end

            else if (modo == pequeno) begin
                if (s_medida > limite_pequeno) // 7cm
                    suficiente <= 0;
                else suficiente <= 1;
            end

            else suficiente <= 1'b0;
        end
        else if (medir) begin
            conta_timeout <= 1'b1;
        end
        else if (reset) begin
            pronto <= 1'b0;
            suficiente <= 1'b0;
            conta_timeout <= 1'b0;
        end
        else begin
            pronto <= 1'b0;
            suficiente <= 1'b0;
        end
    end

    contador_m #(
        .M(50000000), // 1 seg
        .N(26)
    ) contador_timeout (
        .clock   (clock),
        .zera_as (1'b0),
        .zera_s  (reset),
        .conta   (conta_timeout),
        .fim     (timeout),
        .Q       (),
        .meio    ()
    );
    
endmodule