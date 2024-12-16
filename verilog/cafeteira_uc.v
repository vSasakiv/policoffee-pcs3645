module cafeteira_uc (
    input wire clock,
    input wire reset,
    input wire preparar, // ESP
	 input wire fim_temperatura, // ESP
    input wire pronto_serial, // FD
    input wire pronto_sensor_xicara, // FD
    input wire timeout_xicara, // FD
    input wire tem_xicara, // FD
    input wire fim_bomba, // FD
    input wire timeout_ebulidor, // FD
    input wire fim_valvula, // FD
	 input wire fim_contagem, // FD
	 input wire fim_espera_fim, // FD

    output reg zera_sensor_xicara, // FD
    output reg zera_bomba, // FD
    output reg zera_valvula, // FD
    output reg zera_serial, // FD
    output reg zera_ebulidor, // FD
    output reg verifica_xicara, // FD
    output reg erro_sem_xicara, // ESP
    output reg liga_bomba, // FD
    output reg liga_ebulidor, // FD
	 output reg erro_timeout_ebulidor, // ESP
    output reg liga_valvula, // FD
    output reg pronto,
	 output reg conta_interferencia, // FD
	 output reg ebulidor, // EBULIDOR
	 output reg conta_fim, // FD

    output wire [4:0] db_estado
);

    reg [4:0] Eatual, Eprox;

    // Estados
    parameter [4:0] inicial               = 5'b00000; 
    parameter [4:0] prepara               = 5'b00001; 

    parameter [4:0] espera_modo           = 5'b00011; 

    parameter [4:0] prepara_sensor_xicara = 5'b01000; 
    parameter [4:0] ativa_sensor_xicara   = 5'b01001;
    parameter [4:0] espera_sensor_xicara  = 5'b01010; 
    parameter [4:0] erro_xicara           = 5'b01011; 

    parameter [4:0] ativa_bomba           = 5'b01100; 
    parameter [4:0] espera_bomba          = 5'b01101;

    parameter [4:0] ativa_ebulidor        = 5'b01110;
	 parameter [4:0] espera_interferencia  = 5'b10100;
    parameter [4:0] espera_ebulidor       = 5'b10010;
    parameter [4:0] erro_ebulidor         = 5'b01111; 

    parameter [4:0] ativa_valvula         = 5'b10000; 
    parameter [4:0] espera_valvula        = 5'b10011; 

    parameter [4:0] fim                   = 5'b10001; 

	 assign db_estado = Eatual;
	 
    always @(posedge clock, posedge reset) begin
        if (reset) 
            Eatual <= inicial;
        else
            Eatual <= Eprox; 
    end
    
    always @(*) begin
        case(Eatual)
            inicial: Eprox = preparar ? prepara : inicial;
            prepara: Eprox = espera_modo;

            espera_modo: Eprox = pronto_serial ? prepara_sensor_xicara : espera_modo;

            prepara_sensor_xicara: Eprox = ativa_sensor_xicara;
            ativa_sensor_xicara: Eprox = espera_sensor_xicara;
            espera_sensor_xicara: begin
                if (pronto_sensor_xicara) begin
                    if (tem_xicara) Eprox = ativa_bomba;
                    else Eprox = erro_xicara;
                end
                else begin
                    if (timeout_xicara) Eprox = prepara_sensor_xicara;
                    else Eprox = espera_sensor_xicara;
                end
            end
            erro_xicara: Eprox = inicial;

            ativa_bomba: Eprox = espera_bomba;
            espera_bomba: Eprox = fim_bomba ? ativa_ebulidor : espera_bomba;

            ativa_ebulidor: Eprox = espera_interferencia;
				espera_interferencia: Eprox = fim_contagem ? espera_ebulidor : espera_interferencia;
            espera_ebulidor: Eprox = fim_temperatura ? ativa_valvula : espera_ebulidor;

            ativa_valvula: Eprox = espera_valvula;
            espera_valvula: Eprox = fim_valvula ? fim : espera_valvula;
				
				erro_ebulidor: Eprox = inicial;

            fim: Eprox = fim_espera_fim ? inicial : fim;

            default: Eprox = inicial;
        endcase
    end

    always @(*) begin
        zera_bomba = 0;
        zera_sensor_xicara = 0;
        zera_serial = 0;
        zera_ebulidor = 0;
        zera_valvula = 0;
        verifica_xicara = 0;
        erro_sem_xicara = 0;
        liga_bomba = 0;
        liga_ebulidor = 0;
		  erro_timeout_ebulidor = 0;
        liga_valvula = 0;
        pronto = 0;
		  conta_interferencia = 0;
		  ebulidor = 0;

        if (Eatual == prepara || Eatual == inicial) begin
            zera_bomba = 1;
            zera_sensor_xicara = 1;
            zera_serial = 1;
            zera_ebulidor = 1;
            zera_valvula = 1;
        end
        
        else if (Eatual == prepara_sensor_xicara) zera_sensor_xicara = 1;
        else if (Eatual == ativa_sensor_xicara) verifica_xicara = 1;
        else if (Eatual == erro_xicara) erro_sem_xicara = 1;

        else if (Eatual == ativa_bomba) liga_bomba = 1;

        else if (Eatual == ativa_ebulidor) ebulidor = 1;
		  
		  else if (Eatual == espera_interferencia) begin 
			  conta_interferencia = 1;
			  ebulidor = 1;
		  end

		  else if (Eatual == espera_ebulidor) ebulidor = 1;
		  
		  else if (Eatual == erro_ebulidor) erro_timeout_ebulidor = 1;

        else if (Eatual == ativa_valvula) liga_valvula = 1;

        else if (Eatual == fim) begin 
			  pronto = 1;
			  conta_fim = 1;
		  end
    end

endmodule