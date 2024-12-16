module sensor_xicara (
    input clock,
    input reset,
    input medir,
    input echo,

    output reg tem_xicara,
    output wire trigger,
    output wire timeout,
    output reg pronto
);

    reg conta_timeout;
    wire pronto_sensor;
    wire [11:0] s_medida;

    parameter [11:0] limite_xicara = 12'h150; // 15cm

    interface_hcsr04 sensor_xicara (
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
            if (s_medida > limite_xicara) // 15cm
                    tem_xicara <= 0;
            else tem_xicara <= 1;
        end

        else if (medir)
            conta_timeout <= 1'b1;

        else if (reset) begin
            conta_timeout <= 1'b0;
            pronto <= 1'b0;
            tem_xicara <= 1'b0;
        end

        else begin
            pronto <= 1'b0;
            tem_xicara <= 1'b0;
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