module uart_rx #(
    // Comprimento de uma palavra a ser enviada para a UART
    // Baud Rate
    parameter BAUD_RATE = 9600,
    // Frequencia do sinal de clock utilizado no sistema
    parameter CLOCK_HZ = 50_000_000,
    // Quantidade de bits = 1 ao final da palavra
    parameter STOP_BITS = 1,
    // numero de data bits por transmissao
    parameter N_BITS = 8
) (
    input clk,
    input reset,
    input rxd,
    output finished,
    output reg [N_BITS -1: 0] data
);

// Bits enviados por nano segundo
localparam BITS_PNS = 1_000_000_000 * 1/BAUD_RATE;
// Periodo do sinal de clock em nano segundos
localparam CLK_PNS = 1_000_000_000 * 1/CLOCK_HZ;
// Numeros de ciclos de clock por bit de dados
localparam CLK_P_BIT = BITS_PNS / CLK_PNS;
// Tamanho registrador de contagem
localparam COUNTER_LEN = $clog2(CLK_P_BIT);
// Tamanho do registrador de contagem de bits recebidos
localparam DATA_LEN = $clog2(N_BITS);

// Realizarei sample no bit presente na entrada, toda vez que
// o registrador de contagem estiver na metade, garantindo melhor estabilidade

// Parâmetros da pequena maquina de estados da UART
localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam RECEIVE = 2'b10;
localparam FINISH = 2'b11;

reg [COUNTER_LEN : 0] cycle_counter; // contador ciclos de clock
reg [N_BITS - 1: 0] current_data; // dados recebidos
reg [DATA_LEN : 0] data_counter; // numero de dados recebidos
reg sample; // bit obtido durante o sampling
reg received; // bit recebido pelo rxd

reg[1:0] current_state;
reg[1:0] next_state;

// contador chegou ao final se o contador de ciclos contou a quantidade calculada
wire counter_finished = cycle_counter == CLK_P_BIT;
wire counter_half     = cycle_counter == CLK_P_BIT/2;
// a mensagem foi recebida se todos os bits chegaram
wire receive_finished = data_counter == N_BITS;
// "I used to think my life was a tragedy, but now I realize it's a comedy." — Joker

assign finished = current_state == FINISH && next_state == IDLE;

// implementa logica de transicao de estados
always @(*) begin : state_transition
    case(current_state) 
        IDLE: next_state = received ? IDLE : START;
        START: next_state = counter_finished ? RECEIVE : START;
        RECEIVE: next_state = receive_finished ? FINISH : RECEIVE;
        FINISH: next_state = counter_half ? IDLE : FINISH;
        default: next_state = IDLE;
    endcase
end

// realiza a transição de estados
always @(posedge clk) begin : do_transition
    if (reset) current_state <= IDLE;
    else current_state <= next_state;
end

// recebe o valor na entrada
always @(posedge clk) begin: receive
    if (reset) received <= 1;
    else received <= rxd;
end

// realiza contagem de ciclos
always @(posedge clk) begin: count_cycle
    if (reset) cycle_counter <= 0;
    else if (counter_finished) cycle_counter <= 0;
    else if (
        current_state == START || 
        current_state == RECEIVE || 
        current_state == FINISH) cycle_counter <= cycle_counter + 1;
end

// realiza sampling
always @(posedge clk) begin: sampling
    if (reset) sample <= 0;
    else if (counter_half) sample <= received;
end

// grava novo bit na saida
always @(posedge clk) begin: add_received
    if (reset) current_data <= 0;
    else if (current_state == IDLE) current_data <= 0;
    else if (current_state == RECEIVE && counter_finished) begin
        current_data[data_counter[2:0]] <= sample;
    end
end

// incrementa contador de dados
always @(posedge clk) begin: increment
    if (reset) data_counter <= 0;
    else if (current_state != RECEIVE) data_counter <= 0;
    else if (current_state == RECEIVE && counter_finished) begin
        data_counter <= data_counter + 1;
    end
end

// atualiza saida
always @(posedge clk) begin: output_data
    if (reset) data <= 0;
    else if (current_state == FINISH) data <= current_data;
end

endmodule