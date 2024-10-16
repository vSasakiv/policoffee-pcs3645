module cafeteira_fd (
    input wire clock,
    input wire rx_esp,    // ESP
    input wire echo_agua, // HC SR04
    input wire echo_xicara, // HC SR04
    input wire zera_sensor_agua, // UC
    input wire zera_sensor_xicara, // UC
    input wire zera_bomba, // UC
    input wire zera_valvula, // UC
    input wire zera_ebulidor, // UC
    input wire zera_serial, // UC
    input wire medir_agua, // UC
    input wire verifica_xicara, // UC
    input wire liga_bomba, // UC
    input wire liga_ebulidor, // UC
    input wire liga_valvula, // UC
    input wire fim_temperatura, // ESP

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
    output fim_ebulidor, // UC
    output timeout_ebulidor, // UC
    output bomba, // BOMBA
    output valvula, // VALVULA
    output ebulidor, // EBULIDOR
    output fim_valvula // UC
);

    wire [1:0] s_modo;

    cafeteira_serial serial (
        .clock  (clock),
        .reset  (zera_serial),
        .rxd    (rx_esp),
        .pronto (pronto_serial),
        .modo   (s_modo)
    );

    sensor_agua s_agua (
        .clock        (clock),
        .reset        (zera_sensor_agua),
        .medir        (medir_agua),
        .echo         (echo_agua),
        .modo         (s_modo),
        .trigger      (trigger_agua),
        .pronto       (pronto_sensor_agua),
        .suficiente   (suficiente),
        .timeout      (timeout_agua)
    );

    sensor_xicara s_xicara (
        .clock        (clock),
        .reset        (zera_sensor_xicara),
        .medir        (verifica_xicara),
        .echo         (echo_xicara),
        .trigger      (trigger_xicara),
        .pronto       (pronto_sensor_xicara),
        .tem_xicara   (tem_xicara),
        .timeout      (timeout_xicara)
    );

    controle_bomba c_bomba (
        .clock      (clock),
        .reset      (zera_bomba),
        .modo       (s_modo),
        .liga_bomba (liga_bomba),
        .bomba      (bomba),
        .fim_bomba  (fim_bomba)
    );

    controle_ebulidor c_ebulidor (
        .clock           (clock),
        .reset           (zera_ebulidor),
        .liga_ebulidor   (liga_ebulidor),
        .fim_temperatura (fim_temperatura),
        .ebulidor        (ebulidor),
        .fim_ebulidor    (fim_ebulidor),
        .timeout         (timeout_ebulidor)
    );

    controle_valvula c_valvula (
        .clock (clock),
        .reset (zera_valvula),
        .liga_valvula (liga_valvula),
        .valvula (valvula),
        .fim_valvula (fim_valvula)
    );


endmodule