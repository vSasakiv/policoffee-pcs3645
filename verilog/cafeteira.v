module cafeteira (
    input clock,
    input reset,
    input preparar,
    input rx_esp,
    input echo_xicara,
    input fim_temperatura,
    
    output wire fim,
    output wire trigger_xicara,
    output wire bomba,
    output wire ebulidor,
    output wire valvula,
    output wire erro_sem_xicara,
	output wire erro_timeout_ebulidor,
	output wire [6:0] db_estado_hex0,
	output wire [6:0] db_estado_hex1
);

    wire s_zera_sensor_xicara;
    wire s_zera_bomba;
    wire s_zera_valvula;
    wire s_zera_ebulidor;
    wire s_zera_serial;
    wire s_verifica_xicara;
    wire s_liga_bomba;
    wire s_liga_ebulidor;
    wire s_liga_valvula;
    wire s_pronto_serial;
    wire s_pronto_sensor_agua;
    wire s_suficiente;
    wire s_pronto_sensor_xicara;
    wire s_timeout_xicara;
    wire s_tem_xicara;
    wire s_fim_bomba;
    wire s_fim_ebulidor;
    wire s_timeout_ebulidor;
    wire s_fim_valvula;
	 wire s_conta_interferencia;
	 wire s_fim_contagem;
	 wire s_conta_fim;
	 wire s_fim_espera_fim;
	 wire [4:0] db_estado;

cafeteira_fd fd (
    .clock (clock),
    .rx_esp (rx_esp),
    .echo_xicara (echo_xicara),
    .fim_temperatura (fim_temperatura),
    .zera_sensor_xicara (s_zera_sensor_xicara),
    .zera_bomba (s_zera_bomba),
    .zera_valvula (s_zera_valvula),
    .zera_ebulidor (s_zera_ebulidor),
    .zera_serial (s_zera_serial),
    .verifica_xicara (s_verifica_xicara),
    .liga_bomba (s_liga_bomba),
    .liga_ebulidor (s_liga_ebulidor),
    .liga_valvula (s_liga_valvula),
    .trigger_xicara (trigger_xicara),
    .pronto_serial (s_pronto_serial),
    .pronto_sensor_xicara (s_pronto_sensor_xicara),
    .timeout_xicara (s_timeout_xicara),
    .tem_xicara (s_tem_xicara),
    .fim_bomba (s_fim_bomba),
    .timeout_ebulidor (s_timeout_ebulidor),
    .fim_valvula(s_fim_valvula),
    .bomba (bomba),
    .valvula (valvula),
    // .ebulidor (ebulidor),
	 .conta_interferencia(s_conta_interferencia),
	 .fim_contagem (s_fim_contagem),
	 .fim_espera_fim (s_fim_espera_fim),
	 .conta_fim (s_conta_fim)
);

cafeteira_uc uc (
    .clock (clock),
    .reset (reset),
    .preparar (preparar),
	 .fim_temperatura (fim_temperatura),
    .zera_sensor_xicara (s_zera_sensor_xicara),
    .zera_bomba (s_zera_bomba),
    .zera_valvula (s_zera_valvula),
    .zera_ebulidor (s_zera_ebulidor),
    .zera_serial (s_zera_serial),
    .verifica_xicara (s_verifica_xicara),
    .liga_bomba (s_liga_bomba),
    .liga_ebulidor (s_liga_ebulidor),
    .liga_valvula (s_liga_valvula),
    .pronto_serial (s_pronto_serial),
    .pronto_sensor_xicara (s_pronto_sensor_xicara),
    .timeout_xicara (s_timeout_xicara),
    .tem_xicara (s_tem_xicara),
    .fim_bomba (s_fim_bomba),
    .timeout_ebulidor (s_timeout_ebulidor),
    .fim_valvula(s_fim_valvula),
    .erro_sem_xicara (erro_sem_xicara),
	.erro_timeout_ebulidor(erro_timeout_ebulidor),
    .pronto          (fim),
	 .conta_interferencia(s_conta_interferencia),
	 .fim_contagem (s_fim_contagem),
	 .ebulidor (ebulidor),
	 .fim_espera_fim (s_fim_espera_fim),
	 .conta_fim (s_conta_fim),
    .db_estado (db_estado)
);

hexa7seg hex0 (
	 .hexa    (db_estado[3:0]),
	 .display (db_estado_hex0)
);

hexa7seg hex1 (
	 .hexa    ({3'b0, db_estado[4]}),
	 .display (db_estado_hex1)
);

endmodule