module sensor_agua (
    input clock,
    input reset,
    input medir,
    input echo,
    input [7:0] modo,
    input conta_timeout,

    output reg suficiente,
    output wire trigger,
    output wire timeout,
    output reg pronto
);

    wire pronto_sensor;
    wire [11:0] s_medida;

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
            pronto <= 1'b1;
            if (modo == "G") begin
                if (s_medida > 12'h050) // 5cm
                    suficiente <= 0;
                else suficiente <= 1;
            end

            else if (modo == "P") begin
                if (s_medida > 12'h070) // 7cm
                    suficiente <= 0;
                else suficiente <= 1;
            end

            else suficiente <= 1'b0;
        end

        else begin
            pronto <= 1'b0;
            suficiente <= 1'b0;
        end
    end

    contador_m #(
        .M(50000000),
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