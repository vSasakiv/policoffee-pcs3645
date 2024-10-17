module cafeteira (
    input clock,
    input reset,
    input preparar,
    input rx_esp,
    input echo_agua,
    input echo_xicara,
    input fim_temperatura,
    
    output wire fim,
    output wire trigger_agua,
    output wire trigger_xicara,
    output wire bomba,
    output wire ebulidor,
    output wire valvula,
    output wire erro_sem_agua,
    output wire erro_sem_xicara
);

    wire s_zera_sensor_agua;
    wire s_zera_sensor_xicara;
    wire s_zera_bomba;
    wire s_zera_valvula;
    wire s_zera_ebulidor;
    wire s_zera_serial;
    wire s_medir_agua;
    wire s_verifica_xicara;
    wire s_liga_bomba;
    wire s_liga_ebulidor;
    wire s_liga_valvula;
    wire s_pronto_serial;
    wire s_pronto_sensor_agua;
    wire s_timeout_agua;
    wire s_suficiente;
    wire s_pronto_sensor_xicara;
    wire s_timeout_xicara;
    wire s_tem_xicara;
    wire s_fim_bomba;
    wire s_fim_ebulidor;
    wire s_timeout_ebulidor;
    wire s_fim_valvula;

cafeteira_fd fd (
    .clock (clock),
    .rx_esp (rx_esp),
    .echo_agua (echo_agua),
    .echo_xicara (echo_xicara),
    .fim_temperatura (fim_temperatura),
    .zera_sensor_agua (s_zera_sensor_agua),
    .zera_sensor_xicara (s_zera_sensor_xicara),
    .zera_bomba (s_zera_bomba),
    .zera_valvula (s_zera_valvula),
    .zera_ebulidor (s_zera_ebulidor),
    .zera_serial (s_zera_serial),
    .medir_agua (s_medir_agua),
    .verifica_xicara (s_verifica_xicara),
    .liga_bomba (s_liga_bomba),
    .liga_ebulidor (s_liga_ebulidor),
    .liga_valvula (s_liga_valvula),
    .trigger_agua (trigger_agua),
    .trigger_xicara (trigger_xicara),
    .pronto_serial (s_pronto_serial),
    .pronto_sensor_agua (s_pronto_sensor_agua),
    .timeout_agua (s_timeout_agua),
    .suficiente (s_suficiente),
    .pronto_sensor_xicara (s_pronto_sensor_xicara),
    .timeout_xicara (s_timeout_xicara),
    .tem_xicara (s_tem_xicara),
    .fim_bomba (s_fim_bomba),
    .fim_ebulidor (s_fim_ebulidor),
    .timeout_ebulidor (s_timeout_ebulidor),
    .fim_valvula(s_fim_valvula),
    .bomba (bomba),
    .valvula (valvula),
    .ebulidor (ebulidor)
);

cafeteira_uc uc (
    .clock (clock),
    .reset (reset),
    .preparar (preparar),
    .zera_sensor_agua (s_zera_sensor_agua),
    .zera_sensor_xicara (s_zera_sensor_xicara),
    .zera_bomba (s_zera_bomba),
    .zera_valvula (s_zera_valvula),
    .zera_ebulidor (s_zera_ebulidor),
    .zera_serial (s_zera_serial),
    .medir_agua (s_medir_agua),
    .verifica_xicara (s_verifica_xicara),
    .liga_bomba (s_liga_bomba),
    .liga_ebulidor (s_liga_ebulidor),
    .liga_valvula (s_liga_valvula),
    .pronto_serial (s_pronto_serial),
    .pronto_sensor_agua (s_pronto_sensor_agua),
    .timeout_agua (s_timeout_agua),
    .suficiente (s_suficiente),
    .pronto_sensor_xicara (s_pronto_sensor_xicara),
    .timeout_xicara (s_timeout_xicara),
    .tem_xicara (s_tem_xicara),
    .fim_bomba (s_fim_bomba),
    .fim_ebulidor (s_fim_ebulidor),
    .timeout_ebulidor (s_timeout_ebulidor),
    .fim_valvula(s_fim_valvula),
    .erro_sem_agua (erro_sem_agua),
    .erro_sem_xicara (erro_sem_xicara),
    .pronto          (fim),
    .db_estado ()
);

endmodule