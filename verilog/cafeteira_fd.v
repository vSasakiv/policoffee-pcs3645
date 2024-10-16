module cafeteira_fd (
    input wire clock,
    input wire rx_esp,    // ESP
    input wire echo_agua, // HC SR04
    input wire echo_xicara, // HC SR04
    input wire zera_sensor_agua, // UC
    input wire zera_timeout_agua, // UC
    input wire zera_timeout_xicara, // UC
    input wire zera_sensor_xicara, // UC
    input wire zera_bomba, // UC
    input wire zera_valvula, // UC
    input wire zera_serial, // UC
    input wire zera_timeout_ebulidor, // UC
    input wire medir_agua, // UC
    input wire conta_timeout_agua, // UC
    input wire verifica_xicara, // UC
    input wire conta_timeout_xicara, // UC
    input wire conta_bomba, // UC
    input wire conta_timeout_ebulidor, // UC
    input wire conta_valvula, // UC

    output wire trigger_agua, // HC SR04
    output wire trigger_xicara, // HC SR04
    output pronto_serial, // UC
    output pronto_sensor_agua, // UC
    output timeout_agua, // UC
    output suficiente, // UC
    output pronto_sensor_xicara, // UC
    output timeout_xicara, // UC
    output tem_xicara, // UC
    output fim_bomba, // UC
    output timeout_ebulidor, // UC
    output fim_valvula // UC
);

    wire [7:0] s_modo;

    sensor_agua sensor_agua (
        .clock        (clock),
        .reset        (zera_sensor_agua),
        .medir        (medir_agua),
        .echo         (echo_agua),
        .modo         (s_modo),
        .trigger      (trigger_agua),
        .pronto       (pronto_sensor_agua),
        .suficiente   (suficiente),
        .conta_timeout(conta_timeout_agua),
        .timeout      (timeout_agua)
    );

    sensor_xicara sensor_xicara (
        .clock        (clock),
        .reset        (zera_timeout_xicara),
        .medir        (verifica_xicara),
        .echo         (echo_xicara),
        .trigger      (trigger_xicara),
        .pronto       (pronto_sensor_xicara),
        .tem_xicara   (tem_xicara),
        .conta_timeout(conta_timeout_xicara),
        .timeout      (timeout_xicara)
    );

    cafeteira_serial serial (
        .clock  (clock),
        .reset  (zera_serial),
        .rxd    (rx_esp),
        .pronto (pronto_serial),
        .dados  (s_modo)
    );

endmodule